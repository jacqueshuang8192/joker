#ifndef BOYAA_UserServer_H_20100430
#define BOYAA_UserServer_H_20100430

#include "UserSvrSocketHandler.h"
#include "ACE_Application.h"
#include "CommandType.h"
#include "BaseServer.h"

typedef ACE_Connector<UserSvrSocketHandler, ACE_SOCK_CONNECTOR> UserConnector;

class CBaseServer;
class CUserServer
{
public:
	CUserServer(CBaseServer *pServer);
	~CUserServer();

	//初始化连接
	int	InitConnect(ACE_INET_Addr &, ACE_Reactor * = ACE_Reactor::instance());

	//初始化连接
	int	InitConnect(const char* szHost, const char* szPort);

	void Reconnect(void);
	//返回连接状态
	bool IsConnected(void){return m_SocketHandler.IsConnected();}

	int TransferPacket(NETOutputPacket *pPacket);

	int ProcessPacket(NETInputPacket *pPacket);

	int Register();

public:
	UserConnector	m_Connector;
	UserSvrSocketHandler m_SocketHandler;
	CBaseServer *m_pGameServer;
};
#endif

