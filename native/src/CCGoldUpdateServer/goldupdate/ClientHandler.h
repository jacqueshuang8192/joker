#include "CCSocketHandler.h"
#include "ICC_Timer_Handler.h"
#include "ICHAT_PacketBase.h"
#include "LandlordDecoder.h"
#include "global.h"

class GameManager;

class CClientHandler : public CCSocketHandler ,public CCTimer
{
	public:
		CClientHandler(){
			m_gameID = -1;
			m_isSetGameID = false;
			m_userKey = -1;
			m_isAuthorized = false;
			m_ConnType = CONN_TYPE_CLIENT;
			m_svid = -1;
			m_pOwner = NULL;
		}
		virtual ~CClientHandler()
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
	public:
		int m_gameID;
		bool m_isSetGameID;
		int m_userKey;
		bool m_isAuthorized;
		int m_ConnType;
		int m_svid;
		GameManager * m_pOwner;
};

