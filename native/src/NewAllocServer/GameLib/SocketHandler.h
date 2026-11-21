#pragma once
#include "ichatlib.h"
#include "ICHAT_TCP_Handler.h"

#include "ICHAT_PacketBase.h"
#include "ICHAT_PacketParser.h"
#include "wtypedef.h"

class CLogicServer;
class CHallServer;
//数据包结构信息
struct CMD_Info
{
	BYTE cbCheckCode;							//效验字段
};
class SocketHandler:public ICHAT_TCP_Handler<>,
					public ICHAT_PacketParser<NETInputPacket>					
{
public:
	SocketHandler(DWORD);
	virtual ~SocketHandler(void);
public:
	//状态位
	enum STATUS{CONNECT=0, REQUEST, CLOSE};
	//返回状态
	int GetChunkStatus(void){return m_nStatus;}
	//重新分配ID
	DWORD GetHandlerID(void){return m_dwHandlerID;}
	string GetAddr(void){return m_addrremote;}		//返回点分十进制的IP地址
	DWORD  GetPeerAddr(){return m_dwPeerAddr;}		//返回32位地址
public:
	int Send(NETOutputPacket *pPacket, int delete_buffer = 0, int close_flag = 0);
public:
	CLogicServer* m_pLogicServer;
	CHallServer* m_pHallServer;
private:
	// 协议解析
	int OnParser(char *buf, int nLen);
	//连接关闭
	int OnClose(void);
	//连接建立
	int OnConnected(void);
	//OnTimer
	int OnTimer(const void *);
	//packet
	int OnPacketComplete(NETInputPacket *);

	int SendPacketVarErr(void);

	void GetRemoteAddr(void);

public:
	WORD EncryptBuffer(NETOutputPacket *pPacket);
	int  CrevasseBuffer(NETInputPacket *pPacket);

protected:
	static BYTE	m_SendByteMap[256];		//字节映射表
	static BYTE	m_RecvByteMap[256];		//字节映射表
	BYTE MapSendByte(BYTE const cbData);
	BYTE MapRecvByte(BYTE const cbData);
public:
	int m_nStatus;			//Handler状态
	DWORD m_dwHandlerID;	//socket句柄ID
	string m_addrremote;	//远端地址
	int m_nPort;			//端口
	DWORD m_dwPeerAddr;		//32位地址

};
