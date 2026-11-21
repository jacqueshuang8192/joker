#ifndef BOYAA_GLOBAL_H_20090608
#define BOYAA_GLOBAL_H_20090608

#include "ace/ACE.h"
#include "ace/Log_Msg.h"
#include "ace/SOCK_Acceptor.h"
#include "ace/streams.h"
#include "ace/Reactor.h"
#include "ace/OS.h"
#include "ace/Task.h"
//#include "ace/Method_Object.h"
#include "ace/Activation_Queue.h"
#include "ace/Auto_Ptr.h"
#include "ace/Future.h"
#include "ace/Acceptor.h"
#include "ace/Thread_Mutex.h"
#include "ace/Condition_T.h"
#include "ace/Dev_Poll_Reactor.h"
#include "ace/Select_Reactor.h"
#include "ace/Connector.h"
#include "ace/SOCK_Connector.h"
#include "ace/Map_Manager.h" 
#include "ace/ARGV.h"
#include "ace/Get_Opt.h"
#include "ace/Signal.h"

#include "ICHAT_PacketBase.h"
#include "ICHAT_PacketParser.h"
#include "wtypedef.h"

#include <map>
using namespace std;

//根据平台来选择不同的Reactor
#ifdef WIN32
	#define PLAT_ACE_REACTOR ACE_WFMO_Reactor		//windows使用wfmo
#else
	#define PLAT_ACE_REACTOR ACE_Dev_Poll_Reactor 	//linux 使用epoll模型//	ACE_Select_Reactor ACE_Dev_Poll_Reactor//
#endif

#define  RECV_BUFFER_SIZE (1024*8)		//8k的缓冲区
#define  SEND_BUFFER_SIZE (1024*3)		//3k的缓冲区

#define  MAX_CLIENT_SESSION_COUNT	16384
#define  MAX_GAMESERV_SESSION_COUNT	256

#define CLIENT_SERV_PORT	6000

enum ServStatus
{
	StatusConnected,
	StatusDisconnected,
};

void StopService();

#define USER_DISCONNECT_TIMER	0x106

#endif
