#include "GameUser.h"
#include <time.h>

CGameUser::CGameUser()
{
}

CGameUser::CGameUser(int nUserId, long int nMoney, int nExp, int nScore, int nWinTimes, int nLostTimes,int chips):
	m_nUserId(nUserId),
	m_nLMoney(nMoney),
	m_nExp(nExp),
	m_nScore(nScore),
	m_nWintimes(nWinTimes),
	m_nLosttimes(nLostTimes),
	m_chips(chips)
{	
	m_nTurnLMoney = 0;
	m_nTurnScore  = 0;
}
	
CGameUser::~CGameUser(void)
{
}

void CGameUser::UpdateInfo(int Money, int Exp, int Score, int Win, int Lost,int chips)
{
	m_nTurnLMoney = m_nLMoney;
	m_nLMoney += Money;
	m_nLMoney = m_nLMoney > 0 ? m_nLMoney : 0;
	m_nTurnLMoney = m_nLMoney - m_nTurnLMoney;
	m_nExp += Exp;
	m_nExp = m_nExp > 0 ? m_nExp : 0;
	m_nTurnScore = m_nScore;
	m_nScore += Score;
	m_nScore = m_nScore>0 ? m_nScore : 0;
	m_nTurnScore = m_nScore - m_nTurnScore;
	m_nWintimes += Win;
	m_nWintimes = m_nWintimes > 0 ? m_nWintimes : 0;
	m_nLosttimes += Lost;
	m_nLosttimes = m_nLosttimes > 0 ? m_nLosttimes : 0;
	m_chips += chips;
	m_chips = m_chips > 0 ? m_chips : 0;
}
