#ifndef __H_CLIENTBASE_H__
#define __H_CLIENTBASE_H__

#include "CCSocketServer.h"
#include "CCSocketHandler.h"
#include "QEPacketBase.h"
#include "QEDecoder.h"
#include "MarkupSTL.h"
#include "Global.h"

class ClientBase: public CCSocketHandler
{
public:
    ClientBase(string strcli=__PRETTY_FUNCTION__)
    {
        s_cliname=strcli.substr(0,strcli.find(':'));
    }
    virtual ~ClientBase()
    {
        ;
    }
    virtual int OnConnected()
    {
        log_error("ClientBase connect  ip:%s port:%d  SUCCESS n",GetSIP().c_str(),GetPort());
        return 0;
    }
    virtual int OnClose()
    {
        log_error("ClientBase ip:%s port:%d  CLOSE. reconnect flag:%d \n",GetSIP().c_str(),GetPort(),(GetReconnectFlag()?1:0));
        return 0;
    }

    ICC_Decoder* CreateDecoder()
    {
        return new QEDecoder();

    }
    virtual char* ClientName()
    {
        return "ClientBase";
    }

    //链接
    int InitConnect(char* ip,int port)
    {
        if(!ip)
        {
            log_error("ClientBase Error ip NULL\n");
            return -1;
        }

        SetSIP(ip);
        SetPort(port);
        EnableReconnect();
        int iret=-1;
        iret=Connect();
        if(iret<0)
        {
            log_error("ClientBase connect  ip:%s port:%d  ERROR\n",ip,port);
            return iret;
        }

        log_error("ClientBase connect  ip:%s port:%d  ...\n",ip,port);
        return 0;
    }
    int Send(NETOutputPacket* pPacket)
    {
        int ret = CCSocketHandler::Send(pPacket->packet_buf(), pPacket->packet_size());
        if(ret<0)
        {            
            log_error("%s Send data error, ret=%d",s_cliname.c_str(),ret);
        }
        return ret;
    }

    int Send(const char * data, int len)
    {
        int ret=CCSocketHandler::Send(data,len);
        if(ret<0)
        {
            //log_error("%s Send data error, ret=%d",ClientName(),ret);
            //char* p=ClientName();
            log_error("%s Send data error, ret=%d",s_cliname.c_str(),ret);
        }
        return ret;
    }
public:

    string s_cliname;
};

#endif


