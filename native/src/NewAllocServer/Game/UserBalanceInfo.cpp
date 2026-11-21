#include "UserBalanceInfo.h"
#include "GameServer.h"

CUserBalanceInfo::CUserBalanceInfo(CGameServer* pServer, int uid, int sex, string& nickname, string& portrait,int isRobot, string& longitude, string& latitude, string& ip, string& robot_config,int robot_startus, int club_id,int chips)
{
	this->m_uid = uid;
	this->m_sex = sex;
	this->m_nickname = nickname.c_str();
	this->m_portrait = portrait.c_str();
	this->isRobot = isRobot;
	this->m_turnBlc = 0;
	this->m_totalBlc = 0;
	this->m_chips = chips;
	Json::Reader reader;
	Json::FastWriter fastWriter;
	Json::Value uInfJson;
	uInfJson["longitude"] = longitude;
	uInfJson["latitude"] = latitude;
	uInfJson["ip"] = ip;
	string configT = fastWriter.write(uInfJson);
	this->otherInfo = configT;
	this->m_tid = 0;
	this->club_id = club_id;
	this->latitude = latitude;
	this->longitude = longitude;
	this->ip = ip;
	this->m_status = 0;
	this->is_game = 0;
	this->round = 0;
	this->m_activityId = 0;
	this->robot_config = robot_config;
	this->m_pGameServer = pServer;
	this->serverId = 0;
	this->m_level = 0;
	m_autoTimer.SetTimeEventObj(this, USER_AI_TIMER);
}
CUserBalanceInfo::CUserBalanceInfo() {

}
CUserBalanceInfo::~CUserBalanceInfo(void)
{
}
void CUserBalanceInfo::updateUserStatus(int status) {
	this->m_status = status;
}
void CUserBalanceInfo::updateUserChips(int m_chips) {
	this->m_chips = m_chips;
}
void CUserBalanceInfo::updateUserTableInfo(int isGame) {
	this->is_game = isGame;
}
int CUserBalanceInfo::ProcessOnTimerOut(int Timerid)
{
	switch (Timerid)
	{
	case USER_AI_TIMER: {
		this->StopAutoTimer();
		m_pGameServer->ProcessRobot(this);
		break;
	}
	default:
		break;
	}

	return 0;
}
int CUserBalanceInfo::StartAutoTimer(int time)
{
	
	g_pDebugLog->logMsg("StartAutoTimer-time[%d]", time);
	m_autoTimer.StartTimer(time);

	return 0;
}
void CUserBalanceInfo::reset() {
	m_tid = 0;
	m_activityId = 0;
	m_status = 0;
	serverId = 0;
}