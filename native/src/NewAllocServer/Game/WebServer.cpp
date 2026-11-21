#include "WebServer.h"
#include "Singleton.h"
#include <ace/INET_Addr.h>
#include "GameGroup.h"

#include "clib_log.h"
extern clib_log *g_pDebugLog;
extern clib_log *g_pErrorLog;


CWebServer::CWebServer()
{
}


CWebServer::~CWebServer()
{
}

CWebServer* CWebServer::Instance(void)
{
	return CSingleton<CWebServer>::Instance();
}

bool CWebServer::init(const char* pszConfPath)
{
	ICHAT_HTTP_Config ConfigReader;
	int nRet = ConfigReader.Open(pszConfPath);
	if (nRet == -1)
	{
		g_pDebugLog->logMsg("[%D] Open file error [%s] \r\n", pszConfPath);
		return FALSE;
	}

	ACE_Configuration_Section_Key subkey1;
	ConfigReader.OpenSection("BackStageServer", subkey1);

	char request[256] = { 0 };
	ConfigReader.get_section_string(subkey1, "R_UPDATE_TABLE_LIST", request, sizeof(request));
	m_strUpdateTableList = request;
	//g_pDebugLog->logMsg("m_strUpdateTableList   [%s] \r\n", m_strUpdateTableList.c_str());

	backServerUrl = GameGroup::Instance()->backServerUrl;
	backServerPort = GameGroup::Instance()->backServerPort;

	return true;
}

int CWebServer::httpUpdateTableList(int level, int tid, int uid, int game_type)
{
	char request[256];
	sprintf(request, m_strUpdateTableList.c_str(), level, tid, uid);
	HttpPost(backServerUrl.c_str(), backServerPort, request);

	return 0;
}

int CWebServer::HttpPost(const char* strIp, int iPort, char* request)
{
	ACE_SOCK_Stream httpConnect;

	if (ACE_SOCK_Connector().connect(httpConnect, ACE_INET_Addr(iPort, strIp), 2) != -1) {
		char strRequest[65535];
		sprintf(strRequest, "POST /%s HTTP/1.0\r\n\r\n", request);
		httpConnect.send(strRequest, sizeof(strRequest)-1); // "- 1": don't send '\0'
		httpConnect.close();
		g_pDebugLog->logMsg("[%s] line:%d ===> addr:%s:%d\n %s", __FUNCTION__, __LINE__, strIp, iPort, strRequest);

		httpConnect.close_writer();
	}

	g_pDebugLog->logMsg("HttpPost---------finish11111111111\n");
	return 0;
}