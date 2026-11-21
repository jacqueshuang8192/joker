#ifndef __WEB_SERVER_H__
#define __WEB_SERVER_H__

#include <noncopyable.h>
#include <string>

using namespace std;

class CWebServer :
	private noncopyable
{
public:
	CWebServer();
	~CWebServer();

	static CWebServer* Instance(void);

	bool	init(const char* pszConfPath = "GameServer.ini");

	int		httpUpdateTableList(int level, int tid, int uid, int game_type);

protected:
	std::string	backServerUrl;
	int		backServerPort;
	
	std::string	m_strUpdateTableList;

	int		HttpPost(const char* strIp, int iPort, char* request);
};


#endif