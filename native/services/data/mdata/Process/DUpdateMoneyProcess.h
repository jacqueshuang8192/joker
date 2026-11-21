#pragma once
#include "IProcess.h"

class DUpdateMoneyProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

