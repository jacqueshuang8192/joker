#ifndef __LOGIC_SERVER_H
#define __LOGIC_SERVER_H

#include "TimerOutEvent.h"
#include "ICHAT_Timer_Handler.h"
#include "BaseServer.h"
#include <string>
using std::string;
#include <map>
using std::map;

class CGameTable;
class SocketHandler;

class CLogicServer : public TimerOutEvent
{
public:
	CLogicServer(short serverId, int userCount, int tableCount, short level, SocketHandler *pHandler, CBaseServer* pBaseServer);
	~CLogicServer(void);
	CGameTable* GetTable(int tid);
public:
	int ResetLogicServer();
	
	int ProcessOnTimerOut(int timerId);
	void StartCheckCoreTimer();
	void StopCheckCoreTimer();

	void AddLoveTable(int tid);
	void RemoveLoveTable(int tid);
public:
    int	m_nMatchCount;
	short m_nServerId;
	string m_strIp;
	int m_nPort;
	int m_nUserCount;
	int m_nTableCount;
	short m_nRetire;
	short m_nLevel;
	SocketHandler *m_pSocketHandler;
	map<int, CGameTable*> m_TableList;
	map<int, CGameTable*> m_TableLoveGirlList;
	ICHAT_Timer_Handler m_CheckCoreTimer;
	CBaseServer* m_pBaseServer;
	int m_nServerType;//区分3人场，4人场

	int m_nCreateTime;

};
#endif
