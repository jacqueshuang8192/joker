#include "DUpdateChipsProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DUpdateActivityChipsProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	int uid = inputPacket.ReadInt();
	int chips = inputPacket.ReadInt();
	int addchips = inputPacket.ReadInt();
	int activityID = inputPacket.ReadInt();

	VLogMsg(CLIB_LOG_LEV_INFO, "DUpdateActivityChipsProcess [%d] [%d] [%d] [%d]", uid, chips, addchips, activityID);
	CGameUser* pGameUser = m_pOwner->m_UserManager.GetUser(uid);
	if (pGameUser == NULL)
	{
		//printf("DMoney2ChipProcess:pGameUser == NULL\n");
		//fflush(stdout);
		pGameUser = m_pOwner->GetUserInfoInCache(uid);
	}

	if (pGameUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_DEBUG, "Request Get User[%d] not exist", uid);
		return 0;
	}
	m_pOwner->UpdateUserChipsInCache(uid, activityID, chips, addchips);//更新筹码到服务器
	return 0;
}




