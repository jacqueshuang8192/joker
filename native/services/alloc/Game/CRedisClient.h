#ifndef __REDIS_CLIENT_H__
#define __REDIS_CLIENT_H__

#include <string>
#include <panel_redis.h>
#include <vector>
#include <iostream>
#include "hiredis.h"

#include "clib_log.h"
extern clib_log *g_pDebugLog;
#define  MAX_COMMAND_LEN  (131072)

#define FREE_REPLY(x) do{\
	if(NULL != x)\
		freeReplyObject(x);\
	x = NULL;\
}while(0)

#define FREE_REPLY_RETURN(x) do{\
	freeReplyObject(m_reply);\
	m_reply = NULL;\
	return x;\
}while(0)

#define VA_COMMAND_REPLY() do{\
		va_list ap;\
		va_start(ap,format);\
		m_reply = reinterpret_cast<redisReply*>(redisvCommand(m_redis,format,ap));\
		va_end(ap);\
		if(m_reply == NULL){\
			Connect(m_strIP,m_nPort,m_password);\
			return -1;\
		}\
}while(0)

#define RECORD_NOT_EXIST -100


// typedef struct _RedisConf
// {
// 	char ip[32];
// 	int  port;
// 	_RedisConf()
// 	{
// 		memset(this, 0, sizeof(ip));
// 	}
// }RedisConf;

using namespace std;
class CRedisClient
{
public:
	CRedisClient(){
		m_redis=NULL; 
		m_reply=NULL;
		m_error=0;
		memset(m_strIP,0,sizeof(m_strIP));
	};
	~CRedisClient(){
		if(m_reply!=NULL)
			freeReplyObject(m_reply);
		if(m_redis!=NULL)
			free(m_redis);
	}

	int Connect(const char* strIP, unsigned short nPort, string password)
	{
		//printf("-------------------Redis::connect = [%s] [%d]", strIP, nPort); //zswx
		//fflush(stdout);
		if(m_redis != NULL)
		{
			free(m_redis);
			m_redis = NULL;
		}
		memcpy(m_strIP,strIP,strlen(strIP));
		m_nPort = nPort;
		m_password = password;
		m_redis = connectGameRedis(strIP,nPort, m_password.c_str());

		if (!m_redis || m_redis->err)	
		{
			g_pDebugLog->logMsg("Connect_Redis ip=%s, port=%d, ERR!! \n", m_strIP, m_nPort);
		
			return -1;
		}

		g_pDebugLog->logMsg("Connect_Redis ip=%s, port=%d, Success!!  \n", m_strIP, m_nPort);
		return 0;
	}

	int Reconnect()
	{
		redisFree(m_redis);
		m_redis = connectGameRedis(m_strIP, m_nPort, m_password.c_str());
		if (!m_redis || m_redis->err)
		{
			g_pDebugLog->logMsg("[%d]Reconnect_Redis ip=%s, port=%d, ERR!! \n", m_strIP, m_nPort);
			return -1;
		}

		g_pDebugLog->logMsg("Reconnect_Redis ip=%s, port=%d, Success!!  \n", m_strIP, m_nPort);
		

		return 0;
	}
	int RedisCommandChips(const char * command) {
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, command));

		if (m_reply == NULL) // lose connection , reconnect .
		{
			int ret = Reconnect();
			if (ret != 0)
			{
				
				return -1;
			}
			else
			{
				m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, command));
				if (m_reply == NULL)
				{
					
					return -1;
				}
				else
				{
					FREE_REPLY(m_reply);
					return 0;
				}
			}
		}
		FREE_REPLY(m_reply);
		return 0;
	}
	int GET_SISMEMBER_REDIS(char* key, int findUid) {
		char c_command[1024] = { 0 };
		int ret = -1;

		snprintf(c_command, sizeof(c_command) - 1, "SISMEMBER %s %d", key,findUid);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

		if (m_reply != NULL && m_reply->integer > 0)
		{
			g_pDebugLog->logMsg("GET_SISMEMBER_REDIS:%d,integer:%d\n", m_reply->type, m_reply->integer);
			ret = 1;
		}
		else
		{
			ret = 0;
			g_pDebugLog->logMsg("GET_SISMEMBER_REDIS:%d,integer:%d\n", m_reply->type, m_reply->integer);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	int GET_SISMEMBER_USER_REDIS(char* key) {
		char c_command[1024] = { 0 };
		int ret = -1;

		snprintf(c_command, sizeof(c_command) - 1, "EXISTS %s", key);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

		if (m_reply != NULL && m_reply->integer > 0)
		{
			g_pDebugLog->logMsg("GET_SISMEMBER_USER_REDIS:%d,integer:%d\n", m_reply->type, m_reply->integer);
			ret = 1;
		}
		else
		{
			ret = 0;
			g_pDebugLog->logMsg("GET_SISMEMBER_USER_REDIS:%d,integer:%d\n", m_reply->type, m_reply->integer);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	int HGET_USER_CHIPS(char* key, char* field, string &buf)
	{
		char c_command[1024] = { 0 };
		int ret = -1;

		snprintf(c_command, sizeof(c_command) - 1, "HGET %s %s", key, field);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING && m_reply->len > 0)
		{
			buf = std::string(m_reply->str, m_reply->str + m_reply->len);
			ret = m_reply->len;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("HGET_USER_CHIPS:%d,integer:%d\n", m_reply->type, m_reply->integer);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	redisReply* RedisCommand(const char * command)
	{
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, command));

		if(m_reply == NULL) // lose connection , reconnect .
		{
			int ret = Reconnect();
			if(ret != 0)
			{
				return NULL;
			}
			else
			{
				m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,command));
				if(m_reply == NULL)
				{
					return NULL;
				}
				else
				{
					return m_reply;
				}
			}
		}
		return m_reply;
	}

	redisReply* RedisCommandLPUSH(const char * key, const char * value)
	{
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, "LPUSH %s %s", key, value));

		if(m_reply == NULL) // lose connection , reconnect .
		{
			int ret = Reconnect();
			if(ret != 0)
			{
				return NULL;
			}
			else
			{
				m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, "LPUSH %s %s", key, value));
				if(m_reply == NULL)
				{
					return NULL;
				}
				else
				{
					return m_reply;
				}
			}
		}
		return m_reply;
	}
	redisReply* RedisCommandRPUSH(const char * key, const char * value)
	{
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, "RPUSH %s %s", key, value));

		if (m_reply == NULL) // lose connection , reconnect .
		{
			int ret = Reconnect();
			if (ret != 0)
			{
				return NULL;
			}
			else
			{
				m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, "RPUSH %s %s", key, value));
				if (m_reply == NULL)
				{
					return NULL;
				}
				else
				{
					return m_reply;
				}
			}
		}
		return m_reply;
	}
	int Get(string& strReply, const char* format,...)
	{
		strReply = "";
		VA_COMMAND_REPLY();		
		if(m_reply->type == REDIS_REPLY_NIL)
			FREE_REPLY_RETURN(0);
		
		if(m_reply->type == REDIS_REPLY_STRING && m_reply->str != NULL)
		{
			strReply.assign(m_reply->str,m_reply->len);
			FREE_REPLY_RETURN(0);
		}
		g_pDebugLog->logMsg("get reply info,type:%d,integer:%d\n", m_reply->type, m_reply->integer);
		if(m_reply != NULL)
			g_pDebugLog->logMsg("strlen:%d\n", m_reply->len);
		
		FREE_REPLY_RETURN(-1);
	}

	int Get(char* buf,unsigned int buflen,unsigned int& strlength, const char* format,...)
	{
		memset(buf,0,buflen);
		VA_COMMAND_REPLY();		
		if(m_reply->type == REDIS_REPLY_NIL)
			FREE_REPLY_RETURN(0);
		
		if(m_reply->type == REDIS_REPLY_STRING && m_reply->str != NULL)
		{
			if(buflen<m_reply->len)
			{
				g_pDebugLog->logMsg("get binary reply info, buf len over flow ,buflen=%d,replay_len=%d", buflen, m_reply->len);
				FREE_REPLY_RETURN(0);
			}
			memcpy(buf,m_reply->str,m_reply->len);
			strlength=m_reply->len;
			FREE_REPLY_RETURN(0);
		}
		g_pDebugLog->logMsg("get reply info,type:%d,integer:%d", m_reply->type, m_reply->integer);
		if(m_reply != NULL)
			g_pDebugLog->logMsg("strlen:%d\n", m_reply->len);
		FREE_REPLY_RETURN(-1);
	}
	int GET(char* key , char* buf, int buf_len)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		memset(buf, 0, buf_len);
		snprintf(c_command, sizeof(c_command)-1,"GET %s ",key);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING)
		{
			if(buf_len<m_reply->len)
			{
				g_pDebugLog->logMsg("GET  buflen=%d,replay_len=%d", buf_len, m_reply->len);

			}
			memcpy(buf, m_reply->str, m_reply->len);
			ret = m_reply->len; 
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}
        
		FREE_REPLY(m_reply);
		return ret;
	}

	int HGET(char* key, char* field, char* buf, int buf_len)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		memset(buf, 0, buf_len);
		snprintf(c_command, sizeof(c_command)-1,"HGET %s %s", key, field);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING)
		{
			if(buf_len<m_reply->len)
			{
				g_pDebugLog->logMsg("HGET  buflen=%d,replay_len=%d", buf_len, m_reply->len);
			}
			memcpy(buf, m_reply->str, m_reply->len);
			ret = m_reply->len; 
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	
	int HGET_ROBOT_STATUS(char* key, char* field, string &buf)
	{
		char c_command[MAX_COMMAND_LEN] = { 0 };
		int ret = 0;

		snprintf(c_command, sizeof(c_command) - 1, "HGET %s %s", key, field);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING && m_reply->len > 0)
		{
			buf = std::string(m_reply->str, m_reply->str + m_reply->len);
			ret = m_reply->len;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	int HSET_USER_STATUS(int uid, int level, int tid, int activityId) {
		char szMainKey2[32] = { 0 };
		char levelKey2[32] = { 0 };
		int ret = -1;
		snprintf(szMainKey2, sizeof(szMainKey2), "USER_GAME_STATUS");
		sprintf(levelKey2, "%d_%d_%d", level, tid, activityId);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, "HSET %s %d %s", szMainKey2, uid, levelKey2));
		if (m_reply != NULL)
		{
			ret = 1;
			//freeReplyObject(m_reply);
			//return 1;
		}
		FREE_REPLY(m_reply);
		return ret;
	}
	int HSET(char* key, char* field, char* value)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		snprintf(c_command, sizeof(c_command)-1,"HSET %s %s %s ", key, field, value);

		m_reply = RedisCommand(c_command);
		if (m_reply == NULL)
		{
			g_pDebugLog->logMsg("%s Failed.Command[%s]", __FUNCTION__, c_command);
			return -1;
		}
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_INTEGER)
		{
			ret = m_reply->integer; 
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
			ret = -1;
		}
		FREE_REPLY(m_reply);
		return ret;
	}

	int SADD(char* key, char* member)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		snprintf(c_command, sizeof(c_command)-1,"SADD %s %s ", key, member);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_INTEGER)
		{
			ret = m_reply->integer; 
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}
		FREE_REPLY(m_reply);
		return ret;
	}
	int LPUSH(char* key , char* value)
	{
		int ret = 0;

		m_reply = RedisCommandLPUSH(key, value);
		if (m_reply == NULL)
		{
			g_pDebugLog->logMsg("%s Failed.Command", __FUNCTION__);
			return -1;
		}
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_INTEGER)
		{
			ret = m_reply->integer; 
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command \n");
			ret = -1;
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	int RPUSH(char* key, char* value)
	{
		int ret = 0;

		m_reply = RedisCommandRPUSH(key, value);
		if (m_reply == NULL)
		{
			g_pDebugLog->logMsg("%s Failed.Command", __FUNCTION__);
			return -1;
		}
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_INTEGER)
		{
			ret = m_reply->integer;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command \n");
			ret = -1;
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	/*int LPUSH(char* key, char* value)
	{
		char c_command[MAX_COMMAND_LEN] = { 0 };
		int ret = 0;
		snprintf(c_command, sizeof(c_command) - 1, "LPUSH %s %s", key, value);

		m_reply = RedisCommand(c_command);
		if (m_reply == NULL)
		{
			VLogMsg(LM_ERROR, "%s Failed.Command[%s]", __FUNCTION__, c_command);
			return -1;
		}
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_INTEGER)
		{
			ret = m_reply->integer;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			ACE_DEBUG((LM_ERROR, ACE_TEXT("Request Redis ERR.Command[%s] \n"), c_command));
			ret = -1;
		}

		FREE_REPLY(m_reply);
		return ret;
	}*/
	int LPOP(char* key , char* buf, int buf_len)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		snprintf(c_command, sizeof(c_command)-1,"LPOP %s ",key);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING)
		{
			if(buf_len<m_reply->len)
			{
				g_pDebugLog->logMsg("LPOP ,buflen=%d,replay_len=%d", buf_len, m_reply->len);

			}
			memcpy(buf, m_reply->str, m_reply->len);
			ret = m_reply->len; 
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
    int HINCRBY(char* key, char* field, int increment)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		snprintf(c_command, sizeof(c_command)-1,"HINCRBY %s %s %d", key, field, increment);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));
		FREE_REPLY(m_reply);
		return ret;
	}
	int DEL(char* key)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		snprintf(c_command, sizeof(c_command)-1,"DEL %s ",key);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));
		FREE_REPLY(m_reply);
		return ret;
	}
    int KEYS(char* pattern, std::vector<string>& vctReply)
	{
		char c_command[MAX_COMMAND_LEN] = {0};
		int ret = 0;
		snprintf(c_command, sizeof(c_command)-1,"KEYS %s ", pattern);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis,c_command));
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_ARRAY)
		{
			string strTmp;
			for (int i=0; i<m_reply->elements; i++)
			{
				if((m_reply->element[i]->type != REDIS_REPLY_NIL)  && (m_reply->element[i]->len > 0))
					strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
				else
					strTmp = "";
                
				if(!strTmp.empty())
					vctReply.push_back(strTmp);
			}
			ret = m_reply->elements;
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	int HAGETALLNEW(std::vector<string>& vctReply, const char* pattern,...) {
		char c_command[1024] = { 0 };
		int ret = -1;

		snprintf(c_command, sizeof(c_command) - 1, "HGET %s", pattern);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING && m_reply->len > 0)
		{
			g_pDebugLog->logMsg("config===:%s\n", m_reply->str);

			ret = m_reply->len;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("HGET_USER_CHIPS:%d,integer:%d\n", m_reply->type, m_reply->integer);
		}
		FREE_REPLY(m_reply);
		return 1;
	}
	int HGETALL(char* pattern, std::vector<string>& vctReply)
	{
		char c_command[MAX_COMMAND_LEN] = { 0 };
		int ret = 0;
		snprintf(c_command, sizeof(c_command) - 1, "HGETALL %s ", pattern);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_ARRAY)
		{
			string strTmp;
			for (int i = 0; i<m_reply->elements; i++)
			{
				if ((m_reply->element[i]->type != REDIS_REPLY_NIL) && (m_reply->element[i]->len > 0)) 
					strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
				else
					strTmp = "";
				if (!strTmp.empty())
					vctReply.push_back(strTmp);
			}
			ret = m_reply->elements;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}
		//freeReplyObject(m_reply);
		FREE_REPLY(m_reply);
		return ret;
	}
	int HKEYS(char* pattern, std::vector<string>& vctReply)
	{
		char c_command[MAX_COMMAND_LEN] = { 0 };
		int ret = 0;
		snprintf(c_command, sizeof(c_command) - 1, "HKEYS %s ", pattern);
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));
		if (m_reply != NULL && m_reply->type == REDIS_REPLY_ARRAY)
		{
			string strTmp;
			for (int i = 0; i<m_reply->elements; i++)
			{
				
				if ((m_reply->element[i]->type != REDIS_REPLY_NIL) && (m_reply->element[i]->len > 0))
					strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
				else
					strTmp = "";

				if (!strTmp.empty())
					vctReply.push_back(strTmp);
			}
			ret = m_reply->elements;
		}
		else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
			g_pDebugLog->logMsg("Request Redis ERR.Command[%s] \n", c_command);
		}

		FREE_REPLY(m_reply);
		return ret;
	}
	int HMGet(std::vector<string>& vctReply, const char* format, ...)
    {
        VA_COMMAND_REPLY();
        if(m_reply->type == REDIS_REPLY_NIL)
        {
            FREE_REPLY_RETURN(0);
        }

        if(m_reply->type == REDIS_REPLY_ARRAY)
        {
            string strTmp;
            for (int i=0; i<m_reply->elements; i++)
            {
                if((m_reply->element[i]->type != REDIS_REPLY_NIL)  && (m_reply->element[i]->len > 0))
                    strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
                else
                    strTmp = "";

                vctReply.push_back(strTmp);
            }
            int ret = m_reply->elements;
            FREE_REPLY_RETURN(ret);
        }

        if(m_reply != NULL)
        {
            if(m_reply->type == REDIS_REPLY_ERROR)
				g_pDebugLog->logMsg("err_code:%s \n", m_reply->str);
            else
				g_pDebugLog->logMsg("strlen:%d \n", m_reply->len);
        }

        FREE_REPLY_RETURN(-1);
    }

	int Set(const char* format,...)
	{
		VA_COMMAND_REPLY();

		if(m_reply->type == REDIS_REPLY_STATUS && (strncmp(m_reply->str,"OK",2) == 0))
		{
			FREE_REPLY_RETURN(0);			
		}
		g_pDebugLog->logMsg("set reply info, type:%d, integer:%d,\n", m_reply->type, m_reply->integer);
		if(m_reply != NULL)
		{
			if(m_reply->type == REDIS_REPLY_ERROR)
				g_pDebugLog->logMsg("err_code:%s \n", m_reply->str);
			else
				g_pDebugLog->logMsg("strlen:%d \n", m_reply->len);
		}	
		FREE_REPLY_RETURN(-1);			
	}
  
	int HSet(const char* format,...)
	{
		VA_COMMAND_REPLY();

		if(m_reply->type == REDIS_REPLY_INTEGER  && (m_reply->integer==0 || m_reply->integer==1) )
		{
			FREE_REPLY_RETURN(0);			
		}
		if(m_reply != NULL)
		{
			if(m_reply->type == REDIS_REPLY_ERROR)
				g_pDebugLog->logMsg("err_code:%s \n", m_reply->str);
			else
				g_pDebugLog->logMsg("strlen:%d \n", m_reply->len);
		}
		
		FREE_REPLY_RETURN(-1);	
	}

	int Ttl(unsigned& nExpire, const char* format,...)
	{
		VA_COMMAND_REPLY();

		if(m_reply->type == REDIS_REPLY_INTEGER)
		{
			nExpire = m_reply->integer;
			FREE_REPLY_RETURN(0);			
		}
		if(m_reply != NULL)
			g_pDebugLog->logMsg("strlen:%d \n", m_reply->len);
		FREE_REPLY_RETURN(-1);			
	}

	
	int Del(const char* format,...)
	{
		VA_COMMAND_REPLY();

		if(m_reply->type == REDIS_REPLY_INTEGER && (m_reply->integer == 1||m_reply->integer == 0))
		{
			FREE_REPLY_RETURN(0);			
		}
		if(m_reply != NULL)
		{
		}
		FREE_REPLY_RETURN(-1);			
	}
	
	int Expire(const char* format,...)
	{
		VA_COMMAND_REPLY();

		if(m_reply->type == REDIS_REPLY_INTEGER && m_reply->integer == 1)
		{
			FREE_REPLY_RETURN(0);			
		}
		if(m_reply != NULL)
		FREE_REPLY_RETURN(-1);			
	}

    int PING()
	{
		char c_command[MAX_COMMAND_LEN] = "PING";
		m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

		if (m_reply != NULL && m_reply->type == REDIS_REPLY_STATUS)
		{
			FREE_REPLY(m_reply);
			return 0;
		}
		else if(m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
		{
		}
		FREE_REPLY(m_reply);
        Reconnect();
		return -1;
	}
	
private:
	char m_strIP[100];
	unsigned short m_nPort;
	string m_password;
	redisContext *m_redis;				
	redisReply *m_reply;		
	unsigned int m_error;
};

#if 0
int main()
{
	CRedisClient test;
	if(test.Connect("127.0.0.1", 6795))
	{
		cout << "redis connect error:" << std::endl;
		return -1;
	}
	int a=21598725;
	string s;
	s.assign((char*)&a,sizeof(a));
	s[0]=' '; s[1]='\n';s[2]='*';s[3]='$';
	if(test.Set("Set %b %b", s.data(),s.size(),s.data(),s.size() ))
	{
		cout << "set reply error" << endl;
		//return -2;
	}	
    test.Expire("Expire %b %d", s.data(),s.size(),16577);
    sleep(2);
    unsigned int nExpire;
    test.Ttl(nExpire, "TTL %b", s.data(), s.size());
    cout << "expire time:" << nExpire <<endl; 

	if(test.Get(s, "Get %d", a ))
	{
		cout << "get reply error" << endl;
		//return -2;
	}
	cout << "reply:" << s << "size:" << s.size() << endl;

	if(test.Set("Set %b %b", s.data(),s.size(),s.data(),s.size() ))
	{
		cout << "set reply error" << endl;
		//return -2;
	}	

	//sleep(10);
	if(test.Get(s, "Get %b", s.data(),s.size() ))
	{
		cout << "get reply error" << endl;
		//return -2;
	}
	cout << "reply:" << s << "size:" << s.size() << endl;

	return 0;
}
#endif
#endif

