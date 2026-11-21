#include "DUpdateMoneyProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DUpdateMoneyProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	if (m_pOwner == NULL){
		ErrMsg("m_pOwner is NULL");
		return 0;
	}
	int nRet = 0;
	int Source = inputPacket.ReadInt();
	string Describe = inputPacket.ReadString();
	int nMid = inputPacket.ReadInt();
	int Money = inputPacket.ReadInt();
	string clientInfo = inputPacket.ReadString();
	VLogMsg(CLIB_LOG_LEV_INFO,"Request Update User[%d] Money[%d].Source[%d],Describe[%s],clientInfo[%s].",nMid,Money,Source,Describe.c_str(),clientInfo.c_str());    
	CGameUser* pUser = m_pOwner->m_UserManager.GetUser(nMid);
	if(pUser == NULL)
	{
		pUser = m_pOwner->GetUserInfoInCache(nMid);
	}

	if (pUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_DEBUG, "Request Get User[%d] not exist", nMid);
		return 0;
	}
	if(pUser != NULL)
	{
		if(pUser->m_nLMoney+Money >= 0)
		{
			//取相应数加
			pUser->UpdateInfo(Money,0,0,0,0,0);
			nRet = m_pOwner->UpdateUserMoneyInCache(pUser,Describe,Source,clientInfo.c_str());
			VLogMsg(CLIB_LOG_LEV_ERROR,"Update User[%d] Money[%ld].nRet[%d],Source[%d],Describe[%s]",nMid,pUser->m_nLMoney,nRet,Source,Describe.c_str());
		}
		else
		{
			nRet = 2;
			VLogMsg(CLIB_LOG_LEV_ERROR,"Update User[%d] Money[%d] Failed.lack of money.Source[%d],Describe[%s]",nMid,Money,Source,Describe.c_str());
		}
	}
	else
	{
		nRet = 1;
		VLogMsg(CLIB_LOG_LEV_ERROR,"Update User[%d] Money[%d] Failed.Not Exist.Source[%d],Describe[%s]",nMid,Money,Source,Describe.c_str());
	}
	//向客户端回应更新消息
	NETOutputPacket OutPkg;
	OutPkg.Begin(SERVER_COMMAND_UPDATE_RECORD);	
	OutPkg.WriteInt(nMid);
	if(nRet != 0)
	{
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



