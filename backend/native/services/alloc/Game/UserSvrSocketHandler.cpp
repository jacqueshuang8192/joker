#include "UserSvrSocketHandler.h"
#include "CommandType.h"
#include "UserServer.h"
UserSvrSocketHandler::UserSvrSocketHandler(void)
{
    m_ReconnectTimer.SetTimeEventObj(this, 0);
	m_bConntected = false;
}

UserSvrSocketHandler::UserSvrSocketHandler(CUserServer* pUserSvr)
{
    m_ReconnectTimer.SetTimeEventObj(this, 0);
	m_pUserServer = pUserSvr;
}


UserSvrSocketHandler::~UserSvrSocketHandler(void)
{
}


int UserSvrSocketHandler::Send(NETOutputPacket *pPacket, int delete_buffer, int close_flag)
{
	return ICHAT_TCP_Handler<>::Send(pPacket->packet_buf(), pPacket->packet_size(), delete_buffer, close_flag);
}
////////////////////////////////////////////////////////////////////////////////
// OnParser(char *buf, int nLen)
////////////////////////////////////////////////////////////////////////////////
int UserSvrSocketHandler::OnParser(char *buf, int nLen)
{
	return ParsePacket(buf, nLen);
}
////////////////////////////////////////////////////////////////////////////////
// OnPacketComplete 回应完成
////////////////////////////////////////////////////////////////////////////////
int UserSvrSocketHandler::OnPacketComplete(NETInputPacket *pPacket)
{
	return ProcessPacket(pPacket);
}

int UserSvrSocketHandler::ProcessPacket(NETInputPacket* pPacket)
{
	return m_pUserServer->ProcessPacket(pPacket);
}

////////////////////////////////////////////////////////////////////////////////
// OnClose(void)
////////////////////////////////////////////////////////////////////////////////
int UserSvrSocketHandler::OnClose(void)
{
	//连接状态置0 ，并启动定时连接
	if(m_bConntected)	
	{
		m_bConntected = false;
		ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] UserServer close, trying to reconnect\r\n")));
	}
	m_ReconnectTimer.StopTimer();
    m_ReconnectTimer.StartTimer(1);
	return 1;  //only close , but not remove Reactor
}

////////////////////////////////////////////////////////////////////////////////
int UserSvrSocketHandler::OnConnected(void)
{
	m_bConntected = true;
	m_ReconnectTimer.StopTimer();
	ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] UserServer Connect ok\r\n")));
	//m_pUserServer->Register();
	return 0;
}

int UserSvrSocketHandler::OnTimer(const void *)
{
	if(m_pUserServer == NULL)
	{
		ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] UserServer\r\n")));
		return -1;
	}
	ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] Connecting UserServer\r\n")));
 	m_pUserServer->Reconnect();
	return 0;
}

int UserSvrSocketHandler::ProcessOnTimerOut(int timerId)
{
	(void)timerId;
	if(m_pUserServer == NULL)
	{
		ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] m_pUserServer NULL\r\n")));
		return -1;
	}
	ACE_DEBUG((LM_DEBUG, ACE_TEXT("[%D] Connecting UserServer\r\n")));
 	m_pUserServer->Reconnect();
	return 0;
}

