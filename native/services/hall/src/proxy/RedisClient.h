#ifndef __REDIS_CLIENT_H__
#define __REDIS_CLIENT_H__

#include <string>
#include <iostream>
#include "hiredis.h"
#include "log.h"

#define  MAX_COMMAND_LEN  (1024)

#define FREE_REPLY(x) do{\
if (NULL != x)\
	freeReplyObject(x); \
	x = NULL; \
}while (0)


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
        InitConnection(m_strIP,m_nPort);\
        return -1;\
    }\
}while(0)

#define RECORD_NOT_EXIST -100


typedef struct _RedisConf
{
	char ip[32];
	int  port;
	_RedisConf()
	{
		memset(this, 0, sizeof(_RedisConf));
	}
}RedisConf;

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

        void Attach(redisContext *redis, const char* ip, short port){
            m_redis = redis;
            strncpy(m_strIP, ip, sizeof(m_strIP)-1);
            m_nPort = port;
        }
        void Detach()
        {
            m_redis=NULL;
            m_reply = NULL;
            memset(m_strIP,0,sizeof(m_strIP));
            m_nPort = 0;
        }
        bool IsConnect()
        {
            return (m_redis!=NULL);
        }

        int InitConnection(const char* strIP,unsigned short nPort)
        {
            if(m_redis != NULL)
            {
                free(m_redis);
                m_redis = NULL;
            }
            memcpy(m_strIP,strIP,strlen(strIP));
            m_nPort = nPort;
            m_redis = redisConnect(strIP,nPort);

            if (m_redis->err)	
            {
                return -1;
            }
            return 0;
        }

        // <0 err, =0  NULL,  >0 len 
        int Get(string& strReply, const char* format,...)
        {
            strReply = "";
            VA_COMMAND_REPLY();		
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_STRING && m_reply->str != NULL)
            {
                strReply.assign(m_reply->str,m_reply->len);
                int len=m_reply->len;
                FREE_REPLY_RETURN(len);
            }

            log_debug("get reply info,type:%d,integer:%d", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
                log_error("strlen:%d\n", m_reply->len);

            FREE_REPLY_RETURN(-1);
        }

        int GetInteger(int  &replyvalue, const char * format,...)
        {
            replyvalue=0;
            VA_COMMAND_REPLY();
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);
            if((int)m_reply->type == REDIS_REPLY_INTEGER)
            {
                replyvalue=(int)m_reply->integer;
                FREE_REPLY_RETURN(0);
            }
            else if((int)m_reply->type == REDIS_REPLY_STRING)
            {
                replyvalue=atoi(m_reply->str);
                FREE_REPLY_RETURN(0);
            }
            log_debug("GetInteger reply info,type:%d,integer:%d", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
                log_error("strlen:%d\n", m_reply->len);
            FREE_REPLY_RETURN(-1);
        }

        // <0 err,  =0  NULL,  >0 len 
        int Get(char* buf,unsigned int buflen,unsigned int& strlength, const char* format,...)
        {
            memset(buf,0,buflen);
            VA_COMMAND_REPLY();		
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_STRING && m_reply->str != NULL)
            {
                if((int)buflen<m_reply->len)
                {
                    log_error("get binary reply info, buf len over flow ,buflen=%d,replay_len=%d", buflen,m_reply->len);
                    FREE_REPLY_RETURN(-1);
                }
                memcpy(buf,m_reply->str,m_reply->len);
                strlength=m_reply->len;
                FREE_REPLY_RETURN(strlength);
            }

            log_debug("get reply info,type:%d,integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
                log_error("strlen:%d\n", m_reply->len);

            FREE_REPLY_RETURN(-1);
        }
        /*
           int MGet(std::map<string,string>& vctReply, std::vector<string>& vctKey)
           {

           if(vctKey.size() > 100)
           return -1;

           char byCmd[1024]={0};
           snprintf(byCmd,sizeof(byCmd)-1,"mget", 4);
           for(unsigned i=0; i<vctKey.size(); i++)
           {
           snprintf(byCmd+strlen(byCmd),sizeof(byCmd)-strlen(byCmd)-1," %b", vctKey[i].data(), vctKey[i].size());	
           }


           va_list ap;
           va_start(ap,format);
           m_reply = reinterpret_cast<redisReply*>(redisvCommand(m_redis,format,ap));
           va_end(ap);
           if(m_reply == NULL)
           {
           InitConnection(m_strIP,m_nPort);
           return -1;
           }

           if((int)m_reply->type == REDIS_REPLY_ARRAY)
           {
           for(unsigned i=0; i<m_reply->elements; i++)
           {
           if(m_reply->element[i].type == REDIS_REPLY_STRING && m_reply->element[i].str != NULL)
           {

           }
           }
           strReply.assign(m_reply->str,m_reply->len);
           FREE_REPLY_RETURN(0);

           }
           FREE_REPLY_RETURN(-1);
           }
           */
        //call Set SMEMBERS

		int HKeys(std::vector<string>& vctReply, const char* format, ...)
        {
            VA_COMMAND_REPLY();	
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_ARRAY)
            {
                string strTmp;
                for (unsigned int i=0; i<m_reply->elements; i++)
                {
                    strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
                    vctReply.push_back(strTmp);
                }
                int ret = m_reply->elements;
                FREE_REPLY_RETURN(ret);
            }

            log_debug("SGet reply info,type:%d,integer:%d", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
                log_error("strlen:%d\n", m_reply->len);

            FREE_REPLY_RETURN(-1);
        }
		
        int SGet(std::vector<string>& vctReply, const char* format, ...)
        {
            VA_COMMAND_REPLY();	
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_ARRAY)
            {
                string strTmp;
                for (unsigned int i=0; i<m_reply->elements; i++)
                {
                    strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
                    vctReply.push_back(strTmp);
                }
                int ret = m_reply->elements;
                FREE_REPLY_RETURN(ret);
            }

            log_debug("SGet reply info,type:%d,integer:%d", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
                log_debug("strlen:%d\n", m_reply->len);

            FREE_REPLY_RETURN(-1);
        }

        int Set(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_STATUS && (strncmp(m_reply->str,"OK",2) == 0))
            {
                FREE_REPLY_RETURN(0);			
            }

            FREE_REPLY_RETURN(-1);			
        }


		int HGET(char* key, char* field, char* buf, int buf_len)
		{
			char c_command[MAX_COMMAND_LEN] = { 0 };
			int ret = 0;
			memset(buf, 0, buf_len);
			snprintf(c_command, sizeof(c_command)-1, "HGET %s %s", key, field);
			m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

			if (m_reply != NULL && m_reply->type == REDIS_REPLY_STRING)
			{
				if (buf_len < m_reply->len)
				{
					//ACE_DEBUG((LM_ERROR, ACE_TEXT("HGET  buflen=%d,replay_len=%d"), buf_len,m_reply->len));
				}
				memcpy(buf, m_reply->str, m_reply->len);
				ret = m_reply->len;
			}
			else if (m_reply != NULL && m_reply->type == REDIS_REPLY_ERROR)
			{
				//ACE_DEBUG((LM_ERROR, ACE_TEXT("Request Redis ERR.Command[%s] \n"), c_command));	
			}

			FREE_REPLY(m_reply);
			return ret;
		}

        int HGet(string& strReply, const char* format,...)
        {
            strReply = "";
            VA_COMMAND_REPLY();		
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_STRING && m_reply->str != NULL)
            {
                strReply.assign(m_reply->str,m_reply->len);
                int len = m_reply->len;
                FREE_REPLY_RETURN(len);   //返回value长度
            }

            log_debug("HGet reply info,type:%d,integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
            {
                if((int)m_reply->type == REDIS_REPLY_ERROR)
                    log_error("err_code:%s \n", m_reply->str);	
                else
                    log_debug("strlen:%d \n", m_reply->len);
            }

            FREE_REPLY_RETURN(-1);
        }


        int HGet(char* buf, int buflen, const char* format,...)
        {
            memset(buf,0,buflen);
            VA_COMMAND_REPLY();		
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_STRING && m_reply->str != NULL)
            {
                if(buflen<m_reply->len)
                {
                    log_error("get binary reply info, buf len over flow ,buflen=%d,replay_len=%d", buflen,m_reply->len);
                    FREE_REPLY_RETURN(-1);
                }
                memcpy(buf,m_reply->str,m_reply->len);
                int len = m_reply->len;
                FREE_REPLY_RETURN(len);  //返回value长度
            }

            FREE_REPLY_RETURN(-1);
        }

		int SMEMBERS(std::vector<string>& vctReply, const char* key)
		{
			char c_command[MAX_COMMAND_LEN] = { 0 };
			int ret = 0;
			snprintf(c_command, sizeof(c_command)-1, "SMEMBERS %s", key);
			m_reply = reinterpret_cast<redisReply*>(redisCommand(m_redis, c_command));

			if (m_reply->type == REDIS_REPLY_NIL)
			{
				FREE_REPLY_RETURN(0);
			}

			if (m_reply->type == REDIS_REPLY_ARRAY)
			{
				string strTmp;
				for (int i = 0; i<m_reply->elements; i++)
				{
					if ((m_reply->element[i]->type != REDIS_REPLY_NIL) && (m_reply->element[i]->len > 0))
					{
						strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
						vctReply.push_back(strTmp);
					}	
				}
				int ret = m_reply->elements;

				FREE_REPLY_RETURN(ret);
			}

			log_debug("Smembers:return reply info,type:%d,integer:%d, ", m_reply->type, m_reply->integer);
			FREE_REPLY_RETURN(-1);
		}

        int SADD(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER)
            {
                int ret = (int)m_reply->integer;
                FREE_REPLY_RETURN(ret);			
            }

            FREE_REPLY_RETURN(-1);	
        }

        int SREM(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER)
            {
                int ret = (int)m_reply->integer;
                FREE_REPLY_RETURN(ret);			
            }
            log_debug("SREM reply info, type:%d, integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
            {
                if((int)m_reply->type == REDIS_REPLY_ERROR)
                    log_error("err_code:%s \n", m_reply->str);	
                else
                    log_debug("strlen:%d \n", m_reply->len);
            }

            FREE_REPLY_RETURN(-1);	
        }

        int HSet(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER  && ((int)m_reply->integer==0 || (int)m_reply->integer==1) )
            {
                FREE_REPLY_RETURN(0);			
            }

            FREE_REPLY_RETURN(-1);	
        }

        int HMGet(char* buf, int buflen, const char* format,...)
        {
            memset(buf,0,buflen);
            VA_COMMAND_REPLY();		
            if((int)m_reply->type == REDIS_REPLY_NIL)
                FREE_REPLY_RETURN(0);

            if((int)m_reply->type == REDIS_REPLY_ARRAY)
            {
                if(buflen<m_reply->len)
                {
                    log_error("get binary reply info, buf len over flow ,buflen=%d,replay_len=%d", buflen,m_reply->len);
                    FREE_REPLY_RETURN(-1);
                }
                memcpy(buf,m_reply->str,m_reply->len);
                int len = m_reply->len;
                FREE_REPLY_RETURN(len);  //返回value长度
            }

            log_debug("HMGet reply info,type:%d,integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
            {
                if((int)m_reply->type == REDIS_REPLY_ERROR)
                    log_error("err_code:%s \n", m_reply->str);	
                else
                    log_debug("strlen:%d \n", m_reply->len);
            }

            FREE_REPLY_RETURN(-1);
        }

        int HMGet(std::vector<string>& vctReply, const char* format, ...)
        {
            VA_COMMAND_REPLY();
            if(m_reply->type == REDIS_REPLY_NIL)
            {
                //log_error("HMGet:return value = NULL \n");
                FREE_REPLY_RETURN(0);
            }

            if(m_reply->type == REDIS_REPLY_ARRAY)
            {
                string strTmp;
                for (unsigned i=0; i<m_reply->elements; i++)
                {
                    if((m_reply->element[i]->type != REDIS_REPLY_NIL)  && (m_reply->element[i]->len > 0))
                        strTmp.assign(m_reply->element[i]->str, m_reply->element[i]->len);
                    else
                        strTmp = "";

                    vctReply.push_back(strTmp);
                }
                int ret = m_reply->elements;
                //log_debug("HMGet:return value = %d and ret = %d\n", m_reply->type,ret);
                FREE_REPLY_RETURN(ret);
            }

            log_debug("HMGet reply info,type:%d,integer:%lld,", m_reply->type, m_reply->integer);
            if(m_reply != NULL)
            {
                if(m_reply->type == REDIS_REPLY_ERROR)
                {
                    log_error("err_code:%s \n", m_reply->str);
                }
                else
                {
                    log_debug("strlen:%d \n", m_reply->len);
                }
            }

            FREE_REPLY_RETURN(-1);
        }

        int  HMSET(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_STATUS && (strncmp(m_reply->str,"OK",2) == 0))
            {
                FREE_REPLY_RETURN(0);			
            }
            log_debug("HMSET reply info, type:%d, integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
            {
                if((int)m_reply->type == REDIS_REPLY_ERROR)
                    log_error("err_code:%s \n", m_reply->str);	
                else
                    log_debug("strlen:%d \n", m_reply->len);
            }	
            FREE_REPLY_RETURN(-1);	
        }

		int INCR(const char* format, ...)
		{
			VA_COMMAND_REPLY();

			if ((int)m_reply->type == REDIS_REPLY_INTEGER)
			{
				FREE_REPLY_RETURN(0);
			}
			FREE_REPLY_RETURN(-1);
		}

        int Ttl(unsigned& nExpire, const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER)
            {
                nExpire = (int)m_reply->integer;
                FREE_REPLY_RETURN(0);			
            }

            log_debug("ttl reply info,type:%d,integer:%d, ", (int)m_reply->type, (int)m_reply->integer);

            if(m_reply != NULL)
                log_debug("strlen:%d\n", m_reply->len);
            FREE_REPLY_RETURN(-1);			
        }


        int Del(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER && ((int)m_reply->integer == 1||(int)m_reply->integer == 0))
            {
                FREE_REPLY_RETURN(0);			
            }
           log_debug("del reply info,type:%d,integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
            {
                log_error("strlen:%d\n", m_reply->len);
            }
            FREE_REPLY_RETURN(-1);			
        }

        int Expire(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER && (int)m_reply->integer == 1)
            {
                FREE_REPLY_RETURN(0);			
            }

            FREE_REPLY_RETURN(-1);			
        }

        int Exists(const char* format,...)
        {
            VA_COMMAND_REPLY();

            if((int)m_reply->type == REDIS_REPLY_INTEGER )
            {
                int ret=(int)m_reply->integer;
                FREE_REPLY_RETURN(ret);			
            }
            log_debug("exists reply info,type:%d,integer:%d, ", (int)m_reply->type, (int)m_reply->integer);
            if(m_reply != NULL)
                log_debug("strlen:%d\n", m_reply->len);
            FREE_REPLY_RETURN(-1);			
        }


    private:
        char m_strIP[16];
        unsigned short m_nPort;
        redisContext *m_redis;				
        redisReply *m_reply;		
        unsigned int m_error;
};

#if 0
int main()
{
    CRedisClient test;
    if(test.InitConnection("127.0.0.1", 6795))
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

