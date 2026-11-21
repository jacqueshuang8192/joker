#include "ICHAT_Timer_Handler.h"
//#include "TimerServer.h"
//#include "CommandMsg.h"	


ICHAT_Timer_Handler::ICHAT_Timer_Handler(void)
{
	m_nId = 0;
	m_TimeEvent = NULL;
	this->reactor(ACE_Reactor::instance());
}

ICHAT_Timer_Handler::~ICHAT_Timer_Handler(void)
{
}

int ICHAT_Timer_Handler::handle_timeout(const ACE_Time_Value &time, const void *p)
{
	return m_TimeEvent->ProcessOnTimerOut(m_nId);
}