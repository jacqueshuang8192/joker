#include "DDeleteProcess.h"
#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "GameManager.h"

int DDeleteProcess::doRequest(CClientHandler* clientHandler, NETInputPacket & inputPacket ,int cmd){
	if (clientHandler == NULL){
		ErrMsg("Clienthandler is NULL");
		return 0;
	}
	if (m_pOwner == NULL){
		ErrMsg("m_pOwner is NULL");
		return 0;
	}
	int nRet = 0;
	int source = inputPacket.ReadInt();
	string describe = inputPacket.ReadString();
	int nMid = inputPacket.ReadInt();
	VLogMsg(CLIB_LOG_LEV_INFO,"Request Delete User[%d].Source[%d],Describe[%s]",nMid,source,describe.c_str());
	CGameUser* pUser = m_pOwner->m_UserManager.GetUser(nMid);
	if (pUser == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_ERROR,"Delete User[%d] Failed. Not Exist.Source[%d],Describe[%s]", nMid,source,describe.c_str());
		nRet = 1;
	}
	else 
	{
		m_pOwner->DeleteUserInCache(pUser);
		m_pOwner->m_UserManager.DelUser(pUser->m_nUserId);
		delete pUser; 
		pUser = NULL;
		VLogMsg(CLIB_LOG_LEV_INFO,"Delete User[%d].Source[%d],Describe[%s]",nMid,source,describe.c_str());
	}
	NETOutputPacket OutPkg;
	OutPkg.Begin(SERVER_COMMAND_DELETE_RECORD);
	OutPkg.WriteInt(nMid);
	OutPkg.WriteInt(nRet);
	OutPkg.End();
	clientHandler->Send(OutPkg.packet_buf(),OutPkg.packet_size());
	return 0;
}


