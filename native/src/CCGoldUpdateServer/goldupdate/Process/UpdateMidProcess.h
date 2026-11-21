#pragma once

#include "IProcess.h"

class UpdateMidProcess:public IProcess
{
	int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

