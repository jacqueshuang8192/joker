#ifndef __C_HELPERPOOL_H__
#define __C_HELPERPOOL_H__

#include <string.h>
#include <vector>
#include <helper_unit.h>
#define REGION 

HTTP_SVR_NS_BEGIN
typedef struct _LogicInfo
{
	string ip;
	int port;
}LogicInfo;
class CClientUnit;
class CHelperUnit;
class CHelperPool
{
public:
	CHelperPool();
	~CHelperPool();
	short m_GameId;//业务号
	bool m_flag;//标志位
public:
	std::map<int, CHelperUnit*> m_helpermap;
	std::vector<int> m_svidlist;
	std::map<int, CDecoderUnit*> m_objmap;
	std::map<int, std::vector<int> > m_levelmap;
	std::map<int, LogicInfo> m_logicmap;
	CHelperUnit* m_pBroadcastUnit;
	CHelperUnit* m_pFriendUnit;
	CHelperUnit* m_pMatchManager;
	
public:
	int DispatchPacket(CClientUnit * cu,const char *pData, int len);
	int DispatchBackPacket(CHelperUnit * ch,NETInputPacket & input);
	int RandomSvid(vector<int>& v);
	int ProcessUserLogoutHall(CClientUnit * cu);
	void ProcSysCmd(NETInputPacket & input);
	int ProcPenetrateCmd(CClientUnit * cu,const char *pData, int len);
	int ProcClientJoinGame(CHelperUnit * & pHelperUnit ,NETInputPacket & input);
	int ProcClientPrivateRoom(CHelperUnit * & pHelperUnit ,NETInputPacket & input);
	int ProcClientLoginHall(CClientUnit * cu ,NETInputPacket & input);
	int ProcBroadCastCmd(CClientUnit * cu , NETInputPacket & input);
	int ProcBroadCastBackCmd(CDecoderUnit* _decoder,NETInputPacket& input);
	int ProcFriendCmd(CClientUnit * cu , NETInputPacket & input);
	int ProcBroadCastSingle(NETInputPacket & input);
	int ProcBroadCastAll(NETInputPacket & input);
	int ProcBroadCastInfoAll(NETInputPacket & input);
	int ProcClientChat(CDecoderUnit* _decoder,NETInputPacket& input);
	CHelperUnit* GetHelpUnitByLevel(int level);
	int ProcessSetLogLevel(NETInputPacket &input, CClientUnit *cu);
	int ProcClientCustomRoom(CHelperUnit * & pHelperUnit ,NETInputPacket & input);

	//比赛相关逻辑
	int ProcClientMatchCmd(CClientUnit* cu, NETInputPacket &input);
	int ProcMatchCmd(CDecoderUnit* _decoder, NETInputPacket& input);
	
};

HTTP_SVR_NS_END
#endif

