#pragma once

class TimerOutEvent
{
public:
	virtual int ProcessOnTimerOut(int timerId)=0;
};
