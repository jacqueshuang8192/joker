#pragma once

#include "IProcess.h"

class ActivityUserProcess:public IProcess
{
	int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
};

