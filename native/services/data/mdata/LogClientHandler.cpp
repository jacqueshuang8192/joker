#include "LogClientHandler.h"
#include "global.h"
#include "ManagerFactory.h"

int LogClientHandler::OnClose() 
{
	return 0;	
}

int LogClientHandler::OnPacketComplete(const char * data, int len)
{
	return 0;
}

int LogClientHandler::Init()
{
	CCSocketHandler::Init();
	return 0;
}


