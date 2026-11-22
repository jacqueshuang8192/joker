#pragma once

#include <malloc.h>
#include <unistd.h>
#include <string>
#include "clib_log.h"
#include <map>
#include <vector>
#include <string>
#include <set>
#include "protocol.h"
#include "MarkupSTL.h"
#include "wtypedef.h"

using namespace std;

#define LogMsg(format,...) TGlobal::g_pDebugLog->logMsg("[%s %u][%s]" format,__FILE__,__LINE__,__FUNCTION__,##__VA_ARGS__)
#define ErrMsg(format,...) TGlobal::g_pErrorLog->logMsg("[%s %u][%s]" format,__FILE__,__LINE__,__FUNCTION__,##__VA_ARGS__)
#define VLogMsg(level,format,...) TGlobal::g_pDebugLog->vwrite(level,"[%s %u][%s]" format,__FILE__,__LINE__,__FUNCTION__,##__VA_ARGS__)

typedef struct _userinfo_
{
	long int money;
	int exp;
	int score;
	int win;
	int lose;
	int chips;
	_userinfo_()
	{
		money = 0;
		exp = 0;
		score = 0;
		win = 0;
		lose = 0;
		chips = 0;
	}
}UserInfo;

class TGlobal
{

public:
    static string           _ip;  
	static string			_xmlconfig;
    static short        	_port;  
	static int            	_svid;
	static clib_log* 		g_pErrorLog;
	static clib_log* 		g_pDebugLog;
public:
	static int 				heartInteval;
private: //no impl
    TGlobal (void);
    ~TGlobal (void);
    TGlobal (const TGlobal&);
    const TGlobal& operator= (const TGlobal&);
};

long long ustime();
long long mstime();

#define DEFAULT_SERVER_TYPE 0
#define SINGLE_CONNECTION_TYPE 1
#define INVALID_SERVER_TYPE -1

enum{
	CONN_TYPE_INVALID = -1,
	CONN_TYPE_CLIENT = 0,//客户端与HallServer 的链接
	CONN_TYPE_LOGICSERVER = 1,//Hallserver 与 GameServer的链接
	CONN_TYPE_ALLOC = 2,//HallServer
};

#define CHIPS2MONEY_EXCHANGE_RATE 1200

typedef struct _SERVERCONFIG{
	string m_ip;
	int m_port;
	string m_password;
	int m_svid;
	int m_level;
}ServerConfig;

typedef struct _LOGICHANDLERINFO{
	int m_uid;
	int m_port;
	string m_ip;
	int m_svid;
}LogicHandlerInfo;

typedef struct _DBCONFIG{
	string m_ip;
	int m_port;
	int m_id;
	string m_user;
	string m_pwd;
	string m_tableName;
	string m_dbName;
	int m_dbNum;
	int m_tableNum;
}DBConfig;


class GameConfig{
	public:
		GameConfig():m_serverType(DEFAULT_SERVER_TYPE){m_EnableLog = false;m_EnableUpdate = false;m_tableNum = 1;}
		short m_gameID;//游戏类型
		int m_serverType;//server类型
		map<int,ServerConfig> m_ServerMap;

		int m_tableNum;//表个数
		DBConfig m_DBConf;//db ip port 配置
		
		ServerConfig m_LogConf;
		ServerConfig m_UpdateConf;
		bool m_EnableLog;
		bool m_EnableUpdate;
	public:
		bool isExistServerConfig(int gameid);
};



