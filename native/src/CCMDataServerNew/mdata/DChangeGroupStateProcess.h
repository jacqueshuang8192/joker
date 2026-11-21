#pragma once

#include "IProcess.h"

class DChangeGroupStateProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

