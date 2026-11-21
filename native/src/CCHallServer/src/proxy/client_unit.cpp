#include <stdio.h>
#include <sys/un.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <client_unit.h>
#include <decode_unit.h>
#include <memcheck.h>
#include <log.h>
#include <sys/types.h>
#include <iomanip>
#include <fstream>
#include <ctime>
#include <iostream>
#include <cache.h>
#include "mempool.h"
#include <iomanip>
#include <fstream>
#include <ctime>
#include <iostream>
#include <helper_unit.h>
#include <memcheck.h>
#include <CHelper_pool.h>
#include <sstream>
#include <defs.h>
#include <MarkupSTL.h>
#include "Decoder.h"
#include "ICHAT_PacketBase.h" 
#include "incoming.h"

using namespace comm::sockcommu;

#define MAX_ERR_RSP_MSG_LEN 4096

extern CMemPool*	_webMp;

HTTP_SVR_NS_BEGIN

extern std::map<int,CHelperPool *> _helperpoolMap;

CClientUnit::CClientUnit(CDecoderUnit* decoderunit, int fd): 
CPollerObject (decoderunit->pollerunit(), fd),
_stage (CONN_IDLE),
_login_flag(0),
_r(*_webMp),
_w(*_webMp),
_decoderunit (decoderunit),
_uid(0),
_gameID(-1),
_prototype(T_PROTOTYPE_UNKNOW)
{
}

CClientUnit::~CClientUnit (void)
{
	_w.skip( _w.data_len() );
	_r.skip( _r.data_len() );
}

int CClientUnit::Attach (void)
{
    EnableInput ();
    
	if (AttachPoller() == -1)
	{
        log_error ("invoke CPollerObject::AttachPoller() failed.");
		return -1;
	}
	_stage = CONN_IDLE;
    AttachTimer(_decoderunit->get_web_timer());
    return 0;
}

int CClientUnit::recv (void)
{    
    int ret = proc_pkg();
    switch (ret)
    {
        default:
        case DECODE_FATAL_ERROR:
            DisableInput ();
            log_warning ("decode fatal error netfd[%d] stage[%d] msg[%s]", netfd, _stage, strerror(errno));
            _stage = CONN_FATAL_ERROR;
            return -1;

        case DECODE_DATA_ERROR:
            DisableInput ();
            log_warning ("decode error, netfd[%d] stage[%d] msg[%s]", netfd, _stage, strerror(errno));
            _stage = CONN_DATA_ERROR;
            break;
		case DECODE_WAIT_HEAD:
		case DECODE_WAIT_CONTENT:
			_stage = CONN_DATA_RECVING;
			//log_debug ("recving data, netfd[%d] stage[%d] msg[%s]", netfd, _stage, strerror(errno));
			break; 
        case DECODE_DONE:
            _stage = CONN_RECV_DONE;
            log_debug ("decode done, netfd[%d], stage[%d]", netfd, _stage);
            break;     

        case DECODE_DISCONNECT_BY_USER:
            DisableInput ();
            log_notice ("disconnect by user, netfd[%d] stage[%d] msg[%s]", netfd, _stage, strerror(errno));
            _stage = CONN_DISCONNECT;
            break;
    }

	return 0;
}

int CClientUnit::send (void)
{
    //log_debug("CClientUnit response bufLen:[%d] netfd[%d]", _w.data_len(), netfd);	
    if(_w.data_len()!=0 && _prototype==T_PROTOTYPE_QE2)
    {
        //TODO:暂时先不考虑一个_w有多个 PKG的情况;
        NETOutputPacket opk;
        TTransRet tret={0};
        bool ret = opk.Copy(_w.data(),_w.data_len());
        if( !ret){
        	log_error("pkg copy fail");  //当出现错误时，避免crash,暂时未找到w.len 很长的根本原因
        	return -1;
        }
        tret=opk.FlushToInputBuf();
        _w.skip(_w.data_len());
        _w.append(tret.pBuf,tret.nLen);
    }

	if (_w.data_len() != 0)
	{		
		//log_debug("send packet before, length[%d]", _w.data_len());
		int ret = ::send (netfd, _w.data(), _w.data_len(), 0);
		//log_debug("sent packet length[%d] netfd[%d]", ret, netfd);
		if(-1 == ret)
		{
			if(errno == EINTR || errno == EAGAIN || errno == EINPROGRESS)
			{
				log_debug("errno:[%d]", errno);
				EnableOutput ();
				ApplyEvents ();
				return CONN_DATA_SENDING;
			}
		
			//log_debug ("sending package to client failed, ret[%d]",  ret);	
			DisableInput ();
			DisableOutput ();
			ApplyEvents ();
			_stage = CONN_FATAL_ERROR;
			return -1;
		}

		if(ret == (int)_w.data_len())
		{
			//log_debug("send complete");
			DisableOutput();
			ApplyEvents ();
			_w.skip(ret);	
			_stage = CONN_SEND_DONE;
		
			return ret;
		}
		else if (ret < (int)_w.data_len())
		{
			log_debug("had sent part of data");
			EnableOutput ();
			ApplyEvents ();
			_w.skip(ret);
			_stage = CONN_DATA_SENDING;
			return ret;
		}
	}

	DisableOutput();
	ApplyEvents ();	
	_stage = CONN_FATAL_ERROR;
	log_debug("send process failure");
	return -1;
}

int CClientUnit::InputNotify (void)
{
    update_timer();
    recv();
    return _decoderunit->web_input ();
}

int CClientUnit::OutputNotify (void)
{
    update_timer();
    send();
    return _decoderunit->web_output();
}

int CClientUnit::HangupNotify (void)
{
    update_timer();
    log_notice("*STEP: web connection is hangup, netfd[%d] stage[%d]", netfd, _stage);
    return _decoderunit->web_hangup();
}

void CClientUnit::TimerNotify(void)
{
    log_warning("*STEP: web client timer expired, fd[%d] timeout, stage[%d]", netfd, _stage);
	_decoderunit->web_timer();
    return;
}

void CClientUnit::update_timer(void)
{
    DisableTimer();	
    AttachTimer(_decoderunit->get_web_timer());
}

void CClientUnit::add_rsp_buf(const char* data, unsigned int len)
{
	_w.append(data, len);
}

TDecodeStatus CClientUnit::proc_pkg ()
{
	int     curr_recv_len   = 0;
	char    curr_recv_buf[MAX_WEB_RECV_LEN] = {'\0'};

	curr_recv_len = ::recv (netfd, curr_recv_buf, MAX_WEB_RECV_LEN, 0);
	//log_debug ("*STEP: receiving HTTP request, length[%d], request[%s]", curr_recv_len, curr_recv_buf);
	//log_debug ("*STEP: receiving HTTP request, length[%d]", curr_recv_len);
	if(-1 == curr_recv_len)
	{
		if(errno != EAGAIN && errno != EINTR && errno != EINPROGRESS)
		{
			_decodeStatus = DECODE_FATAL_ERROR;
			log_warning ("recv failed from fd[%d], msg[%s]", netfd, strerror(errno));
			return _decodeStatus;
		}
		return _decodeStatus;
	}

	if(0 == curr_recv_len)
	{
		_decodeStatus = DECODE_DISCONNECT_BY_USER;
		//log_notice ("connection disconnect by user fd[%d], msg[%m]", netfd);
		log_debug("%s||Connect disconnect by client, uid:[%d]", __FUNCTION__, _uid);
		return _decodeStatus;
	}

	if(curr_recv_len==23 && curr_recv_buf[0]=='<' && curr_recv_buf[1]=='p')		
	{	
		_decoderunit->set_conn_type(CONN_OTHER);
		std::string policy = "<policy-file-request/>";			
		for(int i=0; i<23; ++i)			
		{				
			if(curr_recv_buf[i] != policy[i])				
			{					
				_decodeStatus = DECODE_FATAL_ERROR;	
				return _decodeStatus;
			}
		}
		std::string resPolicy ="<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0";
		_w.append(resPolicy.c_str(), resPolicy.size());
		send();	
		_decodeStatus = DECODE_FATAL_ERROR;					
		return _decodeStatus;
	}

	_r.append(curr_recv_buf, curr_recv_len);

	while(_r.data_len() > 0)
    {
        int inputRet = HandleInput(_r.data(), _r.data_len(),_prototype);
        if(inputRet < 0)
        {
            _decodeStatus = DECODE_FATAL_ERROR;
            return _decodeStatus;
        }
        else if(inputRet == 0)
        {
            _decodeStatus = DECODE_WAIT_CONTENT;
            return _decodeStatus;
        }

        int handleInputBufRet = HandleInputBuf(_r.data() , inputRet);            
        if( handleInputBufRet < 0 )           
        { 
            _decodeStatus = DECODE_FATAL_ERROR;                 
            return _decodeStatus;            
        }              
        _r.skip(inputRet);
        if(_prototype==T_PROTOTYPE_QE2)
        {
            _r.skip(sizeof(QE2Header)-sizeof(TPkgHeader));
        }
    }
	
	_decodeStatus = DECODE_WAIT_HEAD;
	return _decodeStatus;
}



bool CClientUnit::CheckCmd(int cmd)
{
	/*
	for(int i=0; i<(int)_helperpool->m_cmdlist.size(); i++)
	{
		if(cmd == _helperpool->m_cmdlist[i])
			return true;
	}
	*/
	return false;
}
int CClientUnit::OnUserHeartBeat(const char* pData, int len, int tid, string ip,int port)
{
	CGameUnit *pGameUnit = _decoderunit->get_game_unit();
	if (pGameUnit != NULL)
	{
		pGameUnit->addr = ip;
		pGameUnit->port = port;
		pGameUnit->tid = tid;
		pGameUnit->append_pkg(pData, len);
		//log_debug(" OnUserHeartBeat  tid[%d],ip[%s],port[%d]", tid, pGameUnit->addr.c_str(), pGameUnit->port);

		return pGameUnit->send_to_logic(_decoderunit->get_helper_timer());
	}
	else
	{
		//fatal error.gameserver close the connection by one side.
		log_debug("pGameUnit == NULL _uid[%d]", _uid);
	}
	return 0;
}
int CClientUnit::HandleInputGameServerBuf(const char* pData, int len)
{
	NETInputPacket reqPacket;
 	reqPacket.Copy(pData, len);
	CGameUnit *pGameUnit = _decoderunit->get_game_unit();

	int cmd = reqPacket.GetCmdType();
	short gameID = reqPacket.GetGameID();

	if(pGameUnit != NULL)
	{

	    if(cmd == CMD_BULL_LOGIN_TID || 
	    	cmd == CMD_ROBOT_LOGIN_TID || 
	    	cmd == CMD_SLOT_LOGIN_TID ||
	    	cmd == CMD_PRIROOM_LOGIN_TID || 
	    	cmd == CMD_HUNDRED_LOGIN_TID ||
	    	cmd == CMD_CUSTOM_LOGIN_TID) 
	    {
	    	int tid = 0;
	    	CEncryptDecrypt encryptdecrypt;
	    	encryptdecrypt.DecryptBuffer(&reqPacket);
	    	if(cmd == CMD_BULL_LOGIN_TID ||
	    	   cmd == CMD_ROBOT_LOGIN_TID ||
	    	   cmd == CMD_PRIROOM_LOGIN_TID){
	    		tid = reqPacket.ReadInt();
	    	}else if(cmd == CMD_SLOT_LOGIN_TID ||
	    		     cmd == CMD_HUNDRED_LOGIN_TID ||
	    		     cmd == CMD_CUSTOM_LOGIN_TID){
	    		int uid = reqPacket.ReadInt();
	    		tid = reqPacket.ReadInt();
	    	}
	    	std::map<int,CHelperPool *>::iterator iter =  _helperpoolMap.find(gameID);
	    	if(iter  != _helperpoolMap.end()){
	    		int svid = tid>>16;
	    		CHelperPool *helperpool = iter->second;
				map<int, LogicInfo>::iterator it = helperpool->m_logicmap.find(svid);
				if(it != helperpool->m_logicmap.end()){
					LogicInfo &logicinfo = it->second;
					pGameUnit->addr = logicinfo.ip;
					pGameUnit->port = logicinfo.port;
					pGameUnit->tid = tid;
					log_debug("cmd[0x%x] login  tid[%d],svid[%d],ip[%s],port[%d]",cmd, tid, svid,pGameUnit->addr.c_str(),pGameUnit->port);
					if(pGameUnit->get_netfd() > 0){
						log_error("game[%d]cmd[0x%x] login  tid[%d],svid[%d],error netfd[%d]",(int)gameID,cmd, tid, svid,pGameUnit->get_netfd());
						pGameUnit->reset_helper();
					}
				}else{
					log_error("game[%d]cmd[0x%x] login can't find tid[%d],svid[%d]",(int)gameID,cmd, tid, svid);
					return 0;
				}
	    	}else{
	    		log_error("game[%d]cmd[%d] not pool",(int)gameID,cmd);
	    		return 0;
	    	}


			//CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_room_login_count ");
/*			CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_room_login_count_%s ", 
				CIncoming::Instance()->m_datestring.c_str());
			CIncoming::Instance()->m_MonitorRedis.SADD("SADD bullfight_monitor_room_login_set_%s  %d ", 
				CIncoming::Instance()->m_datestring.c_str(), this->get_uid());*/
	    }

	    log_debug("game[%d]cmd[0x%x] ",(int)gameID,cmd);
	    if(_prototype==T_PROTOTYPE_QE2)
	    {
	        NETInputPacket tempPacket;
	        tempPacket.InitFromInputBuf(pData, len);
	        pGameUnit->append_pkg(tempPacket.packet_buf(), tempPacket.packet_size());
	    }
	    else
	    {
	        pGameUnit->append_pkg(pData, len);
	    }
	    return pGameUnit->send_to_logic(_decoderunit->get_helper_timer());
	}
	else
	{
		//fatal error.gameserver close the connection by one side.
		log_debug("pGameUnit == NULL _uid[%d]",_uid);
	}
	return 0;
}

int CClientUnit::HandleInputBuf(const char *pData, int len)
{
	NETInputPacket reqPacket;
    //QE2.0协议兼容
    if(_prototype==T_PROTOTYPE_QE2)
    {
        reqPacket.InitFromInputBuf(pData,len);
    }
    else
    {
        reqPacket.Copy(pData, len);
    }
	short gameID = reqPacket.GetGameID();
    int cmd=reqPacket.GetCmdType();
	//log_debug("Receive Packet GameID:%d,cmd=0x%x\n",gameID,cmd);
	std::map<int,CHelperPool *>::iterator iter =  _helperpoolMap.find(gameID);
	if(iter!=_helperpoolMap.end())
	{
		CHelperPool * pool = iter->second;
		if(pool == NULL)
		{
			log_error("Fatal Error Pool In Map Is NULL,RegionID:%d",gameID);
		}
		int iret = pool->DispatchPacket(this,reqPacket.packet_buf(),reqPacket.packet_size());
		return iret;
	}
	else
	{
		log_error("Invalid RegionID:%d Not Exist In HelperpoolMap",gameID);
	}
	return 0;
}


int CClientUnit::ResetHelperUnit()
{	
	CMarkupSTL  markup;
    if(!markup.Load("../conf/server.xml"))
    {       
        log_error("Load server.xml failed.");
        return -1;
    }

    if(!markup.FindElem("SYSTEM"))
    {
        log_error("Can not FindElem [SYSTEM] in server.xml failed.");
        return -1;
    }

	if (!markup.IntoElem())    
	{        
		log_error ("IntoElem [SYSTEM] failed.");       
		return -1;    
	}
	
	if(markup.FindElem("Node"))
	{
	}
	return 0;
}

HTTP_SVR_NS_END

