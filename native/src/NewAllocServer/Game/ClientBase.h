#ifndef __H_CLIENTBASE_H__
#define __H_CLIENTBASE_H__

#include "ICHAT_TCP_Handler.h"
#include "ICHAT_PacketBase.h"
#include "wtypedef.h"
//#include "MarkupSTL.h"
#include "Global.h"

class ClientBase;
class ClientSocketHandler:public ICHAT_TCP_Handler<>,
    public ICHAT_PacketParser<NETInputPacket>
{
public:
    ClientSocketHandler(void);
    ClientSocketHandler(ClientBase* pCoreServer);

    virtual ~ClientSocketHandler(void);
public:
    int Send(NETOutputPacket* pPacket, int delete_buffer = 0, int close_flag = 0);
    //关闭
    int OnClose(void);
    //连接完成
    int OnConnected(void);
    //回应
    int OnParser(char* buf, int nLen);
    //OnTimer
    int OnTimer(const void*);
    //是否连接
    bool IsConnected(void)
    {
        return m_bConntected;
    }
    //保存连接地址
    ACE_INET_Addr& Addr(void)
    {
        return m_remote;
    }
    void Addr(ACE_INET_Addr& addr)
    {
        m_remote = addr;
    }

    int OnPacketComplete(NETInputPacket *pPacket);

private:
    //地址
    ACE_INET_Addr m_remote;
    //回调proxyManager
    ClientBase* m_pClient;
    //连接状态
    bool m_bConntected;
};

typedef ACE_Connector<ClientSocketHandler, ACE_SOCK_CONNECTOR> CClientConnector;
class ClientBase
{
public:
    ClientBase();
    virtual ~ClientBase();
    int Send(NETOutputPacket* pPacket, int delete_buffer = 0, int close_flag = 0);
    virtual int ProcessPacket(NETInputPacket*)=0;
    virtual int Reconnect();
    virtual int OnConnected(void){;};
    //返回连接状态
    virtual bool IsConnected(void)
    {
        return m_SocketHandler->IsConnected();
    }
    virtual char* GetClientName(){return "ClientBase";}

    //链接
    int	InitConnect(char* ip,int port);
	
	virtual int InitConnect( const char * strPath = "GameServer.ini" ){;}
    int	InitConnect(ACE_INET_Addr&, ACE_Reactor * = ACE_Reactor::instance());

public:
    ClientSocketHandler* m_SocketHandler;
private:
    CClientConnector	m_Connector;
};


#endif

