#include "DUpdateProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DUpdateProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	int nRet = 0;
	int Source = inputPacket.ReadInt();
	string Describe = inputPacket.ReadString();
	int Uid = inputPacket.ReadInt();
	int Money = inputPacket.ReadInt();
	int Exp = inputPacket.ReadInt();
	int Score = inputPacket.ReadInt();
	int Win = inputPacket.ReadInt();
	int Lost = inputPacket.ReadInt();
	string clientInfo = inputPacket.ReadString();
	int chips = inputPacket.ReadInt();
	if (chips == -1)
	{
		chips = 0;
	}
	VLogMsg(CLIB_LOG_LEV_INFO,"Request Update User[%d] Info.Source[%d],Dscribe[%s],Money[%d],Exp[%d],Score[%d],Win[%d],Lost[%d],clientInfo[%s] chips[%d]",\
		Uid, Source, Describe.c_str(), Money, Exp, Score, Win, Lost, clientInfo.c_str(), chips);
	CGameUser* pUser = m_pOwner->m_UserManager.GetUser(Uid);
	if(pUser == NULL)
	{
		pUser = m_pOwner->GetUserInfoInCache(Uid);
	}

	if (pUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_DEBUG, "Request Get User[%d] not exist", Uid);
		return 0;
	}

	if(pUser != NULL)
	{
		if (pUser->m_nLMoney + Money >= 0 && pUser->m_nScore + Score >= 0 && pUser->m_chips + chips >= 0)
		{
			//increase
			pUser->UpdateInfo(Money, Exp, Score, Win, Lost, chips);
			//update user info
			nRet = m_pOwner->UpdateUserInfoInCache(pUser, Describe, Source, clientInfo.c_str());
			VLogMsg(CLIB_LOG_LEV_INFO,"Update User[%d] Info.nRet[%d],Source[%d],Describe[%s],Money[%ld],Exp[%d],Score[%d],Win[%d],Lost[%d],chips[%d]",\
				Uid, nRet, Source, Describe.c_str(), pUser->m_nLMoney, pUser->m_nExp, pUser->m_nScore, pUser->m_nWintimes, pUser->m_nLosttimes, pUser->m_chips);
		}
		else
		{

	
			//钱或分不够扣，就扣现有部分
			if(pUser->m_nLMoney+Money < 0){
				Money = 0 - pUser->m_nLMoney;
			}else if(pUser->m_nScore+Score < 0){
				Score = 0 - pUser->m_nScore;
			}
			else if (pUser->m_chips + chips < 0){
				chips = 0 - pUser->m_chips;
			}

			//increase
			pUser->UpdateInfo(Money,Exp,Score,Win,Lost,chips);
			//update user info  //nRet总返回0
			nRet = m_pOwner->UpdateUserInfoInCache(pUser, Describe, Source, clientInfo.c_str());

			VLogMsg(CLIB_LOG_LEV_INFO, "Update User[%d] Info Failed.lack of Money.Source[%d],Describe[%s],money[%d],score[%d],cur_chips[%d]", \
				Uid, Source, Describe.c_str(), Money, Score, pUser->m_chips);

			nRet = 2;
		}

	}
	else
	{
		nRet = 1;
		VLogMsg(CLIB_LOG_LEV_ERROR,"Update User[%d] Info Failed.Not Exist.Source[%d],Describe[%s]",\
			Uid,Source,Describe.c_str());
		return 0;
	}
	//Ïò¿Í»§¶Ë»ØÓ¦¸üÐÂÏûÏ¢
	NETOutputPacket OutPkg;
	OutPkg.Begin(SERVER_COMMAND_UPDATE_RECORD);
	OutPkg.WriteInt(Uid);
	if(nRet != 0)
	{
		if(nRet == 2){  //
			OutPkg.WriteInt(nRet);
			OutPkg.WriteInt64(pUser->m_nLMoney);
			OutPkg.WriteInt(pUser->m_nExp);
			OutPkg.WriteInt(pUser->m_nScore);
			OutPkg.WriteInt(pUser->m_nWintimes);
			OutPkg.WriteInt(pUser->m_nLosttimes);
			OutPkg.WriteInt(Money); 
			OutPkg.WriteInt(Score);
			OutPkg.WriteInt(pUser->m_chips);
			OutPkg.End();
		}
		OutPkg.WriteInt(nRet);
		OutPkg.End();
	}
	else
	{
		OutPkg.WriteInt(0);
		OutPkg.WriteInt64(pUser->m_nLMoney);
		OutPkg.WriteInt(pUser->m_nExp);
		OutPkg.WriteInt(pUser->m_nScore);
		OutPkg.WriteInt(pUser->m_nWintimes);
		OutPkg.WriteInt(pUser->m_nLosttimes);
		OutPkg.WriteInt(pUser->m_chips);
		OutPkg.End();
	}
	clientHandler->Send(OutPkg.packet_buf(),OutPkg.packet_size());
	return 0;
}




