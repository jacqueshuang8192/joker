#ifndef __BASE_SERVER_H
#define __BASE_SERVER_H
#include "ICHAT_PacketParser.h"
class CHallServer;
class CLogicServer;

class CBaseServer
{
public:
	virtual int ProcessBackPacket(NETInputPacket *pPacket) = 0;
	virtual int ProcessHallCore(CHallServer* pHallServer) = 0;
	virtual int ProcessLogicCore(CLogicServer* pLogicServer) = 0;
public:
	short m_nLevel;
	short m_nSvid;
	
};
#endif
