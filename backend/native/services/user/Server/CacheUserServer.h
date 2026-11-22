#ifndef __H_CACHEUSERSERVER_H__
#define __H_CACHEUSERSERVER_H__

#include "ClientBase.h"

class CcacheUSvr: public ClientBase
{
    public:
        CcacheUSvr(/*CGameServer* server*/):/*m_pserver(server),*/m_port(0),m_strip(""){;}
        ~CcacheUSvr(){;}
        int Init(char* str,int port);
        int Reconnect();

        int ProcessPacket(NETInputPacket*);
        int Send(NETOutputPacket* pPacket){return ClientBase::Send(pPacket);}

        int ProcUserLogin(int uid,int svid,short isOnline,short terminaltype,int ver);
        int ProcUserClose(int uid);
        int ProcUserEnterRoom(int uid,int tid);
        int ProcUserLeaveRoom(int uid);

        char* GetClientName(){return "CcacheUSvr";}
    private:
        //CGameServer* m_pserver;
        string m_strip;
        int m_port;
};

#endif


