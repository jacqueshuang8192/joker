#pragma once
#include "RedisServer.h"
#include "global.h"

class MemDataRedisClient:public CRedisServer
{
public:
	int GetUserInfoInCache(int Uid,UserInfo & ui);
};

