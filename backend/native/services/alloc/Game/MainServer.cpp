#include "MainServer.h"
#include "common.h"
#include "GameServer.h"
#include "UserServer.h"
CGameServer* g_pGameServer = NULL;


#ifndef WIN32
#include "clib_log.h"
clib_log* g_pDebugLog;
clib_log* g_pErrorLog;
void InitLog(char* debugFileName, char* errorFileName)
{
	g_pDebugLog = new clib_log();
    g_pDebugLog->set_file(debugFileName);
    g_pDebugLog->set_level(5);
    g_pDebugLog->set_maxfile(10);
    g_pDebugLog->set_maxsize(10240000);
    g_pDebugLog->set_timeformat(CLIB_LOG_TFORMAT_0);

	g_pErrorLog = new clib_log();
    g_pErrorLog->set_file(errorFileName);
    g_pErrorLog->set_level(5);
    g_pErrorLog->set_maxfile(10);
    g_pErrorLog->set_maxsize(10240000);
    g_pErrorLog->set_timeformat(CLIB_LOG_TFORMAT_0);
}
#endif

MainServer::MainServer(void)
{
	m_pSocketSever = new CGameServer;
	g_pGameServer = (CGameServer*)m_pSocketSever;
	
	//memset(m_szMemCacheServer, 0, sizeof(m_szMemCacheServer));
}

MainServer::~MainServer(void)
{
	if (m_pSocketSever != NULL)
	{
		delete m_pSocketSever;
	}
}

////////////////////////////////////////////////////////////////////////////////
// init
////////////////////////////////////////////////////////////////////////////////
int MainServer::init(int argc, char *argv[])
{
	if (!ParseArgs(argc, argv))						//解析命令行参数失败
	{
		return -1;
	}
	

	if (ACE_Application::init(argc, argv) == -1)	//网络层调用ace_application的init方法
	{
		return -1;
	}
	CRedisManagerClient* pRedisManagerClient = new CRedisManagerClient(g_pGameServer);
	CDbPart* pDBClient = new CDbPart();
	g_pDebugLog->logMsg("MainServer m_nLevel[%d] m_nSvid[%d]", m_nLevel, m_nSvid);
	if (!g_pGameServer->InitServer(pRedisManagerClient, pDBClient,m_nLevel, m_nSvid/*, m_szMemCacheServer*/))
	{
		return -1;
	}
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// fini
////////////////////////////////////////////////////////////////////////////////
int MainServer::fini(void)
{
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// 主程序入口
////////////////////////////////////////////////////////////////////////////////

bool MainServer::ParseArgs(int argc, char* argv[])
{
	g_pGameServer->robotYs = 0;
	if (argc < 11)
	{
		ACE_ERROR_RETURN((LM_ERROR, ACE_TEXT ("Useage:./AllocRoomServer -p port -l level -s svid -u usercount -m servercount [-d]\n")), false);
	}

	ACE_ARGV  argvEnv(argv);
	ACE_TCHAR szOptions[] = ACE_TEXT (":p:l:s:u:m:f:t:j:d::");
	ACE_Get_Opt cmdOpt(argc, argv, szOptions, 1, 1, ACE_Get_Opt::PERMUTE_ARGS, 1);

	int  nOption;
	while ( ( nOption = cmdOpt () )  !=  EOF )
	{
		switch ( nOption ) 
		{
		case 'd':		//以守护程序运行
			{
				daemonize();
				ACE_LOG_MSG->priority_mask(LM_INFO | LM_ERROR, ACE_Log_Msg::PROCESS);	//禁掉debug日志
				pid_t pid = ACE_OS::getpid();
			/*	char szLogFile[256] = {0};
				sprintf(szLogFile, "AllocServer.log.%u", pid);
				open_filelog(szLogFile);
#ifndef WIN32
				char szDebugFile[256] = {0};
				snprintf(szDebugFile, sizeof(szDebugFile), "AllocServer.debug.%u", pid);
				char szErrorFile[256] = {0};
				snprintf(szErrorFile, sizeof(szErrorFile), "AllocServer.error.%u", pid);
				InitLog(szDebugFile, szErrorFile);
#endif*/
				break;
			}
		case 'p':		//侦听端口			
			m_nPort = atoi(cmdOpt.opt_arg());
			//printf("-----------ProcessSendServerPortIp [%d]\n", m_nPort);
			//fflush(stdout);
			if (m_nPort <= 0)
			{
				ACE_ERROR_RETURN((LM_ERROR, ACE_TEXT("port = %d\n"), m_nPort), false);
			}
			break;
		case 'l':
			m_nLevel = atoi(cmdOpt.opt_arg());
			break;
		case 's':
			m_nSvid = atoi(cmdOpt.opt_arg());
			break;
	/*	case 'm':
			strncpy(m_szMemCacheServer, cmdOpt.opt_arg(), sizeof(m_szMemCacheServer));
			break;*/
		case 'u':
			g_pGameServer->m_nMaxTableUserCount = atoi(cmdOpt.opt_arg());
			break;
		case 'm':		
			g_pGameServer->m_nMaxServerUserCount = atoi(cmdOpt.opt_arg());
			break;
		case 'f':
			g_pGameServer->m_nFillFlag = atoi(cmdOpt.opt_arg());
		case 't':
			g_pGameServer->groupType = atoi(cmdOpt.opt_arg());
			break;
		case 'j':
			g_pGameServer->robotYs = atoi(cmdOpt.opt_arg());
			break;
		default:
			ACE_ERROR_RETURN((LM_ERROR, "", cmdOpt.opt_opt ()), false);
			break;
		}
	}
    OpenFileLog(m_nLevel);

	return true;
}

void OpenFileLog(int m_nLevel)
{
    pid_t pid = ACE_OS::getpid();
	char szLogFile[256] = {0};
	long curtime=time(NULL);
	struct tm* timeinfo;
	timeinfo = localtime(&curtime);
	int year = timeinfo->tm_year+1900;
	int month = timeinfo->tm_mon + 1;
	int day = timeinfo->tm_mday;

    char szLogPath[256] = {0};
	createLogFilePath(szLogPath);

	/*snprintf(szLogFile, sizeof(szLogFile),  "%s/allocServer.log.%u.%02d.%02d", szLogPath, pid, month, day);
	open_filelog(szLogFile);
	char szDebugLog[256] = {0};
	sprintf(szDebugLog, "%s/allocServer.debug.%u.%02d.%02d", szLogPath, pid, month, day);
	char szErrorLog[256] = {0};
	sprintf(szErrorLog, "%s/allocServer.error.%u.%02d.%02d", szLogPath, pid, month, day);
	InitLog(szDebugLog, szErrorLog);
	open_filelog(szLogFile);*/
	snprintf(szLogFile, sizeof(szLogFile), "%s/allocServer.log.%d.%u.%02d.%02d", szLogPath, m_nLevel, pid, month, day);
	open_filelog(szLogFile);
	char szDebugLog[256] = { 0 };
	sprintf(szDebugLog, "%s/allocServer.debug.%d.%u.%02d.%02d", szLogPath, m_nLevel, pid, month, day);
	char szErrorLog[256] = { 0 };
	sprintf(szErrorLog, "%s/allocServer.error.%d.%u.%02d.%02d", szLogPath, m_nLevel, pid, month, day);
	InitLog(szDebugLog, szErrorLog);
}
void open_filelog(char *filename)
{
   ACE_OSTREAM_TYPE *output = new std::ofstream(filename);
   ACE_LOG_MSG->msg_ostream(output, 1);
   ACE_LOG_MSG->set_flags(ACE_Log_Msg::OSTREAM);
   ACE_LOG_MSG->clr_flags(ACE_Log_Msg::STDERR);
}

