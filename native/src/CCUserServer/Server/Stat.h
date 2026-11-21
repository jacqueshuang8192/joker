#pragma once
#include "Singleton.h"
#include "noncopyable.h"
#include <map>

using namespace std;

typedef struct _DATAINFO
{
	int onlineCount;
	int onPlayCount;	
	int onLookerCount; //Count the onlookers by terminal type.
	_DATAINFO()
	{
		onlineCount = 0;
		onPlayCount = 0;
		onLookerCount = 0;
	}
}DATAINFO;

typedef struct _USERSTAT
{
	int terminalType;
	int tid;
}USERSTAT;

enum 
{
	TERMINAL_LOGINTABLE = 1,
	TERMINAL_LOGOUTTABLE = 2,
	TERMINAL_LOGINHALL = 3,
	TERMINAL_LOGOUTHALL = 4,
	TERMINAL_ONLOOKINTABLE = 5,
	TERMINAL_ONLOOKOUTTABLE = 6,
};

enum 
{
	LEVEL_LOGIN = 1,
	LEVEL_LOGOUT = 2,
};

class CStat : private noncopyable
{
public:
	map<short,DATAINFO> m_terminalStatMap;
	map<short, int> m_LevelMgr;
public:
	static CStat * Instance (void);
	int UserLoginHall(int uid,int terminalType,USERSTAT * preStat);
	int UserLogoutTable(int uid,int terminalType);
	int UserLogoutHall(int uid,int terminalType);
	int UserLoginTable(int uid,int terminalType);
	int UpdateTerminalInfo(int uid,int type,int terminalType,void * privatedata);
	int UpdateLevelInfo(int uid,int type,int level,void * privatedata);
	int UserOnLookIn(int uid, int terminal);
	int UserOnLookOut(int uid,int terminal);

	void PrintStatData();
	
private:
	//nocopyright.
};
