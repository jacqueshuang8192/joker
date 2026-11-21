#include "Stat.h"
#include "myglobal.h"

#include "Global.h"
#include "Options.h"
#include "clib_log.h"
extern clib_log *g_pDebugLog;
extern clib_log *g_pErrorLog;


CStat * CStat::Instance()
{
	return CSingleton<CStat>::Instance();
}

int CStat::UserLoginHall(int uid,int terminalType ,USERSTAT * preStat)
{ 
	if(preStat == NULL)
	{
		//new user login
		DATAINFO & statinfo = m_terminalStatMap[terminalType];
		statinfo.onlineCount ++;
		LogMsg("User[UID:%d,TERM:%d] Login Hall,Now Stat Info [ONLINE:%d,PLAY:%d]",uid,terminalType,statinfo.onlineCount,statinfo.onPlayCount);
	}
	else
	{
		//reload.
		DATAINFO & statinfo = m_terminalStatMap[preStat->terminalType];
		DATAINFO & newstatinfo = m_terminalStatMap[terminalType];
		if(preStat->terminalType != terminalType)
		{
			
			if(preStat->tid != 0 && statinfo.onPlayCount > 0)
			{
				statinfo.onPlayCount--;
				//tid不为0时
				//先在新的终端统计中加上.
				newstatinfo.onPlayCount++;
			}
			if(statinfo.onlineCount > 0)
			{
				statinfo.onlineCount--;
			}
			newstatinfo.onlineCount++;
		}
		else
		{
			//重新在相同的终端登录.
		}
		LogMsg("User[UID:%d,TERM:%d] Re Load Hall,Now Stat Info [ONLINE:%d,PLAY:%d],Pre Stat Info[TERM:%d,TID:%d]",\
			uid,terminalType,newstatinfo.onlineCount,newstatinfo.onPlayCount,preStat->terminalType,preStat->tid);
	}
	return 0;
}

int CStat::UserOnLookIn(int uid, int terminal)
{
	DATAINFO & statinfo = m_terminalStatMap[terminal];
	statinfo.onLookerCount++;
	LogMsg("User[UID:%d,TERM:%d] Onlook IN,Now Stat Info [ONLINE:%d,PLAY:%d,ONLOOK:%d]",uid,terminal,statinfo.onlineCount,statinfo.onPlayCount,statinfo.onLookerCount);
	return 0;
}

int CStat::UserOnLookOut(int uid, int terminal)
{
	DATAINFO & statinfo = m_terminalStatMap[terminal];
	if(statinfo.onLookerCount)
		statinfo.onLookerCount--;
	LogMsg("User[UID:%d,TERM:%d] Onlook OUT,Now Stat Info [ONLINE:%d,PLAY:%d,ONLOOK:%d]",uid,terminal,statinfo.onlineCount,statinfo.onPlayCount,statinfo.onLookerCount);
	return 0;
}


int CStat::UserLogoutHall(int uid,int terminalType)
{
	DATAINFO & statinfo = m_terminalStatMap[terminalType];
	if(statinfo.onlineCount> 0)
	{
		statinfo.onlineCount--;
	}
	LogMsg("User[UID:%d,TERM:%d] Logout Hall,Now Stat Info [ONLINE:%d,PLAY:%d]",uid,terminalType,statinfo.onlineCount,statinfo.onPlayCount);
	return 0;
}

int CStat::UserLogoutTable(int uid,int terminalType)
{
	DATAINFO & statinfo = m_terminalStatMap[terminalType];
	if(statinfo.onPlayCount> 0)
	{
		statinfo.onPlayCount--;
	}
	LogMsg("User[UID:%d,TERM:%d] Logout Table,Now Stat Info [ONLINE:%d,PLAY:%d]",uid,terminalType,statinfo.onlineCount,statinfo.onPlayCount);
	return 0;
}



int CStat::UserLoginTable(int uid,int terminalType)
{
	DATAINFO & statinfo = m_terminalStatMap[terminalType];
	statinfo.onPlayCount++;
	LogMsg("User[UID:%d,TERM:%d] Login Table,Now Stat Info [ONLINE:%d,PLAY:%d]",uid,terminalType,statinfo.onlineCount,statinfo.onPlayCount);

	//Options::instance()->m_RedisServer->SetInfo()
	return 0;
}

int CStat::UpdateTerminalInfo(int uid,int type,int terminalType,void * privatedata)
{
	
	switch(type)
	{
		case TERMINAL_LOGINHALL:
		{
			USERSTAT * preStat = NULL;
			if(privatedata != NULL)
			{
				preStat = (USERSTAT *)privatedata;
			}
			UserLoginHall(uid,terminalType ,preStat);
			break;
		}
		case TERMINAL_LOGOUTHALL:
		{
			UserLogoutHall(uid,terminalType);
			break;
		}
		case TERMINAL_LOGINTABLE:
		{
			UserLoginTable(uid,terminalType);
			break;
		}
		case TERMINAL_LOGOUTTABLE:
		{
			UserLogoutTable(uid,terminalType);
			break;
		}
		case TERMINAL_ONLOOKINTABLE:
		{
			UserOnLookIn(uid,terminalType);
			break;
		}
		case TERMINAL_ONLOOKOUTTABLE:
		{
			UserOnLookOut(uid,terminalType);
			break;
		}
	}
//	PrintStatData();
	return 0;
}
int CStat::UpdateLevelInfo(int uid,int type,int level,void * privatedata)
{
	switch(type)
	{
		case LEVEL_LOGIN:
		{
			map<short,int>::iterator iterLevel = m_LevelMgr.find(level);
			if(iterLevel != m_LevelMgr.end())
			{
				int& count = iterLevel->second;
				count++;
				LogMsg("Add User[UID:%d] To Level[%d],now count:%d",uid,level,count);
			}
			else
			{
				m_LevelMgr.insert(pair<short, int>(level, 1));
				LogMsg("Add User[UID:%d] To New Level[%d]",uid,level);
			}
			break;
		}
		case LEVEL_LOGOUT:
		{
			map<short, int>::iterator iterLevel = m_LevelMgr.find(level);
			if(iterLevel != m_LevelMgr.end())
			{
				int& count = iterLevel->second;
				if(count > 0)
					count--;
				LogMsg("Remove User[UID:%d] from Level[%d],now count:%d",uid,level,count);
			}
			else
			{
				LogMsg("Remove User[UID:%d] from Level[%d] which not exist",uid,level);
			}
			break;
		}
	}

//	PrintStatData();
	return 0;
}

void CStat::PrintStatData()
{
	map<short,DATAINFO>::iterator it1 = m_terminalStatMap.begin();
	for(; it1 != m_terminalStatMap.end(); it1++)
	{
		DATAINFO	&data = it1->second;
		DebugMsg("terminal[%d] OnlineCount[%d] PlayeCount[%d]", it1->first, data.onlineCount, data.onPlayCount);
	}

	map<short, int>::iterator it2 = m_LevelMgr.begin();
	for(; it2 != m_LevelMgr.end(); it2++)
	{
		DebugMsg("Level[%d] LevelCount[%d] ", it2->first, it2->second);	
	}
}

