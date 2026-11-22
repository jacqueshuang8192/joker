#pragma once
#include "ichatlib.h"
#include "ACE_Application.h"
#include "SocketServer.h"
#include "ICHAT_HTTP_Config.h"

void OpenFileLog(int m_nLevel);
void open_filelog(char *filename);



class MainServer:public ACE_Application
{
public:
	MainServer(void);
	virtual ~MainServer(void);

	//*********************************************/
	// Method:    init
	// Returns:   int
	// Parameter: int argc
	// Parameter: char * argv[]
	// Description: 初始化Server
	//*********************************************/
	int init(int argc, char *argv[]);
	
	//*********************************************/
	// Method:    fini
	// Returns:   int
	// Parameter: void
	// Description: 释放
	//*********************************************/
	int fini(void);

	//*********************************************/
	// Method:    ParseArgs
	// Returns:   bool
	// Parameter: int argc
	// Parameter: char * argv[]
	// Description: 解析命令行参数
	//*********************************************/
	bool ParseArgs(int argc, char* argv[]);

private:
	
public:
	int m_nLevel;//Alloc等级
	int m_nSvid;//Alloc server id
	
				//char m_szMemCacheServer[256];
};



