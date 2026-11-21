#ifndef __GAME_GROUP_H__
#define __GAME_GROUP_H__

#include <noncopyable.h>
#include <GameTable.h>
#include <GameServer.h>

#include <string>
using std::string;

extern bool Less_ServerUserCount(const SERVERINFO &s1, const SERVERINFO &s2);

const int CREATE_GROUP_TABLE_HAVE_BEEN_EXIST = -4;
const int CREATE_GROUP_TABLE_EXCHANGE_CHIP_FAILED = -3;
const int CREATE_GROUP_TABLE_DIFFERENT_LEVEL = -2;
const int CREATE_GROUP_TABLE_BASE_CHIP_NOT_EXIST = -1;
const int CREATE_GROUP_TABLE_SUCCESS = 0;

const int MONEY2CHIPS_EXCHANGE_RATE = 1200;
const int CHIPS2MONEY_EXCHANGE_RATE = 1000;

class GameGroup : private noncopyable
{
public:
	GameGroup() {};
	~GameGroup() {};
	
	string backServerRequest;
	string backServerCancelGroupRequest;
	string backServerUrl;
	map<int, int> userHallsvidMap;//userid,hall svid
	string costCardRequest;
	string A2IcreateFreeGame;
	int backServerPort;

	string divideMoneyRequest;

	static GameGroup* Instance(void);
	static void Destroy(void);
	bool initTableInfo(CGameTable* pTable,int uid, short userCount, int roomType, int baseChip, string password, string roomName, \
		int isLoveGirl, string loveGirlStr, int createTime, int nLastTime, CLogicServer* pServer, int activityID, string strInviteCode, int needChips, string jsonConfig);

	//bool PerfromCreateGroupTable(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);
	bool PerfromCreateCardGroupTable(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);
	bool PerfromStopGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);
	bool PerfromCostCard(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);
	bool PerfromBeforeCreateGroupCheck(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);
	bool PerfromB2ARemoveGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);
	bool PerfromRequestStopGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);//游戏请求后台退出组局
	bool PerfromRequestStopCardGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer);//游戏请求后台退出房卡组局
	int PerfromSendTableCreate(int club_id, int level);
	int CancelGroupTable(CGameServer *pGameServer, int tid);
protected:
private:
	int HttpPost(const char* strIp, int iPort, char* request);
	int A2MMoney2Chip(CGameServer* pGameServer, int UserID, int activityID, int chip, int addChips, int level);//请求兑换money到chips
	int A2MChip2Money(CGameServer* pGameServer, int uid, int addChips, int activityID);//在clearTableUser里面调用，组局结束后将玩家所有金币兑换成money
	int A2MChangeGroupState(CGameServer* pGameServer, int creatorID, int tableState,int activity_id);
	int GetMemDataRet(CMemDataServer* pMemServer, NETInputPacket& resPacket);
	bool A2BCreateGroupTable(SocketHandler *pSocket, int createFlag, int tableID);
	bool A2GCreateGroupTable(CLogicServer* pServer, int tid, int roomType, int baseChip, string roomName, string password, int uid, \
		int isLoveGirl, CGameTable* pTable,  string strInviteCode, int activityID);
	bool A2GCreateCardGroupTable(CLogicServer* pServer, int tid, int baseChip, int uid, CGameTable* pTable, int minGold, BYTE max_plaeryCount,\
		string strInviteCode, int activityID, int round, string gameConfig = "");
	
	
	int requestCancelGroupTable(string requestUrl,CGameServer *pGameServer, int tid, int activityID, int activityRounds);
	CGameTable* getTable(CGameServer *pGameServer, int tid);

	bool A2GRemoveGroupTable(CLogicServer* pServer, int tid,int activityID);
	bool A2BRemoveGroupTable(SocketHandler *pSocket,int removeStyle);//返回清除组局结果给后台
};

#endif