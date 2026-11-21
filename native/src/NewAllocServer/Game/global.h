#pragma once

#include <malloc.h>
#include <unistd.h>
#include <string>
#include "clib_log.h"
#include <map>
#include <vector>
#include <string>
#include <set>
#include "MarkupSTL.h"
#include "wtypedef.h"

using namespace std;
struct groupConfigInfo {
	string Name;
	int mid;
	string Config;
};

typedef struct _userinfo_
{
	long int money;
	int exp;
	int win;
	int lose;
	_userinfo_()
	{
		money = 0;
		exp = 0;
		win = 0;
		lose = 0;
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

#define DEFAULT_SERVER_TYPE 0
#define SINGLE_CONNECTION_TYPE 1
#define INVALID_SERVER_TYPE -1

enum{
	CONN_TYPE_INVALID = -1,
	CONN_TYPE_CLIENT = 0,//客户端与HallServer 的链接
	CONN_TYPE_LOGICSERVER = 1,//Hallserver 与 GameServer的链接
	CONN_TYPE_ALLOC = 2,//HallServer
};


typedef struct _SERVERCONFIG{
	string m_ip;
	int m_port;
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


