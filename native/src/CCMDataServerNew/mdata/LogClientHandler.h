#pragma once
#include "CCSocketHandler.h"
#include "ICC_Timer_Handler.h"
#include "LandlordDecoder.h"
#include "global.h"

class GameManager;

class LogClientHandler : public CCSocketHandler ,public CCTimer
{
	public:
		LogClientHandler(){
		}
		virtual ~LogClientHandler()
		{
		}

	public:
		int GetFD()
		{
			return netfd;
		}
		virtual int Init();

		virtual int OnClose();

		ICC_Decoder*  CreateDecoder()
		{
			return new CCLandlordDecoder(); 
		}

		virtual int OnPacketComplete(const char * data, int len);
	protected:
		virtual int ProcessOnTimerOut()
		{
			OnClose();
			StopTimer();
			delete this;
			return 0;
		}
};



