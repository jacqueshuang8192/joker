#ifndef BOYAA_MEM_DATASERVER_H_20141021
#define BOYAA_MEM_DATASERVER_H_20141021

#include "ClientBase.h"
// 客户端消息
const int CLIENT_COMMAND_GET_RECORD	= 0x1004;		 //取用户钱数,经验值
const int CLIENT_COMMAND_UPDATE_MONEY = 0x1005;		//新协议，上报台费
const int CLIENT_COMMAND_UPDATE_RECORD = 0x1002;

//const int G2M_UPDATE_CHIPS = 0x1006;		//更新筹码字段 zsw
//const int G2M_UPDATE_CHIP2MONEY = 0x1006;//更新 zsw

const int USER_UPDATE_EXPEND = 10014;              //上报台费actId
//服务器回应消息
const int SERVER_COMMAND_UPDATE_RECORD = 0x2002;     //服务器回应更新记录
const int SERVER_COMMAND_GET_RECORD = 0x2004;		 //服务器回应取用户
const int SYS_COMMAND_UPDATE_RECORD = 0x3002;        //区分server php更新用户信息

const int M2G_UPDATE_CHIPS_RESULT = 0x2005;		 //服务器回应取用户 zsw
const int M2G_UPDATE_CHIPS2MONEY_RESULT = 0x2006;		 //服务器回应取用户 zsw

enum
{
    MONEY=1,
	SAFEBOX,
	TOTALMONEY,
    EXP,
    LEVEL,
    WINTIMES,
    LOSTTIMES,
	DIAMOND,//数据库字段
	CHIP//数据库字段
};

class CMemDataServer:public ClientBase
{
public:
	CMemDataServer();
	~CMemDataServer();
	
	int ProcessPacket(NETInputPacket* pPacket){;};
	int Send(NETOutputPacket* pPacket, int delete_buffer = 0, int close_flag = 0){return ClientBase::Send(pPacket,  delete_buffer = 0,close_flag = 0);}
	char* GetClientName(){return "MemDataServer";}	

public:

};
#endif

