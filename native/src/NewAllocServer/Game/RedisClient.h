#ifndef __GAME_REDIS_CLIENT_H__
#define __GAME_REDIS_CLIENT_H__

#include "CRedisClient.h"
#include <string.h>

using namespace std;

typedef struct _redis_uinfo
{
	int vip_level;
}RedisUserInfo;

class RedisClient:public CRedisClient
{
public:
	int GET_USER_GAME_STATUS(int uid, string &str);
	int GetGroupPlayer();
	int WIN_CLOS_GROUP(int tid, int activityId, int round);
	int ROBOT_STATUS(int club_id,int uid, int status,int level,int tempLevel = 0);
	int SET_DISABLE_USER(int uid, int status, int club_id);
	int GetRobotStatus(int uid, string &str);
	int SET_TEMP_ROBOT_STATUS(int uid, int status, int level);
	int GET_TEMP_ROBOT_STATUS(int uid, string &str);
	int HGET_GROUP_USER_CHIPS(int uid, int club_id, string &str);
	int writeUserChips(int uid, int club_id, int chips);
	int GET_DISABLE_USER(int club_id,int uid, string &str);
	int getAllConfig(int clubId, std::vector<string>& vctReply);
	int GET_SISMEMBER_USER(int clubId, int uid);
	int GET_SISMEMBER(char* key, int findUid);
};

#endif
