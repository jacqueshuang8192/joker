#include "TableList.h"
#include "clib_log.h"
#include "Singleton.h"
//#include "http.h"
extern clib_log * g_pDebugLog;


CTableList* CTableList::Instance(void)
{
	return CSingleton<CTableList>::Instance();
}

CTableList::CTableList()
{
	m_bUserTableList = false;
}


CTableList::~CTableList()
{
}


bool CTableList::init(CGameServer* pGameServer, CLogicServer* pServer, int count,int game_type)
{
	//if (!m_bUserTableList)
	//	return true;
	for (int i = 0; i < count; i++)
	{
		int tid = (pServer->m_nServerId << 16) + pServer->m_nTableCount;
		if (addTable(pServer, tid) == false)
			return false;
	}
	//提交memdata，创建redis

	int memServerId = pServer->m_nLevel % (int)pGameServer->m_MemDataServerMap.size();
	CMemDataServer *pMemServer = pGameServer->GetMemDataServer(memServerId);
	if (pMemServer == NULL)
	{
		return false;
	}
	g_pDebugLog->logMsg("[%s] line:%d ===> requeset memdata level[%d] player_count[%d] table_count[%d]", __FUNCTION__, __LINE__, pServer->m_nLevel, pGameServer->m_nMaxTableUserCount, count);

	NETOutputPacket outPkg;
	outPkg.Begin(A2M_CREATE_TABLE_REDIS);
	outPkg.WriteInt(pServer->m_nLevel);
	outPkg.WriteInt(pServer->m_nServerId);
	outPkg.WriteInt(count);
	outPkg.WriteInt(pGameServer->m_nMaxTableUserCount);
	outPkg.WriteInt(game_type);
	outPkg.End();

	pMemServer->Send(&outPkg);//发送兑换筹码消息到memdataserver zsw

	NETInputPacket resPacket;
	GetMemDataRet(pMemServer, resPacket);//等待回应 zsw

	if (resPacket.GetCmdType() == A2M_CREATE_TABLE_REDIS)
	{
		int result = resPacket.ReadInt();
		if (result)
		{
			g_pDebugLog->logMsg("[%s] line:%d ===> create table list level[%d] player_count[%d] table_count[%d]", __FUNCTION__, __LINE__, pServer->m_nLevel, pGameServer->m_nMaxTableUserCount, count);
			return true;
		}
	}

	return true;
}

bool CTableList::addTable(CLogicServer* pServer,int tid)
{
	if (pServer == NULL)
	{
		return false;
	}
	int sid = pServer->m_nServerId;
	if ((tid >> 16) != sid)
		return false;
	
	CGameTable* pTable = new CGameTable(tid, pServer->m_nServerId, pServer->m_nLevel,0);
	if (pTable != NULL)
	{
		pServer->m_TableList[tid] = pTable;
		pServer->m_nTableCount++;
		pServer->m_nUserCount = 0;
		TableList& tableMap = ((CGameServer*)pServer->m_pBaseServer)->m_CountTableList[0];
		tableMap[tid] = pTable;
	}
	return true;
}

int CTableList::GetMemDataRet(CMemDataServer* pMemServer, NETInputPacket& resPacket)
{
	char pRecvBuffer[ICHAT_TCP_DEFAULT_BUFFER];
	ACE_Time_Value tv(2);
	int nRecv = pMemServer->m_SocketHandler->peer().recv(pRecvBuffer, ICHAT_TCP_DEFAULT_BUFFER, &tv);//memdataserver立即回应 zsw
	if (nRecv <= 0)
	{
		return 1;
	}

	int ret = pMemServer->m_SocketHandler->OnParser(pRecvBuffer, nRecv);
	if (ret == 0)
	{
		resPacket.Copy(pRecvBuffer, nRecv);
	}
	return 1;
}

bool CTableList::updateStatus(CGameServer* pGameServer, CLogicServer* pServer, int tid, int uid, int status)
{
	int memServerId = uid % (int)pGameServer->m_MemDataServerMap.size();
	CMemDataServer *pMemServer = pGameServer->GetMemDataServer(memServerId);
	if (pMemServer == NULL)
	{
		return false;
	}

	NETOutputPacket outPkg;
	outPkg.Begin(A2M_UPDATE_TABLE_STATUS);
	outPkg.WriteInt(pServer->m_nLevel);
	outPkg.WriteInt(tid);
	outPkg.WriteInt(uid);
	outPkg.WriteInt(status);
	outPkg.End();

	pMemServer->Send(&outPkg);//发送兑换筹码消息到memdataserver zsw

	NETInputPacket resPacket;
	GetMemDataRet(pMemServer, resPacket);//等待回应 zsw

	if (resPacket.GetCmdType() == A2M_UPDATE_TABLE_STATUS)
	{
		int result = resPacket.ReadInt();
		if (result)
		{
			return true;
		}
	}

	return true;
}