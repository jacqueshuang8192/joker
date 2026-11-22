#pragma once

#include "global.h"

class CGameUser
{
public:
	CGameUser();
	CGameUser(int nUserId, long int nMoney, int nExp, int nScore, int nWinTimes, int nLostTimes, int chips);
	~CGameUser(void);
	void UpdateInfo(int Money, int Exp, int Score, int Win, int Lost, int chips);

	string getStrMoney()
	{
    	char buf[32]={0};
    	string strMoney;
    	snprintf(buf,sizeof(buf),"%ld",m_nLMoney);
    	strMoney = buf;
    	return strMoney;
	}
public:
	int			 m_nUserId;			 //ÓÃ»§ID
    //int			 m_nMoney;           //ÓÃ»§Ç®±Ò
    long int  	 m_nLMoney;
    int          m_nExp;             //ÓÃ»§¾­Ñé
    int 		 m_nScore;			 //积分
    int			 m_nWintimes;        //ÓÃ»§Ó®µÄ¾ÖÊý
    int			 m_nLosttimes;       //ÓÃ»§ÊäµÄ¾ÖÊý
    unsigned int m_nUpdatetime;      //¸üÐÂÊ±¼ä
	//int          m_nTurnMoney;       //¸üÐÂÊ±µÄÇ®Êý
	long int 	 m_nTurnLMoney;
    int          m_nTurnScore;       //积分变化值
	int			 m_chips;			//筹码
	int			 m_addchips;			//增加筹码
	int			 m_activityID;			//组局活动id
};

