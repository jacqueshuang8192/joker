#pragma once
#include "ICHAT_PacketBase.h"
#include "ProcessFactory.h"
#include "UserManager.h"
#include "global.h"
#include "DbPart.h"
#include "MemDataRedisClient.h"
#include "LogClientHandler.h"
#include "UpdateClientHandler.h"

class CClientHandler;

class CGameUser;

typedef map<int,CDbPart *>  DBMap;
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

class GameManager{
	public:
		int m_svid;
		short m_gameID;
		int m_serverType;
		ProcessFactory * m_pClientFactory;
		DBMap m_DBMap;
		
	public:		
		CUserManager m_UserManager; 		//用户列表
	public:
		MemDataRedisClient m_RedisClient;
	public:
		LogClientHandler * m_pLogClient;
		UpdateClientHandler * m_pUpdateClient;
	public:
		GameManager()
		{
			m_pClientFactory = NULL;
			m_pLogClient = NULL;
			m_pUpdateClient = NULL;
		}
		virtual ~GameManager()
		{
			if(m_pClientFactory){
				delete m_pClientFactory;
			}
		}
	public:
		virtual int ProcessClientPacket(CClientHandler * pHandler,NETInputPacket & input,int cmd){return 0;};	
		virtual void ProcessHandlerClose(CClientHandler * pHandler);
		virtual void Init(GameConfig & gc);
	public:
		virtual int UpdateUserInfoInCache(CGameUser * pUser, const string & describe, int operationSource, string clientInfo);
		virtual int UpdateUserMoneyInCache(CGameUser * pUser,const string & describe,int operationSource,string clientInfo);
		virtual int UpdateUserChipsInCache(int userID, int activityID, int chips, int addchips);
		virtual int DeleteUserInCache(CGameUser * pUser);

		virtual int UpdateGroupState(int creatorID, int tableState, int activity_id);
		
		virtual CGameUser * GetUserInfoInCache(int Uid);
		void BuildPackage(NETOutputPacket* pOutPack, short nCmdType, const char* pszFmt, ...);
		CDbPart* GetDbPart(int index);

		//房间列表相关 neo
		int		addTables(int level,int sid, int counts, int player_count, int game_type);
};

