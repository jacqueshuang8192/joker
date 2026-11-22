#ifndef __REDIS_SERVER_H
#define __REDIS_SERVER_H
#include <string>
#include <string.h>
#include <vector>
#include "hiredis.h"
using namespace std;

enum
{
	REPLY_OK = 0,
	REPLY_NULL,
	REPLY_ELEMENT_NULL,
	REPLY_ELEMENTCOUNT_ERROR,
	REPLY_KEY_ERROR,
	REPLY_KEY_TYPEERROR,
	REPLY_COMMAND_ERROR,
	REPLY_TYPE_ERROR,
	REPLY_ERROR,
	REPLY_MSG_LEN_ERROR,
};

#define REDIS_CONNECT_TIMER 1

#define RANK_REDIS_EXPIRE  2592000        //排名redis 30天过期
#define SCORE_REDIS_EXPIRE 10800          //玩家个人积分redis记录3小时过期

class CRedisServer
{
public:
	CRedisServer();
	~CRedisServer();
	int Connect(const string & ip, int port, string password = "");
	int Reconnect();
	int SetExpire(const char* key, int expire);
	redisReply * RedisCommand(const char * command);	
	redisReply * RedisCommandArgv(vector<string> &v);
	int SetUserStateInfo(int uid, int level,int tid,int activitiyID);
	int DelUserStateInfo(int uid,int level);
	int SetTimeout(struct timeval tv);

	/*------------------------ 更新桌子列表状态 neo ---------------------------*/
	int	SetTableStatus(int level, int tid, vector<int> players, int game_type);

public:
	string m_strIp;
	int m_nPort;
	string m_password;
	redisContext *m_pRedisConn;		//连接hiredis
	redisReply *m_pRedisReply;		//回复hiredis

};
#endif

