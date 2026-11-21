#pragma once
#include "ICHAT_PacketBase.h"
#include "ProcessFactory.h"
#include "global.h"
#include "DbPart.h"
#include "ICC_Timer_Handler.h"
#include "MemDataRedisClient.h"

class CClientHandler;

typedef map<int,CDbPart *>  DBMap;

struct ChipsData 
{
	int chips;
	int add_chips;
	int user_id;
	int activity_id;
};

class GameManager;
typedef struct _ThreadParam
{
	GameManager * pManager;
	vector<int> * pUidVect;
	_ThreadParam()
	{
		pManager = NULL;
		pUidVect = NULL;
	}
}ThreadParam;

typedef struct _ChipsDataParam
{
	GameManager * pManager;
	vector<ChipsData*>* pChipsVect;
	_ChipsDataParam()
	{
		pManager = NULL;
	}
}ChipsDataParam;

class GameManager:public CCTimer
{
	public:
		int m_svid;
		short m_gameID;
		int m_serverType;
		int m_UpdateInteval;
		ProcessFactory * m_pClientFactory;
		DBMap m_DBMap;
		MemDataRedisClient m_MemDataRedisClient;
		set<int> m_UpdateUidSet;
		vector<ChipsData*> m_UpdateChipsData;
		vector<int> m_TempUidVect;
		
	public:
		GameManager()
		{
			m_pClientFactory = NULL;
		}
		virtual ~GameManager()
		{
			if(m_pClientFactory){
				delete m_pClientFactory;
			}
		};
	public:
		virtual int ProcessClientPacket(CClientHandler * pHandler,NETInputPacket & input,int cmd){return 0;};	
		virtual void ProcessHandlerClose(CClientHandler * pHandler);
		virtual void Init(GameConfig & gc);
		virtual void AddUpdateUser(int uid);
		virtual void AddChipsData(int uid, int activity_id, int chips, int add_chips);
		virtual int ProcessOnTimerOut();
		virtual void ProcessUpdateRecord();
		int GetUserInfo(int uid,UserInfo & ui);		
		int UpdateUserInfo(int uid,const UserInfo & ui);
		int UpdateChipsInfo(ChipsData* chips_data);
		CDbPart* GetDbPart(int index);
};

