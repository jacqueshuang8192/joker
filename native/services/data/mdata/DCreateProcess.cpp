#include "DCreateProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DCreateProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	if (m_pOwner == NULL){
		ErrMsg("m_pOwner is NULL");
		return 0;
	}
	int source = inputPacket.ReadInt();
	string describe = inputPacket.ReadString();
	int nMid = inputPacket.ReadInt();
    string strMoney = inputPacket.ReadString();
    long int nMoney = atol(strMoney.c_str());
    int nExp = inputPacket.ReadInt();
    int nScore = inputPacket.ReadInt();
    int nWinTimes = inputPacket.ReadInt();
    int nLostTimes = inputPacket.ReadInt();
	string clientInfo = inputPacket.ReadString();
	int chips = inputPacket.ReadInt();

	int nRet = 0;
	VLogMsg(CLIB_LOG_LEV_INFO,"Request Create User[%d].Source[%d],Describe[%s],Money[%ld],Exp[%d],Score[%d],Win[%d],Lost[%d],chips[%d]",\
		nMid, source, describe.c_str(), nMoney, nExp, nScore, nWinTimes, nLostTimes, chips);
	CGameUser* pOldUser = m_pOwner->m_UserManager.GetUser(nMid);
	if (pOldUser != NULL)
	{
		nRet = 1;
		VLogMsg(CLIB_LOG_LEV_ERROR,"Create User[%d] Failed.Already Exist",nMid);
	}
	else
	{
		unsigned int nCreateTime = time(NULL);
		(void) nCreateTime;
		CGameUser* pUser = new CGameUser(nMid, nMoney, nExp, nScore, nWinTimes, nLostTimes, chips);
		if(pUser != NULL)
		{
			if(m_pOwner->m_UserManager.AddUser(nMid, pUser) == -1)
			{
				nRet = 1;
				delete pUser; 
				pUser = NULL;
				VLogMsg(CLIB_LOG_LEV_ERROR,"Create User[%d] Failed.Already Exist.Source[%d],Describe[%s]",nMid,source,describe.c_str());
			}
			else
			{
				//write user info to cache
				nRet = m_pOwner->UpdateUserInfoInCache(pUser,describe,source,clientInfo);
				VLogMsg(CLIB_LOG_LEV_INFO,"Create User[%d].nRet[%d],Money[%ld],Exp[%d],Score[%d],Win[%d],Lose[%d],Source[%d],Describe[%s],chips[%d]",\
					nMid, nRet, pUser->m_nLMoney, pUser->m_nExp, pUser->m_nScore, pUser->m_nWintimes, pUser->m_nLosttimes, source, describe.c_str(), chips);
			}
		}
		else
		{			
			nRet = 2;
			ErrMsg("Fatal Error.Create New User[%d] failed.Alloc Memory Failed,Source[%d],Describe[%s]", nMid,source,describe.c_str());
		}
	}
	//回复操作结果
	NETOutputPacket OutPkg;
	OutPkg.Begin(SERVER_COMMAND_CREATE_RECORD);
	OutPkg.WriteInt(nMid);
	OutPkg.WriteInt(nRet);
	OutPkg.End();
	clientHandler->Send(OutPkg.packet_buf(),OutPkg.packet_size());
	return 0;
}

