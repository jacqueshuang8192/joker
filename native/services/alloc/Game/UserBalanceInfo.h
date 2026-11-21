#ifndef USER_BALANCE_INFO_H
#define USER_BALANCE_INFO_H

#include "TimerOutEvent.h"
#include "ICHAT_Timer_Handler.h"
#include <string>
#include "Global.h"
using namespace std;
const int USER_AI_TIMER = 3;
class CGameServer;
class CUserBalanceInfo : public TimerOutEvent
{
public:
	CUserBalanceInfo();
	CUserBalanceInfo(CGameServer* pServer, int uid, int sex, string &nickname, string &portrait, int isRobot, string &longitude, string &latitude, string &ip, string& robot_config , int robot_startus, int club_id = 0,int chips = 0);
	~CUserBalanceInfo(void);
	int serverId;
	int m_uid;
	int m_sex;
	string m_nickname;
	string m_portrait;
	int isRobot;
	int m_chips;      //筹码数
	int m_turnBlc;    //单局结算结果
	int m_totalBlc;   //总结算结果
	string otherInfo;
	int m_tid;   //
	int club_id;
	string longitude;
	string ip;
	string latitude;
	int m_status;
	int is_game;
	int round;
	int m_level;
	int m_activityId;
	string robot_config;
	int m_thresholdRound;			//机器人到达局数后，需要达到赢钱阈值
	int m_thresholdTimes4Robots;	//机器人赢钱阈值倍数
	int m_robotSmartRate;			//机器人智能比率
	ICHAT_Timer_Handler m_autoTimer;
	
public:
	CGameServer *m_pGameServer;
public:
	void updateUserStatus(int status);
	void updateUserChips(int m_chips);
	void updateUserTableInfo(int isGame);
	void reset();
	int StartAutoTimer(int time =1);
	int StopAutoTimer()
	{
		m_autoTimer.StopTimer();

		return 0;
	}
private:
	//*********************************************/
	// Method:    ProcessOnTimerOut
	// Returns:   int
	// Parameter: int Timerid
	// Description: 用户的定时器事件
	//*********************************************/
	int ProcessOnTimerOut(int Timerid);
};

#endif // USER_BALANCE_INFO_H