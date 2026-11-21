#ifndef __GAME_TABLE_H
#define __GAME_TABLE_H
#include <string>
#include "UserBalanceInfo.h"
#include "LogicServer.h"
#include "TimerOutEvent.h"
#include "ICHAT_Timer_Handler.h"
#include <iostream>
using std::string;
#include <vector>
using std::vector;
const int TABLE_AI_TIMER = 1;
const int TABLE_AI_TIMER_ADD = 2;
class CGameServer;
class CGameTable : public TimerOutEvent
{
public:
	CGameTable(int tid, short svid, short level,int club_id);
	~CGameTable();
public:
	int max_plaery_count;
	int user_add_count;
	string jsonConfig;
	map<int, string> userList;
	long    numTable;
	int		m_nTid;
	short	m_nServerId;
	short	m_nLevel;
	short	m_nUserCount;
	int		m_nOwnerUid;
	int		m_nRoomType;
	string	m_strRoomName;
	unsigned char 	m_bDirtyRoomName;
	string	m_strPassword;
	int		m_nBaseChip;
	int     m_nIsLoveGirl;
	int     m_nRoomIndex;  //·????÷òyo?
	int     m_needChips;  //·????÷òyo?
	string  m_nLoveGirlStr; //°???àéí·??
	int     m_nCreateTime; 
	string	m_strInviteCode;//组局邀请码
	int	m_activityID;//组局活动id
	int		m_nLiftTime;//持续时间
	CLogicServer* m_pServer;
	int currRound;
	int club_id;
	int isStart;
	int gameType;
	int configId;
	string groupName;
	int joinGamePoint;
	int readyPoint;
	int groupType;  //积分还是房卡  2 是积分 3 是房卡
	int totalRound;
	int typeTable; //是否是是假桌子
	ICHAT_Timer_Handler m_autoTableTimer;
	vector<CUserBalanceInfo *> listBakanceInfo;
public:
	int StartAutoTimer(int time = 1);
	int StopAutoTimer()
	{
		m_autoTableTimer.StopTimer();

		return 0;
	}
public:
	CGameServer *m_pGameServer;
private:
	//*********************************************/
	// Method:    ProcessOnTimerOut
	// Returns:   int
	// Parameter: int Timerid
	// Description: 用户的定时器事件
	//*********************************************/
	int ProcessOnTimerOut(int Timerid);
	int addCurrRound();
};
#endif
