#include "GameManager.h"
#include "ClientHandler.h"
#include <pthread.h>

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void* ThreadFun(void* arg)
{
	//g_pDebugLog->logMsg("ThreadFun begin");
	ThreadParam * pTP = (ThreadParam *) arg;
	
	if(pTP == NULL || pTP->pManager == NULL || pTP->pUidVect == NULL)
		return NULL;
	pthread_mutex_lock(&mutex);
	for(int i=0; i<(int)pTP->pUidVect->size(); i++)
	{
		int uid = (*pTP->pUidVect)[i];
		UserInfo ui;
		int iret = pTP->pManager->GetUserInfo(uid,ui);
		if (iret != 0)
		{
			VLogMsg(CLIB_LOG_LEV_DEBUG,"Get User[%d] Info Failed.",uid);
			continue;
		}
		else
		{
			VLogMsg(CLIB_LOG_LEV_INFO,"Update User[%d] Info[money:%ld,exp:%d,score:%d,win:%d,lose:%d] From MemServer",uid,ui.money,ui.exp,ui.score,ui.win,ui.lose);
		}
		pTP->pManager->UpdateUserInfo(uid,ui);
	}
	pthread_mutex_unlock(&mutex);
	//此处删除内存
	if(pTP->pUidVect)
	{
		delete pTP->pUidVect;
	}
	if(pTP)
	{
		delete pTP;
	}
	return NULL;
}

void* ChipsThreadFun(void* arg)
{
	VLogMsg(CLIB_LOG_LEV_INFO, "ChipsThreadFun start");
	ChipsDataParam * pTP = (ChipsDataParam *)arg;

	if (pTP == NULL || pTP->pManager == NULL || pTP->pChipsVect == NULL)
		return NULL;
	pthread_mutex_lock(&mutex);
	for (int i = 0; i < (int)pTP->pChipsVect->size(); i++)
	{
		ChipsData* chipdata = (*pTP->pChipsVect)[i];
		pTP->pManager->UpdateChipsInfo(chipdata);
	}
	pthread_mutex_unlock(&mutex);
	//此处删除内存

	for (int i = 0; i < (int)pTP->pChipsVect->size(); i++)
	{
		ChipsData* chipdata = (*pTP->pChipsVect)[i];
		if (chipdata != NULL)
		{
			delete chipdata;
		}
		(*pTP->pChipsVect)[i] = NULL;
	}
	pTP->pChipsVect->clear();

	if (pTP->pChipsVect)
	{
		delete pTP->pChipsVect;
	}
	if (pTP)
	{
		delete pTP;
	}
	return NULL;
}

void GameManager::Init(GameConfig & gc){
	m_gameID = gc.m_gameID;
	m_serverType = gc.m_serverType;
	m_UpdateInteval = gc.m_UpdateInteval;
	//connect to memdata server
	m_MemDataRedisClient.Connect(gc.m_MemServerConfig.m_ip,gc.m_MemServerConfig.m_port,gc.m_MemServerConfig.m_password);
	//connect to db
	for (int i=0;i<gc.m_DBConf.m_dbNum;i++)
	{
		int dbindex = i;
		CDbPart *pDbPart = new CDbPart();
		if(pDbPart != NULL)
		{
			char cdbName[255] = {0};
			snprintf(cdbName,sizeof(cdbName),"%s",gc.m_DBConf.m_dbName.c_str());
			DatabaseParam dbp;
			dbp.client_flag = 0;
			dbp.db = cdbName;
			dbp.host = gc.m_DBConf.m_ip;
			dbp.password = gc.m_DBConf.m_pwd;
			dbp.port = (unsigned int)gc.m_DBConf.m_port;
			dbp.user = gc.m_DBConf.m_user;
			dbp.unix_socket = "";
			if(!pDbPart->ConnectDB(dbp))
			{
				ErrMsg("Connect to DB[IP:%s,PORT:%d] Failed.",dbp.host.c_str(),dbp.port);
				return;
			}
			m_DBMap[dbindex] = pDbPart;
		}
	}
	CDbPart::m_tableNum = gc.m_DBConf.m_tableNum;
	CDbPart::m_dbNum = gc.m_DBConf.m_dbNum;
	StartTimer(m_UpdateInteval);
}

void GameManager::ProcessHandlerClose(CClientHandler * pHandler){
	return;
}

void GameManager::AddUpdateUser(int uid)
{
	m_UpdateUidSet.insert(uid);
	VLogMsg(CLIB_LOG_LEV_DEBUG,"Add Uid[%d] To Update Set",uid);
}

void GameManager::AddChipsData(int uid, int activity_id, int chips, int add_chips)
{
	ChipsData* chipsdata = new ChipsData;
	chipsdata->user_id = uid;
	chipsdata->activity_id = activity_id;
	chipsdata->chips = chips;
	chipsdata->add_chips = add_chips;
	m_UpdateChipsData.push_back(chipsdata);
	VLogMsg(CLIB_LOG_LEV_INFO, "Add AddChipsData uid[%d] activity_id[%d] chips[%d] add_chips[%d]", uid, activity_id, chips, add_chips);
}

void GameManager::ProcessUpdateRecord()
{
	if(m_UpdateUidSet.size() > 0)
	{
		vector<int>* pv = new vector<int>();
		set<int>::iterator iter = m_UpdateUidSet.begin();
		for(; iter!=m_UpdateUidSet.end(); iter++)
		{
			int uid = *iter;
			pv->push_back(uid);
		}
		ThreadParam * tp = new ThreadParam();
		tp->pManager = this;
		tp->pUidVect = pv;
		VLogMsg(CLIB_LOG_LEV_INFO, "Create Thread To Update Uid");
		pthread_t threadId;
		pthread_create(&threadId, NULL, ThreadFun, (void*)tp);
		pthread_detach(threadId);
		m_UpdateUidSet.clear();
	}
	if (m_UpdateChipsData.size() > 0)
	{
		vector<ChipsData*>* chips_vec = new vector<ChipsData*>;

		vector<ChipsData*>::iterator iter = m_UpdateChipsData.begin();
		for (; iter != m_UpdateChipsData.end(); iter++)
		{
			ChipsData* chip_data = *iter;
			chips_vec->push_back(chip_data);
		}
		_ChipsDataParam * chipParam = new _ChipsDataParam();
		chipParam->pManager = this;
		chipParam->pChipsVect = chips_vec;
		VLogMsg(CLIB_LOG_LEV_INFO, "Create Thread To Update m_UpdateChipsData");
		pthread_t threadId;
		pthread_create(&threadId, NULL, ChipsThreadFun, (void*)chipParam);
		pthread_detach(threadId);
		m_UpdateChipsData.clear();
	}
}

int GameManager::ProcessOnTimerOut()
{
	ProcessUpdateRecord();
	StartTimer(m_UpdateInteval);
	return 0;
}

int GameManager::GetUserInfo(int uid,UserInfo & ui)
{
	return m_MemDataRedisClient.GetUserInfoInCache(uid,ui);
}

int GameManager::UpdateUserInfo(int uid,const UserInfo & ui)
{
	int index = CDbPart::GetDatabaseIndex(uid);
	CDbPart *pDbPart = GetDbPart(index);
	if(pDbPart != NULL)
	{
		pDbPart->UpdateData(uid, ui);
	}
	return 0;
}

int GameManager::UpdateChipsInfo(ChipsData* chips_data)
{
	int index = CDbPart::GetDatabaseIndex(chips_data->user_id);
	CDbPart *pDbPart = GetDbPart(index);
	if (pDbPart != NULL)
	{
		pDbPart->UpdateChipData(chips_data->user_id, chips_data->chips, chips_data->add_chips, chips_data->activity_id);
	}
	return 0;
}

CDbPart* GameManager::GetDbPart(int index)
{
	CDbPart *pDbPart = NULL;
	DBMap::iterator iter = m_DBMap.find(index);
	if(iter != m_DBMap.end())
	{
		pDbPart = iter->second;
	}
	return pDbPart;
}
