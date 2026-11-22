#include "DGetProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DGetProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	if (m_pOwner == NULL){
		ErrMsg("m_pOwner is NULL");
		return 0;
	}
	int Source = inputPacket.ReadInt();
	int nMid = inputPacket.ReadInt();
	VLogMsg(CLIB_LOG_LEV_INFO, "Request Get User[%d] Info.Source[%d]", nMid, Source);
	CGameUser* pUser = m_pOwner->m_UserManager.GetUser(nMid);
	if(pUser == NULL)
	{
		pUser = m_pOwner->GetUserInfoInCache(nMid);
	}

	if (pUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_INFO, "Request Get User[%d] not exist", nMid);
		return 0;
	}

	NETOutputPacket OutPkg;
	OutPkg.Begin(SERVER_COMMAND_GET_RECORD);
	OutPkg.WriteInt(nMid);
	if(pUser == NULL)
	{
		OutPkg.WriteInt(1);
		OutPkg.End();
		VLogMsg(CLIB_LOG_LEV_INFO, "Get User[%d] Info Failed.Not Exist.Source[%d]", nMid, Source);
	}
	else
	{
		OutPkg.WriteInt(0);
		//OutPkg.WriteInt64(pUser->m_nLMoney);
		OutPkg.WriteString(pUser->getStrMoney().c_str());
		OutPkg.WriteInt(pUser->m_nExp);
		OutPkg.WriteInt(pUser->m_nScore);
		OutPkg.WriteInt(pUser->m_nWintimes);
		OutPkg.WriteInt(pUser->m_nLosttimes);
		OutPkg.WriteInt(pUser->m_chips);
		OutPkg.End();
		VLogMsg(CLIB_LOG_LEV_INFO, "Get User[%d] Success.Money[%s],Exp[%d],Score[%d],Win[%d],Lose[%d],Source[%d],chips[%d]", \
			nMid, pUser->getStrMoney().c_str(), pUser->m_nExp, pUser->m_nScore, pUser->m_nWintimes, pUser->m_nLosttimes, Source, pUser->m_chips);
	}
	clientHandler->Send(OutPkg.packet_buf(),OutPkg.packet_size());
	return 0;
}

