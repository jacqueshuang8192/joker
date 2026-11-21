#include "UpdateMidProcess.h"
#include "json.h"
#include "GameManager.h"

int UpdateMidProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd)
{
	int uid = inputPacket.ReadInt();
	m_pOwner->AddUpdateUser(uid);
	return 0;
}

