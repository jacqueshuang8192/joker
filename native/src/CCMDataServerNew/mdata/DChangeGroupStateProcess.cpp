#include "DChangeGroupStateProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DChangeGroupStateProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd){
	if (clientHandler == NULL){
		ErrMsg("DMoney2ChipProcess:Clienthandler is NULL");
		return 0;
	}

	int creatorID = inputPacket.ReadInt();
	int tableState = inputPacket.ReadInt();
	int activity_id = inputPacket.ReadInt();
	m_pOwner->UpdateGroupState(creatorID, tableState, activity_id);
	return 0;
}
