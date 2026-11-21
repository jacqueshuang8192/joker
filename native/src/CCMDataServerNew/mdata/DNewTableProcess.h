#pragma once

#include "IProcess.h"

class DNewTableProcess :public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

