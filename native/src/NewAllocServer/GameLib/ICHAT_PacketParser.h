#pragma once

enum PACKETVER
{
	SERVER_PACKET_DEFAULT_VER = 1,
	SERVER_PACKET_DEFAULT_SUBVER = 1
};


template <class INPUT_PACKET>
class ICHAT_PacketParser
{
public:
	ICHAT_PacketParser(void)
	{
		m_pBuf = m_Packet.packet_buf();
		m_version = SERVER_PACKET_DEFAULT_VER;
		m_subVersion = SERVER_PACKET_DEFAULT_SUBVER;
		reset();
	}
	virtual ~ICHAT_PacketParser(void){}
	// 返回Packet
	virtual int OnPacketComplete(INPUT_PACKET *) = 0;
	// 处理PACKET数据
	int ParsePacket(char *data, int length)
	{
		int ret = -1; //出错返回
		int ndx = 0;
		while(ndx < length && m_nStatus != REQ_ERROR)//可能会同时来两个包 
		{
			switch(m_nStatus)
			{
			case REQ_REQUEST:
			case REQ_HEADER:
				if(!read_header(data, length, ndx))
					break;
				ret = parse_header();
				if(ret != 0)
				{
					m_nStatus = REQ_ERROR;
					break;
				}else
					m_nStatus = REQ_BODY;
			case REQ_BODY:
				if(parse_body(data, length, ndx))
					m_nStatus = REQ_DONE;
				break;
			default:
				return -1;
			}
			if(m_nStatus == REQ_ERROR)
				return ret;
			if(m_nStatus == REQ_DONE)
			{
				if(OnPacketComplete(&m_Packet) == -1)
					return -1;
				this->reset();
			}
		}
		return 0; // return 0 to continue
	}
protected:
	void reset(void)
	{
		m_nStatus = REQ_REQUEST;
		m_nPacketPos = 0;
		m_nBodyLen = 0;
		m_Packet.Reset();//包完成复位
	}

public:
	short m_version;
	short m_subVersion;

private:
	// 当前处理状态
	int m_nStatus; 
	// PacketPos
	int	m_nPacketPos;
	// BODY长度
	int m_nBodyLen;
	// PacketBuffer 指针
	char *m_pBuf;
	// PacketBuffer
	INPUT_PACKET m_Packet;
	// 状态
	enum REQSTATUS{	REQ_REQUEST=0, REQ_HEADER, REQ_BODY, REQ_DONE, REQ_PROCESS, REQ_ERROR };

private:

	// 读取Packet头数据
	bool read_header(char *data, int length, int &ndx)
	{
		while(m_nPacketPos < INPUT_PACKET::PACKET_HEADER_SIZE && ndx < length)//
		{
			m_pBuf[m_nPacketPos++] = data[ndx++];
		}
		if(m_nPacketPos < INPUT_PACKET::PACKET_HEADER_SIZE)
			return false;
		return true;
	}
	// 解析Packet头信息
	int parse_header(void) //0:成功 -1:包错误 -2:命令范围错误 -3:版本错误 -4:长度错误
	{
		if(m_pBuf[4] != 'B' || m_pBuf[5] != 'Y')
			return -1;

		int nCmdType = m_Packet.GetCmdType();
		if(nCmdType <= 0 || nCmdType >= 32000)
			return -2;
		
		
		m_nBodyLen = m_Packet.GetBodyLength();
		if(m_nBodyLen >= 0 && m_nBodyLen < (INPUT_PACKET::PACKET_BUFFER_SIZE - 4))
			return 0;
		return -4;
	}
	// 解析BODY数据
	bool parse_body(char *data, int length, int &ndx)
	{
		int nNeed = (m_nBodyLen+4) - m_nPacketPos;
		int nBuff = length - ndx;

		if(nNeed <= 0)
			return true;
		if(nBuff <= 0)
			return false;

		int nCopy = nBuff < nNeed ? nBuff : nNeed;
		if(!m_Packet.WriteBody(data + ndx, nCopy))
			return false;

		m_nPacketPos += nCopy;
		ndx += nCopy;

		if(m_nPacketPos < (m_nBodyLen + 4))
			return false;

		return true;
	}
};

