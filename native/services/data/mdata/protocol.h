#pragma once

// 客户端消息
const int CLIENT_COMMAND_CREATE_RECORD = 0x1001;	//创建用户
const int CLIENT_COMMAND_UPDATE_RECORD = 0x1002;	//更新用户钱数,经验值 
const int CLIENT_COMMAND_DELETE_RECORD = 0x1003;	//删除用户
const int CLIENT_COMMAND_GET_RECORD	= 0x1004;		//取用户钱数,经验值

const int CLIENT_COMMAND_UPDATE_MONEY = 0x1005;		//新协议，包含来源,php更新钱
const int CLIENT_COMMAND_UPDATE_ACTIVITY_CHIPS = 0x1006;//更新活动的chips

const int SYS_COMMAND_SET_MID_UPDATE_FILE_INTEVAL = 0x100A;//设置mid更新文件时间

//服务器回应消息
const int SERVER_COMMAND_CREATE_RECORD = 0x2001;		//服务器回应创建用户
const int SERVER_COMMAND_UPDATE_RECORD = 0x2002;		//服务器回应更新用户
const int SERVER_COMMAND_DELETE_RECORD = 0x2003;		//服务器回应删除用户
const int SERVER_COMMAND_GET_RECORD = 0x2004;			//服务器回应取用户

const int FORWARD_COMMAND_SET_RECORD = 0x3001;			//转发设置数据 
const int SYS_COMMAND_UPDATE_RECORD = 0x3002;           //区分server php更新用户信息
const int FORWARD_COMMAND_SET_RECORD_NEW = 0x3003;
const int SYS_COMMAND_UPDATE_MID = 0x3004;
const int SYS_COMMAND_UPDATE_T_ACTIVITY_USER = 0x3005;

const int AG2M_CHANGE_MONEY2CHIPS = 0x301A;		//查询用户兑换筹码结果 zsw
const int AG2M_GET_CHIPS = 0x301C;			//查询用户更新筹码结果 zsw
const int AG2M_CHANGE_CHIP2MONEY = 0x301D;	//查询用户筹码换金币结果 zsw
const int A2M_CHANGE_TABLE_STATE = 0x302D;	//修改组局状态 zsw

const int M2AG_CHANGE_MONEY2CHIPS = 0x301A;			//memdataserver返回用户兑换筹码结果 zsw
const int M2AG_GET_CHIPS = 0x301C;				//memdataserver返回用户更新筹码结果 zsw
const int M2AG_CHANGE_CHIP2MONEY = 0x301D;		//memdataserver返回用户筹码换金币结果 zsw

const int A2M_CREATE_TABLE_REDIS = 0x3200;		//alloc创建房间列表 neo