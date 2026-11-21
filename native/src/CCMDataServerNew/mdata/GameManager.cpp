#include "GameManager.h"
#include "ClientHandler.h"
#include "GameUser.h"

void GameManager::BuildPackage(NETOutputPacket* pOutPack, short nCmdType, const char* pszFmt, ...)
{
	pOutPack->Begin(nCmdType);

	if (pszFmt == NULL)	//内容为空的,就直接构造一个只有命令头的数据包
	{
		pOutPack->End();
		return;
	}

	va_list ap; 
	va_start (ap, pszFmt); 
	const char* p = NULL;

	for (p= pszFmt; *p; p++) 
	{ 
		if (*p != '%') 
		{
			continue; 
		}

		switch (*++p) 
		{ 
		case 'd':	//int
			{
				int nVal= (short)va_arg(ap, int);
				pOutPack->WriteInt(nVal);
				break;
			}
		case 'h':	//short
			{
				short shVal = (short)va_arg(ap, int);
				pOutPack->WriteShort(shVal);
				break;
			}
		case 'u':	//unsigned long
			{
				unsigned long dwVal = (unsigned long)va_arg(ap, unsigned long);
				pOutPack->WriteULong(dwVal);
				break;
			}
		case 's':	//char*
			{
				char* pVal = va_arg(ap, char*);
				pOutPack->WriteString(pVal);
				break;
			}
		}
	}
	pOutPack->End();
}


void GameManager::Init(GameConfig & gc)
{
	m_gameID = gc.m_gameID;
	m_serverType = gc.m_serverType;
	
	map<int,ServerConfig>::iterator iter =  gc.m_ServerMap.begin();
	for(;iter!=gc.m_ServerMap.end();iter++)
	{
		ServerConfig & sc = iter->second;
		m_RedisClient.Connect(sc.m_ip,sc.m_port,sc.m_password);
	}
	if (gc.m_EnableLog)
	{
		m_pLogClient = new LogClientHandler();
		m_pLogClient->SetSIP(gc.m_LogConf.m_ip);
		m_pLogClient->SetPort(gc.m_LogConf.m_port);
		m_pLogClient->EnableReconnect();
		m_pLogClient->Connect();
	}
	if (gc.m_EnableUpdate)
	{
		m_pUpdateClient = new UpdateClientHandler();
		m_pUpdateClient->SetSIP(gc.m_UpdateConf.m_ip);
		m_pUpdateClient->SetPort(gc.m_UpdateConf.m_port);
		m_pUpdateClient->EnableReconnect();
		m_pUpdateClient->Connect();
	}
	
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
				ErrMsg("Connect to DB[IP:%s,PORT:%d dbname:%s user:%s] Failed.",dbp.host.c_str(),dbp.port,
								dbp.db.c_str() , 	dbp.user.c_str());
				return;
			}
			m_DBMap[dbindex] = pDbPart;
		}
	}
	CDbPart::m_tableNum = gc.m_DBConf.m_tableNum;
	CDbPart::m_dbNum = gc.m_DBConf.m_dbNum;

	log_boot("CDbPart::m_dbNum:%d", CDbPart::m_dbNum);
	
	return ;
}

void GameManager::ProcessHandlerClose(CClientHandler * pHandler)
{
	return;
}

int GameManager::UpdateUserInfoInCache(CGameUser * pUser, const string & describe, int operationSource, string clientInfo)
{
	m_RedisClient.UpdateUserInfoInCache(pUser);
	NETOutputPacket outPkg;
	outPkg.Begin(FORWARD_COMMAND_SET_RECORD_NEW);
	outPkg.WriteInt(pUser->m_nUserId);
	outPkg.WriteInt64(pUser->m_nTurnLMoney);
	outPkg.WriteInt64(pUser->m_nLMoney);
	outPkg.WriteInt(pUser->m_nTurnScore);
	outPkg.WriteInt(pUser->m_nScore);
	outPkg.WriteInt(operationSource);
	outPkg.WriteString(describe);
	outPkg.WriteString(clientInfo);
	outPkg.WriteInt(pUser->m_chips);
	outPkg.End();
	if(m_pLogClient)
	{
		m_pLogClient->Send(outPkg.packet_buf(),outPkg.packet_size());
	}
	NETOutputPacket updatePkg;
	updatePkg.Begin(SYS_COMMAND_UPDATE_MID);
	updatePkg.WriteInt(pUser->m_nUserId);
	updatePkg.End();
	if(m_pUpdateClient)
	{
		m_pUpdateClient->Send(updatePkg.packet_buf(),updatePkg.packet_size());
	}
	return 0;
}

int GameManager::UpdateUserMoneyInCache(CGameUser * pUser,const string & describe,int operationSource,string clientInfo)
{
	m_RedisClient.UpdateUserMoneyInCache(pUser);
	NETOutputPacket outPkg;
	outPkg.Begin(FORWARD_COMMAND_SET_RECORD_NEW);
	outPkg.WriteInt(pUser->m_nUserId);
	outPkg.WriteInt64(pUser->m_nTurnLMoney);
	outPkg.WriteInt64(pUser->m_nLMoney);
	outPkg.WriteInt(pUser->m_nTurnScore);
	outPkg.WriteInt(pUser->m_nScore);
	outPkg.WriteInt(operationSource);
	outPkg.WriteString(describe);
	outPkg.WriteString(clientInfo);
	outPkg.End();
	if(m_pLogClient!= NULL)
	{
		m_pLogClient->Send(outPkg.packet_buf(),outPkg.packet_size());
	}
	NETOutputPacket updatePkg;
	updatePkg.Begin(SYS_COMMAND_UPDATE_MID);
	updatePkg.WriteInt(pUser->m_nUserId);
	updatePkg.End();
	if(m_pUpdateClient)
	{
		m_pUpdateClient->Send(updatePkg.packet_buf(),updatePkg.packet_size());
	}
	return 0;
}

int GameManager::UpdateUserChipsInCache(int userID, int activityID, int chips, int addchips)
{
	NETOutputPacket updatePkg;
	updatePkg.Begin(SYS_COMMAND_UPDATE_T_ACTIVITY_USER);
	updatePkg.WriteInt(userID);
	updatePkg.WriteInt(activityID);
	updatePkg.WriteInt(chips);
	updatePkg.WriteInt(addchips);
	updatePkg.End();
	if (m_pUpdateClient)
	{
		m_pUpdateClient->Send(updatePkg.packet_buf(), updatePkg.packet_size());
	}
	return 0;
}

int GameManager::DeleteUserInCache(CGameUser * pUser)
{
	m_RedisClient.DeleteUserInCache(pUser);
	return -1;
}

int GameManager::UpdateGroupState(int creatorID, int tableState,int activity_id)
{
	m_RedisClient.UpdateGroupState(creatorID, tableState, activity_id);
	return 0;
}

CGameUser * GameManager::GetUserInfoInCache(int uid)
{
	CGameUser * pUser = NULL;
	UserInfo ui;
	int iret = m_RedisClient.GetUserInfoInCache(uid,ui);
	if (iret == 0)
	{
		pUser = new CGameUser(uid,ui.money,ui.exp,ui.score,ui.win,ui.lose,ui.chips);
		//m_UserManager.m_UserList[uid] = pUser;
		m_UserManager.AddUser(uid,pUser);
	}

 	else 
 	{
	
 		// get from db 
 		int index = CDbPart::GetDatabaseIndex(uid);
		CDbPart *pDbPart = GetDbPart(index);
		int ret = -1;
		if(pDbPart != NULL)
		{
			ret = pDbPart->GetUserInfo(uid, ui.money, ui.exp, ui.score, ui.win, ui.lose, ui.chips);
		}
 		if(ret == 0)
 		{
			pUser = new CGameUser(uid, ui.money, ui.exp, ui.score, ui.win, ui.lose, ui.chips);
			m_UserManager.AddUser(uid,pUser);
 		}
		else
		{
			LogMsg("Get User[%d] info in DB failed.",uid);
		}

 	}


	return pUser;
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


/*----------------------------- 房间列表 by neo -----------------------------------*/
int GameManager::addTables(int level,int sid, int counts, int player_count, int game_type)
{
	m_RedisClient.addTables(level,sid, counts, player_count,game_type);
	return 0;
}