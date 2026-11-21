#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include<unistd.h>
#include<stdlib.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include <sys/resource.h>
#include <MarkupSTL.h>
#include <log.h>
#include <global.h>
#include <CHelper_pool.h>
#include <sstream>

using namespace std;

HTTP_SVR_NS_BEGIN

#define DEFAULT_LOG_PATH "../log/"
#define DEFAULT_LOG_LEVEL  7
#define DEFAULT_FILE_NUM    10
#define DEFAULT_FILE_SIZE   1*1024*1024*1024




extern std::map<int,CHelperPool *> _helperpoolMap;

volatile int*   TGlobal::_module_close           = NULL;
volatile int    TGlobal::_stopped                = 0;
int             TGlobal::_accesslog              = 0;
const char*     TGlobal::_progname               = "proxy";
const char*     TGlobal::_version                = "fanhou_svr 1.0";
string          TGlobal::_config_file;
char            TGlobal::_addr[64]               = "0.0.0.0";  
uint16_t        TGlobal::_port                   = 80;  
int             TGlobal::_backlog                = 256;
int             TGlobal::_maxpoller              = 1024;
int             TGlobal::_webtimeout             = 10;
int             TGlobal::_helpertimeout          = 5;
int             TGlobal::_svid                   = 0;
string			TGlobal::_key                    = "";
string          TGlobal::_HARedisIp              = "0.0.0.0";
int             TGlobal::_HARedisPort            = 0;
clib_log* 		TGlobal::g_pErrorLog 			 = NULL;
clib_log* 		TGlobal::g_pDebugLog 			 = NULL;

string  TGlobal::_log_path=DEFAULT_LOG_PATH;
int     TGlobal::_log_level=DEFAULT_LOG_LEVEL;
int     TGlobal::_log_max_num=DEFAULT_FILE_NUM;
int     TGlobal::_log_maxsize=DEFAULT_FILE_SIZE;


void TGlobal::ShowVersion ()
{
	printf("%s v%s\n", _progname, _version);
}

void TGlobal::ShowUsage ()
{
	ShowVersion();    
	printf("Usage:\n    %s [-d] [-f httpsvr.conf] [-x cgiconfig.xml]\n", _progname);
}



int TGlobal::DaemonInit (const char* conf_file)
{
    if (NULL == conf_file || strlen(conf_file) == 0)
    {
        fprintf(stderr, "module config file is invalid.\n");
        return -1;
    }

    _config_file = conf_file;

    CMarkupSTL  markup;
    if(!markup.Load(conf_file))
    {       
        fprintf(stderr, "Load xml %s failed\n", conf_file);
        return -1;
    }

    if(!markup.FindElem("SYSTEM"))
    {
        fprintf(stderr, "Can not FindElem [SYSTEM] in xml %s failed\n", conf_file);
        return -1;
    }

    TGlobal::_log_path  = markup.GetAttrib("LogDir");
    string log_level = markup.GetAttrib("LogLevel");
	TGlobal::_log_level = atoi(log_level.c_str());
    set_log_level(TGlobal::_log_level);
    
    //get access log switch
    _accesslog = atoi(markup.GetAttrib("AccessLog").c_str());

    //get max poll
    _maxpoller = atoi(markup.GetAttrib("MaxFdCount").c_str());
    if(_maxpoller < 1024)
    {
        _maxpoller = 1024;
    }

    //get web time out
    _webtimeout = atoi(markup.GetAttrib("WebTimeout").c_str());
    if (_webtimeout < 1)
    {
        _webtimeout = 1;
    }
   log_boot ("_webtimeout is %d",_webtimeout);

   
   _helpertimeout = atoi(markup.GetAttrib("HelperTimeout").c_str());
    if (_helpertimeout < 1)
    {
        _helpertimeout = 1;
    }
   log_boot ("HelperTimeout is %d",_helpertimeout);
   
    
    //get listen backup
    _backlog = atoi(markup.GetAttrib("MaxListenCount").c_str());
    if (_backlog < 256)
    {
        _backlog = 256;
    }

    _HARedisIp = markup.GetAttrib("HARedisServer"); //-- store hall ip and port info 
    _HARedisPort = atoi(markup.GetAttrib("HARedisPort").c_str());
	
    TGlobal::_key = markup.GetAttrib("KEY");

	//¶ÁÈ¡ÒµÎñÅäÖÃ
	
    return 0;
}


int TGlobal::split_str(const char* ps_str , char* ps_sp , vector<std::string> &v_ret)
{    
	char* ps_temp;    
	char* p;    
	int i_len = (int)strlen(ps_str);    
	std::string st_str;    
	ps_temp = new char[i_len+2];    
	snprintf(ps_temp , i_len+1 , "%s" , ps_str);    
	char *last = NULL;    p = strtok_r(ps_temp , ps_sp , &last);    
	if(NULL == p)
	{        
		delete ps_temp;        
		return 0;    
	}    
	st_str = (std::string)p;    
	v_ret.push_back(st_str);    
	while( NULL != ( p=strtok_r(NULL , ps_sp , &last) ) )
	{        
		st_str = (std::string)p;        
		v_ret.push_back(st_str);    
	}    
	delete ps_temp;    
	return 0;
}

string TGlobal::binary2char(char c) 
{
    string k = "";
    int j=1;
    for(int i=0; i<8; i++) 
    {
        k+=(char)(bool)(c&j)+'0'; 
        j<<=1;
    } 
    return k; 
}



void TGlobal::DaemonStart(void)
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

HTTP_SVR_NS_END

