#include "DMoney2ChipProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DMoney2ChipProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket, int cmd){
	if (clientHandler == NULL){
		//printf("clientHandler == NULL\n");
		//fflush(stdout);
		return 0;
	}

	if (m_pOwner == NULL){
		//printf("m_pOwner == NULL\n");
		//fflush(stdout);
		return 0;
	}

	int userID = inputPacket.ReadInt();
	int activityID = inputPacket.ReadInt();
	int needChip = inputPacket.ReadInt();
	inputPacket.ReadInt();
	int chips2moneyExchangeRate = CHIPS2MONEY_EXCHANGE_RATE;//暂时所有游戏一样 zsw
	int addChips = inputPacket.ReadInt();

	CGameUser* pGameUser = m_pOwner->m_UserManager.GetUser(userID);
	if (pGameUser == NULL)
	{
		pGameUser = m_pOwner->GetUserInfoInCache(userID);
	}

	if (pGameUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_DEBUG, "Request Get User[%d] not exist", userID);
		return 0;
	}

	VLogMsg(CLIB_LOG_LEV_INFO, "DMoney2ChipProcess:before [%d] [%1d] [%d] [%d]\n", needChip, pGameUser->m_chips, pGameUser->m_addchips, chips2moneyExchangeRate);
	int nRet = 0;
	int needMoney = int(float(needChip) * float(chips2moneyExchangeRate) / 1000);
	if (needMoney <= pGameUser->m_nLMoney)
	{
		pGameUser->m_nLMoney -= needMoney;
		pGameUser->m_chips += needChip;
		pGameUser->m_activityID = activityID;
		pGameUser->m_addchips = addChips;

		m_pOwner->UpdateUserChipsInCache(userID, activityID, pGameUser->m_chips, addChips);//更新筹码到服务器
		m_pOwner->UpdateUserInfoInCache(pGameUser, "", 0, "");
		nRet = 1;
	}
	VLogMsg(CLIB_LOG_LEV_INFO, "DMoney2ChipProcess:after [%1d] [%d]\n", pGameUser->m_chips, pGameUser->m_addchips);
	//m_pOwner->UpdateUserMoneyInCache(pGameUser, Describe, Source, clientInfo.c_str());
	
	//printf("DMoney2ChipProcess:pUserServer curChip[%ld] [%d] [%d] [%d] [%ld] [%ld]\n", needMoney, userID, needChip, activityID, pGameUser->m_nLMoney, pGameUser->m_chips);
	//fflush(stdout);
	VLogMsg(CLIB_LOG_LEV_INFO, "DMoney2ChipProcess:pUserServer curChip[%d] [%d] [%d] [%d] [%ld] [%ld] [%1d]\n", needMoney, userID, needChip, activityID, pGameUser->m_nLMoney, pGameUser->m_chips, pGameUser->m_addchips);
	rebackRequestServer(clientHandler, nRet, userID, pGameUser->m_nLMoney, pGameUser->m_chips, needChip);
	//回复操作结果
	
	return 0;
}

void DMoney2ChipProcess::rebackRequestServer(CClientHandler* clientHandler, int result, int userID, int curMoney, int curChip, int needChip)
{
	NETOutputPacket OutPkg;
	OutPkg.Begin(M2AG_CHANGE_MONEY2CHIPS);
	OutPkg.WriteInt(result);
	OutPkg.WriteInt(curChip);
	OutPkg.WriteInt(curMoney);
	OutPkg.WriteInt(needChip);
	OutPkg.End();
	clientHandler->Send(OutPkg.packet_buf(), OutPkg.packet_size());
}