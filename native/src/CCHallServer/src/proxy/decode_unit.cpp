#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <decode_unit.h>
#include <client_unit.h>
#include <helper_unit.h>
#include <game_unit.h>
#include <listener.h>
#include <memcheck.h>
#include <log.h>
#include <sys/types.h>
#include <iomanip>
#include <fstream>
#include <ctime>
#include <iostream>
#include <timestamp.h>
#include <CHelper_pool.h>
#include <sstream>
#include "ICHAT_PacketBase.h"
#include "incoming.h"

HTTP_SVR_NS_BEGIN
extern std::map<int,CHelperPool *> _helperpoolMap;

void HexDumpImp0(const void *pdata, unsigned int len, int num)
{
	if(pdata == 0 || len == 0)
		return;
	
	int cnt  = 0;
	int n    = 0;
	int cnt2 = 0;
	
	const char *data = (const char *)pdata;
	cout<<"Address               Hexadecimal values                  Printable\n";
	cout<<"-------  -----------------------------------------------  -------------\n";
	cout<<"num:[" << num << "]";
	cout << "\n";
	
	unsigned char buffer[20];
	unsigned int rpos = 0;

	while ( 1 )
	{
		if(len <= rpos)
			break;

		if(len >= rpos + 16)
		{
			memcpy(buffer, data + rpos, 16);
			rpos += 16;
			cnt   = 16;
		}
		else
		{
			memcpy(buffer, data + rpos, len - rpos);
			cnt  = len - rpos;
			rpos = len;
		}

		if(cnt <= 0)
			return;

		cout << setw(7) << ( int ) rpos << "  ";

		cnt2 = 0;
		for ( n = 0; n < 16; n++ )
		{
			cnt2 = cnt2 + 1;
			if ( cnt2 <= cnt )
				cout << hex << setw(2) << setfill ( '0' ) <<  (unsigned int)buffer[n];
			else
				cout << "  ";

			cout << " ";
		}

		cout << setfill ( ' ' );
		cout << " ";

		cnt2 = 0;
		for ( n = 0; n < 16; n++ )
		{
			cnt2 = cnt2 + 1;
			if ( cnt2 <= cnt )
			{
				if ( buffer[n] < 32 || 126 < buffer[n] )
					cout << '.';
				else
					cout << buffer[n];
			}
		}

		cout << "\n";
		cout << dec;
	}
}


extern std::map<int,CHelperPool *> _helperpoolMap;

CDecoderUnit::CDecoderUnit (CListener* owner) : 
_pollerUnit(NULL),
_webTimer (NULL),
_helperTimer (NULL),
_webUnit (NULL),
_gameUnit (NULL),
_listener (owner),
_flag(0),
_fd(0),
_conn_type(CONN_CLINET)
{
}

CDecoderUnit::~CDecoderUnit (void)
{	
	std::map<int,CHelperPool *>::iterator iterHelpPool = _helperpoolMap.find(_webUnit->_gameID);
	if(iterHelpPool != _helperpoolMap.end())
	{
		CHelperPool * php = iterHelpPool->second;
		if (php!=NULL)
		{
			std::map<int, CDecoderUnit*>::iterator iter = php->m_objmap.find(_flag);
			if(iter != php->m_objmap.end())
			{
				php->m_objmap.erase(iter);
			}
			log_debug("delete object from map, length[%d]", (int)php->m_objmap.size());	
		}
		else
		{
			log_error("[%s|%d] Fatal Error.",__FUNCTION__,__LINE__);
		}
	}
	else
	{
		log_error("[%s|%d] Fatal Error.",__FUNCTION__,__LINE__);
	}

	if (NULL == _gameUnit || _gameUnit->get_netfd()<=0)
	{
		//CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_hall_offline_count ");
		/*CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_hall_offline_count_%s ", 
			CIncoming::Instance()->m_datestring.c_str());
		CIncoming::Instance()->m_MonitorRedis.SADD("SADD bullfight_monitor_hall_offline_set_%s  %d ", 
			CIncoming::Instance()->m_datestring.c_str(), get_flag());*/
	}
	else
	{
		//CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_room_offline_count ");
	/*	CIncoming::Instance()->m_MonitorRedis.INCR("INCR  bullfight_monitor_room_offline_count_%s ", 
			CIncoming::Instance()->m_datestring.c_str());
		CIncoming::Instance()->m_MonitorRedis.SADD("SADD bullfight_monitor_room_offline_set_%s  %d ", 
			CIncoming::Instance()->m_datestring.c_str(), get_flag());*/
	}

	DELETE (_webUnit);
	DELETE (_gameUnit);
}

int CDecoderUnit::listener_input (void)
{
	NEW (CClientUnit(this, _fd), _webUnit);
	if (NULL == _webUnit)
	{
		log_error ("create CClient object failed, errno[%d], %m", errno);
		return -1;
	}

	NEW(CGameUnit(this), _gameUnit);
	if(NULL == _gameUnit)
	{
		log_error ("create helper object failed, errno[%d], %m", errno);
		return -1;
	}

	//set user id
	_webUnit->set_netfd(_fd);
	if (_webUnit->Attach() == -1)
	{
		log_error ("Invoke CClient::Attach() failed");
		return -1;
	}
	return 0;
}

int CDecoderUnit::web_input (void)
{
	int webfd   = _webUnit->get_netfd ();
	int stage   = _webUnit->get_state ();

	switch (stage)
	{
		case CONN_DATA_ERROR:
			log_warning("web input decode error, webfd[%d], stage[%d]", webfd, stage);
			_listener->complete (this);
			return POLLER_COMPLETE;

		case CONN_DISCONNECT:
			log_notice("web input disconnect by user, webfd[%d], stage[%d]", webfd, stage);
			_listener->complete(this);
			return POLLER_COMPLETE;

		case CONN_DATA_RECVING:
		case CONN_IDLE:
			return POLLER_SUCC;

		case CONN_RECV_DONE:			
			return POLLER_SUCC;

		case CONN_FATAL_ERROR:
			log_error("web input fatal error, webfd[%d], stage[%d]", webfd, stage);
			_listener->complete (this);
			return POLLER_COMPLETE;

		default:
			log_error("web input unknow status, webfd[%d], stage[%d]", webfd, stage);
			_listener->complete (this);
			return POLLER_COMPLETE;
		}
}


int CDecoderUnit::ProcessUserClose()
{
	if(_flag == 0)
		return 0;
	log_debug("%s||Connect close, uid:[%d]", __FUNCTION__, _flag);
	NETOutputPacket packet;
	packet.Begin(CLIENT_CLOSE_PACKET);
	packet.WriteInt(_flag);
	packet.WriteInt(TGlobal::_svid);
	packet.End();
	CHelperPool * php = NULL;
	if (_webUnit->_gameID >=0 ){
		std::map<int,CHelperPool *>::iterator hpiter = _helperpoolMap.find(_webUnit->_gameID);
		if(hpiter != _helperpoolMap.end()){
			php = hpiter->second;
		}
		else{
			//fatal error
		}
	}
	if (php != NULL){
		if((int)php->m_svidlist.size() > 0){
			//int svid = php->RandomSvid(php->m_svidlist);
			int svid = 1;
			CHelperUnit *pHelperUnit = php->m_helpermap[svid];
			if(pHelperUnit != NULL){
				pHelperUnit->SendPacketToLogic(packet.packet_buf(),packet.packet_size(),get_helper_timer());
			}
		}
	}
	else{
		//fatal error
	}
	return 0;
}

int CDecoderUnit::SendPacketToClient(const char * buffer,int size)
{
	if(_webUnit != NULL){
		_webUnit->add_rsp_buf(buffer,size);
		return _webUnit->send();
	}
	else{
		return -1;
	}
}
 
int CDecoderUnit::web_output (void)
{
	int stage = _webUnit->get_state();
	switch (stage)
	{
		case CONN_SEND_DONE:
			log_debug ("reponse data completed, netfd[%d]", _webUnit->get_netfd());
		    return POLLER_COMPLETE;
		case CONN_DATA_SENDING:
		case CONN_APPEND_SENDING:
		case CONN_APPEND_DONE:
			if (_webUnit->send() < 0)
			{
				_listener->complete (this);
				return POLLER_COMPLETE;
			}

			stage = _webUnit->get_state ();
			switch (stage)
			{
				case CONN_SEND_DONE:
					log_debug ("response data complete, netfd[%d]", _webUnit->get_netfd());
					return POLLER_COMPLETE;

				case CONN_DATA_SENDING:
				case CONN_APPEND_SENDING:
				case CONN_APPEND_DONE:
					log_debug ("responsing data, netfd[%d]", _webUnit->get_netfd());
					return POLLER_COMPLETE;

				default:
					log_debug ("response data to client failed, netfd[%d]", _webUnit->get_netfd());
					_listener->complete (this);
					return POLLER_COMPLETE;
			}

		default:
			log_debug ("response data to client failed, netfd[%d],stage[%d]", _webUnit->get_netfd(), stage);
			_listener->complete (this);
			return POLLER_COMPLETE;
	}
}
 
int CDecoderUnit::web_hangup(void)
{
	_listener->complete(this);
	return POLLER_COMPLETE;    
} 

int CDecoderUnit::web_timer(void)
{
	_listener->complete(this);
	return POLLER_COMPLETE;
}

void CDecoderUnit::complete (void)
{
	return _listener->complete (this);
}
HTTP_SVR_NS_END

