#include "ClientBase.h"

ClientBase::ClientBase() { ; }

ClientBase::~ClientBase()
{
    if(m_SocketHandler)
    {
        delete m_SocketHandler;
        m_SocketHandler=NULL;
    }
}

int	ClientBase::InitConnect(char* ip,int port)
{
    if(!ip)
    {
        ACE_DEBUG((LM_ERROR,ACE_TEXT("[%D]:(%P|%t) ClientBase Error ip NULL\n")));
        return -1;
    }

    ACE_DEBUG((LM_ERROR,ACE_TEXT("[%D]:(%P|%t) [%s] connect  ip:%s port:%d\n"),GetClientName(),ip,port));

    ACE_INET_Addr hallAddr(port,ip);
    return InitConnect(hallAddr);
}

int ClientBase::InitConnect(ACE_INET_Addr& remote, ACE_Reactor * pReactor = ACE_Reactor::instance())
{
    m_Connector.open(pReactor, ACE_NONBLOCK);
    m_SocketHandler = new ClientSocketHandler(this);
    if(m_SocketHandler == NULL)
    {
        return 0;
    }
    ClientSocketHandler* pHandler = m_SocketHandler;
    pHandler->Addr(remote);    //保存起来
    int nRet = m_Connector.connect(pHandler, remote, ACE_Synch_Options::synch);
    if(nRet<0)
    {
        ACE_DEBUG((LM_ERROR,ACE_TEXT("%s Connect Error!!\n"),GetClientName()));
    }
    else
    {
        ACE_DEBUG((LM_ERROR,ACE_TEXT("%s Connect Success!!\n"),GetClientName()));
    }


    return nRet;
}

int	ClientBase::Reconnect()
{
    if(!m_SocketHandler)
    {
        ACE_DEBUG((LM_ERROR,ACE_TEXT("[%D]:(%P|%t) ClientBase Reconnect Error SocketHandler Null\n")));
        return -1;
    }
	//ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]:(%P|%t) [%s] connecting\r\n"), m_pClient->GetClientName()));
	//ACE_DEBUG((LM_DEBUG, "get_host_addr:[%s]\n", m_SocketHandler->Addr().get_host_addr()));
	//ACE_DEBUG((LM_DEBUG, "get_host_addr:[%s]\n", m_SocketHandler->Addr().get_port_number()));
	/*ACE_DEBUG((LM_ERROR, ACE_TEXT("%s get_host_addr!!\n"), m_SocketHandler->Addr().get_host_addr()));
	ACE_DEBUG((LM_ERROR, ACE_TEXT("%d get_port_number!!\n"), m_SocketHandler->Addr().get_port_number()));*/
	//ACE_Synch_Options::asynch  //异步
	//ACE_Synch_Options::synch   //同步
    m_Connector.connect(m_SocketHandler, m_SocketHandler->Addr(), ACE_Synch_Options::synch);
    return 0;
}

int ClientBase::Send(NETOutputPacket* pPacket, int delete_buffer = 0, int close_flag = 0)
{
    if(!m_SocketHandler || !m_SocketHandler->IsConnected())
    {
        return -1;
    }
    if(!pPacket)
    {
        return -1;
    }

    m_SocketHandler->Send(pPacket, delete_buffer, close_flag);
    return 0;
}

ClientSocketHandler::ClientSocketHandler(void)
{
    m_bConntected = false;
}

ClientSocketHandler::ClientSocketHandler(ClientBase* pClient)
{
    m_bConntected = false;
    m_pClient = pClient;
}

ClientSocketHandler::~ClientSocketHandler(void)
{
}

int ClientSocketHandler::Send(NETOutputPacket* pPacket, int delete_buffer, int close_flag)
{
    return ICHAT_TCP_Handler<>::Send(pPacket->packet_buf(), pPacket->packet_size(), delete_buffer, close_flag);
}

////////////////////////////////////////////////////////////////////////////////
// OnParser(char *buf, int nLen)
////////////////////////////////////////////////////////////////////////////////
int ClientSocketHandler::OnParser(char* buf, int nLen)
{
    int ret = ParsePacket(buf, nLen);
    return ret;
}

////////////////////////////////////////////////////////////////////////////////
// OnPacketComplete 回应完成
////////////////////////////////////////////////////////////////////////////////
int ClientSocketHandler::OnPacketComplete(NETInputPacket* pPacket)
{
    return m_pClient->ProcessPacket(pPacket);
}

////////////////////////////////////////////////////////////////////////////////
// OnClose(void)
////////////////////////////////////////////////////////////////////////////////
int ClientSocketHandler::OnClose(void)
{
    //连接状态置0 ，并启动定时连接
    if(m_bConntected)
    {
        m_bConntected = false;
        ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]:(%P|%t) [%s] close.Trying to reconnect\r\n"),m_pClient->GetClientName()));
    }
    this->StartTimer(3);
    return 1;  //only close , but not remove Reactor
}

////////////////////////////////////////////////////////////////////////////////
// OnConnected(void)
////////////////////////////////////////////////////////////////////////////////
int ClientSocketHandler::OnConnected(void)
{
    m_bConntected = true;
    this->StopTimer();
    ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]:(%P|%t) [%s] Connect ok\r\n"),m_pClient->GetClientName()));
    m_pClient->OnConnected();
    return 0;
}

int ClientSocketHandler::OnTimer(const void*)
{
    if(m_pClient == NULL)
    {
        ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]:(%P|%t) ClientHandler \r\n")));
        return -1;
    }
	
	/*ACE_DEBUG((LM_ERROR, ACE_TEXT("%s get_host_addr!!\n"), Addr().get_host_addr()));
	ACE_DEBUG((LM_ERROR, ACE_TEXT("%d get_port_number!!\n"), Addr().get_port_number()));*/
    ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]:(%P|%t) [%s] connecting\r\n"),m_pClient->GetClientName()));
    m_pClient->Reconnect();

    return 0;
}

