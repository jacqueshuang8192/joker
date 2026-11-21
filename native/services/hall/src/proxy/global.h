#ifndef _HTTP_GLOBAL_H_
#define _HTTP_GLOBAL_H_

#include <malloc.h>
#include <unistd.h>
#include <string>
#include <stdint.h>
#include <defs.h>
#include <zlib.h>
#include "clib_log.h"

#include <map>
using std::map;
#include <vector>
using std::vector;

using std::string;

// #define LogMsg(format,...) TGlobal::g_pDebugLog->logMsg("[%s %u][%s]"format,__FILE__,__LINE__,__FUNCTION__,##__VA_ARGS__)
// #define ErrMsg(format,...) TGlobal::g_pErrorLog->logMsg("[%s %u][%s]"format,__FILE__,__LINE__,__FUNCTION__,##__VA_ARGS__)

HTTP_SVR_NS_BEGIN

class TGlobal
{
public: //method
    static void ShowVersion(void);
    static void ShowUsage(void);
    static int DaemonInit(const char* conf_file);
    static void DaemonStart(void);
	static int split_str(const char* ps_str , char* ps_sp , vector<std::string> &v_ret);
	static string binary2char(char c);
public: //property
    static volatile int*    _module_close;
    static volatile int     _stopped;
    static int              _accesslog;
    static const char*      _progname;
    static const char*      _version;
    static std::string      _config_file;
public:
    static char            _addr[64];  
    static uint16_t        _port;  
    static int             _backlog;
    static int             _maxpoller;
    static int             _webtimeout;
    static int             _helpertimeout;
    static std::string     _key;
	static int             _svid;
	static std::string     _HARedisIp;
	static int             _HARedisPort;
	static clib_log* g_pErrorLog;
	static clib_log* g_pDebugLog;

    static string          _log_path;
    static int             _log_level;
    static int             _log_max_num;
    static int             _log_maxsize;
private: //no impl
    TGlobal (void);
    ~TGlobal (void);
    TGlobal (const TGlobal&);
    const TGlobal& operator= (const TGlobal&);
};

HTTP_SVR_NS_END

#endif // #define _HTTP_GLOBAL_H_

