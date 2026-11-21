#include <assert.h>
#include "mempool.h"
#include "memcheck.h"
#include "ICC_Timer_Handler.h"
#include "CCReactor.h"

#include <signal.h>

using namespace comm::sockcommu;


CMemPool* _memPool = NULL;

CCReactor::CCReactor()
{
	m_bReady2Exit = false;
}

int CCReactor::SetLog(const char* logfile, int level)
{
	init_log (logfile);
	set_log_level (level);
	return 0;
}

int CCReactor::Init(int maxpoller)
{
	char logfile[256];
	sprintf(logfile,"%s%d","UserServer.log.",getpid());
	SetLog(logfile, 0);

	this->_maxpoller = maxpoller;

	NEW (CPollerUnit(_maxpoller), _pollerunit);
	assert (_pollerunit);
	
	if(_pollerunit->InitializePollerUnit() < 0)
	{
	    log_boot ("poller unit init failed.");
		abort();
	}

	NEW( CMemPool(), _memPool);
	assert (_memPool);

	NEW( CTimerUnit(), _timerunit);
	assert (_timerunit);
	return 0;
}

CCReactor::~CCReactor()
{

} 


void exitSignalHandler(int signo)
{
	(void)signo;
	log_boot("siguser1 recved, prepare to exit.");
	CCReactor::Instance()->m_bReady2Exit = true;
}


void CCReactor::InitExitSignalHandler()
{
	signal(SIGUSR1, exitSignalHandler);
	m_bReady2Exit = false;
}


CCReactor* CCReactor::Instance (void)
{
	return CSingleton<CCReactor>::Instance ();
}

void  CCReactor::Destroy (void)
{
	return CSingleton<CCReactor>::Destroy ();
}


int CCReactor::RunEventLoop()
{
	while(1)
    {
        _pollerunit->WaitPollerEvents (_timerunit->ExpireMicroSeconds(1000));
        uint64_t now = GET_TIMESTAMP();
        _pollerunit->ProcessPollerEvents();
        _timerunit->CheckExpired (now);
        _timerunit->CheckPending ();
		
		if (m_bReady2Exit) {
			log_boot("siguser1 recved, exit.");		
			break;
		}
		
    }
    return 0;
}


 int CCReactor::RegistServer(ICC_TCP_Server* server) 
 {
	return this->AttachPoller (server);
 }

 int CCReactor::RegistClient(ICC_TCP_Handler* client)
 {
	return this->AttachPoller (client);
 }

int CCReactor::AttachPoller (CPollerObject* poller)
{
	if(poller->Init()!=0)
	{
		log_error ("poller Attach failed.");
		return -1;
	}
	return poller->AttachPoller(this->_pollerunit);
}


int CCReactor::RegistTimer(ICC_Timer_Handler* timer, long t)
{
	CTimerList* list = _timerunit->GetTimerList(t);
	assert (list);
	timer->DisableTimer();
	timer->AttachTimer(list);
	return 0;
}

int CCReactor::Connect(ICC_TCP_Handler* handler, const char* host, short port, int timeout)
{
	if(handler==NULL)
		return -1;	

	int fd = -1;
	int ret = CNet::tcp_connect(&fd, host, port, 0,timeout);
	if(ret==0 && fd!=SOCKET_INVALID)
	{
		handler->SetNetfd(fd);
		if( handler->OnConnected()<0 )
		{
			close(fd);
            handler->SetNetfd(-1);
			return -1;
		}
		handler->SetSIP(host);//
		handler->SetPort(port);
		return this->AttachPoller(handler);
	}
	else
	{
		close(fd);
		return -1;
	}	
}

