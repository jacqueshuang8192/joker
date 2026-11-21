#pragma once
#include "IProcess.h"

class DUpdateProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

