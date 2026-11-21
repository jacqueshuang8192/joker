#ifndef BOYAA_DBPART_H_20090707
#define BOYAA_DBPART_H_20090707
#include <string>
using std::string;

#include <map>
using std::map;

#include "ConnectPool.h"
#include "global.h"

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
	BOOL ConnectDB(DatabaseParam& dbParam);
	int UpdateData(int uid,const UserInfo & data);
	static int GetDatabaseIndex(int mid);
	static int GetTableIndex(int mid);
	int GetUserInfo(int nUserId, long int& nMoney,int& nExp, int& nScore,  int& nWinTimes, int& nLoseTimes,int& chips);
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
};
#endif
