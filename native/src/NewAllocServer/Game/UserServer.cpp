#include "UserServer.h"
#include "ICHAT_HTTP_Config.h"

#ifndef WIN32
#include "clib_log.h"
extern clib_log* g_pDebugLog;
extern clib_log* g_pErrorLog;
#endif

CUserServer::CUserServer(CBaseServer *pServer):m_SocketHandler(this)
{
	m_pGameServer = pServer;
}

CUserServer::~CUserServer()
{

}
////////////////////////////////////////////////////////////////////////////////
// ��ʼ��proxy����
////////////////////////////////////////////////////////////////////////////////
int	CUserServer::InitConnect(ACE_INET_Addr &remote, ACE_Reactor *pReactor)
{
	m_Connector.open(pReactor, ACE_NONBLOCK);
	UserSvrSocketHandler *pHandler = &m_SocketHandler;
	pHandler->Addr(remote);    //��������
	
	int nRet = m_Connector.connect(pHandler, remote, ACE_Synch_Options::synch);
	return nRet;
}

int CUserServer::InitConnect(const char* szHost, const char* szPort)
{
	ACE_INET_Addr userAddr(szPort, szHost);
	return InitConnect(userAddr);
}

////////////////////////////////////////////////////////////////////////////////
// proxyserver�ر��Զ�����
////////////////////////////////////////////////////////////////////////////////
void CUserServer::Reconnect(void)  //EWOULDBLOCK
{
	UserSvrSocketHandler *pClient = &m_SocketHandler;
	m_Connector.connect(pClient, pClient->Addr(), ACE_Synch_Options::synch);
}

int CUserServer::TransferPacket(NETOutputPacket *pPacket)
{
	if(!IsConnected())
	{
#ifndef WIN32
		g_pErrorLog->logMsg("UserServer not connect");
		return -1;
#endif
	}

	m_SocketHandler.Send(pPacket);
	return 0;
}

int CUserServer::ProcessPacket(NETInputPacket *pPacket)
{
	return m_pGameServer->ProcessBackPacket(pPacket);
}


int CUserServer::Register()
{
	//NETOutputPacket reqPacket;
	//reqPacket.Begin(ALLOC_REGISTER_PACKET);
	//reqPacket.WriteInt(m_pGameServer->m_nSvid);
	//reqPacket.WriteInt(m_pGameServer->m_nLevel);
	//reqPacket.End();
	//TransferPacket(&reqPacket);
	return 0;
}