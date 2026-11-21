#ifndef __INCOMING_H__
#define __INCOMING_H__

#include <global.h>
#include <noncopyable.h>
#include <stdint.h>
#include <poller.h>
#include <timerlist.h>
#include "RedisClient.h"

HTTP_SVR_NS_BEGIN

class CListener;
class CIncoming : private noncopyable
{
public: //method
    CIncoming (void);
    virtual ~CIncoming (void);
    static CIncoming* Instance (void);
    static void Destroy (void);
    int open (void);
    int run (void);
	int InitHelperUnit();
    CTimerList * GetTimeList(int timeout);
    
private: //property
    CPollerUnit*    _pollerunit;
    CListener*      _listener;
    CTimerUnit*     _timerunit;
    CTimerList*     _webtimerlist;    
    CTimerList*     _helpertimerlist;    
    int             _epwaittimeout;
public:
	RedisConf m_MonitorRedisConf;
	CRedisClient m_MonitorRedis;
	std::string m_datestring;
};

HTTP_SVR_NS_END

#endif //__INCOMING_H__

