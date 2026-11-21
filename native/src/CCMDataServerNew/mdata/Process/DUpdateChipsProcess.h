#pragma once
#include "IProcess.h"

class DUpdateActivityChipsProcess :public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

