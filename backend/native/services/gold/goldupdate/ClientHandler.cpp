#include "ClientHandler.h"
#include "global.h"
#include "EncryptDecrypt.h"
#include "ManagerFactory.h"

int CClientHandler::OnClose() 
{
	if(m_pOwner){
		m_pOwner->ProcessHandlerClose(this);
	}
	return 0;	
}

int CClientHandler::OnPacketComplete(const char * data, int len)
{
	NETInputPacket input;
	input.Copy(data,len);
	int cmd = input.GetCmdType();
	int gameID = input.GetGameID();
	GameManager * pManager = NULL;
	if(m_isSetGameID == false)
	{
		pManager = ManagerFactory::Instance()->getGameManager(gameID);
		if(pManager == NULL){
			VLogMsg(CLIB_LOG_LEV_INFO,"Get Game Manager Failed.GameID:%d",gameID);
			return 0;
		}
		m_gameID = gameID;
		m_isSetGameID = true;
		m_pOwner = pManager;
	}
	else
	{
		if (m_gameID != gameID){
			ErrMsg("Fatal Error. GameID Changed.Pre[%d],Now[%d]",m_gameID,gameID);
			return 0;
		}
	}
	int iret = -1;
	switch(m_ConnType){
		case CONN_TYPE_CLIENT:
			{
				iret = m_pOwner->ProcessClientPacket(this,input,cmd);
				break;
			}
		default:
			{
				ErrMsg("Invalid Connection Type[%d]",m_ConnType);
			}
	}
	if(iret < 0){
		VLogMsg(CLIB_LOG_LEV_DEBUG,"Server[SVID:%d,GameID:%d] Process Packet[0x%x] Failed.",pManager->m_svid,pManager->m_gameID,cmd);
	}
	else
	{
		StopTimer();
		StartTimer(TGlobal::heartInteval);
	}
	return 0;
}

int CClientHandler::Init()
{
	CCSocketHandler::Init();
	StartTimer(TGlobal::heartInteval);
	return 0;
}

