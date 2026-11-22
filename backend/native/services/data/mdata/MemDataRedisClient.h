#pragma once
#include "RedisServer.h"
#include "global.h"

class CGameUser;

class MemDataRedisClient:public CRedisServer
{
public:
	int UpdateUserInfoInCache(CGameUser * pUser);
	int UpdateUserMoneyInCache(CGameUser * pUser);
	int DeleteUserInCache(CGameUser * pUser);
	int GetUserInfoInCache(int Uid,UserInfo & ui);

	int UpdateGroupState(int creatorID,int state, int activity_id);

	//房间列表 neo
	int	addTables(int level,int sid, int counts, int player_count,int game_type);
};

