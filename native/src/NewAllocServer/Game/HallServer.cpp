#include "HallServer.h"

#define CORE_CHECK 1

const int CHECK_CORE_TIME = 10;

CHallServer::CHallServer(int svid, SocketHandler* pHandler, CBaseServer* pServer)
{
	m_pBaseServer = pServer;
	m_nServerId = svid;
	m_pSocketHandler = pHandler;
	m_CheckCoreTimer.SetTimeEventObj(this, CORE_CHECK);
}

CHallServer::~CHallServer()
{
}

void CHallServer::StartCheckCoreTimer()
{
	m_CheckCoreTimer.StartTimer(CHECK_CORE_TIME);
}

void CHallServer::StopCheckCoreTimer()
{
	m_CheckCoreTimer.StopTimer();
}

int CHallServer::ProcessOnTimerOut(int timerId)
{
	switch(timerId)
	{
	case CORE_CHECK:
		m_pBaseServer->ProcessHallCore(this);
		break;
	default:
		break;
	}
	return 0;
}