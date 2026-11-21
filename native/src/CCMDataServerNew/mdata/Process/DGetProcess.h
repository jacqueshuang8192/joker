#pragma once
#include "IProcess.h"

class DGetProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

