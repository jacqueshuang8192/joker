#ifndef BOYAA_GAME_SERVER_H
#define BOYAA_GAME_SERVER_H

#include "SocketServer.h"
#include "LogicServer.h"
#include "GameTable.h"
#include "GameMatch.h"
#include <map>
using std::map;
#include <vector>
using std::vector;
#include <set>
using std::set;
#include "ICHAT_Timer_Handler.h"
#include "BaseServer.h"
#include "UserServer.h"
#include "MemCacheClient.h"
#include "ICHAT_HTTP_Config.h"
#include "HallServer.h"
#include "MemDataServer.h"
#include "AllocServer.h"
#include "RedisManagerClient.h"
#include "DbPart.h"
#include "../Json/json.h"
#include "UserBalanceInfo.h"
#include <string.h>
#include <iostream>
#include <sstream>
typedef map<short, CLogicServer*> ServerList;
typedef map<int, CGameTable*> TableList;
typedef map<int, CHallServer*> HallServerList;
typedef map<short, TableList> CountTableList;
typedef map<int, CUserServer*> UserServerList;
typedef map<int, CGameMatch*>	MatchList;
typedef map<int, CMemDataServer*>	MemDataServerMap;		//mserver通信对象
typedef map<int, TableList> clubTableList;   //
typedef vector<groupConfigInfo> itemConfig;

#pragma pack(1)
struct SERVERINFO
{
	int serverId;
	int userCount;
};
#pragma pack()

struct TABLEINFO
{
	int tid;
	short userCount;
};

#pragma pack(1)

enum
{
	CHANGE_LOG_FILE_TIMER = 0x102,  //定时创建日志文件的定时器
	TIME_AOUT_TABLE,     //检测创建房间
	TIME_AOUT_ADD_TABLE,     //检测创建房间
};

//自定义比赛房间类型
enum
{
	MATCH_FOR_PEESONAL = 1,//个人赛
	MATCH_FOR_ENTERPRISE = 2, //企业赛
};

enum
{
	FREEING=0,			//空闲
	WAITING,			//等待进入
	MATCHING,			//比赛中
};
//#define float PI = 3.14159265358979323846;
#define MAKEWORD(a, b) ((WORD)(((BYTE)(((DWORD_PTR)(a)) & 0xff)) |((WORD)((BYTE)(((DWORD_PTR)(b)) & 0xff))) << 8))
#define MAKELONG(a, b) ((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) |((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
#define LOWORD(l) ((WORD)(((DWORD_PTR)(l)) & 0xffff))
#define HIWORD(l) ((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))
#define LOBYTE(w) ((BYTE)(((DWORD_PTR)(w)) & 0xff))
#define HIBYTE(w) ((BYTE)((((DWORD_PTR)(w)) >> 8) & 0xff))


#define MAKEIPLOCALORDER(FIELD1,FIELD2,FIELD3,FIELD4)(MAKELONG(MAKEWORD(FIELD4,FIELD3), MAKEWORD(FIELD2,FIELD1)))
#define MAKEIPHOSTORDER(FIELD1,FIELD2,FIELD3,FIELD4)(MAKELONG(MAKEWORD(FIELD1,FIELD2), MAKEWORD(FIELD3,FIELD4)))

typedef struct PrivetRoomConf{	
	int nLevel;   //数据上报用的假level,私人房等级只有一个
	int nBaseChip;   //底注	
	int nOutMoney;   //最小进场金币	
	int nTableCost;  //台费	
	int nLowMoney;  //出局金币数
}TPrivateRoomConf;
typedef struct distanceInfo {
	string Latitude;   //经度
	string Longitude;   //纬度	
}distanceInfoCount;

struct MATCHINFO
{	
	int matchId;	
	short usercount;	
	short serverId;
};
#pragma pack()

class ICHAT_HTTP_Config;

class CGameServer:public SocketServer, public TimerOutEvent, public CBaseServer
{
public:
	CGameServer(void);
	virtual ~CGameServer(void);
	
public:


	BOOL ReadCommonConf(const char* pszConfPath = "GameServer.ini");
	BOOL InitServer(CRedisManagerClient* pRedisManagerClient, CDbPart* pDBClient,int level, int svid/*, char* szMemCacheServer*/);
	int  ProcessPacket(NETInputPacket* pPacket, SocketHandler *pSocket);	
	int  ProcessClose(SocketHandler *pSocket);
	int ProcessBackPacket(NETInputPacket* pPacket);
	CMemDataServer* GetMemDataServer(int id);
public:
	map<int, string>	m_ActivityTableList;//活动字典
	MemDataServerMap	m_MemDataServerMap;	//MServer列表
private://发给后端UserServer处理
	//需要回包的命令字
	int ProcessClientPacket(int uid, int svid, NETInputPacket* pPacket, SocketHandler *pSocket,int ip=0);
	//不需要回包的命令字,转发给后端
private://本地处理
	int ProcessUserJoinGame(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket, int ip = 0);
	int ProcessGetNewRoom(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessRequireIpAndPort(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessUserJoinMatch(int uid, int svid, short level, SocketHandler *pSocket); //处理用户进入超快赛
	int ProcessUserJoinHuodongMatch(int uid, int svid, short level, SocketHandler *pSocket);//处理用户进入活动赛
	int ProcessUserApplyMatch(int uid, int svid, short level, SocketHandler *pSocket);//处理用户报名
	CGameMatch* GetQuiteMatchRoom(int level,int &matchId,short& serverId);//获取超快赛server
	CGameMatch* GetHuodongMatchRoom(int level,int &matchId,short& serverId);//获取活动赛server


	//私人房
	int ProcessPrivateRoomCreate(int uid, int svid,  NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessPrivateRoomEnter(int uid, int svid,  NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessPrivateRoomList(int uid, int svid,  NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessPrivateRoomFind(int uid, int svid,  NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessPrivateRoomRefreshCount(int uid, int svid, NETInputPacket *pPacket, SocketHandler * pSocket);
	int ProcessReadPrivateConf(NETInputPacket *pPacket, SocketHandler *pSocket);
	BOOL ReadPrivateRoomConf();
	int InitConfig(char* strXML = "config.xml");
private://server命令字
	int ProcessReportServerData(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessUpdateRoomUserCount(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessUpdateMatchUserCount(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessSendServerPortIp(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessSetServerRetired(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessReportPrivateRoomData(NETInputPacket *pPacket, SocketHandler *pSocket);
	
private:	
	int SendClientPacket(int uid, int svid, NETOutputPacket *pPacket, SocketHandler *pSocket);
	int ProcessTransferPacket(int uid, NETInputPacket *pPacket);
	int ProcessUserJoinGame(NETInputPacket *pPacket);

	int ProcessCheckUserTable(int uid, int svid, int cmd,NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessUserTable(NETInputPacket *pPacket);
	int ProcessChangeLevelToLogin(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessCheckServerStatus(NETInputPacket *pPacket, SocketHandler *pSocket);
	//void ProcBroadToAllows(int uid, int svid, int revlevel);
	int SendAllowPacket(int uid, int svid, int slevel, NETOutputPacket *pPacket, SocketHandler *pSocket);
	/*---------------------------- by neo ------------------------------*/
	//user to alloc更新桌子列表
	int	ProcessUpdateTableList(NETInputPacket *pPacket);
	int SendClientAllocPacket(int uid, int svid,int level, NETOutputPacket *pPacket, SocketHandler *pSocket);
	void  ProcessHandleAllow(int uid,int svid,int sLevel,NETInputPacket *pPacket, SocketHandler *pSocket);
	int PerfromTableInfoAllow(NETInputPacket *pPacket, SocketHandler *pSocket);
	void UpdateRobotStatus(int club_id, int uid, int status, int level = 0);
	void BG2UpdateRobotStatus(int club_id, int uid, int status);
	int getRobotStatus(int club_id, int uid);
public:
	
	CGameTable* GetFillRoom();
	CGameTable* GetGameRoom();
	CGameTable* GetGameRoom(CLogicServer* pServer);
	CGameTable* GetTable(int count);
	//CGameTable* GetTable(short serverId, int count);
	CLogicServer* GetServer(short serverId);
	CHallServer* GetHallServer(int svid);
	int ProcessOnTimerOut(int timerId);
	CUserServer* GetUserServer(int id);
public:
	//int PerfromClearTid(int tid, int uid);
	void UpdateClearRobotStatus(int uid);
	void UpdateClearRobotStatus(int uid,int level);
	int ReleaseRobot(int club_id, int uid,int level,int tid);
	int ReleaseRobot(int level);
	int ProcessRobot(CUserBalanceInfo * balanceInfo);
	int clearTidbleInfo(int m_nTid);
	int clearClubTableInfo(int m_nTid);
	int clearClubTable(int level);
	void SendAllowCreateTable(int svid,CGameTable * pTable);
	int ProcessHallClose(CHallServer* pHallServer);
	virtual int ProcessHallCore(CHallServer* pHallServer);
	int ProcessLogicClose(CLogicServer *pLogicServer);
	virtual int ProcessLogicCore(CLogicServer *pLogicServer);
	BOOL InitUserServer();
	int ProcessSetServerAddrToMC();
	void ProcessResetFillFlag(NETInputPacket *pPacket);
	void ProcessRequireClubData(int uid, int svid, NETInputPacket * pPacket, SocketHandler * pSocket);
	void ProcessDisableUser(int uid, int svid, NETInputPacket * pPacket, SocketHandler * pSocket);
	BOOL ReadPrivateRoomMaxListCount(ICHAT_HTTP_Config * = NULL);
	int ProcessClubInfo();
	void AddPrivateRoomIndex(int tid);
	int GetPrivateRoomIndex(int tid);
	
	int ProcLogFileTimer();

	void RandVector(vector<CGameTable*>first, vector<CGameTable*>&second);
	void SortVector(vector<CGameTable*>&first);
	void SortTabeList(vector<CGameTable*>&list);
	CGameTable* FindCreateTable(int uid);
private:
	map<int, int> list_false;//假桌子level
//自定义比赛
public:
	CGameMatch* CreateNewMatch();
	CAllocServer* allocServer;
	int GET_USER_GAME_STATUS(int uid);
	void AddMatchIndex(int matchID);
	void UpdateRobotIsGame(int isGame, int club_id, int uid);
	void AddRobotUser(CGameTable *pTable);
	int getRobotList();
	int GetMatchIndex(int matchID);
	int ProcessCreateMatch(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessFindMatch(int uid, int svid,NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessListMatch(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessEnterMatch(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessUpdatePrivateMatchInfo(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessUpdatePrivateMatchUserCount(NETInputPacket *pPacket, SocketHandler *pSocket);
	int ProcessTransferPacketTemp(int uid, NETOutputPacket pPacket);
	int ProcessUpdateTablelist(int uid,int updateCode);//更新桌子列表 应对快速开始
	int ProcessUserJoinGame(int uid, int level, int tid, int baseChip, int activityID, int isWatch, int svid, SocketHandler* pSocket);
	int ProcessFastJoinTable(int uid, int svid, NETInputPacket* pPacket, SocketHandler* pSocket); //快速加入
	
	void SetClubID(map<int, vector<int> > &testGroupList, int player_id, int group_id,int type);
	int CheckRoomType(int nRoomType);	//检查房间类型是否正确
	int CheckRoomCreateFull();		//检查房间创建个数是否已达上限
	int sendCluUpdatebAlloc(NETInputPacket *pPacket, SocketHandler *pSocket);
	int getUserChips(int club_id, int uid);
	bool CheckTableMaxUser(int club_id, int level);
	bool CheckTableMaxUser(int club_id, int level, int cpmfigId);
	int checkTableList(int levelC,int type,int groupTypeTemp =2);
	int checkTableListTest(int levelC = 342, int club_id = 100028, int groupTypeTemp = 2);
	int joinTableTemp(CGameTable *pTable, int type);
	int sendRound(CGameTable *pTable);
	int closeTableTemp(CGameTable *pTable);
	int sendUserGameStatus(int uid, int svid, SocketHandler *pSocket);
	void split(const string& s, vector<int>& sv, const char flag = ' ');
public:
	ServerList						m_ServerList;	//GameServer列表, key为svid, value为GameServer对象指针
	CountTableList					m_CountTableList;	//桌子列表，key为tid, value为桌子对象指针
	map<int, CHallServer*>					m_HallServerList;
	MatchList						m_MatchList;	//比赛房间列表, key为matchid, value为比赛房间对象指针
	int m_nServerId;
	CRedisManagerClient* m_pRedisManagerClient;         //redis客户端，redis主要保存了用户信息
	CDbPart*     m_pDBClient;           //访问DB的客户端
	//map<int, map<int, int> >                    m_tidClubList;   //根据tid 找俱乐部id
	map<int, int>                    m_tidClubList;   //根据tid 找俱乐部id
	map<int, vector<int> > groupPlayer;   //俱乐部id    用户id;
	map<int, CAllocServer*> listAllocServer;
	map<int, CUserBalanceInfo*> m_userRobotMap; //机器人数据
	map<int, map<int, CUserBalanceInfo*> > groupRobotMap; //俱乐部机器人列表数据
	map<int, string> robotConfig;
	map<int, int> m_userRobotTable;
	map<int, int> groupLevel;
	map<int, int> robotStatus;
	map<int, vector<int> > m_userRobotTableLst;
	map<int, bool> userOnClub;  //用户是否是在俱乐部的桌子
	map<int, vector<int> > userListTable; //用户的桌子
	
	public:
		int StopTableAutoTimer()
		{
			m_autoTableTimer.StopTimer();
			return 0;
		}
		int StartTableAutoTimer() {
			//g_pDebugLog->logMsg("StartTableAutoTimer=%d", checkeTable);
			m_autoTableTimer.StartTimer(1, checkeTable);
		}
		int StopAddTableAutoTimer()
		{
			m_autoAddTableTimer.StopTimer();
			return 0;
		}
		int StartAddTableAutoTimer(long time) {
			m_autoAddTableTimer.StartTimer(1, time);
		}
private://超快赛专用
	int currentSvid; //当前分配的是那个server
	CGameMatch* GetMatch(int matchId);
#ifndef WIN32
	CMemcacheClient*                m_pMemCacheClient;
#endif

public:
	UserServerList					m_UserServerList;
public:
	//map<int, map<int, CGameTable*> > m_clubTableList;//俱乐部桌子  key为俱乐部id , value为桌子对象指针
	//map<int, CGameTable*> tableTempList;
	map<int, TableList> tableTempList;
	map<int, clubTableList> cardJiFenList;
	long numTable;  //每次桌子加一
	int testInt;
	int m_nMaxTableUserCount;
	int m_nMaxServerUserCount;
	int m_nFillFlag;
	int m_nMaxListPriRoomCount;
	int m_nMaxListLoveGirlRoomCount;
	ICHAT_Timer_Handler m_logOpenTimer;
	ICHAT_Timer_Handler m_autoTableTimer;
	ICHAT_Timer_Handler m_autoAddTableTimer;
	int groupType;  //积分还是房卡  2 是积分 3 是房卡
	map<int, int>userGroupType;
	int robotYs;
	int joinGame;
	int checkeTable;
	int tableUser;
	int tableUser_rend;
	map<int, int> m_GroupTableDict_TID;	//组局状态的桌子字典zsw
	map<int, int> m_GroupTableDict_AcitiveId;	//组局状态的桌子字典zsw
	map<int, int> m_GroupTableDict;	//组局状态的桌子字典zsw
	map<int, int> m_GroupCreatorDict;	//组局创建者的字典 zsw
	map<int, int> m_GroupServerDict;	//组局tableid对应服务器的字典 zsw
	map<int, int> m_GroupActivityCreatorDict;	//[组局id，userid]的字典 zsw
	map<int, int> m_GroupTidCreatorDict;	//[组局id，userid]的字典 zsw
	 
	map<int, vector<int> > m_Table_PlayerJoin;
	map<int, vector<int> > m_Table_PlayerSit;
	map<int, map<int, distanceInfo> > m_Table_Distance; //存放经度纬度
//私人房	
public:
	map<int, int> m_nTableIndexList;  //私人房房间Index查询tabelID
	map<int, int> m_nTableIdList;     //tableId查索引Index
	map<int, TPrivateRoomConf>m_nPrivateRoomConf;
    friend class CLogicServer;

	
//自定义比赛

public:
	map<int, int>m_nMatchIndexList;  //index查询matchID
	map<int, int>m_nMatchIDList;     //MatchID索引查询index
	
	int m_nMaxRoomCreateCount;	//比赛房间的创建个数上限
	int m_nSelfMaxListCount;	//自办比赛显示的企业个数上限
	map<int, int> status_Watch;
	map<int, int> userIpMap;//userid,ip
	map<int, int> userTableMap;//userid,tableId
	map<int, int> userHallServiceId;  //uid 大厅SVID
	map<int, int> userIsWatch;  //uid 大厅SVID
	map<int, int> groupOwerMap;
};

#endif
