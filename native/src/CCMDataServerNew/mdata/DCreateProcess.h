#pragma once

#include "IProcess.h"

class DCreateProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

