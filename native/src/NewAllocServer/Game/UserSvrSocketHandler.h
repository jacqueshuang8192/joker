#ifndef BOYAA_MEMSVR_SOCKETHANDLER_H_20100430
#define BOYAA_MEMSVR_SOCKETHANDLER_H_20100430

#include "ICHAT_TCP_Handler.h"
#include "ICHAT_Timer_Handler.h"
#include "ICHAT_PacketBase.h"
#include "wtypedef.h"

class CUserServer;

class UserSvrSocketHandler:public ICHAT_TCP_Handler<>,
	public ICHAT_PacketParser<NETInputPacket>,
    public TimerOutEvent
{ 
public:
	UserSvrSocketHandler(void);
    UserSvrSocketHandler(CUserServer* pTJSvr);
	virtual ~UserSvrSocketHandler(void);
public:
	int Send(NETOutputPacket *pPacket, int delete_buffer = 0, int close_flag = 0);
	//关闭
	int OnClose(void);
	//连接完成
	int OnConnected(void);
	//回应
	int OnParser(char *buf, int nLen);
	//OnTimer
	int OnTimer(const void *);
	//是否连接
	bool IsConnected(void)	{return m_bConntected;}
	//保存连接地址
	ACE_INET_Addr &Addr(void) {return m_remote;}
	void Addr(ACE_INET_Addr &addr) { m_remote = addr;}

	NETInputPacket *GetPacket(void)
	{
		return &m_Packet;
	}

	int  ProcessOnTimerOut(int timerId);
private:
	NETInputPacket m_Packet;
	
	ICHAT_Timer_Handler m_ReconnectTimer;//重连大厅定时器
	//地址
	ACE_INET_Addr m_remote;
	//回调proxyManager
	CUserServer *m_pUserServer;
	//连接状态
	bool m_bConntected;
	//packet
	int OnPacketComplete(NETInputPacket *pPacket);

	int ProcessPacket(NETInputPacket* pPacket);
};
#endif


