#pragma once
#include <fstream>
#include "Global.h"
#include "SocketServer.h"

class ACE_Application
{
public:
	ACE_Application()
	{
		m_pSocketSever = NULL;
	}
	virtual ~ACE_Application()
	{
		m_pSocketSever = NULL;
	}
	////////////////////////////////////////////////////////////////////////////////
	// 
	////////////////////////////////////////////////////////////////////////////////
	int start(int argc, char *argv[])
	{
		if(init(argc, argv) == -1)
			return -1;

		return run();
	}
	////////////////////////////////////////////////////////////////////////////////
	// waitForShutdown
	////////////////////////////////////////////////////////////////////////////////
	virtual int waitForShutdown(void)
	{
		//ACE_Time_Value timeout(10);
		return ACE_Reactor::instance()->run_reactor_event_loop();
	}
	////////////////////////////////////////////////////////////////////////////////
	// waitForShutdown
	////////////////////////////////////////////////////////////////////////////////
	virtual int waitForShutdown(ACE_Time_Value &tv)
	{
		return ACE_Reactor::instance()->run_reactor_event_loop(tv);
	}
	// 用户需重载函数并调用该函数
	// 初始化
	virtual int init(int argc, char *argv[])
	{
		(void)argc;
		(void)argv;
		ACE_Reactor * pMyReacotr = new ACE_Reactor(new PLAT_ACE_REACTOR, 1);
		pMyReacotr->restart(1);
		ACE_Reactor::instance(pMyReacotr);
		disable_sigpipe();
		return 0;
	}
	// 释放
	virtual int fini(void) = 0;
	// 主程序入口
	virtual int run()
	{
		ACE_INET_Addr listen(m_nPort);

		if(m_pSocketSever->open(listen, ACE_Reactor::instance(), ACE_NONBLOCK) == -1)
			ACE_ERROR_RETURN((LM_ERROR, ACE_TEXT("[%D]%p\r\n"), ACE_TEXT("prot err")), -1);
		ACE_DEBUG((LM_INFO, ACE_TEXT("[%D]Server have been started,listen port:%d...\r\n"), m_nPort));

		return 0;
	}

protected:
	virtual void disable_sigpipe(void)
	{
		sigset_t sigsetNew[1];
		sigset_t sigsetOld[1];
		ACE_OS::sigemptyset (sigsetNew);
		ACE_OS::sigaddset (sigsetNew, SIGPIPE);
		ACE_OS::sigprocmask (SIG_BLOCK, sigsetNew, sigsetOld);
	}
	////////////////////////////////////////////////////////////////////////////////
	// open_filelog
	////////////////////////////////////////////////////////////////////////////////
	virtual void open_filelog(char *filename)
	{
		ACE_OSTREAM_TYPE *output = new std::ofstream(filename);
		ACE_LOG_MSG->msg_ostream(output, 1);
		ACE_LOG_MSG->set_flags(ACE_Log_Msg::OSTREAM);
		ACE_LOG_MSG->clr_flags(ACE_Log_Msg::STDERR);
	}
	
	void set_server(SocketServer* pServer, int nPort)		//设置server指针
	{

		m_pSocketSever = pServer;
		m_nPort = nPort;
		//printf("-----------set_server [%d]\n", m_nPort);
		//fflush(stdout);
	}

protected:
	SocketServer* m_pSocketSever;
	int m_nPort;
} ;



