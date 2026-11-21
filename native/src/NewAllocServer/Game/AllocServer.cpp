#include "AllocServer.h"

#include "ICHAT_HTTP_Config.h"
#include "clib_log.h"
extern clib_log* g_pDebugLog;
extern clib_log* g_pErrorLog;

CAllocServer::CAllocServer(int prot)
{
	InitConnect("127.0.0.1", prot);
}

CAllocServer::~CAllocServer()
{

}
