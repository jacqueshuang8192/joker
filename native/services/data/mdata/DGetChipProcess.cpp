#include "DCreateProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"
#include "DGetChipProcess.h"

int DGetChipProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	
	return 0;
}

