#pragma once
#include "ichatlib.h"
#include "ICHAT_TCP_Handler.h"
#include "TimerOutEvent.h"
class TimerOutEvent;
class ICHAT_Timer_Handler:public ACE_Event_Handler
{
public:
	ICHAT_Timer_Handler(void);
	virtual ~ICHAT_Timer_Handler(void);
public:
	//OnTimer

	int handle_timeout(const ACE_Time_Value &time, const void *p);

	void SetTimeEventObj(TimerOutEvent * obj, int id=0)
	{
		m_nId = id;
		m_TimeEvent = obj;
		this->reactor(ACE_Reactor::instance());
	}
	////////////////////////////////////////////////////////////////////////////////
	// // 开始定时器(初始延时nSecond秒, 间隔interval秒
	////////////////////////////////////////////////////////////////////////////////
	void StartTimer(long nSecond, long interval=0)
	{
		if(interval == 0)
			this->reactor()->schedule_timer(this, 0, ACE_Time_Value(nSecond));
		else
			this->reactor()->schedule_timer(this, 0, ACE_Time_Value(nSecond), ACE_Time_Value(interval));
	}
	void StopTimer(void)
	{
		this->reactor()->cancel_timer(this);
	}

private:
	int m_nId;
	TimerOutEvent *m_TimeEvent;
};

