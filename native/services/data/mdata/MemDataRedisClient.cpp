#include "MemDataRedisClient.h"
#include "GameUser.h"

int MemDataRedisClient::UpdateUserInfoInCache(CGameUser * pUser)
{
	char key[255] = {0};
	snprintf(key,sizeof(key),"MEMDATA_%d",pUser->m_nUserId);
	char command[1024] = {0};
	snprintf(command,sizeof(command),"HMSET %s MONEY %ld EXP %d SCORE %d WIN %d LOST %d CHIPS %d",\
		key, pUser->m_nLMoney, pUser->m_nExp, pUser->m_nScore, pUser->m_nWintimes, pUser->m_nLosttimes, pUser->m_chips);
	m_pRedisReply = RedisCommand(command);
	if (m_pRedisReply == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_INFO, "Update User[%d] Info Failed.Command[%s]", pUser->m_nUserId, command);
		return -1;
	}
	VLogMsg(CLIB_LOG_LEV_INFO, "Update User[%d] Info Successed.Command[%s]", pUser->m_nUserId, command);
//RELEASE:
	if(m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
	}
	return 0;
}

int MemDataRedisClient::UpdateUserMoneyInCache(CGameUser * pUser)
{
	char key[255] = {0};
	snprintf(key,sizeof(key),"MEMDATA_%d",pUser->m_nUserId);
	char command[1024] = {0};
	snprintf(command,sizeof(command),"HMSET %s MONEY %ld",key,pUser->m_nLMoney);
	m_pRedisReply = RedisCommand(command);
	if (m_pRedisReply == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_ERROR,"Update User[%d] Money Failed.Command[%s]",pUser->m_nUserId,command);
		return -1;
	}
	VLogMsg(CLIB_LOG_LEV_TRACE,"Update User[%d] Money Successed.Command[%s]",pUser->m_nUserId,command);
//RELEASE:
	if(m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
	}
	return 0;
}

int MemDataRedisClient::DeleteUserInCache(CGameUser * pUser)
{
	char key[255] = {0};
	snprintf(key,sizeof(key),"MEMDATA_%d",pUser->m_nUserId);
	char command[1024] = {0};
	snprintf(command,sizeof(command),"DEL %s",key);
	m_pRedisReply = RedisCommand(command);
	if (m_pRedisReply == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_ERROR,"Delete User[%d] Failed.Command[%s]",pUser->m_nUserId,command);
		return -1;
	}
	VLogMsg(CLIB_LOG_LEV_TRACE,"Delete User[%d] Successed.Command[%s]",pUser->m_nUserId,command);
//RELEASE:
	if(m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
	}
	return 0;
}

int MemDataRedisClient::UpdateGroupState(int creatorID, int state, int activity_id)
{
	char key[255] = { 0 };
	char command[1024] = { 0 };

	snprintf(key, sizeof(key), "GROUP_USER_TABLE_STATE_%d", creatorID);
	LogMsg("%s:key [%s] state [%d] activity_id[%d]\n", __FUNCTION__, key, state, activity_id);
	VLogMsg(CLIB_LOG_LEV_INFO, "%s:key [%s] state [%d] activity_id[%d]\n",__FUNCTION__, key, state, activity_id);
	snprintf(command, sizeof(command), "HMSET %s %d %ld", key, activity_id, state);
	m_pRedisReply = RedisCommand(command);
	if (m_pRedisReply == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_ERROR, "CREATE Group[%d] Failed.Command[%s]", creatorID, command);
		return -1;
	}

	if (m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
	}
	return 0;
}

int MemDataRedisClient::GetUserInfoInCache(int uid,UserInfo & ui)
{
	char key[255] = {0};
	snprintf(key,sizeof(key),"MEMDATA_%d",uid);
	char command[1024] = {0};
	snprintf(command,sizeof(command),"HMGET %s MONEY EXP WIN LOST SCORE CHIPS ",key);
	m_pRedisReply = RedisCommand(command);
	int nret = 0;
	if (m_pRedisReply == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_INFO, "Get User[%d] Failed.Command[%s]", uid, command);
		return -1;
	}
	VLogMsg(CLIB_LOG_LEV_INFO, "Get User[%d] Successed.Command[%s]", uid, command);
	if (m_pRedisReply->type == REDIS_REPLY_ARRAY)
	{
		if (m_pRedisReply->elements != 6)
		{
			VLogMsg(CLIB_LOG_LEV_ERROR,"Get User[%d] Failed. Elements[%d]",uid,(int)m_pRedisReply->elements);
			nret = -1;
			goto RELEASE;
		}
		else
		{
			if (m_pRedisReply->element[0] != 0)
			{
				redisReply * rp = m_pRedisReply->element[0];
				if (rp->type == REDIS_REPLY_STRING)
				{
					ui.money = atol(rp->str);
				}
				else if(rp->type == REDIS_REPLY_INTEGER)
				{
					ui.money = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element Type[%d]", rp->type);
					nret = -1;
					goto RELEASE;
				}
			}
			else
			{
				VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element");
				nret = -1;
				goto RELEASE;
			}
			
			if (m_pRedisReply->element[1] != 0)
			{
				redisReply * rp = m_pRedisReply->element[1];
				if (rp->type == REDIS_REPLY_STRING)
				{
					ui.exp = atoi(rp->str);
				}
				else if(rp->type == REDIS_REPLY_INTEGER)
				{
					ui.exp = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element Type[%d]", rp->type);
					nret = -1;
					goto RELEASE;
				}
			}
			else
			{
				VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element");
				nret = -1;
				goto RELEASE;
			}
			
			if (m_pRedisReply->element[2] != 0)
			{
				redisReply * rp = m_pRedisReply->element[2];
				if (rp->type == REDIS_REPLY_STRING)
				{
					ui.win = atoi(rp->str);
				}
				else if(rp->type == REDIS_REPLY_INTEGER)
				{
					ui.win = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element Type[%d]", rp->type);
					nret = -1;
					goto RELEASE;
				}
			}
			else
			{
				VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element");
				nret = -1;
				goto RELEASE;
			}
			
			if (m_pRedisReply->element[3] != 0)
			{
				redisReply * rp = m_pRedisReply->element[3];
				if (rp->type == REDIS_REPLY_STRING)
				{
					ui.lose = atoi(rp->str);
				}
				else if(rp->type == REDIS_REPLY_INTEGER)
				{
					ui.lose = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element Type[%d]", rp->type);
					nret = -1;
					goto RELEASE;
				}
			}
			else
			{
				VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element");
				nret = -1;
				goto RELEASE;
			}

			if (m_pRedisReply->element[4] != 0)
			{
				redisReply * rp = m_pRedisReply->element[4];
				if (rp->type == REDIS_REPLY_STRING)
				{
					ui.score = atoi(rp->str);
				}
				else if(rp->type == REDIS_REPLY_INTEGER)
				{
					ui.score = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element Type[%d]", rp->type);
					nret = -1;
					goto RELEASE;
				}
			}
			else
			{
				VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element");
				nret = -1;
				goto RELEASE;
			}

			if (m_pRedisReply->element[5] != 0)
			{
				redisReply * rp = m_pRedisReply->element[5];
				if (rp->type == REDIS_REPLY_STRING)
				{
					ui.chips = atoi(rp->str);
				}
				else if (rp->type == REDIS_REPLY_INTEGER)
				{
					ui.chips = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element Type[%d]", rp->type);
					nret = -1;
					goto RELEASE;
				}
			}
			else
			{
				VLogMsg(CLIB_LOG_LEV_ERROR, "Invalid Element");
				nret = -1;
				goto RELEASE;
			}
		}
	}
	else
	{
		VLogMsg(CLIB_LOG_LEV_ERROR,"Get User[%d] Failed.Invalid Reply Type[%d]",uid,m_pRedisReply->type);
		nret = -1;
	}
	VLogMsg(CLIB_LOG_LEV_TRACE,"Get User[%d] Successed.Command[%s]",uid,command);
RELEASE:
	if(m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
	}
	return nret;
}


/*----------------------------- 房间列表 by neo -----------------------------------*/
int MemDataRedisClient::addTables(int level,int sid, int counts, int player_count, int game_type)
{
	char sMainKey[255] = { 0 };
	char command[1024] = { 0 };
	snprintf(sMainKey, sizeof(sMainKey), "TABLE_LIST_%d", level);
	VLogMsg(CLIB_LOG_LEV_INFO, "%s:key [%s] counts [%d] game_type[%d]\n", __FUNCTION__, sMainKey, counts, game_type);
	char sValue[128] = { 0 };
	for (int i = 0; i < player_count; i++)
	{
		if (i == 0)
			sprintf(sValue, "%s", "0");
		else
			sprintf(sValue, "%s,0", sValue);
	}

	for (int i = 0; i < counts; i ++)
	{
		int subKey = (sid << 16) + i;
		snprintf(command, sizeof(command), "HMSET %s %d %s", sMainKey, subKey, sValue);
		m_pRedisReply = RedisCommand(command);

		if (m_pRedisReply != NULL)
		{
			freeReplyObject(m_pRedisReply);
		}
	}
	return 0;
}

