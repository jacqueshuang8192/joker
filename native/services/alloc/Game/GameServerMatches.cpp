#include "GameServer.h"
#include "CommandType.h"
#include "MainServer.h"
#include "GameMatch.h"
#include "GameGroup.h"
#ifndef WIN32
#include "clib_log.h"
extern clib_log *g_pDebugLog;
#endif

int CGameServer::ProcessUpdatePrivateMatchInfo(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    (void)pSocket;
    int serverId = pPacket->ReadInt();
    int matchId = pPacket->ReadInt();
    short level = pPacket->ReadShort();
    short tableUserCount = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();
    int status = pPacket->ReadInt();
    int roomType = pPacket->ReadInt();
    int index = pPacket->ReadInt();
    int total = pPacket->ReadInt();
    int roomUid = pPacket->ReadInt();
    int createTime = pPacket->ReadInt();
    string matchName = pPacket->ReadString();
    string passWord = pPacket->ReadString();

    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pDebugLog->logMsg("ProcessUpdatePrivateMatchInfo||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
#endif
        return 0;
    }
    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        pLogicServer->m_nUserCount = userCount;
        if((matchId>>16) == serverId)
        {
            CGameMatch *pMatch = GetMatch(matchId);
            if(pMatch != NULL)
            {
                pMatch->m_nCurrentNum = tableUserCount;
            }
            else
            {
                pMatch = new CGameMatch(serverId, matchId);
                if(pMatch != NULL)
                {
                    m_MatchList[matchId] = pMatch;
                    pMatch->m_nCurrentNum = tableUserCount;
                    pLogicServer->m_nMatchCount++;
                }
            }
            if (pMatch != NULL)
            {
                pMatch->m_nCreateTime = createTime;
                pMatch->m_nIndex = index;
                pMatch->m_nName = matchName;
                pMatch->m_nPassWord = passWord;
                pMatch->m_nRoomUid = roomUid;
                pMatch->m_nTotal = total;
                pMatch->m_nRoomType= roomType;
                pMatch->m_nStatus = status;
            }
            g_pDebugLog->logMsg("ProcessUpdatePrivateMatchInfo|| serverId[%d] matchId[%d] level[%d] tableUser[%d] userCount[%d] matchType[%d]",serverId, matchId, level, tableUserCount, userCount, roomType);
            g_pDebugLog->logMsg("ProcessUpdatePrivateMatchInfo|| index[%d] total[%d] roomuid[%d] createTime[%d] matchName[%s] password[%s]",index, total, roomUid, createTime, matchName.c_str(), passWord.c_str());
  
        }
    }
    return 0;
}
int CGameServer::ProcessUpdatePrivateMatchUserCount(NETInputPacket * pPacket,SocketHandler * pSocket)
{
    (void)pSocket;
    short serverId = pPacket->ReadShort();
    int matchId = pPacket->ReadInt();
    short level = pPacket->ReadShort();
    short tableUserCount = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();
    int status = pPacket->ReadInt();

    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessUpdateMatchUserCount||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
        return 0;
    }

    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        pLogicServer->m_nUserCount = userCount;
        if((matchId>>16) == serverId)
        {
            CGameMatch *pMatch = GetMatch(matchId);
            if(pMatch != NULL)
            {
                pMatch->m_nCurrentNum = tableUserCount;
                pMatch->m_nStatus = status;
            }
            else
            {
                pMatch = new CGameMatch(serverId, matchId);
                if(pMatch != NULL)
                {
                    m_MatchList[matchId] = pMatch;
                    pMatch->m_nStatus = status;
                    pMatch->m_nCurrentNum = tableUserCount;
                    pLogicServer->m_nMatchCount++;
                }
            }
        }
    }
    return 0;
}


void CGameServer::AddMatchIndex(int matchID)
{ 
    int index = GetMatchIndex(matchID);
    if (index == 0)
    {
        while (1)
        {
            index++;
            map<int, int>::iterator it = m_nMatchIndexList.find(index);
            if (it == m_nMatchIndexList.end())
            {
                break;
            }
        }
    }
    m_nMatchIDList[matchID] = index;
    m_nMatchIndexList[index] = matchID; 
}

int CGameServer::GetMatchIndex(int matchID)
{
    int index = 0;
    map<int,int>::iterator it = m_nMatchIDList.find(matchID);
    if (it != m_nMatchIDList.end())
    {
       index = it->second;
    }
    return index;   
}

CGameMatch* CGameServer::CreateNewMatch()
{
    MatchList::iterator iter = m_MatchList.begin();
    for(; iter!=m_MatchList.end(); iter++)  //先遍历所有的比赛场  
    {
        CGameMatch *pMatch = iter->second;
        if(NULL != pMatch)
        {
            CLogicServer* pServer = GetServer(pMatch->m_nServerId);
            if(pServer != NULL)
            {
                if(0==pServer->m_nRetire && pMatch->m_nCurrentNum == 0 && pServer->m_nUserCount<m_nMaxServerUserCount)
                {
                    int matchID = pMatch->m_nMatchId;
                    pMatch->m_nCreateTime = time(NULL);
                    AddMatchIndex(matchID);
                    pMatch->m_nIndex  = GetMatchIndex(matchID);
                    return pMatch;
                }
            }
        }
    }
    vector<SERVERINFO> serverInfo;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!=m_ServerList.end(); iterServer++)//查找所有的server 找出人数最少的一个server创建比赛场
    {
        CLogicServer* pServer = iterServer->second;
        if(NULL!=pServer && 0==pServer->m_nRetire && pServer->m_nUserCount<m_nMaxServerUserCount)
        {
            SERVERINFO sinfo;
            sinfo.serverId = pServer->m_nServerId;
            sinfo.userCount = pServer->m_nUserCount;
            serverInfo.push_back(sinfo);
        }
    }
    if((int)serverInfo.size() > 0)
    {
        std::sort(serverInfo.begin(), serverInfo.end(), Less_ServerUserCount);
        SERVERINFO &sInfo = serverInfo[0];
        CLogicServer *pLogicServer = m_ServerList[sInfo.serverId];
        if(pLogicServer != NULL)
        {
            int newMatchId = (sInfo.serverId<<16) + pLogicServer->m_nMatchCount + 1;
            CGameMatch *pNewMatch = new CGameMatch(sInfo.serverId, newMatchId);
            if(pNewMatch != NULL)
            {
                pLogicServer->m_nMatchCount++;
                pNewMatch->m_nCreateTime = time(NULL);
                AddMatchIndex(newMatchId);
                pNewMatch->m_nIndex  = GetMatchIndex(newMatchId);
                m_MatchList[newMatchId] = pNewMatch;
                return pNewMatch;
            }
        }
    }
    
    return NULL;
}

int CGameServer::ProcessCreateMatch(int uid, int svid, NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    int roomType = pPacket->ReadInt();
    int num = pPacket->ReadInt();
    string matchName = pPacket->ReadString();
    string passWord = pPacket->ReadString();

    int matchID = 0;
    int serverId = 0;
    string ip = "";
    int port = 0;

	//检查创建房间的类型是否正确
	if(-1 == CheckRoomType(roomType))
	{
		NETOutputPacket outpkg;
        outpkg.Begin(CLIENT_CMD_CREATE_MATCH);
        outpkg.WriteInt(0);
		outpkg.WriteInt(ERROR_CREATE_ROOMTYPE);
        outpkg.End();
        SendClientPacket(uid, svid, &outpkg, pSocket);
        return 0;
	}

	if(-1 == CheckRoomCreateFull())
	{
		NETOutputPacket outpkg;
        outpkg.Begin(CLIENT_CMD_CREATE_MATCH);
        outpkg.WriteInt(0);
		outpkg.WriteInt(ERROR_CREATE_MAX_ROOMCOUNT);
        outpkg.End();
        SendClientPacket(uid, svid, &outpkg, pSocket);
        return 0;
	}
	
    CGameMatch* pMatch = CreateNewMatch();
    if (pMatch == NULL)
    {
        NETOutputPacket outpkg;
        outpkg.Begin(CLIENT_CMD_CREATE_MATCH);
        outpkg.WriteInt(0);
		outpkg.WriteInt(ERROR_CREATE_FAILED);
        outpkg.End();
        SendClientPacket(uid, svid, &outpkg, pSocket);
        return 0;
    }
    pMatch->m_nRoomUid = uid;
    pMatch->m_nCurrentNum = 1;
    pMatch->m_nPassWord = passWord;
    pMatch->m_nName = matchName;
    pMatch->m_nTotal = num;
    pMatch->m_nRoomType= roomType;
    pMatch->m_nStatus = WAITING;
	
    g_pDebugLog->logMsg("[ProcessCreateMatch] uid[%d] matchId[%d] index[%d] matchType[%d] total[%d] level[%d] matchName[%s] \
		passWord[%s]", uid,pMatch->m_nMatchId,pMatch->m_nIndex, roomType, num, level, matchName.c_str(), passWord.c_str());

	ServerList::iterator it = m_ServerList.find(pMatch->m_nServerId);
    if (it != m_ServerList.end())
    {
        CLogicServer* pLogServer = it->second;
         
        serverId = pLogServer->m_nServerId;
        ip = pLogServer->m_strIp;
        port = pLogServer->m_nPort;
        matchID = pMatch->m_nMatchId;
        
        NETOutputPacket outpkg;
        outpkg.Begin(SERVER_CREATE_MATCH);
        outpkg.WriteInt(pMatch->m_nMatchId);
        outpkg.WriteInt(pMatch->m_nRoomUid);
        outpkg.WriteInt(pMatch->m_nRoomType);
        outpkg.WriteInt(pMatch->m_nTotal);
        outpkg.WriteInt(pMatch->m_nCreateTime);
        outpkg.WriteInt(pMatch->m_nIndex);
        outpkg.WriteString(pMatch->m_nName.c_str());
        outpkg.WriteString(pMatch->m_nPassWord.c_str());
        outpkg.End();
        pLogServer->m_pSocketHandler->Send(&outpkg);
       
    }

    NETOutputPacket response;
    response.Begin(CLIENT_CMD_CREATE_MATCH);
    response.WriteInt(1);
    response.WriteInt(serverId);
    response.WriteInt(matchID);
    response.WriteString(ip.c_str());
    response.WriteInt(port);
    response.WriteInt(pMatch->m_nIndex);
    response.WriteInt(pMatch->m_nCreateTime);
    response.End();
    SendClientPacket(uid, svid, &response, pSocket);

	return 0;
}


int CGameServer::ProcessEnterMatch(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessEnterMatch|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
  
    int roomIndex = pPacket->ReadInt();
    string password = pPacket->ReadString();
    int createTime = pPacket->ReadInt();
    map<int,int>::iterator it = m_nMatchIndexList.find(roomIndex);
    if (it == m_nMatchIndexList.end())
    {
        g_pDebugLog->logMsg("ProcessEnterMatch|| error, uid:[%d], roomIndex=[%d]",uid, roomIndex);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int matchId = it->second;
    CGameMatch* pMatch = GetMatch(matchId);
    if (pMatch == NULL)
    {
        g_pDebugLog->logMsg("ProcessEnterMatch|| error, uid:[%d], roomIndex=[%d] matchID[%d]",uid, roomIndex, matchId);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    if (pMatch->m_nStatus == MATCHING)
    {
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_MATCH_BEGIN);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        g_pDebugLog->logMsg("ProcessEnterMatch|| error, uid:[%d], roomIndex=[%d] matchID[%d] matchbegin",uid, roomIndex, matchId);
        return 0;
    }
   
    int serverId = pMatch->m_nServerId;
    CLogicServer *pServer = GetServer(serverId);
    if(pServer != NULL)
    {
       
        int errorCode = 0;
       
        if(pMatch->m_nCurrentNum == 0 || pMatch->m_nCreateTime != createTime)
        {
            errorCode = ERROR_ROOM_NOT_EXIST;
        }
        else if(password != pMatch->m_nPassWord)
        {
            errorCode = ERROR_PASSWORD;
        }
        else if(pMatch->m_nCurrentNum == pMatch->m_nTotal)
        {
            errorCode = ERROR_MAX_USERCOUNT;
        }
       
        g_pDebugLog->logMsg("ProcessEnterMatch||uid:[%d], matchId=[%d]  password=[%s]  createTime[%d] errorCode=[%d] ",uid, matchId,password.c_str(),createTime, errorCode);

        if(errorCode)
        {
            NETOutputPacket resPacket;
            resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
            resPacket.WriteShort(0);  //大厅用
            resPacket.WriteInt(errorCode);
            resPacket.End();
            SendClientPacket(uid, svid, &resPacket, pSocket);
        }
        else
        {
            string ip = "";
            int port = 0;
            if(pServer->m_nRetire == 0)
            {
                ip = pServer->m_strIp;
                port = pServer->m_nPort;
            }
            NETOutputPacket resPacket;
            resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
            resPacket.WriteShort(1);   //大厅用
            resPacket.WriteString(ip.c_str());
            resPacket.WriteInt(port);
            resPacket.WriteInt(matchId);
            resPacket.WriteInt(pMatch->m_nIndex);
            resPacket.WriteInt(pMatch->m_nRoomType);
            resPacket.WriteInt(pMatch->m_nStatus);
            resPacket.End();
            SendClientPacket(uid, svid, &resPacket, pSocket);
        }
    } 
	else 
	{
        g_pDebugLog->logMsg("ProcessEnterMatch||uid:[%d], matchId=[%d] pServer= NULL",uid, matchId);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
    }
    return 0;
}

int CGameServer::ProcessFindMatch(int uid, int svid, NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessFindMatch|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_FIND_MATCH);
        resPacket.WriteInt(0);            
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int roomIndex = pPacket->ReadInt();
    map<int,int>::iterator it = m_nMatchIndexList.find(roomIndex);
    if (it == m_nMatchIndexList.end())
    {
        g_pDebugLog->logMsg("ProcessFindMatch|| error, uid:[%d], roomIndex=[%d]",uid, roomIndex);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_FIND_MATCH);
        resPacket.WriteInt(0);   
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int matchId = it->second;
    CGameMatch* pMatch = GetMatch(matchId);
    if (pMatch == NULL)
    {
        g_pDebugLog->logMsg("ProcessFindMatch|| error, uid:[%d], roomIndex=[%d] matchID[%d]",uid, roomIndex, matchId);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_FIND_MATCH);
        resPacket.WriteInt(0);              
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }

     NETOutputPacket outpkg;
     outpkg.Begin(CLIENT_CMD_FIND_MATCH);
     outpkg.WriteInt(1);           
     outpkg.WriteInt(pMatch->m_nMatchId);
     outpkg.WriteInt(pMatch->m_nRoomUid);
     outpkg.WriteInt(pMatch->m_nRoomType);
     outpkg.WriteInt(pMatch->m_nTotal);
     outpkg.WriteInt(pMatch->m_nCreateTime);
     outpkg.WriteInt(pMatch->m_nIndex);
     outpkg.WriteInt(pMatch->m_nStatus);
     outpkg.WriteString(pMatch->m_nName.c_str());
     outpkg.End();   
     SendClientPacket(uid, svid, &outpkg, pSocket);
return 0;
}


int CGameServer::ProcessListMatch(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    vector<CGameMatch*> list;
    list.clear();
    int num = 0;
    MatchList::iterator iter = m_MatchList.begin();
    for (;iter != m_MatchList.end(); iter++)
    {
        CGameMatch* pMatch = iter->second;
        if (pMatch != NULL && pMatch->m_nRoomType == MATCH_FOR_ENTERPRISE && pMatch->m_nStatus == WAITING)
        {
            if (num == m_nSelfMaxListCount)	//默认最多5个
				break;
            list.push_back(pMatch);
            num++;
        }
    }

    NETOutputPacket outpkg;
    outpkg.Begin(CLIENT_CMD_LIST_MATCH);
    outpkg.WriteInt(num);        
    for (int i = 0; i < num; i++)
    {
        CGameMatch* pMatch = list[i];
        outpkg.WriteInt(pMatch->m_nMatchId);
        outpkg.WriteInt(pMatch->m_nRoomUid);
        outpkg.WriteInt(pMatch->m_nRoomType);
        outpkg.WriteInt(pMatch->m_nTotal);
        outpkg.WriteInt(pMatch->m_nCreateTime);
        outpkg.WriteInt(pMatch->m_nIndex);
        outpkg.WriteInt(pMatch->m_nStatus);
        outpkg.WriteString(pMatch->m_nName.c_str());
    }
    outpkg.End();   
    SendClientPacket(uid, svid, &outpkg, pSocket);

return 0;
}
