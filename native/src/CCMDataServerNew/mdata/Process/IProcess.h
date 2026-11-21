#pragma once
#include "ICHAT_PacketBase.h"

class CClientHandler;
class GameManager;
class IProcess{
	public:
		IProcess():m_pOwner(NULL){};
		virtual ~IProcess() {};
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd) = 0;
		inline void setCmd(int cmd){ this->cmd=cmd; };
	public:
		int cmd;
		GameManager * m_pOwner;
};

