#include "RedisServer.h"
#include "global.h"
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
	m_strIp = ip;
	m_nPort = port;
	m_password = password;

	m_pRedisConn = redisConnect(ip.c_str(), port);
	if (m_pRedisConn->err)
	{
		//ACE_DEBUG((LM_ERROR, ACE_TEXT("Connect Redis Server failed, ip:%s, port:%d\r\n"), ip.c_str(), port));
		return -1;
	}
	else
	{
		VLogMsg(CLIB_LOG_LEV_DEBUG," Connect Redis Server success, ip:%s, port:%d", ip.c_str(), port);
	}

	if (m_password.length() > 0)
	{
		char szVal[25];
		sprintf(szVal, "AUTH %s", m_password.c_str());
		RedisCommand(szVal);
	}
	
	return 0;
}

int CRedisServer::Reconnect()
{
	redisFree(m_pRedisConn);
	m_pRedisConn = redisConnect(m_strIp.c_str(), m_nPort);
	if (m_pRedisConn->err)
	{
		return -1;
	}

	if (m_password.length() > 0)
	{
		char szVal[25];
		sprintf(szVal, "AUTH %s", m_password.c_str());
		RedisCommand(szVal);
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





