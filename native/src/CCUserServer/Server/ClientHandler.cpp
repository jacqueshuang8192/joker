#include "ClientHandler.h"
#include "Global.h"
#include "GameCmd.h"
#include "Stat.h"


#include "HashMap.hpp"
#include "GameUserSHM.h"
#include "ShmHashMap.hpp"

using namespace comm::commu;

#include "Options.h"

using namespace std;

#include "clib_log.h"
extern clib_log *g_pDebugLog;
extern clib_log *g_pErrorLog;

static const short LevelArr[] = {11, 12, 13, 14, 16, 17, 15, 20};

#define SYS_CTRL_BROADCAST_SWITCH "sys_ctrl_broadcast_switch"
#define SYS_CTRL_LEVELCOUNT_RANDOM "sys_ctrl_level_count_random"
#define SYS_CTRL_LEVEL_INFO		"sys_ctrl_level_info"

GameUserSHM gshm;


static string ToLower(const string & str)
{
    if(str.length() == 0)
        return "";

    char buf[512] = {0};
    snprintf(buf, sizeof(buf), "%s", str.c_str());
    int len = strlen(buf);
    for(int i=0; i<len; ++i)
    {
        if(buf[i] >= 'A' && buf[i] <= 'Z')
            buf[i] += ('a'-'A');
    }

    return string(buf);
}


void GetTime(string& strTm)
{
    time_t now = time(NULL);
    struct tm tm;
    localtime_r(&now, &tm);
    char szTm[100] = {0};
    snprintf(szTm, sizeof(szTm), "[%04d-%02d-%02d %02d:%02d:%02d]", tm.tm_year+1900, tm.tm_mon+1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec);
    strTm = szTm;
}

static int split_str(const char* ps_str , char* ps_sp , vector<std::string> &v_ret)
{
    char* ps_temp;
    char* p;
    int i_len = (int)strlen(ps_str);
    std::string st_str;
    ps_temp = new char[i_len+2];
    snprintf(ps_temp , i_len+1 , "%s" , ps_str);
    char *last = NULL;
    p = strtok_r(ps_temp , ps_sp , &last);
    if(NULL == p)
    {
        delete ps_temp;
        return 0;
    }
    st_str = (std::string)p;
    v_ret.push_back(st_str);
    while( NULL != ( p=strtok_r(NULL , ps_sp , &last) ) )
    {
        st_str = (std::string)p;
        v_ret.push_back(st_str);
    }
    delete ps_temp;
    return 0;
}

static int m_nRandCount = 0;

static int GetRand()
{
    if(m_nRandCount > 1000000000)
        m_nRandCount = 0;
    srand((int)time(NULL)+m_nRandCount++);
    return rand() % Options::instance()->m_nRoundLimit;
}


static int CheckPacketComplete(const char * pData,const int & nLen)
{
    if( NULL == pData)
    {
        return 0;

    }

    int nHeadLen = sizeof(struct TPkgHeader);
    if(nLen < nHeadLen)
    {
        g_pErrorLog->logMsg("%s||Invalid Packet nLen[%d] HeadLen[%d]", __FUNCTION__, nLen, nHeadLen);
        return 0;
    }

    TPkgHeader *pHeader = (struct TPkgHeader*)pData;
    if(pHeader->flag[0]!='Q' || pHeader->flag[1]!='E')
    {
        g_pErrorLog->logMsg("%s||Invalid Packet", __FUNCTION__);

    }

//  int pkglen = sizeof(int) + ntohs(pHeader->length);  //转换成大端

    int pkglen = sizeof(pHeader) + ntohl(pHeader->length) - 4;

    if(pkglen<0 || pkglen>8*1024)
    {
        g_pErrorLog->logMsg("%s||Invalid packet, pkglen:[%d]", __FUNCTION__, pkglen);
        return 0;
    }
//  g_pDebugLog->logMsg("%s||Len[%d] pkgLen[%d]", __FUNCTION__, nLen, pkglen);
    if(nLen != pkglen)
    {
        g_pErrorLog->logMsg("%s||Len[%d] pkgLen[%d]", __FUNCTION__, nLen, pkglen);
        return 0;
    }
    return 1;

}


ClientHandler::ClientHandler()
{

}

ClientHandler::~ClientHandler()
{
    this->_decode = NULL;

}

int ClientHandler::OnClose()
{
    DebugMsg("ip[%s] port[%d] fd[%d] close", m_addrRemote.c_str(), m_nPort, netfd);
    return 0;

}


int ClientHandler::OnConnected(void)
{
    GetRemoteAddr();
    DebugMsg("ip[%s] port[%d] fd[%d] connect", m_addrRemote.c_str(), m_nPort, netfd);
    return 0;

}


void ClientHandler::GetRemoteAddr(void)
{
    struct in_addr sin_addr;
    sin_addr.s_addr = this->_ip;
    char * addr = inet_ntoa(sin_addr);
    m_nPort = this->_port;

    if(addr)
        m_addrRemote = string(addr);
    else
        m_addrRemote = "NULL";
}


void ClientHandler::SetServerUserTid0(short sid)
{
    std::list<int> tid0User;
    CShmHashMap<int>::vistor v(gshm.m_ShmHashMap);
    HashNode<int> * pNode = v.begin();

    while(NULL != pNode)
    {
        CGameUser user;
        int len = sizeof(CGameUser);

        int ret = v.GetData(pNode, (char *)&user, &len);
        if(ret == -1 || len != sizeof(CGameUser))
        {
            pNode = v.next(pNode);
            continue;
        }

        if(user.m_nTid > 0 && (user.m_nTid >> 16) == sid)
        {
            user.m_nTid = 0;
            CStat::Instance()->UpdateTerminalInfo(user.m_nUid,TERMINAL_LOGOUTTABLE, user.m_nTerminalType,NULL);

            if(user.m_nServerLevel != -1)
            {
                CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGOUT, user.m_nServerLevel,NULL);
                user.m_nServerLevel = -1;
            }

            tid0User.push_back(user.m_nUid);
        }

        pNode = v.next(pNode);
    }

    std::list<int>::iterator it = tid0User.begin();
    for(; it!=tid0User.end(); ++it)
    {
        CGameUser user;
        if(gshm.Find(*it, user) == 0)
        {
            user.m_nTid = 0;
            user.m_nServerLevel = -1;
            gshm.SetValue(user);
        }
    }

}


void ClientHandler::SetUserOfflineHallCore(int hid)
{

	g_pDebugLog->logMsg("ProcessClientClose|| hid[%d]", hid);

    std::list<int> userHallCore;
    CShmHashMap<int>::vistor v(gshm.m_ShmHashMap);
    HashNode<int> * pNode = v.begin();
    while(NULL != pNode)
    {
        CGameUser user;
        HashNode<int> * pTempNode = pNode;
        int len = sizeof(CGameUser);

        int ret = v.GetData(pNode, (char *)&user, &len);
        if(ret == -1 || len != sizeof(CGameUser))
        {
            pNode = v.next(pNode);
            continue;
        }

        if(user.m_nHallServerId == hid)
        {
            map<int, int>::iterator iter = Options::instance()->m_OfflineUserMgr.find(user.m_nUid);
            if(iter == Options::instance()->m_OfflineUserMgr.end())
            {
                Options::instance()->m_OfflineUserMgr[user.m_nUid] = (int)time(NULL);
            }

            userHallCore.push_back(user.m_nUid);
        }

        pNode = v.next(pNode);
    }

    std::list<int>::iterator it = userHallCore.begin();
    for(; it!=userHallCore.end(); ++it)
    {
        CGameUser user;

        if(gshm.Find(*it, user) == 0)
        {
            user.m_nHallServerId = -1;
            gshm.SetValue(user);
        }
    }

}


int ClientHandler::OnPacketComplete(const char * data,int len)
{
    pPacket.Copy(data,len);
    //*****处理包****/
    return ProcessPacket(&pPacket);

}

int ClientHandler::ProcessPacket(NETInputPacket * pPacket)
{
    int nCmd = pPacket->GetCmdType();
//  DebugMsg("CMD[%x]", nCmd);
	g_pDebugLog->logMsg("[%s function:%s] ===> cmd[0x%x]",__FILE__, __FUNCTION__, nCmd);
	DebugMsg("[%s function:%s] ===> cmd[0x%x]", __FILE__, __FUNCTION__, nCmd);
    switch(nCmd)
    {
        case ALLOC_REGISTER_PACKET:
            return ProcessAllocRegister(pPacket);
        case SYS_GET_USER_TABLE://查询用户桌子状态
            return ProcessGetUserTable(pPacket);
		case G2U_BEFORE_CREATE_GROUP_CHECK://组局查询用户状态
			return ProcessGetUserTable(pPacket);

		case SYS_GET_USER_TABLE_COMMON:
			return ProcessGetUserTable_Common(pPacket);
			
        case CLIENT_PACKET2:
        case CLIENT_PACKET:
            return ProcessSubPacket(pPacket);
        case CLIENT_CLOSE_PACKET:
            return ProcessClientClose(pPacket);
        case TABLE_DATA_CHANGE:
            return ProcessTabDataPacket(pPacket);
        case SYS_USER_LEAVE_ROOM:
            return ProcessReportUserLeaveRoom(pPacket);
        case SYS_USER_ENTER_ROOM:
            return ProcessReportUserEnterRoom(pPacket);
        case SYS_ONLOOK_ENTER_ROOM:
            return ProcessReportOnlookInRoom(pPacket);
        case SYS_ONLOOK_LEAVE_ROOM:
            return ProcessReportOnlookOutRoom(pPacket);
        case SYS_LOGIC_CORE:
            return ProcessLogicCore(pPacket);
        case SYS_HALL_CORE:
            return ProcessHallCore(pPacket);
        case CMD_CLEAR_SERVERINFO:
            return ProcessClearServerInfo(pPacket);;

        case SYS_SYN_BROADCAST_SWITCH:
            return ProcessBroadCastSwitch(pPacket);
        case SYS_SET_TJ_SWITCH:
            return ProcessTJSwitch(pPacket);
        case GET_USER_HALLID:
            return ProcessGetUserHallID(pPacket);

	    case GET_USER_TABLE_INFO:
		    return ProcessGetUserTableInfo(pPacket);

			
            case SYS_SET_LEVEL_COUNT_RANDOM:
                return ProcessSetLevelCountRandom(pPacket);

	    case SYS_RESET_LEVEL_INFO:
		    return ProcessResetLevelInfo(pPacket);
	
	
        default:
            g_pErrorLog->logMsg("%s||Invalid cmd:[%d]", __FUNCTION__,nCmd);
            break;
    }
    return 0;

}

//Server上报有人离开围观模式
int ClientHandler::ProcessReportOnlookOutRoom(NETInputPacket *pPacket)
{
    int uid = pPacket->ReadInt();
    int onlookId = pPacket->ReadInt();
    int tid = pPacket->ReadInt();

	log_error("Leave Room  uid[%d] onlookId[%d] tid[%d]", uid, onlookId, tid);
	
    CGameUser user;
    int shmRet = gshm.Find(uid, user);
	
    if(shmRet == 0)
    {
		
		
        if( (user.m_nTid == tid ) && (user.m_onlookId == onlookId) ) //围观退出房间
        {
            CStat::Instance()->UpdateTerminalInfo(user.m_nUid,TERMINAL_ONLOOKOUTTABLE,user.m_nTerminalType,NULL);
        }

        user.m_nTid = 0;
        user.m_onlookId = 0;
        user.m_nUpdateTime = (int)time(NULL);

        if(user.m_nServerLevel != -1)
        {
            CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGOUT,user.m_nServerLevel,NULL);

            user.m_nServerLevel = -1;
        }

        gshm.SetValue(user);

    }
    return 0;
}

//Server上报围观玩家进入围观模式
int ClientHandler::ProcessReportOnlookInRoom(NETInputPacket *pPacket)
{
    int userId = pPacket->ReadInt();
    int onlookId = pPacket->ReadInt();
    int tid = pPacket->ReadInt();

	log_error("Enter Room  uid[%d] onlookId[%d] tid[%d]", userId, onlookId, tid);
	
    CGameUser user;
    int shmRet = gshm.Find(userId, user);
    if(shmRet == 0)
    {

        if(user.m_nTid == 0)//统计围观数据
        {
            CStat::Instance()->UpdateTerminalInfo(user.m_nUid,TERMINAL_ONLOOKINTABLE,user.m_nTerminalType,NULL);
        }

        user.m_nTid = tid;
        user.m_onlookId = onlookId;  //被围观玩家
        user.m_nUpdateTime = (int)time(NULL);

        short nServerId = (tid>>16);

        CLogicServer *pServer = Options::instance()->GetServer(nServerId);
        if( NULL == pServer )
        {

            pServer = Options::instance()->GetServerFromMc(nServerId);
        }

        if( NULL != pServer)
        {
            if(pServer->m_nLevel != user.m_nServerLevel)
            {
                if(user.m_nServerLevel != -1)
                {
                    CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGOUT,user.m_nServerLevel,NULL);
                }
                CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGIN,pServer->m_nLevel,NULL);
                user.m_nServerLevel = pServer->m_nLevel;
            }

        }
        gshm.SetValue(user);
    }

    return 0;
}


int ClientHandler::ProcessAllocRegister(NETInputPacket * pPacket)
{
    NOT_USE(pPacket);
    return 0;

}

int ClientHandler::ProcessGetUserTable_Common(NETInputPacket * pPacket)
{
	int uid     = pPacket->ReadInt();
    int svid    = pPacket->ReadInt();       //大厅serverid
    short level = pPacket->ReadShort();     //用户请求场等级
    int cmd     = pPacket->ReadInt();       //游戏cmd
    short flag = pPacket->ReadShort();		//请求类型
    int tid     = 0;

    short serverId      = 0;
    string ip           = "";
    int port            = 0;
    short serverLevel   = -1;

    int ret = 0;

    CGameUser user;
    int shmRet = gshm.Find(uid, user);

    if(shmRet == 0 && user.m_nTid > 0)
    {
        ret = 1;
        user.m_nUpdateTime = (int)time(NULL);
        tid = user.m_nTid;
        serverId = (tid>>16);
        CLogicServer* pServer = Options::instance()->GetServer(serverId);
        if(pServer != NULL)
        {
            ip          = pServer->m_strIp;
            port        = pServer->m_nPort;
            serverLevel = pServer->m_nLevel;
        }
        else
        {
            if( 1 == Options::instance()->GetServerInfoFromMc(serverId,serverLevel,ip,port))
            {
                pServer = new CLogicServer(serverId, serverLevel, ip, port);
                if(pServer != NULL)
                {
                    Options::instance()->AddLogicServer(serverId, pServer);
                }
            }
        }

        gshm.SetValue(user);
    }


    if(ret)
    {
        //之前就在房间
        int onlookId = 0;
        onlookId = user.m_onlookId;
        NETOutputPacket resPacket;
        resPacket.Begin(SYS_GET_USER_TABLE_COMMON);
        resPacket.WriteInt(uid);
        resPacket.WriteInt(svid);
		resPacket.WriteInt(cmd);
		resPacket.WriteShort(flag);
        resPacket.WriteInt(ret);
        resPacket.WriteInt(onlookId);
        resPacket.WriteInt(tid);
        resPacket.WriteShort(serverId);
        resPacket.WriteString(ip.c_str());
        resPacket.WriteInt(port);
        resPacket.WriteShort(serverLevel);//2013-2-26，区分3人与4人地主新增加参数
		
		resPacket.WriteInt(Options::instance()->m_LevelInfo[serverLevel]);
		
        resPacket.End();
        Send(&resPacket);

    }
    else
    {
        NETOutputPacket resPacket;
        resPacket.Begin(SYS_GET_USER_TABLE_COMMON);
        resPacket.WriteInt(uid);
        resPacket.WriteInt(svid);
		resPacket.WriteInt(cmd);		
		resPacket.WriteShort(flag);
        resPacket.WriteInt(ret);
        resPacket.WriteShort(level);
        resPacket.End();
        Send(&resPacket);
    }

    return 0;
}
	
int ClientHandler::ProcessGetUserTable(NETInputPacket * pPacket)
{
	int uid = pPacket->ReadInt();
	int svid = pPacket->ReadInt();       //大厅serverid
	short level = pPacket->ReadShort();     //用户请求场等级
	int sid = pPacket->ReadInt();       //游戏serverid
	int activityID = pPacket->ReadInt();    //游戏activityID
	int userIp = pPacket->ReadInt();    //用户的ip

	DebugMsg("ClientHandler::ProcessGetUserTable %d %d %d", uid, activityID, userIp);
	int tid = 0;

	short serverId = 0;
	string ip = "";
	int port = 0;
	short serverLevel = -1;

	int ret = 0;

	CGameUser user;
	int shmRet = gshm.Find(uid, user);

	if (shmRet == 0 && user.m_nTid > 0)
	{
		ret = 1;
		user.m_nUpdateTime = (int)time(NULL);
		tid = user.m_nTid;
		serverId = (tid >> 16);
		CLogicServer* pServer = Options::instance()->GetServer(serverId);
		if (pServer != NULL)
		{
			ip = pServer->m_strIp;
			port = pServer->m_nPort;
			serverLevel = pServer->m_nLevel;
		}
		else
		{
			if (1 == Options::instance()->GetServerInfoFromMc(serverId, serverLevel, ip, port))
			{
				pServer = new CLogicServer(serverId, serverLevel, ip, port);
				if (pServer != NULL)
				{
					Options::instance()->AddLogicServer(serverId, pServer);
				}
			}
		}

		gshm.SetValue(user);
	}


	if (ret)
	{
		//之前就在房间
		int onlookId = 0;
		onlookId = user.m_onlookId;
		NETOutputPacket resPacket;
		resPacket.Begin(SYS_GET_USER_TABLE);
		resPacket.WriteInt(uid);
		resPacket.WriteInt(svid);
		resPacket.WriteInt(ret);
		resPacket.WriteInt(onlookId);
		resPacket.WriteInt(tid);
		resPacket.WriteShort(serverId);
		resPacket.WriteString(ip.c_str());
		resPacket.WriteInt(port);
		resPacket.WriteShort(serverLevel);//2013-2-26，区分3人与4人地主新增加参数
		resPacket.WriteInt(Options::instance()->m_LevelInfo[serverLevel]);
		resPacket.WriteInt(activityID);//活动id
		resPacket.WriteInt(userIp);//活动id
		
		resPacket.End();
		Send(&resPacket);

	}
	else
	{
		NETOutputPacket resPacket;
		resPacket.Begin(SYS_GET_USER_TABLE);
		resPacket.WriteInt(uid);
		resPacket.WriteInt(svid);
		resPacket.WriteInt(ret);
		resPacket.WriteShort(level);
		resPacket.WriteInt(sid);
		resPacket.WriteInt(activityID);//活动id
		resPacket.WriteInt(userIp);//活动id
		resPacket.End();
		Send(&resPacket);
	}

	return 0;
}

int ClientHandler::ProcessBeforeCreateGroupCheck(NETInputPacket * pPacket)
{
	int uid = pPacket->ReadInt();//玩家账号id zsw
	int svid = pPacket->ReadInt();//服务器id zsw
	int level = pPacket->ReadInt();//实际对应游戏类型 zsw
	int roomType = pPacket->ReadInt();//房间类型zsw 
	int baseChip = pPacket->ReadInt();//开局的底分，暂时无用到，会直接读配置文件 zsw
	int needChip = pPacket->ReadInt();// zsw 玩家需要携带多少筹码才能开始组局
	string roomName = pPacket->ReadString();//zsw 组局名
	string password = pPacket->ReadString();//zsw 预留字段，暂时无用
	int isLoveGirl = pPacket->ReadInt();//zsw 预留字段，暂时无用
	string loveGirlStr = pPacket->ReadString();//zsw 预留字段，暂时无用
	string strInviteCode = pPacket->ReadString();//zsw 组局邀请码，也是唯一的id
	string strActivity = pPacket->ReadString();//zsw 组局的此组局的唯一id
	int	nLastTime = pPacket->ReadInt();//zsw 预留字段，暂时无用s

    int tid     = 0;

    short serverId      = 0;
    string ip           = "";
    int port            = 0;
    short serverLevel   = -1;

    int ret = 0;

    CGameUser user;
    int shmRet = gshm.Find(uid, user);

    if(shmRet == 0 && user.m_nTid > 0)
    {
        ret = 1;
        user.m_nUpdateTime = (int)time(NULL);
        tid = user.m_nTid;
        serverId = (tid>>16);
        CLogicServer* pServer = Options::instance()->GetServer(serverId);
        if(pServer != NULL)
        {
            ip          = pServer->m_strIp;
            port        = pServer->m_nPort;
            serverLevel = pServer->m_nLevel;
        }
        else
        {
            if( 1 == Options::instance()->GetServerInfoFromMc(serverId,serverLevel,ip,port))
            {
                pServer = new CLogicServer(serverId, serverLevel, ip, port);
                if(pServer != NULL)
                {
                    Options::instance()->AddLogicServer(serverId, pServer);
                }
            }
        }

        gshm.SetValue(user);
    }

    if(ret)
    {
		//之前就在房间
		int onlookId = 0;
		onlookId = user.m_onlookId;
		NETOutputPacket resPacket;
		resPacket.Begin(SYS_GET_USER_TABLE);
		resPacket.WriteInt(uid);
		resPacket.WriteInt(svid);
		resPacket.WriteInt(ret);
		resPacket.WriteInt(onlookId);
		resPacket.WriteInt(tid);
		resPacket.WriteShort(serverId);
		resPacket.WriteString(ip.c_str());
		resPacket.WriteInt(port);
		resPacket.WriteShort(serverLevel);//2013-2-26，区分3人与4人地主新增加参数
		resPacket.WriteInt(Options::instance()->m_LevelInfo[serverLevel]);
		resPacket.WriteString(strActivity.c_str());//活动id

		resPacket.End();
		Send(&resPacket);
    }
    else
    {
        NETOutputPacket resPacket;
		resPacket.Begin(U2G_BEFORE_CREATE_GROUP_CHECK);
		resPacket.WriteInt(uid);
		resPacket.WriteInt(svid);
		resPacket.WriteInt(level);
		resPacket.WriteInt(roomType);
		resPacket.WriteInt(baseChip);
		resPacket.WriteInt(needChip);
		resPacket.WriteString(roomName.c_str());
		resPacket.WriteString(password.c_str());
		resPacket.WriteInt(isLoveGirl);
		resPacket.WriteString(loveGirlStr.c_str());
		resPacket.WriteString(strInviteCode.c_str());
		resPacket.WriteString(strActivity.c_str());
		resPacket.WriteInt(nLastTime);
        resPacket.End();
        Send(&resPacket);
    }

    return 0;
}

int ClientHandler::ProcessTabDataPacket(NETInputPacket* pPacket)
{
    int nCmd = pPacket->GetCmdType();
    int nUid = pPacket->ReadInt();//玩家账号id zsw
    DebugMsg("ProcessTabDataPacket Uid[%d]  Cmd[%x]", nUid, nCmd);
    CGameUser user, * pUser(NULL);
    int shmRet = gshm.Find(nUid, user);
    if (shmRet == 0) {
        DebugMsg("ProcessTabDataPacket shmRet[%d]  m_nHallServerId[%x]", shmRet, user.m_nHallServerId);
        if (user.m_nUid == nUid)
        {
            DebugMsg("ProcessTabDataPacket Uid[%d] nSvid[%d] Cmd[%x]", nUid, user.m_nHallServerId, nCmd);
            NETOutputPacket tempPacket;
            tempPacket.Copy(pPacket->packet_buf(), pPacket->packet_size());
            tempPacket.End();
            SendClientPacket(nUid, user.m_nHallServerId, &tempPacket);
            return 0;
        }
    }
   
   /* CShmHashMap<int>::vistor v(gshm.m_ShmHashMap);
    HashNode<int>* pNode = v.begin();
    while (NULL != pNode)
    {
        CGameUser user;
        HashNode<int>* pTempNode = pNode;
        int len = sizeof(CGameUser);

        int ret = v.GetData(pNode, (char*)&user, &len);
        if (ret == -1 || len != sizeof(CGameUser))
        {
            pNode = v.next(pNode);
            continue;
        }
        DebugMsg("ProcessTabDataPacket Uid[%d] nUid[%d] Cmd[%x]", user.m_nUid, nUid, nCmd);
        if (user.m_nUid == nUid)
        {
            DebugMsg("ProcessTabDataPacket Uid[%d] nSvid[%d] Cmd[%x]", nUid, user.m_nHallServerId, nCmd);
            NETOutputPacket tempPacket;
            tempPacket.Copy(pPacket->packet_buf(), pPacket->packet_size());
            tempPacket.End();
            SendClientPacket(nUid, user.m_nHallServerId, &tempPacket);
            return 0;
        }
    }*/
   
    return 0;

}

int ClientHandler::ProcessSubPacket(NETInputPacket * pPacket)
{
    int nCmd = pPacket->GetCmdType();
    char szTemp[10240];
    int uid, svid, nLen;
    string appNetworkType = "";
    string appVersion = "";
    int appIp = 0;
    BYTE cheatFlag = 0;
    short api;

    if(nCmd == CLIENT_PACKET)
    {
        uid  = pPacket->ReadInt();
        svid = pPacket->ReadInt();              //大厅 id
        nLen = pPacket->ReadBinary(szTemp, sizeof(szTemp));
    }
    else if(nCmd == CLIENT_PACKET2)
    {
        uid  = pPacket->ReadInt();
        svid = pPacket->ReadInt();              //大厅 id
        appIp = pPacket->ReadInt();
        appNetworkType = pPacket->ReadString();
        api = pPacket->ReadShort();
        appVersion = pPacket->ReadString();
        cheatFlag = pPacket->ReadByte();
        nLen = pPacket->ReadBinary(szTemp, sizeof(szTemp));
    }

    if(nLen < 0)
    {
        g_pErrorLog->logMsg("%s||pPacket->ReadBinary error, nLen<0",__FUNCTION__);
        return 0;
    }
    if( !CheckPacketComplete(szTemp, nLen))
    {
        return 0;
    }

    NETInputPacket tempPacket;
    if(!tempPacket.Copy(szTemp, nLen))
    {
        g_pErrorLog->logMsg("%s||tempPacket.Copy error",__FUNCTION__);
        return 0;
    }
    return ProcessClientPacket(uid, svid, &tempPacket);

}

int ClientHandler::ProcessClientPacket(int nUid, int nSvid,NETInputPacket *pPacket)
{
    CEncryptDecrypt decrypt;

    if(decrypt.DecryptBuffer(pPacket) < 0)
    {
        g_pErrorLog->logMsg("%s||DecryptBuffer error", __FUNCTION__);
        return 0;

    }
    int cmd = pPacket->GetCmdType();
    DebugMsg("ProcessClientPacket Uid[%d] nSvid[%d] Cmd[%x]", nUid, nSvid, cmd);

    switch(cmd)
    {
        case CLIENT_CMD_USER_LOGIN:
            return ProcessUserLogin(nUid, nSvid,pPacket);
        case CMD_GET_ROOM_LEVER_NUM:
            return ProcessGetRoomLevelNum(nUid, nSvid, pPacket);
        case CLIENT_CMD_LEAVE_ROOM:
            return 0;
        case CLIENT_CMD_ENTER_ROOM:
            return 0;

        default:
            g_pErrorLog->logMsg("%s||Invalid cmd:[%d]", __FUNCTION__,cmd);
    }
    return 0;

}

int ClientHandler::SendClientPacket(int uid,int svid,NETOutputPacket * pPacket)
{
    CEncryptDecrypt crypt;
    crypt.EncryptBuffer(pPacket);
    NETOutputPacket resPacket;
    resPacket.Begin(CLIENT_PACKET);
    resPacket.WriteInt(uid);
    resPacket.WriteInt(svid);
    resPacket.WriteBinary(pPacket->packet_buf(), pPacket->packet_size());
    resPacket.End();
    Send(&resPacket);
    return 0;


}

int ClientHandler::SendServerClosePacket(int uid,int svid)
{
    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CLOSE_PACKET);
    resPacket.WriteInt(uid);
    resPacket.WriteInt(svid);
    resPacket.End();
    Send(&resPacket);

    return 0;
}


int ClientHandler::ProcessUserLogin(int nUid, int nSvid,NETInputPacket *pPacket)
{
    int     userId          = pPacket->ReadInt();
    short   isOnline        = pPacket->ReadShort();
    short   terminalType    = pPacket->ReadShort();
    int     version         = pPacket->ReadInt();

    log_error("ProcessUserLogin| uid[%d] nSvid[%d]", userId, nSvid);
	
    if(userId <= 0)
    {
        g_pErrorLog->logMsg("%s||Login Invalid uid:[%d], terminalType:[%hd], version:[%d]", __FUNCTION__,userId, terminalType, version);
        return 0;
    }
    Options::instance()->m_pCacheUserSvr->ProcUserLogin(userId,nSvid,isOnline,terminalType,version);
    CGameUser user, * pUser(NULL);
    int shmRet = gshm.Find(userId, user);

    if(shmRet == 0)
    {
        if(nSvid != user.m_nHallServerId && -1 != user.m_nHallServerId)
        {
            NETOutputPacket resPacket;
            resPacket.Begin(SERVER_CMD_KICK_OUT);
            resPacket.End();
            SendClientPacket(nUid, user.m_nHallServerId, &resPacket);
            SendServerClosePacket(nUid, user.m_nHallServerId);
        }

        USERSTAT preStat;
        preStat.terminalType = user.m_nTerminalType;
        preStat.tid = user.m_nTid;

        CStat::Instance()->UpdateTerminalInfo(user.m_nUid, TERMINAL_LOGINHALL, terminalType, &preStat);
        user.m_nStatus = isOnline;
        user.m_nTerminalType = terminalType;
        user.m_nVersion = version;
        user.m_nHallServerId = nSvid;
        user.m_nUpdateTime = (int)time(NULL);

        pUser = new CGameUser(user.m_nUid, user.m_nHallServerId, user.m_nStatus, user.m_nTerminalType, user.m_nVersion, user.m_nUpdateTime);
        pUser->m_nTid = user.m_nTid;
        pUser->m_onlookId = user.m_onlookId;
        pUser->m_nServerLevel = user.m_nServerLevel;

//      gshm.SetValue(user);
    }
    else
    {
        int updateTime = (int)time(NULL);
        pUser = new CGameUser(userId, nSvid, isOnline, terminalType, version, updateTime);
        if(updateTime - Options::instance()->m_nStartTime <= TIME_INTEVAL)
        {
            int nTid = 0;
            if( 1 == Options::instance()->GetUserInfoFromMc(userId,nTid))
            {
                pUser->m_nTid = nTid;

            }
        }

        CStat::Instance()->UpdateTerminalInfo(pUser->m_nUid, TERMINAL_LOGINHALL, terminalType, NULL);

    }

    Options::instance()->DeleteOfflineUser(userId);

    NETOutputPacket resPacket;
    //围观玩家重连
    if(pUser->m_nTid > 0 &&  pUser->m_onlookId < 0)
    {
        resPacket.Begin(SERVER_ONLOOK_RECONNECT_ROOM);
    }
    else
    {
        resPacket.Begin(SERVER_CMD_LOGIN_SUCCESS);
    }

    int ver = 1;
    resPacket.WriteInt(ver);
//  int levelCount = (int)sizeof(LevelArr)/sizeof(short);
    int levelCount = 0;
    resPacket.WriteInt(levelCount);
    for(int i=0; i<levelCount; i++)
    {
        int randCount = GetRand();
        int nCOunt = Options::instance()->GetLevelCount(LevelArr[i]);
        resPacket.WriteInt(randCount);
    }
    int friendCount = 0;
    resPacket.WriteInt(friendCount);

    int         tid = 0;
    int         onlookId = 0;
    string      ip = "";
    int         port = 0;
    short       serverLevel = -1;

    if( NULL != pUser && pUser->m_nTid > 0)
    {
        tid             = pUser->m_nTid;
        short serverId  = (pUser->m_nTid>>16);
        CLogicServer* pServer = Options::instance()->GetServer(serverId);
        if(pServer != NULL)
        {
            ip          = pServer->m_strIp;
            port        = pServer->m_nPort;
            serverLevel = pServer->m_nLevel;
        }
        else
        {
            if( 1 == Options::instance()->GetServerInfoFromMc(serverId,serverLevel,ip,port))
            {
                pServer = new CLogicServer(serverId, serverLevel, ip, port);
                if(pServer != NULL)
                {
                    Options::instance()->AddLogicServer(serverId, pServer);
                }
            }
        }

        pUser->m_nServerLevel = serverLevel;
    }

    gshm.SetValue(*pUser);


    resPacket.WriteInt(tid);
    resPacket.WriteString(ip.c_str());
    resPacket.WriteInt(port);
    resPacket.WriteShort(serverLevel);

	
    //if(pUser->m_nTid > 0 &&  pUser->m_onlookId > 0)
    //{
        onlookId = pUser->m_onlookId;
        resPacket.WriteInt(onlookId);
    //}
    //Type
    resPacket.WriteInt(Options::instance()->m_LevelInfo[serverLevel]);

	g_pDebugLog->logMsg("uid[%d] tid[%d] level[%d] type[%d] ", nUid, tid, serverLevel, Options::instance()->m_LevelInfo[serverLevel]);
    resPacket.WriteByte(Options::instance()->m_LevelList.size());
    vector<int>::iterator iter = Options::instance()->m_LevelList.begin();
    for(; iter != Options::instance()->m_LevelList.end(); iter++)
    {
        int nCount = Options::instance()->GetLevelCount(*iter);
        resPacket.WriteInt(*iter);
        resPacket.WriteInt(nCount);
    }


    //获取Alloc对应的ID


    resPacket.End();
    SendClientPacket(nUid, nSvid, &resPacket);


    delete(pUser);

    return 0;

}


int ClientHandler::ProcessGetRoomLevelNum(int nUid,int nSvid,NETInputPacket * pPacket)
{
	NETOutputPacket resPacket;
	resPacket.Begin(CMD_GET_ROOM_LEVER_NUM);

	resPacket.WriteByte(Options::instance()->m_LevelList.size());
	vector<int>::iterator iter = Options::instance()->m_LevelList.begin();
	for(; iter != Options::instance()->m_LevelList.end(); iter++)
	{
	    int nCount = Options::instance()->GetLevelCount(*iter);
	    resPacket.WriteInt(*iter);
	    resPacket.WriteInt(nCount);
	}

	resPacket.End();
	SendClientPacket(nUid, nSvid, &resPacket);
	return 0;
}


int ClientHandler::ProcessClientClose(NETInputPacket * pPacket)
{
    int nUid = pPacket->ReadInt();

	g_pDebugLog->logMsg("ProcessClientClose| uid[%d]", nUid);

    Options::instance()->m_pCacheUserSvr->ProcUserClose(nUid);
    CGameUser user;
    int shmRet = gshm.Find(nUid, user);
    if(shmRet == 0)
    {
        if(user.m_nTid>0)
        {
            int nTime = (int)time(NULL);
            Options::instance()->AddOfflineUser(nUid, nTime);
            user.m_nHallServerId = -1;                  //表示与大厅断开连接
            user.m_nUpdateTime = nTime;
            gshm.SetValue(user);
            return 0;
        }

        Options::instance()->DeleteOfflineUser(nUid);

        CStat::Instance()->UpdateTerminalInfo(user.m_nUid, TERMINAL_LOGOUTHALL, user.m_nTerminalType, NULL);

        gshm.Delete(nUid);

    }

    return 0;

}


int ClientHandler::ProcessReportUserLeaveRoom(NETInputPacket * pPacket)
{
	int nUid = pPacket->ReadInt();
	int nTid = pPacket->ReadInt();
	int nlevel = pPacket->ReadInt();
	Options::instance()->m_pCacheUserSvr->ProcUserLeaveRoom(nUid);
	short nServerId = (nTid >> 16);
	CLogicServer *pServer = Options::instance()->GetServer(nServerId);
	DebugMsg("[%s function:%s] ===> nlevel%d nUid[%d]", __FILE__, __FUNCTION__, nlevel, nUid);
	log_error("Leave Room  uid[%d]", nUid);

	g_pDebugLog->logMsg("[%s] line:%d ===>  uid[%d] level[%d]", __FUNCTION__, __LINE__, nUid, nlevel);
	if (Options::instance()->m_RedisServer->DelUserStateInfo(nUid, nlevel) == 0)
	{

		vector<int> vPlayers;
		int	count = pPacket->ReadByte();
		for (int i = 0; i < count; i++)
		{
			vPlayers.push_back(pPacket->ReadInt());
		}
		int game_type = pPacket->ReadInt();
		Options::instance()->m_RedisServer->SetTableStatus(nlevel, nTid, vPlayers, game_type);
		if (pServer) {
			NETOutputPacket resPacket;
			resPacket.Begin(SYS_UPDATE_TABLE_LIST);
			resPacket.WriteInt(pServer->m_nLevel);
			resPacket.WriteInt(nTid);
			resPacket.WriteInt(nUid);
			resPacket.WriteInt(game_type);

			resPacket.End();
			Send(&resPacket);
		}		
	}


	CGameUser user;
	int shmRet = gshm.Find(nUid, user);
	if(shmRet == 0)
	{
		if(user.m_nTid > 0)
		{
			CStat::Instance()->UpdateTerminalInfo(user.m_nUid,TERMINAL_LOGOUTTABLE,user.m_nTerminalType,NULL);
		}
		user.m_nTid = 0;
		user.m_nUpdateTime = (int)time(NULL);
		if(user.m_nServerLevel != -1)
		{
			CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGOUT,user.m_nServerLevel,NULL);
			user.m_nServerLevel = -1;
		}

		gshm.SetValue(user);
	}
	else
	{
		log_error("cannot find uid :%d", nUid);
	}

    return 0;
}


int ClientHandler::ProcessReportUserEnterRoom(NETInputPacket * pPacket)
{
    int nUid = pPacket->ReadInt();
    int nTid = pPacket->ReadInt();
	int nlevel = pPacket->ReadInt();
	int ActicityId = pPacket->ReadInt();
	vector<int> vPlayers;
	int	count = pPacket->ReadByte();
	if (count > 0)
	{
		for (int i = 0; i < count; i++)
		{
			vPlayers.push_back(pPacket->ReadInt());
		}
	}
	int game_type = pPacket->ReadInt();
	g_pDebugLog->logMsg("Enter Room  uid[%d] Tid[%d]", nUid, nTid, nlevel);

    //立马上报cacheUser 
    Options::instance()->m_pCacheUserSvr->ProcUserEnterRoom(nUid, nTid);
	short nServerId = (nTid >> 16);
	CLogicServer *pServer = Options::instance()->GetServer(nServerId);
	int server_level = 0;
    CGameUser user;
    int shmRet = gshm.Find(nUid, user);
	
    if(shmRet == 0)
    {
        if(user.m_nTid == 0)
        {
            CStat::Instance()->UpdateTerminalInfo(user.m_nUid,TERMINAL_LOGINTABLE, user.m_nTerminalType,NULL);
        }

        user.m_nTid = nTid;
        user.m_nUpdateTime = (int)time(NULL);
	
        if( NULL == pServer )
        {

            pServer = Options::instance()->GetServerFromMc(nServerId);
		}
		else {
			g_pDebugLog->logMsg("SetUserStateInfo uid[%d] m_nServerLevel[%d] ActicityId[%d]", nUid, pServer->m_nLevel, ActicityId);
		}
		if (pServer)
		{
			server_level = pServer->m_nLevel;
		}
		g_pDebugLog->logMsg("SetUserStateInfo uid[%d] m_nServerLevel[%d]  user_level[%d]",nUid, server_level, user.m_nServerLevel);
		int iret = Options::instance()->m_RedisServer->SetUserStateInfo(nUid, nlevel, nTid, ActicityId);
		log_error("SetUserStateInfo uid[%d] m_nServerLevel[%d] setUserOnline[%d] user_level[%d]", nUid, server_level, iret, user.m_nServerLevel);
		if ( iret == 0)
		{
			//更新桌子列表
			if (count > 0)
			{
				Options::instance()->m_RedisServer->SetTableStatus(server_level, nTid, vPlayers, game_type);
				NETOutputPacket resPacket;
				resPacket.Begin(SYS_UPDATE_TABLE_LIST);
				resPacket.WriteInt(server_level);
				resPacket.WriteInt(nTid);
				resPacket.WriteInt(nUid);
				resPacket.WriteInt(game_type);

				resPacket.End();
				Send(&resPacket);
			}
		}

        if( NULL != pServer)
        {
            if(pServer->m_nLevel != user.m_nServerLevel)
            {
                if(user.m_nServerLevel != -1)
                {
                    CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGOUT,user.m_nServerLevel,NULL);
                }
                CStat::Instance()->UpdateLevelInfo(user.m_nUid,LEVEL_LOGIN,pServer->m_nLevel,NULL);
                user.m_nServerLevel = pServer->m_nLevel;

            }

        }

        gshm.SetValue(user);
    }
    else
   {
   	log_error("cannot find uid:%d  tid:%d", nUid, nTid);
   }
    return 0;

}



int ClientHandler::ProcessLogicCore(NETInputPacket * pPacket)
{
    short nServerId = pPacket->ReadShort();
    g_pDebugLog->logMsg("%s||GameServer core, serverId:[%hd]", __FUNCTION__, nServerId);
    CLogicServer* pServer = Options::instance()->GetServer(nServerId);
    if( NULL != pServer)
    {
        delete pServer;
        pServer = NULL;

    }
    Options::instance()->DeleteLogicServer(nServerId);

    SetServerUserTid0(nServerId);

    return 0;

}

int ClientHandler::ProcessHallCore(NETInputPacket * pPacket)
{
    int nSvid = pPacket->ReadInt();


    SetUserOfflineHallCore(nSvid);
    return 0;
}


int ClientHandler::ProcessClearServerInfo(NETInputPacket * pPacket)
{
    NOT_USE(pPacket);
    g_pDebugLog->logMsg("%s||Clear server info", __FUNCTION__);
    Options::instance()->ClearServerList();
    return 0;

}

int ClientHandler::ProcessBroadCastSwitch(NETInputPacket * pPacket)
{
    string key = pPacket->ReadString();
    if(strcmp(key.c_str(), SYS_CTRL_BROADCAST_SWITCH) != 0)
    {
        g_pErrorLog->logMsg("%s||Strcmp [%s]--[%s]", __FUNCTION__,key.c_str(), SYS_CTRL_BROADCAST_SWITCH);
        return 0;
    }

    int nBroadcastSwitch = pPacket->ReadInt();
    Options::instance()->SetBroadCastSwitch(nBroadcastSwitch);
    g_pDebugLog->logMsg("%s||flag:[%d]", __FUNCTION__, nBroadcastSwitch);
    return 0;

}

int ClientHandler::ProcessTJSwitch(NETInputPacket * pPacket)
{
    int nTJSwitch = pPacket->ReadInt();
    int nTJInteval = pPacket->ReadInt();
    Options::instance()->SetTjSwitch(nTJSwitch, nTJInteval);
    g_pDebugLog->logMsg("%s||flag:[%d], inteval:[%d]", __FUNCTION__,nTJSwitch, nTJInteval);
    return 0;


}

int  ClientHandler::ProcessResetLevelInfo(NETInputPacket * pPacket)
{
	string key = pPacket->ReadString();
	if(strcmp(key.c_str(), SYS_CTRL_LEVEL_INFO) != 0)
	{
	    g_pErrorLog->logMsg("%s||Strcmp [%s]--[%s]", __FUNCTION__,key.c_str(), SYS_CTRL_LEVELCOUNT_RANDOM);
	    return 0;
	}
	
	
	Options::instance()->ReadLevelInfo("../conf/config.ini");
	g_pDebugLog->logMsg("%s||Set  LevelInfo", __FUNCTION__);
}
	

int ClientHandler::ProcessSetLevelCountRandom(NETInputPacket * pPacket)
{
    string key = pPacket->ReadString();
    if(strcmp(key.c_str(), SYS_CTRL_LEVELCOUNT_RANDOM) != 0)
    {
        g_pErrorLog->logMsg("%s||Strcmp [%s]--[%s]", __FUNCTION__,key.c_str(), SYS_CTRL_LEVELCOUNT_RANDOM);
        return 0;
    }

    Options::instance()->ReadRandomConfig("../conf/config.ini");
    g_pDebugLog->logMsg("%s||Set RandomCOunt", __FUNCTION__);
    return 0;
}

int ClientHandler::ProcessGetUserTableInfo(NETInputPacket * pPacket)
{
	int nUid = pPacket->ReadInt();
	CGameUser user;
	int shmRet = gshm.Find(nUid, user);
	NETOutputPacket pkg;
	pkg.Begin(GET_USER_TABLE_INFO);
	pkg.WriteInt(nUid);
	if(shmRet == 0)
	{
		pkg.WriteInt(user.m_nTid);
		pkg.WriteInt(user.m_nUpdateTime);
	}
	else
	{
		pkg.WriteInt(0);
		pkg.WriteInt(0);
	}

	pkg.End();
	Send(&pkg);
	return 0;
}

int ClientHandler::ProcessGetUserHallID(NETInputPacket * pPacket)
{
    int nUid = pPacket->ReadInt();
    CGameUser user;
    int shmRet = gshm.Find(nUid, user);
    NETOutputPacket pkg;
    pkg.Begin(GET_USER_HALLID);
    pkg.WriteInt(nUid);
    if(shmRet == 0)
    {
        pkg.WriteInt(user.m_nHallServerId);
    }
    else
    {
        pkg.WriteInt(-1);
    }

    pkg.End();
    Send(&pkg);
    return 0;
}

