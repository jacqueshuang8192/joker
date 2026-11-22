#include "GameTable.h"
#include "GameServer.h"
CGameTable::CGameTable(int tid, short svid, short level, int club_id_v)
{
	typeTable = 0;
	user_add_count = 0;
	numTable = 0;
	currRound = 0;
	m_nTid = tid;
	m_nServerId = svid;
	m_nLevel = level;
	m_nUserCount = 0;
	m_nOwnerUid = 0;
	m_nRoomType = 0;
	m_strRoomName = "";
	m_bDirtyRoomName = 0;
	m_strPassword = "";
	m_nBaseChip = 0;
    m_nIsLoveGirl = 0;
    m_nLoveGirlStr = "";
    m_nCreateTime = 0;
    m_pServer = NULL;
	max_plaery_count = 0;
	jsonConfig = "";
	userList.clear();
	club_id = club_id_v;
	isStart = 0;
	gameType = -1;
	configId = -1;
	joinGamePoint = 0;
	readyPoint = 0;
	listBakanceInfo.clear();
	m_autoTableTimer.SetTimeEventObj(this, TABLE_AI_TIMER_ADD);
	totalRound = 0;
}

CGameTable::~CGameTable()
{
}
int CGameTable::ProcessOnTimerOut(int Timerid)
{
	switch (Timerid)
	{
	case TABLE_AI_TIMER_ADD:
		this->addCurrRound();
		break;
	default:
		break;
	}

	return 0;
}
int CGameTable::StartAutoTimer(int time)
{

	//g_pDebugLog->logMsg("StartAutoTimer-time[%d]", time);
	m_autoTableTimer.StartTimer(1,time);

	return 0;
}
int CGameTable::addCurrRound()
{
	currRound++;
	if (currRound > totalRound) {
		return 0;
	}
	if (currRound == totalRound) {
		this->StopAutoTimer();
		for (int i = 0; i < listBakanceInfo.size(); i++)
		{
			listBakanceInfo[i]->reset();

		}
		m_pGameServer->closeTableTemp(this);
		m_pGameServer->clearTidbleInfo(m_nTid);
		/*for (map<int, TableList>::iterator itre = m_pGameServer->tableTempList.begin(); itre != m_pGameServer->tableTempList.end();itre++) {
			if (itre->second.find(m_nTid) != itre->second.end()) {
				itre->second.erase(itre->second.find(m_nTid));
				break;
			}
		}*/
		
		/*if (m_pGameServer->tableTempList.find(m_nTid) != m_pGameServer->tableTempList.end()) {
			m_pGameServer->tableTempList.erase(m_pGameServer->tableTempList.find(m_nTid));
		}*/
		
	}
	else {
		m_pGameServer->sendRound(this);
	}
	return 0;
}