#ifndef BOYAA_ALLOC_SERVER_H
#define BOYAA_ALLOC_SERVER_H
#include "ClientBase.h"
// 客户端消息


//服务器回应消息


class CAllocServer:public ClientBase
{
public:
	CAllocServer(int prot);
	~CAllocServer();
	
	int ProcessPacket(NETInputPacket* pPacket){;};
	int Send(NETOutputPacket* pPacket){return ClientBase::Send(pPacket);}
	char* GetClientName(){return "AllocServer";}	

public:
	int m_level;
};
#endif


