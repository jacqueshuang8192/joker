#include "GameUser.h"
#include <time.h>

CGameUser::CGameUser(int uid, int svid, short status, short terminalType, int version, int updateTime)
{
	m_nUid = uid;
	m_nHallServerId = svid;
	m_nStatus = status;
	m_nTerminalType = terminalType;
	m_nVersion = version;
	m_nTid = 0;
	m_nServerLevel = -1;
	m_nUpdateTime = updateTime;
	m_onlookId = 0;
}


CGameUser::CGameUser() :
	m_nUid(0), m_nHallServerId(0), m_nStatus(0), m_nTerminalType(0), m_nVersion(0), m_nTid(0),m_onlookId(0),m_nServerLevel(-1), m_nUpdateTime(0)
{
	
}


CGameUser::~CGameUser(void)
{
}
