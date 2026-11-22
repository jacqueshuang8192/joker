#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include <log.h>
#include <game_unit.h>
#include <net.h>
#include <memcheck.h>
#include <extend_http.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <iomanip>
#include <fstream>
#include <ctime>
#include <iostream>
#include <socket.h>
#include <CHelper_pool.h>
#include <sstream>
#include <client_unit.h>
#include "ICHAT_PacketBase.h"
#include "EncryptDecrypt.h"
#include "Decoder.h"
#include "incoming.h"

HTTP_SVR_NS_BEGIN
extern std::map<int,CHelperPool *> _helperpoolMap;

class TPkgHeader;
class CClientUnit; 

CGameUnit::CGameUnit(CDecoderUnit* decoderunit) : CPollerObject (decoderunit->pollerunit()),
		_stage (CONN_IDLE),
		_decoderunit(decoderunit),
		_r(*_helpMp),
		_w(*_helpMp)
{
	addr = "0.0.0.0";
	port = 0;
	tid = 0;
}

CGameUnit::~CGameUnit ()
{
	reset_helper();
}

int CGameUnit::send_to_logic (CTimerList* lst)
{
	_helperTimer = lst;
	EnableInput ();
	if (connect() < 0)
	{
		reset_helper();
		//log_debug("Connect logic server ip[%s], port[%d] tid[%d] failed!",addr.c_str(), port, tid);
		return -1;
	}
	AttachTimer(_helperTimer);
	return send_to_cgi();
}

int CGameUnit::reConnect(void)
{
	int ret = -1;
	//log_debug("*STEP: PROXY CNet::reConnect before");
	ret = CNet::tcp_connect(&netfd, addr.c_str(), port, 0);
	//log_debug("*STEP: PROXY CNet::reConnect ret :[%d], netfd:[%d]", ret, netfd);
	if (ret < 0)
	{
		if (ret == SOCKET_CREATE_FAILED)
		{
			log_error("*STEP: helper create socket failed, errno[%d], msg[%s]", errno, strerror(errno));
			return -1;
		}
		if(errno != EINPROGRESS)
		{
			log_error("*STEP: PROXY connect to logic failed, errno[%d], msg[%s]",errno , strerror(errno));
			return -1;
		}
		_stage = CONN_CONNECTING;
		//log_debug("*STEP: PROXY connecting to logic, unix fd[%d]", netfd);
		goto exit;
	}
	_stage = CONN_CONNECTED;

exit:
	return AttachPoller();
}

int CGameUnit::connect (void)
{
	int ret = -1;

	//log_debug("*STEP: PROXY CNet::tcp_connect before");

	if (_stage == CONN_IDLE)
	{
		//printf("-------------------CGameUnit::connect = [%s] [%d]", addr.c_str(), port);//zswx
		//fflush(stdout);
		ret = CNet::tcp_connect(&netfd, addr.c_str(), port, 0);
		//log_debug("game_unit connect tid [%d], ip:[%s], port:[%d]", tid, addr.c_str(), port);
	}
	else
	{
		if (netfd < 0)
		{
			//printf("-------------------CGameUnit::connect = [%s] [%d]", netfd, addr.c_str(), port);//zswx
			//fflush(stdout);
			ret = CNet::tcp_connect(&netfd,addr.c_str(), port, 0);
			//log_debug("game_unit connect tid [%d],  ip:[%s], port:[%d]", tid, addr.c_str(), port);
		}
		else
		{
			ret = 0;
		}
	}

	//log_debug("*STEP: PROXY CNet::tcp_connect ret :[%d], netfd:[%d]", ret, netfd);

	if (ret < 0)
	{	
		if (ret == SOCKET_CREATE_FAILED)
		{
			log_error("*STEP: helper create socket failed, errno[%d], msg[%s]", errno, strerror(errno));
			return -1;
		}

		if(errno != EINPROGRESS)
		{
			log_error("*STEP: PROXY connect to logic failed, errno[%d], msg[%s]", errno , strerror(errno));
			return -1;
		}

		_stage = CONN_CONNECTING;
		log_debug("*STEP: PROXY connecting to logic, unix fd[%d]", netfd);
		goto exit;
	}
	_stage = CONN_CONNECTED;
	
exit:
	return AttachPoller();
}

int CGameUnit::send_to_cgi(void)
{
	int ret = 0;
	//log_debug("_w data size:[%d]", _w.data_len());
	if (_w.data_len() != 0)
	{
		ret = ::send (netfd, _w.data(), _w.data_len(), 0);
		//log_debug("sent packet size:[%d]", ret);
		if(-1 == ret)
		{
			if(errno == EINTR || errno == EAGAIN || errno == EINPROGRESS)
			{
				EnableOutput ();
				ApplyEvents ();		
				return CONN_DATA_SENDING;
			}
		
			log_error("*STEP: sending package to logic server failed, ret code[%d]", ret);	
			DisableInput ();
			DisableOutput ();
			ApplyEvents();
			::close(netfd);
			netfd = -1;
			DetachPoller();
			log_error("*STEP: sends a packet failure, empty cache");
			_w.skip( _w.data_len() );
			_r.skip( _r.data_len() );
			_stage = CONN_FATAL_ERROR;
			return -1;
		}

		if(ret == (int)_w.data_len())
		{
			_w.skip(ret);
			DisableOutput ();
			ApplyEvents();
			_stage = CONN_SEND_DONE;
			//log_debug ("*STEP: sent package to logic server, netfd[%d] packet size[%d]", netfd, ret);
			return ret;
		}
		else if (ret < (int)_w.data_len())
		{
			EnableOutput ();
			ApplyEvents ();	
			_w.skip(ret);
			_stage = CONN_DATA_SENDING;
			return ret;
		}
		DisableInput ();
		DisableOutput ();
		ApplyEvents();
		_stage = CONN_FATAL_ERROR;
		log_debug ("*STEP: sending package to logic server in exception, netfd[%d]", netfd);
		return ret;
	}
	return ret;
}


int CGameUnit::recv_from_cgi(void)
{
	char _curRecvBuf[MAX_HELPER_RECV_BUF] = {0};
	int ret = ::recv (netfd, _curRecvBuf, MAX_HELPER_RECV_BUF, 0);	
	//log_debug("*STEP: recv from logic server fd[%d] recv len[%d] this time", netfd, ret);	
	if (-1 == ret)
	{
		log_debug("*STEP: ret = -1");		
		if((errno == EINTR) || (errno == EAGAIN) || (errno == EINPROGRESS))
		{
			_stage = CONN_DATA_RECVING;
			return 0;
		}		
		_stage = CONN_FATAL_ERROR;
		log_error ("*STEP: recv from logic server failed, unix fd[%d]", netfd);
		return -1;
	}

	if (0 == ret)
	{
		_stage = CONN_DISCONNECT;
		log_debug ("*STEP:logic server close, unix fd[%d]", netfd);
		return -1;
	}
		
	_r.append(_curRecvBuf, ret);
	if(process_pkg() < 0)
		return -1;
	_stage = CONN_RECV_DONE;
	//log_debug("*STEP: recving from logic server complete, unix fd[%d] current recv len[%d]", netfd, ret);
	return ret;
} 

int CGameUnit::InputNotify (void)
{
	update_timer();
	int ret = recv_from_cgi();
	if (ret < 0)
	{
		log_error("call recv failed, helper client netfd[%d]", netfd); 
		reset_helper();
		_decoderunit->complete();
		return POLLER_COMPLETE;
	}
	return POLLER_SUCC;
}

int CGameUnit::OutputNotify (void)
{
	update_timer();
	if(send_to_cgi() < 0
)
	{
		reset_helper();
		_decoderunit->complete();
	}
	return POLLER_SUCC;
}

int CGameUnit::HangupNotify (void)
{
	log_debug("CHelperUnit object hangup notify: fd[%d]", netfd);
	update_timer();
	process_pkg();
	reset_helper();
	_decoderunit->complete();
	return POLLER_COMPLETE;
}

void CGameUnit::TimerNotify (void)
{
	log_debug ("*STEP: timer expired, unix fd[%d], timeout.", netfd);
	reset_helper();
	_decoderunit->complete();
}

void CGameUnit::update_timer(void)
{
	DisableTimer();
	AttachTimer(_helperTimer);
}

int CGameUnit::append_pkg(const char* buf, unsigned int len)
{
	_w.append(buf, len);
	return 0;
}

int CGameUnit::process_pkg(void)
{
	int headLen  = sizeof(struct TPkgHeader);
	int totalLen = _r.data_len();
	//log_debug("forward packets to the client start headLen[%d],totalLen[%d]", headLen, totalLen);
	while( totalLen > 0)
	{
        int protype=0;
		int pkglen = HandleInput(_r.data(), _r.data_len(),protype);
		if(pkglen < 0)
		{
			return -1;
		}
		else if(pkglen == 0)
		{
			break;
		}
		NETInputPacket tranPacket;
		tranPacket.Copy(_r.data(), pkglen);
		int cmd = tranPacket.GetCmdType();
	
		_decoderunit->SendPacketToClient(tranPacket.packet_buf(),tranPacket.packet_size());
		_r.skip(pkglen);
		totalLen -= pkglen;

        //log_debug("CGameUnit::process_pkg | recv cmd :%x", cmd);		

		if(cmd == SERVER_COMMAND_LOGOUT_SUCCESS || 
		   cmd == SERVER_COMMAND_LOGIN_FAILED || 
		   cmd == SERVER_COMMAND_KICKOUT ||
		   cmd == HUNDRED_CMD_LOOUT)//ó??§?y3￡í?3?·???￡?2????aclientunitá??ó
		{
			log_debug("CGameUnit::process_pkg | Logout Success");
			reset_helper();
			break;
		}

		if(cmd == SLOT_CMD_LOGOUT ||
			cmd == HUNDRED_CMD_LOOUT ||
			cmd == CUSTOM_CMD_LOOUT){
			CEncryptDecrypt decrypt;
			decrypt.DecryptBuffer(&tranPacket);
			int ret = tranPacket.ReadInt();
			if(ret == 0 || ret == 2){   //0-成功退出，2-server kick user
				log_debug("CGameUnit::process_pkg | cmd[%d] Logout Success ret[%d]",cmd,ret);
				reset_helper();
				break;
			}
		}
		

		if (SERVER_COMMAND_LOGIN_FAILED == cmd)
		{
			//CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_room_login_err_count ");
/*			CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_room_login_err_count_%s ", 
				CIncoming::Instance()->m_datestring.c_str());
			CIncoming::Instance()->m_MonitorRedis.SADD("SADD bullfight_monitor_room_login_err_set_%s  %d ", 
				CIncoming::Instance()->m_datestring.c_str(), _decoderunit->get_flag());*/
		}
	}
	//log_debug("forward packets to the client end");
	return 0;
}

void CGameUnit::reset_helper(void)
{
	//log_debug("reset helper object");
	_w.skip( _w.data_len() );
	_r.skip( _r.data_len() );
	DisableInput();
	DisableOutput();
	ApplyEvents();
	CPollerObject::DetachPoller();
	if(netfd > 0)
	{
		::close(netfd);
	}
	netfd  = -1;
	_stage = CONN_IDLE;
}

HTTP_SVR_NS_END

