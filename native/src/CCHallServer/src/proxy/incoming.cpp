#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <incoming.h>
#include <memcheck.h>
#include <listener.h>
#include <config.h>
#include <log.h>
#include <Singleton.h>
#include <MarkupSTL.h>
#include <helper_unit.h>
#include <string>
using std::string;
#include <CHelper_pool.h>

#include <sstream>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include "Logic.h"

HTTP_SVR_NS_BEGIN


extern std::map<int,CHelperPool *> _helperpoolMap;

CIncoming::CIncoming (void) :
_pollerunit (NULL),
_listener (NULL),
_timerunit (NULL),
_webtimerlist (NULL),
_helpertimerlist (NULL),
_epwaittimeout (1000)
{  
}

CIncoming::~CIncoming (void) 
{
    DELETE (_timerunit);
    DELETE (_listener);
    DELETE (_pollerunit);
}

CIncoming* CIncoming::Instance (void)
{
    return CSingleton<CIncoming>::Instance ();
}

void CIncoming::Destroy (void)
{
    return CSingleton<CIncoming>::Destroy ();
}

int CIncoming::open (void)
{ 
    //create poller unit
    NEW (CPollerUnit(TGlobal::_maxpoller), _pollerunit);

    if (NULL == _pollerunit)
    {
        log_boot ("create CPollerUnit object failed.");

        return -1;
    }

    //create listener
    NEW (CListener(TGlobal::_addr, TGlobal::_port, MAX_ACCEPT_COUNT), _listener);

    if (NULL == _listener)
    {
        log_boot ("create CListener object failed.");

        return -1;
    }

    //create CTimerUnit object
    NEW (CTimerUnit(), _timerunit);
    if (NULL == _timerunit)
    {
        log_boot ("create CTimerUnit object failed.");
        return -1;
    }

    //create web timer list
    _webtimerlist = _timerunit->GetTimerList (TGlobal::_webtimeout);
	
    if (NULL == _webtimerlist)
    {
        log_boot ("create web CTimerList object failed.");
        return -1;
    }

    _helpertimerlist = _timerunit->GetTimerList (TGlobal::_helpertimeout);

    if (NULL == _helpertimerlist)
    {
        log_boot ("create helper CTimerList object failed.");
        return -1;
    }
           
    //init poller unit
    if(_pollerunit->InitializePollerUnit() < 0)
    {
        log_boot ("poller unit init failed.");
      	return -1;
    }
    
    //attach decoder unit
    if (_listener->Attach (_pollerunit, _webtimerlist, _helpertimerlist, TGlobal::_backlog) < 0)
    {
        log_boot ("invoke CListener::Attach() failed.");
        return -1;
    }

	//init hall connect logic server
	if(InitHelperUnit() < 0)
	{
		log_boot ("InitHelperUnit failed.");
        return -1;
	}
    return 0;

}

CTimerList * CIncoming::GetTimeList(int timeout)
{
	return _timerunit->GetTimerList (timeout);
}

int CIncoming::InitHelperUnit()
{
	CMarkupSTL  markup;
    if(!markup.Load("../conf/server.xml"))
    {       
        log_error("Load server.xml failed.");
        return -1;
    }

    if(!markup.FindElem("SYSTEM"))
    {
        log_error("Can not FindElem [SYSTEM] in server.xml failed.");
        return -1;
    }

	if (!markup.IntoElem())    
	{        
		log_error ("IntoElem [SYSTEM] failed.");       
		return -1;    
	}
	
	while(markup.FindElem("Node"))
	{
		if (!markup.IntoElem())    
		{        
			log_error ("IntoElem failed.");       
			return -1;    
		}
		
		CHelperPool * hp = new CHelperPool();

		if(!markup.FindElem("GameID"))
		{
			log_error ("IntoElem [RegionID] failed.");     
			return -1;
		}
		
		hp->m_GameId = atoi(markup.GetAttrib("gameID").c_str());

		log_boot("Game Id:[%d]", hp->m_GameId);
		
		if(!markup.FindElem("ServerList"))
		{
			log_error ("IntoElem [ServerList] failed.");     
			return -1; 
		}
		
		if (!markup.IntoElem())    
		{        
			log_error ("IntoElem [ServerList] failed.");       
			return -1;    
		}
		
		while(markup.FindElem("Server"))
		{
			int svid =  atoi(markup.GetAttrib("svid").c_str());
			int level = atoi(markup.GetAttrib("level").c_str());
			string ip = markup.GetAttrib("ip");
			int port = atoi(markup.GetAttrib("port").c_str());
			CHelperUnit *pHelperUnit = NULL;
			map<int, CHelperUnit*>::iterator iter = hp->m_helpermap.find(svid);
			if(iter != hp->m_helpermap.end())
			{
				pHelperUnit = iter->second;
			}
			else
			{
				pHelperUnit = new CHelperUnit(_pollerunit,hp);
				hp->m_helpermap[svid] = pHelperUnit;
			}
			
			if(pHelperUnit == NULL)
			{
				log_boot("pHelperUnit NULL");
				return -1;
			}	

			hp->m_svidlist.push_back(svid);
			
			pHelperUnit->addr = ip;
			pHelperUnit->port = port;

			vector<int>& v = hp->m_levelmap[level];
			v.push_back(svid);
		
			log_boot("alloc server id:[%d], level:[%d], ip:[%s], port:[%d]", svid, level, ip.c_str(), port);
		}

		if(markup.FindElem("BroadCastServer"))
		{
			string ip = markup.GetAttrib("ip");
			int port = atoi(markup.GetAttrib("port").c_str());

			CHelperUnit *pBroadcastUnit = new CHelperUnit(_pollerunit,hp);
			pBroadcastUnit->addr = ip;
			pBroadcastUnit->port = port;
			hp->m_pBroadcastUnit = pBroadcastUnit;
			log_boot("broadcast server ip:[%s], port:[%d]", ip.c_str(), port);
		}

		if(markup.FindElem("MatchManagerServer"))
		{
			string ip = markup.GetAttrib("ip");
			int port = atoi(markup.GetAttrib("port").c_str());

			CHelperUnit *pMatchManager = new CHelperUnit(_pollerunit,hp);
			pMatchManager->addr = ip;
			pMatchManager->port = port;
			hp->m_pMatchManager = pMatchManager;
			log_boot("pMatchManager server ip:[%s], port:[%d]", ip.c_str(), port);

			pMatchManager->RegesterHall(_helpertimerlist);
		}


		if (markup.FindElem("FriendServer"))
		{
			string ip = markup.GetAttrib("ip");
			int port = atoi(markup.GetAttrib("port").c_str());

			CHelperUnit *pFriendUnit = new CHelperUnit(_pollerunit, hp);
			pFriendUnit->addr = ip;
			pFriendUnit->port = port;
			hp->m_pFriendUnit = pFriendUnit;
			log_boot("friend server ip:[%s], port:[%d]", ip.c_str(), port);
		}

		if (markup.FindElem("monitor_redis"))
		{
			std::string ip = markup.GetAttrib("ip");
			int port = atoi(markup.GetAttrib("port").c_str());
			snprintf(m_MonitorRedisConf.ip, 30, "%s", ip.c_str());
			m_MonitorRedisConf.port = port;

			if (-1 == m_MonitorRedis.InitConnection(m_MonitorRedisConf.ip, m_MonitorRedisConf.port))
			{
				log_boot("connect to monitor_redis [%s,%d] error", m_MonitorRedisConf.ip, m_MonitorRedisConf.port);
				return -1;
			}
			log_boot("monitor_redis ip:[%s], port:[%d]", ip.c_str(), port);
			time_t curtime = time(NULL);
			this->m_datestring = CLogic::GetDateString(curtime).c_str();
		}


		if (!markup.OutOfElem())    
		{        
			log_error ("OutOfElem [ServerList] failed.");       
			return -1;    
		}
		
		
		if (!markup.OutOfElem())
		{
			log_error ("OutOfElem [Node] failed.");
			return -1;
		}
		_helperpoolMap[hp->m_GameId] = hp;
	}
	return 0;
}


int CIncoming::run (void)
{
    while(!(*(TGlobal::_module_close)))
    {
        _pollerunit->WaitPollerEvents (_timerunit->ExpireMicroSeconds(_epwaittimeout));
        uint64_t now = GET_TIMESTAMP();
        _pollerunit->ProcessPollerEvents();
        _timerunit->CheckExpired (now);
        _timerunit->CheckPending ();
    }

    return 0;
}
HTTP_SVR_NS_END

