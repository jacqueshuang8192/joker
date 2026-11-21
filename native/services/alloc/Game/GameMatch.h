#ifndef _GAME_MATCH_H_
#define _GAME_MATCH_H_

#include "LogicServer.h"
class CGameMatch
{
public:
	CGameMatch(int svid,int matchID);
	~CGameMatch();
	
public:
	short	m_nCurrentNum;	//当前比赛场有多少人
	short	m_nServerId;	//比赛场属于哪个server
	int 	m_nMatchId;		// match的id

	int     m_nRoomUid;    //房主ID 
	int     m_nCreateTime;
	int     m_nIndex;
	int     m_nRoomType; //1个人赛 2企业赛
	int     m_nTotal;
	string  m_nName;
	string  m_nPassWord;
	int     m_nStatus;
};
#endif

