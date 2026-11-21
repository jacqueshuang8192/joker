#ifndef __REDIS_MANAGER_CLIENT_H__
#define __REDIS_MANAGER_CLIENT_H__

#include "RedisClient.h"
#include "MarkupSTL.h"

typedef struct _redisconf
{
	int m_redisId;
	string m_strip;
	int m_port;
	string m_password;
}RedisConf;

typedef map<int,RedisClient*>   RedisMap;
class CGameServer;
class CRedisManagerClient
{
public:
	CRedisManagerClient(CGameServer* server) :m_pserver(server) { ; }
	~CRedisManagerClient();
	
public:
	int Init(char* strXML = "server.xml");
	int InitConnect();
	int GetGroupPlayer();
	int WIN_CLOS_GROUP(int tid, int activityId, int round);
	int ROBOT_STATUS(int club_id,int uid, int status,int level = 0,int tempLevel = 0);
	int SET_TEMP_ROBOT_STATUS(int uid, int status, int level);
	int GET_USER_GAME_STATUS(int uid, string& buff);
	int GET_TEMP_ROBOT_STATUS(int uid, string& buff);
	int GetRobotStatus(int uid, string& buff);
	int HGET_GROUP_USER_CHIPS(int uid, int club_id, string &str);
	int writeUserChips(int uid, int club_id, int chips);
	int SET_DISABLE_USER(int uid, int status, int club_id);
	int GET_DISABLE_USER(int club_id,int uid, string& buff);
	int HSET_USER_STATUS(int uid,int level, int tid, int activitId);
	int getAllConfig(int clubId, std::vector<string>& vctReply);
	int GET_SISMEMBER_USER(int club_id, int uid); //查看玩家是否在同桌
	int GET_SISMEMBER(int club_id, int uid,int findUid);
private:
	CGameServer* m_pserver;
	map<int,RedisConf*> m_RedisConfMap;
	RedisMap  m_RedisClientList;

};

#endif
