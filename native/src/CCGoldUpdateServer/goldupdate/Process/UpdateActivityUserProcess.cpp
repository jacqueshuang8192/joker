#include "UpdateActivityUserProcess.h"
#include "json.h"
#include "GameManager.h"

int ActivityUserProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd)
{
	int uid = inputPacket.ReadInt();
	int activityID = inputPacket.ReadInt();
	int chips = inputPacket.ReadInt();
	int addchips = inputPacket.ReadInt();
	VLogMsg(CLIB_LOG_LEV_INFO, "ActivityUserProcess [%d] [%d] [%d] [%d]", uid, activityID, chips, addchips);
	m_pOwner->AddChipsData(uid, activityID, chips, addchips);
	return 0;
}

