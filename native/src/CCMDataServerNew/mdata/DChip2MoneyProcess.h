#pragma once

#include "IProcess.h"

class DChip2MoneyProcess:public IProcess{
	public:
		virtual int doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd);
		void rebackQuestServer(CClientHandler* clientHandler, int userID, int curMoney, int curChip);
};

