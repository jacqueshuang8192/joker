#include "DChip2MoneyProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DChip2MoneyProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd){
	if (clientHandler == NULL){
		ErrMsg("DMoney2ChipProcess:Clienthandler is NULL");
		return 0;
	}

	int userID = inputPacket.ReadInt();

	CGameUser* pGameUser = m_pOwner->m_UserManager.GetUser(userID);
	if (pGameUser == NULL)
	{
		//printf("DMoney2ChipProcess:pGameUser == NULL\n");
		//fflush(stdout);
		pGameUser = m_pOwner->GetUserInfoInCache(userID);
	}

	if (pGameUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_DEBUG, "Request Get User[%d] not exist", userID);
		return 0;
	}

	

	int chips2money_exchange_rate = inputPacket.ReadInt();

	VLogMsg(CLIB_LOG_LEV_INFO, "DChip2MoneyProcess:before [%d] [%d] [%d] [%d]\n", pGameUser->m_nLMoney, pGameUser->m_chips, userID, chips2money_exchange_rate);
	if (chips2money_exchange_rate == 0)//证明账号没有在game里面登录，只是创建组局
	{
		pGameUser->m_nLMoney += int(pGameUser->m_chips);
	}
	else
	{
		int addChips = inputPacket.ReadInt();
		int activityID = inputPacket.ReadInt();

		pGameUser->m_nLMoney += int(pGameUser->m_chips*float(chips2money_exchange_rate / 1000));
		pGameUser->m_activityID = activityID;
		pGameUser->m_addchips = addChips;
	}

	//m_pOwner->UpdateUserChipsInCache(pGameUser);//更新最后的筹码到服务器
	//回复操作结果

	//printf("DChip2MoneyProcess:pUserServer curChip[%d] [%d] [%d]\n", userID, pGameUser->m_chips, pGameUser->m_nLMoney);
	//fflush(stdout);

	pGameUser->m_chips = 0;
	m_pOwner->UpdateUserInfoInCache(pGameUser, "", 0, "");
	VLogMsg(CLIB_LOG_LEV_INFO, "DChip2MoneyProcess:after[%d] [%1d] [%d]\n", pGameUser->m_nLMoney, pGameUser->m_chips, pGameUser->m_addchips);
	rebackQuestServer(clientHandler, userID, pGameUser->m_nLMoney, pGameUser->m_chips);
	return 0;
}

void DChip2MoneyProcess::rebackQuestServer(CClientHandler* clientHandler, int userID, int curMoney, int curChip)
{
	NETOutputPacket OutPkg;
	OutPkg.Begin(M2AG_CHANGE_CHIP2MONEY);
	OutPkg.WriteInt(curChip);
	OutPkg.WriteInt(curMoney);
	OutPkg.End();
	clientHandler->Send(OutPkg.packet_buf(), OutPkg.packet_size());
}