#include "SocketServer.h"

SocketServer::SocketServer(void)
{
	m_dwHandlerID = 0;
}

SocketServer::~SocketServer(void)
{
}

////////////////////////////////////////////////////////////////////////////////
// 继承至ICHAT_TCP_Server, 创建新HANDLER时用
////////////////////////////////////////////////////////////////////////////////
ICHAT_TCP_Handler<> * SocketServer::CreateHandler(void)
{
	SocketHandler *pNewHandler;
	ACE_NEW_RETURN(pNewHandler, SocketHandler(++m_dwHandlerID), 0);
	return pNewHandler;
}
////////////////////////////////////////////////////////////////////////////////
// 超时
////////////////////////////////////////////////////////////////////////////////
int 
SocketServer::ProcessOnTimer(DWORD dwHanlerID)
{
	SocketHandler* pHandler = FindHandler(dwHanlerID);
	if (pHandler == NULL)
	{
		return 0;
	}

	if(pHandler->GetChunkStatus() == SocketHandler::CONNECT)
	{
		return -1;
	}
	return 0;
}
////////////////////////////////////////////////////////////////////////////////
// 处理新连接 加入map
////////////////////////////////////////////////////////////////////////////////
int SocketServer::ProcessConnected(SocketHandler *pHandler)
{
	int nRet = m_HandlerMap.bind(pHandler->GetHandlerID(), pHandler);
	//assert(nRet == 0);
	//if(nRet != 0)
	//	ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]SocketServer::ProcessConnected Error %d\r\n"), pHandler->GetHandlerID()));
	return 0;
}
////////////////////////////////////////////////////////////////////////////////
// 处理Handler关闭
////////////////////////////////////////////////////////////////////////////////
int SocketServer::ProcessClose(SocketHandler *pSocket)
{
	int nRet = m_HandlerMap.unbind(pSocket->GetHandlerID());
	//if(nRet != 0)
	//	ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]SocketServer::ProcessClose Error %d\r\n"), dwHanlerID));
	//assert(nRet == 0);
	return 0;
}
////////////////////////////////////////////////////////////////////////////////
// FindHandler
////////////////////////////////////////////////////////////////////////////////
SocketHandler * SocketServer::FindHandler(DWORD dwHandlerID)
{
	SocketHandler *pHandler;
	if(m_HandlerMap.find(dwHandlerID, pHandler) == -1)
	{
		return NULL;
	}
	return pHandler;
}

DWORD SocketServer::GetHandlerID(void)
{
	return ++m_dwHandlerID;
}

//发命令给客户端
int SocketServer::SendCmdToClient(int nCmdType, DWORD dwHanlerID)
{
	NETOutputPacket outPkg;
	BuildPackage(&outPkg, nCmdType);
	//return GetSession(dwSessionID)->SendPackage(&outPkg);
	SocketHandler* pHandler = FindHandler(dwHanlerID);
	if (pHandler != NULL)
	{
		return pHandler->Send(&outPkg);
	}
	return -1;
}

//发数据包给客户端
int SocketServer::SendPackageToClient(NETOutputPacket* pPackage, DWORD dwHanlerID)
{
	SocketHandler* pHandler = FindHandler(dwHanlerID);
	if (pHandler != NULL)
	{
		return pHandler->Send(pPackage);
	}
	return -1;	
}

//发数据包给客户端
int SocketServer::SendPackageToClient(NETOutputPacket* pPackage, SocketHandler* pSocket)
{
	SocketHandler* pHandler = pSocket;
	if (pHandler != NULL)
	{
		return pHandler->Send(pPackage);
	}
	return -1;	
}
//////////////////////////////////////////////////////////////////////////
//实现构造一个NETOutputPacket数据包,参数可变长
//支持的类型有int,DWORD,short,char*,
//对应类型为 %d====int, %u====DWORD, %h=====short, %s=====char*
//pszFmt为各个要发送的数据字段的格式组成的字符串,可以不带该参数,也可以带.如"%d,%u,%h,%s"
//也可以加上一些注释信息,如:"id:%d ntype:%h key:%u name:%s"
//////////////////////////////////////////////////////////////////////////
void SocketServer::BuildPackage(NETOutputPacket* pOutPack, short nCmdType, const char* pszFmt, ...)
{
	pOutPack->Begin(nCmdType);

	if (pszFmt == NULL)	//内容为空的,就直接构造一个只有命令头的数据包
	{
		pOutPack->End();
		return;
	}

	va_list ap; 
	va_start (ap, pszFmt); 
	const char* p = NULL;

	for (p= pszFmt; *p; p++) 
	{ 
		if (*p != '%') 
		{
			continue; 
		}

		switch (*++p) 
		{ 
		case 'd':	//int
			{
				int nVal= va_arg(ap, int);
				pOutPack->WriteInt(nVal);
				break;
			}
		case 'h':	//short
			{
				short shVal = va_arg(ap, short);
				pOutPack->WriteShort(shVal);
				break;
			}
		case 'u':	//unsigned long
			{
				unsigned long dwVal = va_arg(ap, unsigned long);
				pOutPack->WriteULong(dwVal);
				break;
			}
		case 's':	//char*
			{
				char* pVal = va_arg(ap, char*);
				pOutPack->WriteString(pVal);
				break;
			}
		}
	}
	pOutPack->End();
}
