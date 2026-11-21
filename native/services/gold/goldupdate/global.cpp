#include "global.h"
#include <sys/time.h>
#include <malloc.h>


string			TGlobal::_xmlconfig				 = "config.xml";
string	        TGlobal::_ip	               	 = "0.0.0.0";  
short        	TGlobal::_port                   = 80;  
int             TGlobal::_svid                   = 0;
clib_log* 		TGlobal::g_pErrorLog 			 = NULL;
clib_log* 		TGlobal::g_pDebugLog 			 = NULL;
int 			TGlobal::heartInteval			 = 10*60*1000;
/* Return the UNIX time in microseconds */
long long ustime(void) {
    struct timeval tv;
    long long ust;

    gettimeofday(&tv, NULL);
    ust = ((long long)tv.tv_sec)*1000000;
    ust += tv.tv_usec;
    return ust;
}

/* Return the UNIX time in milliseconds */
long long mstime(void) {
    return ustime()/1000;
}



