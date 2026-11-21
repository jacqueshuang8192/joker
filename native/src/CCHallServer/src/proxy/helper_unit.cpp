#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include <log.h>
#include <helper_unit.h>
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
#include <sstream>
#include <client_unit.h>
#include "ICHAT_PacketBase.h"
#include "EncryptDecrypt.h"
#include "Decoder.h"
#include "CHelper_pool.h"
#include "incoming.h"

HTTP_SVR_NS_BEGIN
extern std::map<int,CHelperPool *> _helperpoolMap;

class TPkgHeader;
class CClientUnit; 

CHelperUnit::CHelperUnit(CPollerUnit* unit, CHelperPool *hp) : CPollerObject (unit),
		_stage (CONN_IDLE),
		_r(*_helpMp),
		_w(*_helpMp),
		_help_pool(hp)
{
}

CHelperUnit::~CHelperUnit ()
{
	reset_helper();
}

int CHelperUnit::send_to_logic (CTimerList* lst)
{
	_helperTimer = lst;
	EnableInput ();
	if (connect() < 0)
	{
		reset_helper();
		//log_debug("Connect logic server failed ip:[%s], port:[%d]", addr.c_str(), port);
		return -1;
	}
	AttachTimer(_helperTimer);
	return send_to_cgi();
	}
int CHelperUnit::reConnect(void)
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

int CHelperUnit::connect (void)
{
	int ret = -1;
	
	if (_stage == CONN_IDLE)
	{
		//printf("-------------------CHelperUnit::connect = [%s] [%d]", addr.c_str(), port);//zswx
		//fflush(stdout);
		ret = CNet::tcp_connect(&netfd, addr.c_str(), port, 0);
		log_debug("ip:[%s], port:[%d]", addr.c_str(), port);
	}
	else
	{
		if (netfd < 0)
		{
			//printf("-------------------CHelperUnit::connect = [%s] [%d]", addr.c_str(), port);//zswx
			//fflush(stdout);
			ret = CNet::tcp_connect(&netfd,addr.c_str(), port, 0);
			//log_debug("ip:[%s], port:[%d]", addr.c_str(), port);
	}
		else
		{
			ret = 0;
	}
	}

	log_debug("*STEP: PROXY CNet::tcp_connect ret :[%d], netfd:[%d]", ret, netfd);

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
		//log_debug("*STEP: PROXY connecting to logic, unix fd[%d]", netfd);
		goto exit;
	}
	_stage = CONN_CONNECTED;
	
exit:
	return AttachPoller();
}

int CHelperUnit::send_to_cgi(void)
{
	int ret = 0;
	//int reConnectCount = 0;
	//log_debug("_w data size:[%d]", _w.data_len());
//logic:		
	if (_w.data_len() != 0)
	{
		ret = ::send (netfd, _w.data(), _w.data_len(), 0);
		log_boot("*STEP: send_to_cgi, data_len:[%u], ret:[%d], errno:[%d], netfd:[%d]", _w.data_len(), ret, errno, netfd);
		//log_debug("sent packet size:[%d]", ret);
		if(-1 == ret)
		{
			if(errno == EINTR || errno == EAGAIN || errno == EINPROGRESS)
			{
				EnableOutput ();
				ApplyEvents ();		
				return CONN_DATA_SENDING;
			}
		
			//log_error("*STEP: sending package to logic server failed, ret code[%d]", ret);	
			DisableInput ();
			DisableOutput ();
			ApplyEvents();
			::close(netfd);
			netfd = -1;
			DetachPoller();
			//log_error("*STEP: sends a packet failure, empty cache");
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
		//log_debug ("*STEP: sending package to logic server in exception, netfd[%d]", netfd);
		return ret;
	}
	return ret;
}


int CHelperUnit::recv_from_cgi(void)
{
	int ret = ::recv (netfd, _curRecvBuf, MAX_HELPER_RECV_BUF, 0);	
	//log_debug("*STEP: recv from logic server fd[%d] recv len[%d] this time", netfd, ret);	
	if (-1 == ret)
	{
		//log_debug("*STEP: ret = -1");		
		if((errno == EINTR) || (errno == EAGAIN) || (errno == EINPROGRESS))
		{
			_stage = CONN_DATA_RECVING;
			return 0;
		}		
		_stage = CONN_FATAL_ERROR;
		//log_error ("*STEP: recv from logic server failed, unix fd[%d]", netfd);
		return -1;
	}

	if (0 == ret)
	{
		_stage = CONN_DISCONNECT;
		//log_debug ("*STEP:logic server close, unix fd[%d]", netfd);
		return -1;
	}
		
	_r.append(_curRecvBuf, ret);
	if(process_pkg() < 0)
	{
		_stage = CONN_FATAL_ERROR;
		return -1;
	}
	_stage = CONN_RECV_DONE;
	//log_debug("*STEP: recving from logic server complete, unix fd[%d] current recv len[%d]", netfd, ret);
	return ret;
} 

int CHelperUnit::InputNotify (void)
{
	update_timer();
	int ret = recv_from_cgi();
	if (ret < 0)
	{
		//log_error("call recv failed, helper client netfd[%d]", netfd); 
		reset_helper();
		return POLLER_COMPLETE;
	}
	return POLLER_SUCC;
}

int CHelperUnit::OutputNotify (void)
{
	update_timer();
	send_to_cgi();
	return POLLER_SUCC;
}

int CHelperUnit::HangupNotify (void)
{
	//log_debug("CHelperUnit object hangup notify: fd[%d]", netfd);
	update_timer();
	process_pkg();
	reset_helper();
	return POLLER_COMPLETE;
}

void CHelperUnit::TimerNotify (void)
{
	//log_debug ("*STEP: timer expired, unix fd[%d], timeout.", netfd);
	reset_helper();
}

void CHelperUnit::update_timer(void)
{
	DisableTimer();
	AttachTimer(_helperTimer);
}

int CHelperUnit::append_pkg(const char* buf, unsigned int len)
{
	_w.append(buf, len);
	return 0;
}

int CHelperUnit::ProcessUserJoinGame(CDecoderUnit* pDecoder, NETInputPacket* pPacket)
{
	if (pDecoder == NULL)
	{
		log_debug("ProcessUserJoinGame||pDecoder is NULL");
		return 0;
	}
	CEncryptDecrypt decrypt;
	decrypt.DecryptBuffer(pPacket);
	int tid = pPacket->ReadInt();
	short serverId = pPacket->ReadShort();
	(void)serverId;

	string ip = pPacket->ReadString();
	int port = pPacket->ReadInt();
	int res = pPacket->ReadInt();
	CGameUnit *pGameUnit = pDecoder->get_game_unit();
	// if(pGameUnit != NULL)
	// {
	// 	log_debug("ProcessUserJoinGame||uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
	// 	pGameUnit->addr = ip;
	// 	pGameUnit->port = port;
	// 	pGameUnit->tid = tid;
	// }
	//log_boot("ProcessUserJoinGame uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
	if(pGameUnit != NULL){
		//log_error("ProcessUserJoinGame uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
		int svid = tid>>16;
		map<int, LogicInfo>::iterator it = _help_pool->m_logicmap.find(svid);
		if(it != _help_pool->m_logicmap.end()){
			LogicInfo &logicinfo = it->second;
			logicinfo.ip = ip;
			logicinfo.port = port ;
		}else{
			LogicInfo logicinfo;
			logicinfo.ip = ip;
			logicinfo.port = port;
			_help_pool->m_logicmap[svid] = logicinfo;
	}
	}
	return 0;
}

int CHelperUnit::ProcessUserLoginSuccess(CDecoderUnit* pDecoder, NETInputPacket* pPacket)
{
	//printf("-------------------ProcessUserLoginSuccess");
	//fflush(stdout);
	if (pDecoder == NULL)
	{
		log_debug("ProcessUserLoginSuccess||pDecoder is NULL");
		return 0;
	}
	CEncryptDecrypt decrypt;
	decrypt.DecryptBuffer(pPacket);
	int ver = pPacket->ReadInt();
	(void)ver;
	int levelCount = pPacket->ReadInt();
	for(int i=0; i<levelCount; i++)
	{
		pPacket->ReadInt();
	}
	int friendCount = pPacket->ReadInt();
	(void)friendCount;
	int tid = pPacket->ReadInt();
	if(tid > 0)
	{
		string ip = pPacket->ReadString();
		int port = pPacket->ReadInt();
		CGameUnit *pGameUnit = pDecoder->get_game_unit();
		// if(pGameUnit != NULL)
		// {
		// 	log_debug("ProcessUserLoginSuccess||uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
		// 	pGameUnit->addr = ip;
		// 	pGameUnit->port = port;
		// 	pGameUnit->tid = tid;	
		// }

		if(pGameUnit != NULL)
		{
			//log_error("ProcessUserLoginSuccess||uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
			int svid = tid>>16;
			map<int, LogicInfo>::iterator it = _help_pool->m_logicmap.find(svid);
			if(it != _help_pool->m_logicmap.end()){
				LogicInfo &logicinfo = it->second;
				logicinfo.ip = ip;
				logicinfo.port = port ;
			}else{
				LogicInfo logicinfo;
				logicinfo.ip = ip;
				logicinfo.port = port;
				_help_pool->m_logicmap[svid] = logicinfo;
			}
	}
		//CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_reconn_count ");
/*		CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_reconn_count_%s ", 
			CIncoming::Instance()->m_datestring.c_str());
		CIncoming::Instance()->m_MonitorRedis.SADD("SADD bullfight_monitor_reconn_set_%s  %d ",
			CIncoming::Instance()->m_datestring.c_str(), pDecoder->get_flag());*/
	}
	//CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_login_count ");
/*	CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_login_count_%s ", 
		CIncoming::Instance()->m_datestring.c_str());
	CIncoming::Instance()->m_MonitorRedis.SADD("SADD bullfight_monitor_login_set_%s  %d ", 
		CIncoming::Instance()->m_datestring.c_str(), pDecoder->get_flag());
*/
	return 0;
}

int CHelperUnit::SendPacketToLogic(const char * buf,unsigned int len,CTimerList* lst)
{
	log_boot("*STEP: SendPacketToLogic, len:[%u], _stage:[%d], netfd:[%d]", len, _stage, netfd);
	if (_stage != CONN_IDLE)
	{
		log_boot("*STEP: SendPacketToLogic, resetting helper before send");
		reset_helper();
	}
	append_pkg(buf,len);
	log_boot("*STEP: SendPacketToLogic, after append_pkg, _w.data_len:[%u]", _w.data_len());
	return send_to_logic(lst);
}


int CHelperUnit::process_pkg(void)
{
	int headLen  = sizeof(struct TPkgHeader);
	int totalLen = _r.data_len();
	//log_debug("forward packets to the client start headLen[%d],totalLen[%d]", headLen, totalLen);
	while( totalLen > 0)
	{
        int protype=0;
		int inputRet = HandleInput(_r.data(), _r.data_len(),protype);
		if(inputRet == 0)
		{
			break;
	}
		else if (inputRet<0)
		{
			return -1;
	}
		
		NETInputPacket tranPacket;
		tranPacket.Copy(_r.data(), inputRet);
		short regionID = tranPacket.GetRegionID();
		//log_debug("Receive Packet RegionID:%d",regionID);
		std::map<int,CHelperPool *>::iterator iter =  _helperpoolMap.find(regionID);
		if(iter!=_helperpoolMap.end())
		{
			CHelperPool * pool = iter->second;
			if(pool == NULL)
			{
				//log_error("Fatal Error Pool In Map Is NULL,RegionID:%d",regionID);
			}
			int iret = pool->DispatchBackPacket(this,tranPacket);
			(void)iret;
	}
		else
		{
			//log_debug("Invalid RegionID:%d Not Exist In HelperpoolMap",regionID);
	}
		_r.skip(inputRet);
		totalLen -= inputRet;
	}
	//log_debug("forward packets to the client end");
	return 0;
}


int CHelperUnit::RandomSvid(vector<int>& v)
{
	int size = (int)v.size();
	srand((unsigned)time(NULL));
	int value = rand()%size;
	return v[value];
}
void CHelperUnit::reset_helper(void)
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

void CHelperUnit::ProcessUserClose(int uid)
{
	if(uid == 0){
		return;
	}
	log_debug("CHelperUnit ProcessUserClose||uid[%d]", uid);
	NETOutputPacket packet;
	packet.Begin(CLIENT_CLOSE_PACKET);
	packet.WriteInt(uid);
	packet.WriteInt(TGlobal::_svid);
	packet.End();
	SendPacketToLogic(packet.packet_buf(),packet.packet_size(),_helperTimer);;
	return;
}

int CHelperUnit::ProcessJoinPrivateRoom(int uid, CDecoderUnit* pDecoder, NETInputPacket* pPacket)
{
	if (pDecoder == NULL)
	{
		log_debug("ProcessJoinPrivateRoom||pDecoder is NULL");
		return 0;
	}
	CEncryptDecrypt decrypt;
	decrypt.DecryptBuffer(pPacket);
	int ret = pPacket->ReadShort();
	if(ret == 0)
	{
		int tid = pPacket->ReadInt();
		short serverId = pPacket->ReadShort();
		(void)serverId;
		short level = pPacket->ReadShort();
		(void)level;
		string ip = pPacket->ReadString();
		int port = pPacket->ReadInt();
		CGameUnit *pGameUnit = pDecoder->get_game_unit();
		// if(pGameUnit != NULL)
		// {
		// 	log_debug("uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
		// 	pGameUnit->addr = ip;
		// 	pGameUnit->port = port;
		// 	pGameUnit->tid = tid;
		// }

		if(pGameUnit != NULL){
			//log_error("ProcessUserJoinGame uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
			int svid = tid>>16;
			map<int, LogicInfo>::iterator it = _help_pool->m_logicmap.find(svid);
			if(it != _help_pool->m_logicmap.end()){
				LogicInfo &logicinfo = it->second;
				logicinfo.ip = ip;
				logicinfo.port = port ;
			}else{
				LogicInfo logicinfo;
				logicinfo.ip = ip;
				logicinfo.port = port;
				_help_pool->m_logicmap[svid] = logicinfo;
			}
		}	
	}
	
	return 0;
}


int CHelperUnit::ProcessJoinCustomRoom(int uid, CDecoderUnit* pDecoder, NETInputPacket* pPacket)
{
	if (pDecoder == NULL)
	{
		log_debug("ProcessJoinCustomRoom||pDecoder is NULL");
		return 0;
	}
	CEncryptDecrypt decrypt;
	decrypt.DecryptBuffer(pPacket);
	int ret = pPacket->ReadShort();
	if(ret == 0)
	{
		int tid = pPacket->ReadInt();
		short serverId = pPacket->ReadShort();
		(void)serverId;
		short level = pPacket->ReadShort();
		(void)level;
		string ip = pPacket->ReadString();
		int port = pPacket->ReadInt();
		CGameUnit *pGameUnit = pDecoder->get_game_unit();

		if(pGameUnit != NULL){
			//log_error("ProcessJoinCustomRoom uid:[%d], tid:[%d], ip:[%s], port:[%d]", pDecoder->get_flag(), tid, ip.c_str(), port);
			int svid = tid>>16;
			map<int, LogicInfo>::iterator it = _help_pool->m_logicmap.find(svid);
			if(it != _help_pool->m_logicmap.end()){
				LogicInfo &logicinfo = it->second;
				logicinfo.ip = ip;
				logicinfo.port = port ;
			}else{
				LogicInfo logicinfo;
				logicinfo.ip = ip;
				logicinfo.port = port;
				_help_pool->m_logicmap[svid] = logicinfo;
			}
		}	
	}
	
	return 0;
}


int CHelperUnit::RegesterHall(CTimerList* lst)
{
	NETOutputPacket packet;
	packet.Begin(HALL_MATCH_REGIST_CMD);
	packet.WriteInt(TGlobal::_svid);
	packet.End();
	SendPacketToLogic(packet.packet_buf(),packet.packet_size(),lst);
	return 0;
}


HTTP_SVR_NS_END

