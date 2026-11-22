#include "LogicServer.h"
#include "GameServer.h"

#ifndef WIN32
#include "clib_log.h"
extern clib_log *g_pDebugLog;
extern clib_log *g_pErrorLog;
#endif



#define CORE_CHECK 1

const int CHECK_CORE_TIME = 10;

CLogicServer::CLogicServer(short serverId, int userCount, int tableCount, short level, SocketHandler *pHandler, CBaseServer* pBaseServer)
{
	m_nServerId = serverId;
	m_nUserCount = userCount;
	m_nTableCount = tableCount;
	m_nLevel = level;
	m_pSocketHandler = pHandler;
	m_strIp = "";
	m_nPort = 0;
	m_nRetire = 0;
	m_pBaseServer = pBaseServer;
	m_CheckCoreTimer.SetTimeEventObj(this, CORE_CHECK);
	m_nMatchCount = 0;
	m_nServerType = 0;
    m_nCreateTime = time(NULL);
    m_TableLoveGirlList.clear();

}

CLogicServer::~CLogicServer()
{
}

CGameTable* CLogicServer::GetTable(int tid)
{
	CGameTable *pTable = NULL;
	map<int, CGameTable*>::iterator iter = m_TableList.find(tid);
	if(iter != m_TableList.end())
	{
		pTable = iter->second;
	}
    if (pTable == NULL)
    {
        map<int, CGameTable*>::iterator iter = m_TableLoveGirlList.find(tid);
        if(iter != m_TableLoveGirlList.end())
        {
            pTable = iter->second;
        }
    }
	return pTable;
}


void CLogicServer::StartCheckCoreTimer()
{
	m_CheckCoreTimer.StartTimer(CHECK_CORE_TIME);
}

void CLogicServer::StopCheckCoreTimer()
{
	m_CheckCoreTimer.StopTimer();
}

int CLogicServer::ProcessOnTimerOut(int timerId)
{
	switch(timerId)
	{
	case CORE_CHECK:
		m_pBaseServer->ProcessLogicCore(this);
		break;
	default:
		break;
	}
	return 0;
}


int CLogicServer::ResetLogicServer()
{

    CGameServer* m_pGameServer = (CGameServer*)m_pBaseServer;
    if (m_pGameServer == NULL) return 0;
     //先清除server中的桌子信息
    TableList::iterator iterTable = m_TableList.begin();
    for(; iterTable!= m_TableList.end(); iterTable++)
    {
        CGameTable *pTable = iterTable->second;
        if(pTable != NULL)
        {
            //如果server挂，为了保险，防止出现野指针，如下在每个CountTableList里面查找并除去除去该桌子
            for(int i=0; i<=MAX_TABLE_USER_COUNT; i++)
            {
                CountTableList::iterator iterCount = m_pGameServer->m_CountTableList.find(i);
                if(iterCount != m_pGameServer->m_CountTableList.end())
                {
                    TableList& tableMap = iterCount->second;
                    TableList::iterator iter = tableMap.find(pTable->m_nTid);
                    if(iter != tableMap.end())
                    {
                        g_pDebugLog->logMsg("ResetLogicServer||Remove table, tid:[%d], userCount:[%d]", pTable->m_nTid, i);
                        tableMap.erase(iter);
                    }
                }
            }

            delete pTable;
            pTable = NULL;
        }
    }
    m_TableList.clear();

    TableList::iterator iter = m_TableLoveGirlList.begin();
    for(; iter!=m_TableLoveGirlList.end(); iter++)
    {
        CGameTable *pTable = iter->second;
        if(pTable != NULL)
        {
            //如果server挂，为了保险，防止出现野指针，如下在每个CountTableList里面查找并除去除去该桌子
            for(int i=0; i<=MAX_TABLE_USER_COUNT; i++)
            {
                CountTableList::iterator iterCount = m_pGameServer->m_CountTableList.find(i);
                if(iterCount != m_pGameServer->m_CountTableList.end())
                {
                    TableList& tableMap = iterCount->second;
                    TableList::iterator iter = tableMap.find(pTable->m_nTid);
                    if(iter != tableMap.end())
                    {
                        g_pDebugLog->logMsg("ResetLogicServer||Remove table, tid:[%d], userCount:[%d]", pTable->m_nTid, i);
                        tableMap.erase(iter);
                    }
                }
            }

            delete pTable;
            pTable = NULL;
        }
    }
    m_TableLoveGirlList.clear();
    
return 0;
}



void CLogicServer::AddLoveTable(int tid)
{
    CGameTable *pTable = NULL;
    map<int, CGameTable*>::iterator iter = m_TableList.find(tid);
    if(iter != m_TableList.end())
    {
        pTable = iter->second;
    }
    if (pTable != NULL)
    {
        m_TableLoveGirlList[tid] = pTable;
        m_TableList.erase(iter);
    }
}

void CLogicServer::RemoveLoveTable(int tid)
{
    CGameTable *pTable = NULL;
    map<int, CGameTable*>::iterator iter = m_TableLoveGirlList.find(tid);
    if(iter != m_TableLoveGirlList.end())
    {
        pTable = iter->second;
    }
    if (pTable != NULL)
    {
        m_TableList[tid] = pTable;
        m_TableLoveGirlList.erase(iter);
    }
}



