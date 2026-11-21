#ifndef SOCKET_HANDLER_H
#define SOCKET_HANDLER_H


#include "CCSocketServer.h"
#include "CCSocketHandler.h"
#include "QEPacketBase.h"
#include "QEDecoder.h"
#include "EncryptDecrypt.h"
#include <string>
#include <vector>


/*
#pragma pack(1)
struct TPkgHeader
{	
	 short length;
	 char  flag[2];	 	
	 char  cVersion;	
	 char  cSubVersion;
	 short cmd;
	 unsigned char  code;
};
#pragma pack()*/



using namespace std;

class ClientHandler: public CCSocketHandler
{
public:
	ClientHandler();
	virtual ~ClientHandler();

	string m_addrRemote;
	int    m_nPort;

	int Send(NETOutputPacket * packet, bool encode = false)
	{
		if( encode)
		{	
			CEncryptDecrypt encrypt;
			encrypt.EncryptBuffer(packet);
		}
		return CCSocketHandler::Send(packet->packet_buf(), packet->packet_size())>0 ?0: -1;
	}

	int OnConnected(void); 
	int OnClose();

private:
	int OnPacketComplete(const char * data,int len);
	int ProcessPacket(NETInputPacket *pPacket);
	ICC_Decoder* CreateDecoder()
	{
		return new QEDecoder();
	}

	void GetRemoteAddr(void);
	NETInputPacket	pPacket;

public:


private:
	//业务逻辑方面
	int ProcessTabDataPacket(NETInputPacket* pPacket);
	int ProcessAllocRegister(NETInputPacket *pPacket);
	int ProcessGetUserTable(NETInputPacket *pPacket);	
	int ProcessBeforeCreateGroupCheck(NETInputPacket * pPacket);
	int ProcessGetUserTable_Common(NETInputPacket * pPacket);
	int ProcessSubPacket(NETInputPacket *pPacket);
	int ProcessClientPacket(int nUid, int nSvid,NETInputPacket *pPacket);
	int ProcessUserLogin(int nUid, int nSvid,NETInputPacket *pPacket);
	int ProcessGetRoomLevelNum(int nUid, int nSvid,NETInputPacket *pPacket);

	int ProcessClientClose(NETInputPacket *pPacket);
	int ProcessReportUserLeaveRoom(NETInputPacket *pPacket);
	int ProcessReportUserEnterRoom(NETInputPacket *pPacket);
	int ProcessLogicCore(NETInputPacket *pPacket);
	int ProcessHallCore(NETInputPacket *pPacket);
	int ProcessClearServerInfo(NETInputPacket *pPacket);
	int ProcessBroadCastSwitch(NETInputPacket *pPacket);
	int ProcessTJSwitch(NETInputPacket *pPacket);
	int ProcessSetLevelCountRandom(NETInputPacket *pPacket);
	int ProcessResetLevelInfo(NETInputPacket * pPacket);
	int ProcessGetUserHallID(NETInputPacket *pPacket);
	int ProcessGetUserTableInfo(NETInputPacket * pPacket);

	int SendClientPacket(int uid, int svid, NETOutputPacket *pPacket);
	int SendServerClosePacket(int uid, int svid);

	void SetServerUserTid0(short sid);
	void SetUserOfflineHallCore(int hid);
	int	ProcessReportOnlookInRoom(NETInputPacket *pPacket);
	int	ProcessReportOnlookOutRoom(NETInputPacket *pPacket);


public:
	
	
	
};



#endif


