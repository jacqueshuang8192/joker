#include <stdio.h>
#include <signal.h>
#include "CCSocketServer.h"
#include "CCReactor.h"
#include "global.h"
#include "ClientHandler.h"
#include "ManagerFactory.h"

#define MAX_LOG_FILE 10
void InitLog()
{
	char logfile[256];
	sprintf(logfile,"%s_%d","./Debug.log",getpid());
	TGlobal::g_pDebugLog = new clib_log();
	TGlobal::g_pDebugLog->set_file( logfile );
	TGlobal::g_pDebugLog->set_level( CLIB_LOG_LEV_DEBUG);
	TGlobal::g_pDebugLog->set_maxfile( MAX_LOG_FILE );
	TGlobal::g_pDebugLog->set_maxsize( (2<<20) * 512 );//200M
	TGlobal::g_pDebugLog->set_logtype( CLIB_LOG_TYPE_DAY );//200M
	TGlobal::g_pDebugLog->set_timeformat(CLIB_LOG_TFORMAT_0);

	sprintf(logfile,"%s_%d","./Error.log",getpid());
	TGlobal::g_pErrorLog = new clib_log();
	TGlobal::g_pErrorLog->set_file( logfile );
	TGlobal::g_pErrorLog->set_level( CLIB_LOG_LEV_DEBUG );
	TGlobal::g_pErrorLog->set_maxfile( MAX_LOG_FILE );
	TGlobal::g_pErrorLog->set_maxsize( (2<<20) * 512 );//200M
	TGlobal::g_pErrorLog->set_logtype( CLIB_LOG_TYPE_DAY );//200M
	TGlobal::g_pErrorLog->set_timeformat(CLIB_LOG_TFORMAT_0);
	return;
}

void DaemonStart(void)
{   
	struct sigaction sa;
	memset(&sa, 0, sizeof(sa));
	sigaction(SIGINT, &sa, NULL);
	sigaction(SIGTERM, &sa, NULL);
	sigaction(SIGQUIT, &sa, NULL);
	sigaction(SIGHUP, &sa, NULL);
	signal(SIGPIPE,SIG_IGN); 
	signal(SIGCHLD,SIG_IGN); 
	sigset_t sset;
	sigemptyset(&sset);
	sigaddset(&sset, SIGSEGV);
	sigaddset(&sset, SIGBUS);
	sigaddset(&sset, SIGABRT);
	sigaddset(&sset, SIGILL);
	sigaddset(&sset, SIGCHLD);
	sigaddset(&sset, SIGFPE);
	sigprocmask(SIG_UNBLOCK, &sset, &sset);
	daemon (1, 1);
}  


int Global_Init(int argc,char ** argv)
{
	DaemonStart();
	InitLog();
	char* option = "p:h:s:";
	int result;
	while((result = getopt(argc, argv, option)) != -1)
	{		   
		if (result=='h'){
			TGlobal::_ip = optarg;
		}
		else if(result=='p'){
			TGlobal::_port = atoi(optarg);
		}
		else if(result=='s'){
			TGlobal::_svid= atoi(optarg);
		}
	}
	return 0;
}

int InitGameManager(){
	
	CMarkupSTL  markup;
	if(!markup.Load(TGlobal::_xmlconfig.c_str()))
    {       
        log_boot("Load xml %s failed", TGlobal::_xmlconfig.c_str());
        return -1;
    }
	
	if(!markup.FindElem("SYSTEM"))
    {
        log_boot("Not Found Elem [PUSHSERVER] in xml[%s]", TGlobal::_xmlconfig.c_str());
        return -1;
    }
	
	if (!markup.IntoElem())    
	{        
		log_error ("IntoElem [SYSTEM] failed.");       
		return -1;    
	}
	
	while(markup.FindElem("GAME")){
		
		GameConfig gc;
		
		gc.m_gameID = atoi(markup.GetAttrib("GameID").c_str());
		
		gc.m_serverType= atoi(markup.GetAttrib("ServerType").c_str());

		log_boot("Add New Game,ID:%d,Type:%d",gc.m_gameID,gc.m_serverType);
		
		if (!markup.IntoElem())    
		{        
			log_error ("IntoElem failed.");       
			return -1;    
		}

		if(!markup.FindElem("Log"))
		{
			log_error ("IntoElem [RedisList] failed.");     
			return -1; 
		}
		int log_level = atoi(markup.GetAttrib("level").c_str());
		TGlobal::g_pDebugLog->set_level( log_level);
		TGlobal::g_pErrorLog->set_level( log_level);

		
		if(!markup.FindElem("RedisList"))
		{
			log_error ("IntoElem [RedisList] failed.");     
			return -1; 
		}
		
		if (!markup.IntoElem())    
		{        
			log_error ("IntoElem [RedisList] failed.");       
			return -1;    
		}
		
		while(markup.FindElem("Redis"))
		{
			ServerConfig sc;
			sc.m_svid =  atoi(markup.GetAttrib("svid").c_str());
			sc.m_ip = markup.GetAttrib("ip");
			sc.m_port = atoi(markup.GetAttrib("port").c_str());
			sc.m_password = markup.GetAttrib("password").c_str();
			gc.m_ServerMap[sc.m_svid] = sc;
			log_boot("Add New Redis For Game[%d],ID:%d,IP:%s,Port:%d", gc.m_gameID, sc.m_svid, sc.m_ip.c_str(), sc.m_port, sc.m_password.c_str());
		}
		
		if (!markup.OutOfElem())
		{
			log_error ("OutOfElem [Node] failed.");
			return -1;
		}

		if (markup.FindElem("LogServer"))
		{
			gc.m_LogConf.m_ip = markup.GetAttrib("ip");
			gc.m_LogConf.m_port = atoi(markup.GetAttrib("port").c_str());
			gc.m_EnableLog = true;
		}

		if (markup.FindElem("UpdateServer"))
		{
			gc.m_UpdateConf.m_ip = markup.GetAttrib("ip");
			gc.m_UpdateConf.m_port = atoi(markup.GetAttrib("port").c_str());
			gc.m_EnableUpdate= true;
		}

		if(!markup.FindElem("DBList"))
		{
			log_error ("IntoElem [DBList] failed.");     
			return -1; 
		}

		if (!markup.IntoElem())    
		{        
			log_error ("IntoElem [DBList] failed.");       
			return -1;    
		}

		if(markup.FindElem("DB"))
		{
			gc.m_DBConf.m_ip = markup.GetAttrib("ip");
			gc.m_DBConf.m_port = atoi(markup.GetAttrib("port").c_str());
			gc.m_DBConf.m_user = markup.GetAttrib("user");
			gc.m_DBConf.m_pwd = markup.GetAttrib("pwd");
			gc.m_DBConf.m_tableName = markup.GetAttrib("tableName");
			gc.m_DBConf.m_dbName = markup.GetAttrib("dbName");
			gc.m_DBConf.m_dbNum = atoi(markup.GetAttrib("dbNum").c_str());
			gc.m_DBConf.m_tableNum = atoi(markup.GetAttrib("tableNum").c_str());
			log_boot("Add New DB For Game[%d],IP:%s,Port:%d dbName:%d ",gc.m_gameID,gc.m_DBConf.m_ip.c_str(),gc.m_DBConf.m_port, gc.m_DBConf.m_dbNum);
		}
		
		if (!markup.OutOfElem())    
		{        
			log_error ("OutOfElem [ServerList] failed.");       
			return -1;    
		}
		
		ManagerFactory::Instance()->AddGameConfig(gc);
		
	}
	return 0;
}

int main(int argc, char *argv[])
{	
	Global_Init(argc,argv);
	
	CCReactor::Instance()->Init();

	SocketServer<CClientHandler> Server(TGlobal::_ip.c_str(),TGlobal::_port);

	int iret = CCReactor::Instance()->RegistServer(&Server);

	if (iret != 0){
		log_boot("Regist Server Failed.");
		return -1;
	}

	iret = InitGameManager();
	if(iret != 0){
		log_boot("Init GameManager Failed.");
		return -1;
	}
	
	CCReactor::Instance()->RunEventLoop();
	
	return 0;
}
