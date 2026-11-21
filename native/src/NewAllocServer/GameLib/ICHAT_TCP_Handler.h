#pragma once
#include "ichatlib.h"
#include "ace/SOCK_Stream.h"
#include "ace/Svc_Handler.h"
#include "LoopBuffer.h"

const int MAX_LOOP_BUFFER_LEN = 64*1024;//byte

class ICHAT_TCP_Server;
template <int _buffer_size = ICHAT_TCP_DEFAULT_BUFFER>
class ICHAT_TCP_Handler:public ACE_Svc_Handler<ACE_SOCK_STREAM, ACE_NULL_SYNCH>
{
public:
	ICHAT_TCP_Handler(void)
	{
		m_pServer = NULL;
		m_pSendLoopBuffer = NULL;
	}
	virtual ~ICHAT_TCP_Handler(void)
	{
		if (m_pSendLoopBuffer)
		{
			delete m_pSendLoopBuffer;
		}
		m_pSendLoopBuffer = NULL;

	}

	// 公共接口
public:
	////////////////////////////////////////////////////////////////////////////////
	// // 发送数据
	////////////////////////////////////////////////////////////////////////////////
	int Send(const char *buf, int nLen, int delete_buffer = 0, int close_flag = 0)
	{
		(void)delete_buffer;
		(void)close_flag;
		int ret = m_pSendLoopBuffer->Put((char *)buf, nLen);
		if(ret == 0)
		{
			ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] [%s] Buffer no space, fuck\r\n"), __FUNCTION__));
		}

		int nPeekLen = 0;
		int nHaveSendLen = 0;
		do 
		{
			nPeekLen = m_pSendLoopBuffer->Peek(m_pTmpSendBuffer,sizeof(m_pTmpSendBuffer));

			nHaveSendLen = this->peer().send(m_pTmpSendBuffer, nPeekLen, MSG_NOSIGNAL);

			if(nHaveSendLen < 0 && ACE_OS::last_error() != EWOULDBLOCK && ACE_OS::last_error() != EINTR)
			{
				m_pSendLoopBuffer->Erase(nPeekLen);
				return -1;
			}
			m_pSendLoopBuffer->Erase(nHaveSendLen);
		} while (nHaveSendLen>0 && m_pSendLoopBuffer->DataCount()>0);
		return 0;
	}
	////////////////////////////////////////////////////////////////////////////////
	// // 发送数据后关闭连接
	////////////////////////////////////////////////////////////////////////////////
	int Send_and_Close(const char *buf, int nLen, int delete_buffer = 0)
	{
		return this->Send(buf, nLen, delete_buffer, 1);
	}
	////////////////////////////////////////////////////////////////////////////////
	// // 开始定时器
	////////////////////////////////////////////////////////////////////////////////
	void StartTimer(long nSecond)
	{
		this->reactor()->schedule_timer(this, 0, ACE_Time_Value(nSecond));
	}
	////////////////////////////////////////////////////////////////////////////////
	// // 停止定时器
	////////////////////////////////////////////////////////////////////////////////
	void StopTimer(void)
	{
		this->reactor()->cancel_timer(this);
	}

	// 获取及设置server对象指针
	ICHAT_TCP_Server * server(void)				{return m_pServer;}
	virtual void server(ICHAT_TCP_Server *p)	{m_pServer = p;}
	DWORD GetHandlerID(void)				{return (int)this->get_handle();}
	// ACE_Svc_Handler 钩子函数
public:
	////////////////////////////////////////////////////////////////////////////////
	// // 新连接时调用
	////////////////////////////////////////////////////////////////////////////////
	int open(void * = 0)
	{
		if(this->OnConnected() != 0)
			return -1;
		this->water_marks(ACE_IO_Cntl_Msg::SET_HWM, 4*1024*1024);
		if(base::open() == -1)
			return -1;
		m_pSendLoopBuffer = new CLoopBuffer(MAX_LOOP_BUFFER_LEN);
		if (m_pSendLoopBuffer == NULL)	
		{
			ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D] Can't alloc the SendloopBuffer=NULL\r\n")));
			return -1;
		}
		this->peer().enable(ACE_NONBLOCK);
		return 0;
	}
	////////////////////////////////////////////////////////////////////////////////
	// 
	////////////////////////////////////////////////////////////////////////////////
	int handle_close(ACE_HANDLE handle = ACE_INVALID_HANDLE,
		ACE_Reactor_Mask close_mask = ACE_Event_Handler::ALL_EVENTS_MASK)
	{
        
		//ACE_DEBUG((LM_INFO, ACE_TEXT("[%D]handler closed!\r\n")));
		ACE_UNUSED_ARG(handle);
		if(close_mask == ACE_Event_Handler::WRITE_MASK)
			return 0;
		this->msg_queue_->close();
		this->StopTimer();
		this->flush();
		if(this->OnClose() == 1) // only close , but not remove Reactor
			this->peer().close();
		else
			this->destroy();
		return 0;
	}
	////////////////////////////////////////////////////////////////////////////////
	// 
	////////////////////////////////////////////////////////////////////////////////
	int handle_input(ACE_HANDLE fd = ACE_INVALID_HANDLE)
	{
        
		//ICHAT_DEBUG_IO((LM_DEBUG, ACE_TEXT("(%P|%t) input!!!!!!!\r\n")));
		ACE_UNUSED_ARG(fd);

		int nRecv = this->peer_.recv(m_pRecvBuffer, _buffer_size, MSG_NOSIGNAL);

		//ICHAT_DEBUG_IO((LM_DEBUG, ACE_TEXT("(%P|%t) Receive data %d, %X, fd=%d\r\n"), nRecv, this, fd));

		if(nRecv <= 0)
		{
			//ACE_DEBUG((LM_DEBUG, ACE_TEXT("(%P|%t) 客户端主动关闭连接 %X\r\n"), this));
			return -1;
		}
		return OnParser(m_pRecvBuffer, nRecv);
	}
	////////////////////////////////////////////////////////////////////////////////
	// 
	////////////////////////////////////////////////////////////////////////////////
	int handle_timeout(const ACE_Time_Value &time, const void *p)
	{
		(void)time;
		return OnTimer(p);
	}

private:
	ICHAT_TCP_Server *m_pServer;
	char m_pRecvBuffer[_buffer_size];
	typedef ACE_Svc_Handler<ACE_SOCK_STREAM, ACE_NULL_SYNCH> base;
	CLoopBuffer* m_pSendLoopBuffer;
	char m_pTmpSendBuffer[SEND_BUFFER_SIZE];

protected:
	// ICHAT_TCP_Handler 自定义Hook 函数
	virtual int OnClose(void)			{return -1;}	// 连接断开后调用 注意:如果返回1则不会删除对象只会关闭连接
	virtual int OnConnected(void)		{return 0;}	// 连接成功建立后调用
	virtual int OnTimer(const void *)	{return -1;}// 定时器触发时调用
	virtual int OnParser(char *, int)	{return -1;}// 需解析数据包时调用
};
