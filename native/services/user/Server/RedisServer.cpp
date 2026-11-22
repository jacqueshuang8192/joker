#include "RedisServer.h"
#include <panel_redis.h>
#include "json.h"
#include "log.h"
#include "clib_log.h"
extern clib_log *g_pDebugLog;
extern clib_log *g_pErrorLog;
CRedisServer::CRedisServer()
{
	m_strIp = "";
	m_nPort = 0;
	m_pRedisConn = NULL;
	m_pRedisReply = NULL;
}

CRedisServer::~CRedisServer()
{
}

int CRedisServer::Connect(const string& ip, int port, string password)
{
//	printf("-------------------CRedisServer::connect = [%s] [%d]", ip.c_str(), port);//zswx
	//fflush(stdout);
	m_strIp = ip;
	m_nPort = port;
	m_password = password;
	m_pRedisConn = connectGameRedis(ip.c_str(), port, m_password.c_str());
	if (!m_pRedisConn || m_pRedisConn->err)
	{
		//ACE_DEBUG((LM_ERROR, ACE_TEXT("Connect Redis Server failed, ip:%s, port:%d\r\n"), ip.c_str(), port));
		return -1;
	}
	else
	{
		
	}
	
	return 0;
}

int CRedisServer::Reconnect()
{
	redisFree(m_pRedisConn);
	m_pRedisConn = connectGameRedis(m_strIp.c_str(), m_nPort, m_password.c_str());
	if (!m_pRedisConn || m_pRedisConn->err)
	{
		return -1;
	}

	return 0;
}

int CRedisServer::SetExpire(const char *key, int expire)
{
	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, "EXPIRE %s %d", key, expire));
	if (m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
	}
	else
	{
		//ACE_DEBUG((LM_INFO, ACE_TEXT("(%P|%t) SetExpire m_pRedisReply=NULL\r\n")));
	}
	return 0;
}

int CRedisServer::SetTimeout(struct timeval tv)
{
	if(m_pRedisConn!=NULL)
	{
		int ret = redisSetTimeout(m_pRedisConn,tv);
		return ret;
	}
	return REDIS_ERR;
}

redisReply * CRedisServer::RedisCommand(const char * command)
{
	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, command));
	if(m_pRedisReply == NULL) // lose connection , reconnect .
	{
		int ret = Reconnect();
		if(ret != 0)
		{
			return NULL;
		}
		else
		{
			m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn,command));
			if(m_pRedisReply == NULL)
			{
				return NULL;
			}
			else
			{
				return m_pRedisReply;
			}
		}
	}
	return m_pRedisReply;
}

redisReply * CRedisServer::RedisCommandArgv(vector<string> &v)
{
	vector<const char *> argv( v.size());
	int j = 0;
	for ( vector<string>::const_iterator i = v.begin(); i != v.end(); ++i,++j)
	{
   		argv[j] = i->c_str();
	}
	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommandArgv(m_pRedisConn,v.size(),&argv[0],NULL));
	if(m_pRedisReply == NULL) // lose connection , reconnect .
	{
		int ret = Reconnect();
		if(ret != 0)
		{
			return NULL;
		}
		else
		{
			m_pRedisReply = reinterpret_cast<redisReply*>(redisCommandArgv(m_pRedisConn,v.size(),&argv[0],NULL));
			if(m_pRedisReply == NULL)
			{
				return NULL;
			}
			else
			{
				return m_pRedisReply;
			}
		}
	}
	return m_pRedisReply;
}


int CRedisServer::SetUserStateInfo(int uid, int level,int tid,int ActicityId)
{
	/*char szMainKey2[32] = { 0 };
	char levelKey2[32] = { 0 };

	snprintf(szMainKey2, sizeof(szMainKey2), "USER_GAME_STATUS");
	sprintf(levelKey2, "%d_%d_%d", level, tid, ActicityId);
	g_pDebugLog->logMsg("[%s] line:%d ===>  uid[%d] level[%d] ActicityId[%d]", __FUNCTION__, __LINE__, uid, level, ActicityId);

	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, "HSET %s %d %s", szMainKey2, uid, levelKey2));
	if (m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
		
	}*/
	char szMainKey[32] = { 0 };
	char levelKey[32] = { 0 };

	snprintf(szMainKey, sizeof(szMainKey), "USER_ONLINE_GAME");
	sprintf(levelKey,"%d", level);
	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, "HSET %s %d %s", szMainKey, uid, levelKey));
	if (m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
		return 0;
	}
	return -1;

}
int CRedisServer::DelUserStateInfo(int uid,int level)
{
	//char szMainKey2[32] = { 0 };
	//char levelKey2[32] = { 0 };

	//snprintf(szMainKey2, sizeof(szMainKey2), "USER_GAME_STATUS");
	//sprintf(levelKey2, "%d_%d_%d", level, 0,0);
	//g_pDebugLog->logMsg("[%s] line:%d ===>  uid[%d]", __FUNCTION__, __LINE__, uid);
	//m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, "HSET %s %d %s", szMainKey2, uid, levelKey2));
	//if (m_pRedisReply != NULL)
	//{
	//	//	value = m_pRedisReply->str;
	//	freeReplyObject(m_pRedisReply);
	//	
	//}
	char szMainKey[32] = { 0 };
	char levelKey[32] = { 0 };

	snprintf(szMainKey, sizeof(szMainKey), "USER_ONLINE_GAME");
	sprintf(levelKey, "%d", 0);
	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, "HSET %s %d %s", szMainKey, uid, levelKey));
	if (m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
		return 0;
	}

	return -1;

}

/*------------------------ 更新桌子列表状态 neo ---------------------------*/
int CRedisServer::SetTableStatus(int level, int tid, vector<int> players, int game_type)
{
	char szMainKey[32] = { 0 };
	char strValue[128] = { 0 };

	snprintf(szMainKey, sizeof(szMainKey), "TABLE_LIST_%d",level);
	for (int i = 0; i < players.size(); i ++)
	{
		if (i == 0)
			sprintf(strValue, "%d", players[i]);
		else
			sprintf(strValue, "%s,%d", strValue, players[i]);
	}
	
	m_pRedisReply = reinterpret_cast<redisReply*>(redisCommand(m_pRedisConn, "HSET %s %d %s", szMainKey, tid, strValue));
	if (m_pRedisReply != NULL)
	{
		freeReplyObject(m_pRedisReply);
		return 0;
	}

	return -1;
}
