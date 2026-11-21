#include "CacheUserServer.h"
#include "GameCmd.h"

int CcacheUSvr::Init(char* str,int port)
{
    m_strip=str;
    m_port=port;

    return InitConnect((char*)m_strip.c_str(),m_port);
}


int CcacheUSvr::ProcessPacket(NETInputPacket* pk)
{
    return 0;
}

int CcacheUSvr::ProcUserLogin(int uid,int svid,short isOnline,short terminaltype,int ver)
{
    NETOutputPacket opk;

    opk.Begin(CA_CLIENT_CMD_USER_LOGIN);
    opk.WriteInt(uid);
    opk.WriteInt(svid);
    opk.WriteShort(isOnline);
    opk.WriteShort(terminaltype);
    opk.WriteInt(ver);
    opk.End();

    Send(&opk);

    return 0;
}

int CcacheUSvr::ProcUserClose(int uid)
{
    NETOutputPacket opk;

    opk.Begin(CA_CLIENT_CLOSE_PACKET);
    opk.WriteInt(uid);
    opk.End();

    Send(&opk);
    return 0;
}

int CcacheUSvr::ProcUserEnterRoom(int uid,int tid)
{
    NETOutputPacket opk;

    opk.Begin(CA_SYS_USER_ENTER_ROOM);
    opk.WriteInt(uid);
    opk.WriteInt(tid);
    opk.End();

    Send(&opk);
    return 0;
}

int CcacheUSvr::ProcUserLeaveRoom(int uid)
{
    NETOutputPacket opk;

    opk.Begin(CA_SYS_USER_LEAVE_ROOM);
    opk.WriteInt(uid);
    opk.End();

    Send(&opk);
    return 0;
}


