#ifndef BOYAA_DBPART_H_20090707
#define BOYAA_DBPART_H_20090707
#include <string>
using std::string;

#include <map>
using std::map;
#include "UserBalanceInfo.h"
#include "ConnectPool.h"
#include "global.h"
#include "Global.h"
#include "clib_log.h"
extern clib_log *g_pDebugLog;

struct USERDATA
{
	long int money;
	int exp;
	int level;
	int wintimes;
	int losetimes;
};

struct DatabaseParam			//数据库参数
{
	string host;				//主机名
	string user;				//用户名
	string password;			//密码
	string db;					//数据库名
	unsigned int port;			//端口，一般为0
	string unix_socket;			//套接字，一般为NULL
	unsigned int client_flag;	//一般为0
};

class CMysqlStore;
class CConnect;

class CDbPart
{
public:
	CDbPart();
	virtual ~CDbPart();

public:
	int Init(char* strXML="server.xml");
	BOOL ConnectDB(DatabaseParam& dbParam);
	int GE_TUSER_INGFO(CGameServer* gamsSever,int uid, map<int, CUserBalanceInfo*>& m_userRobotMap,map<int, map<int, CUserBalanceInfo*> >& groupRobotMap);
	static int GetDatabaseIndex(int mid);
	static int GetTableIndex(int mid);
	int GetGroupPlayerList(CGameServer *gamsSever, map<int, vector<int> > &testGroupList, map<int, map<int, CUserBalanceInfo*> > &groupRobotMap, map<int, CUserBalanceInfo*> &m_userRobotMap, map<int, string> &robotConfig);
	//int GetConfigList(int clubId, int level, itemConfig &listConfig);
	int GetUserClubPoint(int clubId, int uid, int &ret);
	vector<groupConfigInfo> GetConfigList(int clubId, int level);
private:
	BOOL CallProcedure(const char * strMysql);
public:
	string m_strError;
protected:
	CConnect*    m_pMysqlConn;
	CMysqlStore*  m_pStore;
public:
	static int m_tableNum;
	static int m_dbNum;
	DatabaseParam dbp;
};
#endif
