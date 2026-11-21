#include <stdio.h>
#include <errno.h>
#include <global.h>
#include <incoming.h>
#include <log.h>
#include <proxy_module.h>
#include <cache.h>
#include <CHelper_pool.h>
#include <signal.h>
#include <map>
#include "Logic.h"

using namespace comm::sockcommu;
#define LOG_TIME_INTERVAL 60*60*24

MODULE_INSTANCE_EXPORT(__http_svr_ns__::CProxyModule, qzhttp_proxy, 2_0_0)
MODULE_DESTROY_EXPORT(__http_svr_ns__::CProxyModule, qzhttp_proxy, 2_0_0)

CMemPool*				_webMp;
CMemPool*				_helpMp;


HTTP_SVR_NS_BEGIN

std::map<int,CHelperPool *> _helperpoolMap;

const string VERSION = "1.0.0";

CProxyModule::CProxyModule (void)
{
}

CProxyModule::~CProxyModule (void)
{
}

void CProxyModule::InitUserLog()
{
	char szDebugName[100] = {0};
	snprintf(szDebugName, sizeof(szDebugName), "HallServer.debug-s%d.%u", TGlobal::_svid , getpid());
	TGlobal::g_pDebugLog = new clib_log();    
	TGlobal::g_pDebugLog->set_file(szDebugName);    
	TGlobal::g_pDebugLog->set_level(TGlobal::_log_level);    
	TGlobal::g_pDebugLog->set_maxfile(5);    
	TGlobal::g_pDebugLog->set_maxsize(10240000); 
	TGlobal::g_pDebugLog->set_logtype( CLIB_LOG_TYPE_DAY ); //day   
	TGlobal::g_pDebugLog->set_timeformat(CLIB_LOG_TFORMAT_0);

	char szErrorName[100] = {0};
	snprintf(szErrorName, sizeof(szErrorName), "HallServer.error-s%d.%u",TGlobal::_svid , getpid());
	TGlobal::g_pErrorLog = new clib_log();    
	TGlobal::g_pErrorLog->set_file(szErrorName); 
	TGlobal::g_pErrorLog->set_level(TGlobal::_log_level);    
	TGlobal::g_pErrorLog->set_maxfile(5);    
	TGlobal::g_pErrorLog->set_maxsize(10240000);    
	TGlobal::g_pErrorLog->set_timeformat(CLIB_LOG_TFORMAT_0);


    CLogic::InitLog();

}

void CProxyModule::StartTimer(int timeout)
{
	log_error("start timeout[%d]",timeout);
    DisableTimer();	
    AttachTimer(CIncoming::Instance()->GetTimeList(timeout));
}

void CProxyModule::TimerNotify(void)
{
    log_error("time out ");
    CLogic::InitLog();
    StartTimer(LOG_TIME_INTERVAL);

	time_t curtime = time(NULL);
	CIncoming::Instance()->m_datestring = CLogic::GetDateString(curtime).c_str();
    return;
}

void CProxyModule::SetVersion(int argc, char** argv)
{
	string startstr="";
	//string const * g_pVersion;//°æ±¾ºÅ
	//g_pVersion = &VERSION;
	startstr = (string)argv[0];
	for(int i=1 ; i<argc ; i++)
	{
		startstr = startstr + " " +(string)argv[i];
	}
	startstr = startstr + " -Version:" + VERSION;
	char *argstart = argv[0];
	sprintf(argstart , "%s" , startstr.c_str());
}

int CProxyModule::open (int argc, char** argv)
{
	InitUserLog();
	TGlobal::DaemonStart(); //zsw ÊØ×oßM³ÌÆÁ±Î
	_webMp = new CMemPool();
	_helpMp = new CMemPool(); 

    if(TGlobal::DaemonInit("../conf/config.xml") < 0)
		return -1;
	if((string)argv[1]!="-p" || (string)argv[3]!="-s" || (string)argv[5]!="-h")
	{
		log_boot("param format error %s,%s,%s", argv[1], argv[3], argv[5]);
		return -1;
	}
	TGlobal::_port = atoi(argv[2]);
	TGlobal::_svid = atoi(argv[4]);
	string strHallIp = argv[6];

	if(TGlobal::_port<=0 || TGlobal::_svid<=0)
	{
		log_boot("param value error");
		return -1;
	}
	
	m_pHARedisServer = new CRedisServer();
	if(m_pHARedisServer == NULL)
	{
		return -1;
	}

	if(m_pHARedisServer->Connect(TGlobal::_HARedisIp, TGlobal::_HARedisPort) != 0 )
	{
		log_boot("Connect HARedis[ip:%s,port:%d] Failed!",TGlobal::_HARedisIp.c_str(),TGlobal::_HARedisPort);
		return -1;
	}
	if(m_pHARedisServer->SetInfo(strHallIp, TGlobal::_port, TGlobal::_svid) != 0 )
	{
		log_boot("Set Info to HARedis Failed!");
		return -1;
	}
	
	SetVersion(argc,argv);
    if(CIncoming::Instance()->open() < 0)
    {
        log_boot("Init incoming instance failed");
        return -1;
    }

    int t = CLogic::TimeToMidnight();   //get time to midnight
    StartTimer(t+1);
    return 0;
}

int CProxyModule::close (void)
{
    CIncoming::Destroy ();
    log_boot ("%s v%s: stopped", TGlobal::_progname, TGlobal::_version);
    return 0;
}

int CProxyModule::run (void* parameter)
{
    TGlobal::_module_close = (int*)(parameter);
    //process network event
    CIncoming::Instance()->run ();
    return 0;
}

int CProxyModule::exception (void)
{
    return 0;
}


HTTP_SVR_NS_END
	
using namespace __http_svr_ns__;


int main (int argc, char** argv)
{
	CProxyModule cpm;
	int iRet = cpm.open(argc, argv);
	
	if (iRet != 0)
	{
        log_boot("CProxyModule open failed. iRet : [%d]", iRet);
		return 0;
	}
	
    log_boot("Proxy open is done!!");
	cpm.run((void*)&(TGlobal::_stopped));
	log_boot("Proxy open is done!!111");
}

