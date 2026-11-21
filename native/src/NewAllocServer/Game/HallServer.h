#ifndef __HALL_SERVER_H
#define __HALL_SERVER_H
#include "TimerOutEvent.h"
#include "ICHAT_Timer_Handler.h"
#include "BaseServer.h"

class SocketHandler;

class CHallServer : public TimerOutEvent
{
public:
	CHallServer(int svid, SocketHandler* pHandler, CBaseServer* pServer);
	~CHallServer();
public:
	int ProcessOnTimerOut(int timerId);
	void StartCheckCoreTimer();
	void StopCheckCoreTimer();
public:
	int m_nServerId;
	ICHAT_Timer_Handler m_CheckCoreTimer;
	SocketHandler* m_pSocketHandler;
	CBaseServer* m_pBaseServer;
};
#endif