#ifndef CLOGSERVER_H_
#define CLOGSERVER_H_


#include "ICC_Timer_Handler.h" 
#include "CCSocketHandler.h" 
#include "QEPacketBase.h"
#include "QEDecoder.h"

#include "GameCmd.h"
#include "Stat.h"




class CBackServer : public CCSocketHandler, public CCTimer
{
public:
	CBackServer(string strFlag);
	virtual ~CBackServer();

	virtual int Init();
	int OnConnected();
    int OnClose();
    int OnPacketComplete(const char* data, int len);
	ICC_Decoder* CreateDecoder()
    {
		return new QEDecoder();
    }
	virtual int ProcessOnTimerOut();

	int reConnect();

	int Send(NETOutputPacket  *pPakcet);
	NETInputPacket  pPacket;
private:
	string strServer_flag;
	bool   m_bIsConnected;

	int ProcessPacket(NETInputPacket  *pPacket);


public:
	int 	InitConnect(const char *ip, int port);
	void 	SynData(map<short, int>& levelMgr, map<short, DATAINFO>& terminalTypeMgr);
private:
	void	ProcessSynData(NETInputPacket  *pPacket);
};

#endif

