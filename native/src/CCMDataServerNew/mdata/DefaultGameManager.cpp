#include "DefaultGameManager.h"
#include "IProcess.h"
#include "EncryptDecrypt.h"
#include "global.h"
#include "ClientHandler.h"
#include "DefaultProcessFactory.h"

DefaultGameManager::DefaultGameManager(){
	m_pClientFactory = new DefaultProcessFactory();
	m_pClientFactory->m_pOwner = this;
}

int DefaultGameManager::ProcessClientPacket(CClientHandler * pHandler,NETInputPacket & input,int cmd){
	if(pHandler == NULL){
		ErrMsg("Fatal Error.pHandler Is NULL.");
		return 0;
	}

	VLogMsg(CLIB_LOG_LEV_INFO,"Recive CMD[0x%x]",cmd);
	
	IProcess* processer = m_pClientFactory->getProcesser(cmd);

	if(processer)
	{
		int ret = processer->doRequest(pHandler,input,cmd);
		if(ret<0)
		{
			ErrMsg( "Process Error ret=[%d]" ,ret) ;
			return 0;
		}
	}
	else
	{
		ErrMsg("Invalid Command[0x%x].Request By IP[%d]",cmd,pHandler->GetIP());
		return 0;
	}
	return 0;
}

void DefaultGameManager::ProcessHandlerClose(CClientHandler * pHandler){
	return;
}


