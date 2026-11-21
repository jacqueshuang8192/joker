#include "MemDataRedisClient.h"

int MemDataRedisClient::GetUserInfoInCache(int uid,UserInfo & ui)
{
	char key[255] = {0};
	snprintf(key,sizeof(key),"MEMDATA_%d",uid);
	char command[1024] = {0};
	snprintf(command,sizeof(command),"HMGET %s MONEY EXP WIN LOST SCORE CHIPS",key);
	m_pRedisReply = RedisCommand(command);
	int nret = 0;
	if (m_pRedisReply == NULL)
	{
		VLogMsg(CLIB_LOG_LEV_ERROR,"Get User[%d] Failed.Command[%s]",uid,command);
		return -1;
	}
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
					VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element Type");
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
					VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element Type");
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
					VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element Type");
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
					VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element Type");
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
					VLogMsg(CLIB_LOG_LEV_ERROR,"Invalid Element Type");
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
					ui.chip = atoi(rp->str);
				}
				else if (rp->type == REDIS_REPLY_INTEGER)
				{
					ui.chip = rp->integer;
				}
				else
				{
					VLogMsg(CLIB_LOG_LEV_ERROR, "chip Invalid Element Type");
					nret = -1;
					goto RELEASE;
				}
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

