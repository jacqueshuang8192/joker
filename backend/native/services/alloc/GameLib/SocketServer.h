#pragma once
#include "ichatlib.h"
#include "ICHAT_TCP_Server.h"
#include "SocketHandler.h"
#include "ICHAT_HashMap.h"

class SocketServer:public ICHAT_TCP_Server
{
public:
	SocketServer(void);
	virtual ~SocketServer(void);

public:
	//*********************************************/
	// Method:    CreateHandler
	// Returns:   ICHAT_TCP_Handler<> *
	// Parameter: void
	// Description: 创建一个Handle连接
	//*********************************************/
	ICHAT_TCP_Handler<> * CreateHandler(void);

	//*********************************************/
	// Method:    ProcessConnected
	// Returns:   int
	// Parameter: SocketHandler *
	// Description: 处理新连接
	//*********************************************/
	virtual int ProcessConnected(SocketHandler *);

	//*********************************************/
	// Method:    ProcessClose
	// Returns:   int
	// Parameter: DWORD dwHanlerID
	// Description: 处理Handler关闭
	//*********************************************/
	virtual int ProcessClose(SocketHandler *);

	//*********************************************/
	// Method:    ProcessOnTimer
	// Returns:   int
	// Parameter: DWORD dwHanlerID
	// Description: 处理OnTimer
	//*********************************************/
	virtual int ProcessOnTimer(DWORD dwHanlerID);

	//*********************************************/
	// Method:    ProcessPacket
	// Returns:   int
	// Parameter: NETInputPacket * pPacket
	// Parameter: DWORD dwHanlerID
	// Description: 处理定时器事件
	//*********************************************/
	virtual int ProcessPacket(NETInputPacket *pPacket, SocketHandler * pSocket) = 0;

	//*********************************************/
	// Method:    FindHandler
	// Returns:   SocketHandler *
	// Parameter: DWORD
	// Description: 查找Handler
	//*********************************************/
	SocketHandler *FindHandler(DWORD);

	//*********************************************/
	// Method:    GetHandlerID
	// Returns:   unsigned int
	// Parameter: void
	// Description: 取一个HandlerID
	//*********************************************/
	DWORD GetHandlerID(void);
	
	//*********************************************/
	// Method:    SendCmdToClient
	// Returns:   int
	// Parameter: int nCmdType
	// Parameter: DWORD dwHanlerID
	// Description: 发命令给客户端
	//*********************************************/
	int SendCmdToClient(int nCmdType, DWORD dwHanlerID);

	//*********************************************/
	// Method:    SendPackageToClient
	// Returns:   int
	// Parameter: NETOutputPacket * pPackage
	// Parameter: DWORD dwHanlerID
	// Description: 发数据包给客户端
	//*********************************************/
	int SendPackageToClient(NETOutputPacket* pPackage, DWORD dwHanlerID);
	int SendPackageToClient(NETOutputPacket* pPackage, SocketHandler* pSocket);
	//*********************************************/
	// Method:    BuildPackage
	// Returns:   void
	// Parameter: NETOutputPacket * pOutPack
	// Parameter: short nCmdType
	// Parameter: const char * pszFmt
	// Parameter: ...
	// Description: 构造NETOutputPacket数据包,参数可变长
	//				支持的类型有int,DWORD,short,char*,
	//				对应类型为 %d====int, %u====DWORD, %h=====short, %s=====char*
	//				pszFmt为各个要发送的数据字段的格式组成的字符串,可以不带该参数,也可以带.如"%d,%u,%h,%s"
	//				也可以加上一些注释信息,如:"id:%d ntype:%h key:%u name:%s"
	//*********************************************/
	void BuildPackage(NETOutputPacket* pOutPack, short nCmdType, const char* pszFmt = NULL, ...);

public:
	DWORD m_dwHandlerID;							//分配给Handler的唯一标识

protected:
	ICHAT_Hash_Map<int, SocketHandler*> m_HandlerMap; 	//HandlerMap

};
