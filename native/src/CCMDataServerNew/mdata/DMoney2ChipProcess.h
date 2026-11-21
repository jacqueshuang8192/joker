#pragma once

#include "IProcess.h"

class DMoney2ChipProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
		void rebackRequestServer(CClientHandler* clientHandler, int result, int userID, int curMoney, int curChip, int needChip);
};

