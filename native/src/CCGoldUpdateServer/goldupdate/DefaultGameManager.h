#pragma once
#include "GameManager.h"
#include "ProcessFactory.h"

class DefaultGameManager:public GameManager{
public:
	DefaultGameManager();
	virtual int ProcessClientPacket(CClientHandler * pHandler,NETInputPacket & input,int cmd);
	virtual void ProcessHandlerClose(CClientHandler * pHandler);
};
