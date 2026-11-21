#include "RedisClient.h"

int RedisClient::GetGroupPlayer() {

	char reply[1024*8];
	string str = "";
	int len = 0;
	//int ret = HGET("GROUP_PLAYER", "222222", reply, sizeof(reply));
	vector<string>list;
	int ret = HGETALL("GROUP_PLAYER",list);
	str += reply;
	for (int i = 0; i < list.size(); i++)
	{
		g_pDebugLog->logMsg("reply.c_str()[%s]", list[i].c_str());
	}
	

	return ret;
}
int RedisClient::GetRobotStatus(int uid, string &str) {
	string key = "ROBOT_STATUS";
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	return HGET_ROBOT_STATUS(key.c_str(), field, str);
}


int RedisClient::ROBOT_STATUS(int club_id,int uid, int status, int level,int tempLevel)
{
	if (uid < 0) {
		return -1;
	}
	string key = "ROBOT_STATUS";
	char keyStr[255] = { 0 };
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	snprintf(keyStr, sizeof(keyStr) - 1, "%d_%d_%d_%d", level, club_id, status, tempLevel);

	int ret = HSET(key.c_str(), field, keyStr);

	if (ret <= 0)
	{
		//fail
		return -1;
	}
	else {
		return 0;
	}
}
int RedisClient::GET_USER_GAME_STATUS(int uid, string &str) {
	string key = "USER_GAME_STATUS";
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	return HGET_ROBOT_STATUS(key.c_str(), field, str);
}
int RedisClient::GET_TEMP_ROBOT_STATUS(int uid, string &str) {
	string key = "TEMP_ROBOT_STATUS";
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	return HGET_ROBOT_STATUS(key.c_str(), field, str);
}
int RedisClient::HGET_GROUP_USER_CHIPS(int uid, int club_id, string &str) {
	char key[255] = { 0 };
	snprintf(key, sizeof(key) - 1, "GROUP_USER_CHIPS_%d", club_id);
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	int ret = HGET_USER_CHIPS(key, field, str);
	return ret;
}
int RedisClient::writeUserChips(int uid, int club_id, int chips) {
	char key[255] = { 0 };
	snprintf(key, sizeof(key) - 1, "GROUP_USER_CHIPS_%d", club_id);
	char command[1024] = { 0 };
	snprintf(command, sizeof(command), "HMSET %s %d %d", key, uid, chips);
	int ret = RedisCommandChips(command);
	return ret;
}
int RedisClient::SET_TEMP_ROBOT_STATUS(int uid, int status, int level)
{
	if (uid < 0) {
		return -1;
	}
	string key = "TEMP_ROBOT_STATUS";
	char keyStr[255] = { 0 };
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	snprintf(keyStr, sizeof(keyStr) - 1, "%d_%d", level, status);

	int ret = HSET(key.c_str(), field, keyStr);

	if (ret <= 0)
	{
		//fail
		return -1;
	}
	else {
		return 0;
	}
}
int RedisClient::SET_DISABLE_USER(int uid, int status, int club_id)
{
	if (uid < 0) {
		return -1;
	}
	char key[255] = { 0 };
	snprintf(key, sizeof(key) - 1, "DISABLE_USER_%d", club_id);
	char command[1024] = { 0 };
	snprintf(command, sizeof(command), "HMSET %s %d %d", key, uid, status);
	int ret = RedisCommandChips(command);
	return ret;
}
int RedisClient::GET_DISABLE_USER(int club_id,int uid, string &str) {
	char key[255] = { 0 };
	snprintf(key, sizeof(key) - 1, "DISABLE_USER_%d", club_id);
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", uid);
	int ret = HGET_USER_CHIPS(key, field, str);
	return ret;
}
int RedisClient::GET_SISMEMBER_USER(int club_id, int uid) {
	char key[255] = { 0 };
	snprintf(key, sizeof(key) - 1, "CLUB_USER_JOIN_TOGETHER_LIMIT_%d_%d", club_id, uid);
	int ret = GET_SISMEMBER_USER_REDIS(key);
	return ret;
}
int RedisClient::GET_SISMEMBER(char* key, int findUid) {
	
	int ret = GET_SISMEMBER_REDIS(key, findUid);
	return ret;
}

int RedisClient::WIN_CLOS_GROUP(int tid, int activityId, int round)
{
	string key = "WAIT_CLOSE_GROUP_NEW";
	char keyStr[255] = { 0 };
	char field[50] = { 0 };
	snprintf(field, sizeof(field) - 1, "%d", activityId);
	snprintf(keyStr, sizeof(keyStr) - 1, "%d_%d_%d", tid,activityId, round);

	int ret = HSET(key.c_str(), field, keyStr);

	if (ret <= 0)
	{
		//fail
		return -1;
	}
	else {
		return 0;
	}
}
int RedisClient::getAllConfig(int clubId, std::vector<string>& vctReply)
{
	char field[520] = { 0 };
	snprintf(field, sizeof(field) - 1, "GroupGameConfig_%d %d", clubId,357);
	return HAGETALLNEW(vctReply, field);
}
