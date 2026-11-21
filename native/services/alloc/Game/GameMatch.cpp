#include "GameMatch.h"

CGameMatch::CGameMatch(int svid,int matchID)
{
    m_nCurrentNum= 0;
    m_nServerId = svid;
    m_nMatchId = matchID;
    m_nCreateTime = time(NULL);
    m_nIndex = -1;
    m_nTotal = 0;

}

CGameMatch::~CGameMatch()
{}
