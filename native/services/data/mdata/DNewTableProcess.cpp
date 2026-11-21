#include "DNewTableProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DNewTableProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd){
	if (clientHandler == NULL){
		ErrMsg("DNewTableProcess:Clienthandler is NULL");
		return 0;
	}

	int level = inputPacket.ReadInt();
	int server_id = inputPacket.ReadInt();
	int count = inputPacket.ReadInt();
	int	player_count = inputPacket.ReadInt();
	int	game_type = inputPacket.ReadInt();
	
	m_pOwner->addTables(level,server_id, count, player_count,game_type);

	NETOutputPacket OutPkg;
	OutPkg.Begin(A2M_CREATE_TABLE_REDIS);
	OutPkg.WriteInt(1);
	OutPkg.End();
	clientHandler->Send(OutPkg.packet_buf(), OutPkg.packet_size());

	return 0;
}
