#include "UpdateClientHandler.h"
#include "global.h"
#include "ManagerFactory.h"

int UpdateClientHandler::OnClose() 
{
	return 0;	
}

int UpdateClientHandler::OnPacketComplete(const char * data, int len)
{
	return 0;
}

int UpdateClientHandler::Init()
{
	CCSocketHandler::Init();
	return 0;
}


