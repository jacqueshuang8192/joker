#pragma once
//#include "global.h"
////////////////////////////////////////////////////////////////////////////////
// PacketBase
////////////////////////////////////////////////////////////////////////////////

#ifndef ICHAT_TCP_MIN_BUFFER	//TCP socket 缺省接收 Buffer Size
#	define	ICHAT_TCP_MIN_BUFFER	1024
#endif

#ifndef ICHAT_TCP_DEFAULT_BUFFER	//TCP socket 缺省接收 Buffer Size
#	define	ICHAT_TCP_DEFAULT_BUFFER	8192
#endif

#ifndef ICHAT_TCP_MAX_BUFFER	//TCP socket 最大接收 Buffer Size
#	define	ICHAT_TCP_MAX_BUFFER	1024*16
#endif

#ifndef ICHAT_UDP_DEFAULT_BUFFER	//TCP socket 缺省接收 Buffer Size
#	define	ICHAT_UDP_DEFAULT_BUFFER	1024*8
#endif
// 默认HTTP最大请求长度
#ifndef MAX_HTTP_REQUEST_SIZE
#	define		MAX_HTTP_REQUEST_SIZE		ICHAT_TCP_DEFAULT_BUFFER
#endif

// 默认HTTP最大Head个数
#ifndef MAX_HTTP_REQUEST_FIELDS
#	define		MAX_HTTP_REQUEST_FIELDS		100
#endif

#ifndef _WINDEF_
typedef unsigned char       BYTE;
typedef int			BY_INT;
#else
typedef int		BY_INT;
#endif
// STL头文件定义
#include <string.h>
#include <queue>
#include <vector>
#include <deque>
#include <list>
#include <iostream>
#include <map>
#include <arpa/inet.h> 


using namespace std;
typedef unsigned int        UINT;
typedef unsigned long ULONG;
typedef unsigned short USHORT;
typedef USHORT *PUSHORT;
typedef unsigned char UCHAR;
typedef wchar_t WCHAR;    // wc,   16-bit UNICODE character
typedef unsigned short      WORD;
typedef unsigned long       DWORD;
typedef unsigned long long _u64_;
#define de_htonll(x) \
({ \
    _u64_ __x = (x); \
    ((_u64_)( \
    (_u64_)(((_u64_)(__x) & (_u64_)0x00000000000000ffULL) << 56) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0x000000000000ff00ULL) << 40) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0x0000000000ff0000ULL) << 24) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0x00000000ff000000ULL) <<  8) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0x000000ff00000000ULL) >>  8) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0x0000ff0000000000ULL) >> 24) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0x00ff000000000000ULL) >> 40) | \
    (_u64_)(((_u64_)(__x) & (_u64_)0xff00000000000000ULL) >> 56) )); \
})

inline long long htonll(long long hvalue)
{
    //判断本机是大端还是小端
	union _v_{
		unsigned short a;
		unsigned char b[2];
	}v;
	v.b[0] = 0x1;
	v.b[1] = 0x2;
    if( v.a == 0x12 ) //本地是大端
    {
        return hvalue;
    } 
    else //本地是小端，需要转换
    {
        return (long long)de_htonll(hvalue);
    }
}

inline long long ntohll(long long hvalue)
{
    //判断本机是大端还是小端
   union _v_{
		unsigned short a;
		unsigned char b[2];
	}v;
	v.b[0] = 0x1;
	v.b[1] = 0x2;
    if( v.a == 0x12 ) //本地是大端
    {
        return hvalue;
    }
    else //本地是小端，需要转换
    {
        return (long long)de_htonll(hvalue);
    }
}


#define LUA_CCPACKET_LEN 8192

typedef struct {
	char m_strBuf[LUA_CCPACKET_LEN];
	int m_nPacketSize;
	int m_nBufPos;
}CCPacket;

#pragma pack(1)
struct TPkgHeader
{	
	 int length;
	 char  flag[2];
	 short  cVersion;
	 int cmd;
	 short gameid;
	 short regionid;
	 char deviceid;
	 unsigned char  code;
};
#pragma pack()

typedef struct _HEADINFO{
	short version;
	short gameid;
	short regionid;
	BYTE  deviceid;
	_HEADINFO()
	{
		version = 0;
		gameid = 0;
		regionid = 0;
		deviceid = 0;
	}
	void SetInfo(const _HEADINFO & info)
	{
		version = info.version;
		gameid = info.gameid;
		regionid = info.regionid;
		deviceid = info.deviceid;
	}
}HeadInfo;


template <int _buffer_size>
class PacketBase
{
public:
	PacketBase(void){}
	virtual ~PacketBase(void){}

	char *packet_buf(void)	{return m_strBuf;}
	int packet_size(void)	{return m_nPacketSize;}
	bool InitFromCCPacket(CCPacket * pCCPacket)
	{
		if(pCCPacket == NULL)
		{
			return false;
		}
		if(pCCPacket->m_nBufPos > pCCPacket->m_nPacketSize || pCCPacket->m_nBufPos <0 || pCCPacket->m_nPacketSize<0)
		{
			//invalid pos 
			return false;
		}
		if(!_copy(pCCPacket->m_strBuf,pCCPacket->m_nPacketSize))
		{
			//copye failed.
			return false;
		}
		m_nBufPos = pCCPacket->m_nBufPos;
		return true;
	}
	
	bool Flush2CCPacket(CCPacket * pCCPacket)
	{
		if(pCCPacket == NULL)
		{
			return false;
		}
		if(m_nPacketSize > LUA_CCPACKET_LEN)
		{
			//huge
			return false;
		}
		memcpy(pCCPacket->m_strBuf,m_strBuf,m_nPacketSize);
		pCCPacket->m_nPacketSize = m_nPacketSize;
		pCCPacket->m_nBufPos = m_nBufPos;
		return true;
	}
	
	enum
	{
		PACKET_HEADER_SIZE = 18,
		PACKET_BUFFER_SIZE = _buffer_size
	};
private:
	char m_strBuf[PACKET_BUFFER_SIZE];	// 报文包缓存
	int m_nPacketSize ;	// 实际报文总长度
	int m_nBufPos;
public:
	HeadInfo m_HeadInfo;
protected:
	////////////////////////////////////////////////////////////////////////////////
	bool _copy(const void *pInBuf, int nLen)
	{
		if(nLen > PACKET_BUFFER_SIZE || nLen < 0){
			//ErrMsg("Fatal Error , nLen:%d",nLen);
			return false;
		}
		_reset();
		memcpy(m_strBuf, pInBuf, nLen);
		m_nPacketSize = nLen;
		//ACE_ASSERT(m_nPacketSize>PACKET_HEADER_SIZE);
		return true;
	}
	////////////////////////////////////////////////////////////////////////////////
	void _begin(int nCmdType, short cVersion,short gameid,short regionid,char deviceid)
	{
		_reset();
		
		nCmdType = htonl(nCmdType);
		cVersion = htons(cVersion);
		gameid = htons(gameid);
		regionid = htons(gameid);
		
		_writeHeader("BY", sizeof(char)*2, 4);			// magic word
		_writeHeader((char*)&cVersion, sizeof(short), 6);		// 版本号
		//_writeHeader(&cSubVersion, sizeof(char), 5);	// 子版本号
		_writeHeader((char*)&nCmdType, sizeof(int), 8);		// 命令码
		_writeHeader((char*)&gameid, sizeof(short), 12);// 游戏ID
		_writeHeader((char*)&regionid, sizeof(short), 14);	// 业务ID
		_writeHeader((char*)&deviceid, sizeof(char), 16);	// 平台ID
	}
	void _SetBegin(int nCmdType)
	{
		nCmdType = htonl(nCmdType);
		_writeHeader((char*)&nCmdType, sizeof(int), 8);// 命令码
	}
public:
	void SetHeadInfo(const HeadInfo & info)
	{
		m_HeadInfo.SetInfo(info);
	}
	HeadInfo GetHeadInfo()
	{
		HeadInfo hi;
		hi.gameid = GetGameID();
		hi.deviceid = GetDeviceID();
		hi.regionid = GetRegionID();
		hi.version = GetVersion();
		return hi;
	}
	int GetCmdType(void)
	{
		int nCmdType;
		_readHeader((char*)&nCmdType, sizeof(int), 8);// 命令码
		int cmd = ntohl(nCmdType);
		return cmd;
	}
	short GetVersion(void)
	{
		short c;
		_readHeader((char *)&c, sizeof(short),6);	// 主版本号
		c = ntohs(c);
		return c;
	}
	int GetBodyLength(void)
	{
		int nLen;
		_readHeader((char*)&nLen, sizeof(int), 0);// 包正文长度
		int len = ntohl(nLen);
		return len;
	}
	BYTE GetcbCheckCode(void)
	{
		BYTE code;
		_readHeader((char*)&code, sizeof(BYTE), 17);// cb code
		return code;
	}
	short GetGameID(void)
	{
		short gameID;
		_readHeader((char*)&gameID, sizeof(short), 12);// 游戏ID
		gameID = ntohs(gameID);
		return gameID;
	}
	short GetRegionID(void)
	{
		short regionID;
		_readHeader((char*)&regionID, sizeof(short), 14);// 业务ID
		regionID = ntohs(regionID);
		return regionID;
	}
	BYTE GetDeviceID(void)
	{
		BYTE deviceID;
		_readHeader((char*)&deviceID, sizeof(BYTE), 16);// 平台ID
		return deviceID;
	}
protected:
	void _end()
	{
		int nBody = m_nPacketSize - 4;	//数据包长度包括命令头和body,4个字节是数据包长度
		int len = htonl(nBody);
		_writeHeader((char*)&len, sizeof(int), 0);	// 包正文长度
		BYTE code = 0;
		_writeHeader((char*)&code, sizeof(BYTE), 17);	//效验码
	}
	/////////////////////////////////////////////////////////////////////////////////
	void _reset(void)
	{
		memset(m_strBuf, 0, PACKET_BUFFER_SIZE);
		m_nBufPos = PACKET_HEADER_SIZE;
		m_nPacketSize = PACKET_HEADER_SIZE;
	}
	// 取出一个变量
	bool _Read(char *pOut, int nLen)
	{
		if((nLen + m_nBufPos) > m_nPacketSize || (nLen + m_nBufPos) > PACKET_BUFFER_SIZE || nLen < 0){
			//ErrMsg("Fatal Error , nLen:%d , m_nBufPos:%d",nLen,m_nBufPos);
			return false ;
		}
		memcpy(pOut, m_strBuf + m_nBufPos, nLen);
		m_nBufPos += nLen;
		return true;
	}
	//取出变量并从包中移除
	bool _ReadDel(char *pOut, int nLen)
	{
		if(!_Read(pOut, nLen))
			return false;
		memcpy(m_strBuf + m_nBufPos - nLen, m_strBuf + m_nBufPos, PACKET_BUFFER_SIZE - m_nBufPos);
		m_nBufPos -= nLen;
		m_nPacketSize -= nLen;
		_end();
		return true;
	}
	//读撤消
	void _readundo(int nLen)
	{
		m_nBufPos -= nLen;
	}
	//读出当前POS位置的BUFFER指针
	char *_readpoint(int nLen) //注意返回的是指针 请慎重使用string
	{
		if((nLen + m_nBufPos) > m_nPacketSize || nLen < 0){
			//ErrMsg("Fatal Error , nLen:%d , m_nBufPos:%d",nLen,m_nBufPos);
			return NULL; 
		}
		char *p = &m_strBuf[m_nBufPos];
		m_nBufPos += nLen;
		return p;
	}
	// 写入一个变量
	bool _Write(const char *pIn, int nLen)
	{
		if((m_nPacketSize < 0) || ((nLen + m_nPacketSize) > PACKET_BUFFER_SIZE) || nLen < 0){
			//ErrMsg("Fatal Error , nLen:%d , m_nPacketSize:%d",nLen,m_nPacketSize);
			return false ;
		}
		memcpy(m_strBuf+m_nPacketSize, pIn, nLen);
		m_nPacketSize += nLen;
		return true;
	}
	//插入一个变量
	bool _Insert(const char *pIn, int nLen)
	{
		if((nLen + m_nPacketSize) > PACKET_BUFFER_SIZE || nLen < 0){
			//ErrMsg("Fatal Error , nLen:%d , m_nPacketSize:%d",nLen,m_nPacketSize);
			return false;
		}
		memcpy(m_strBuf+PACKET_HEADER_SIZE+nLen, m_strBuf+PACKET_HEADER_SIZE, m_nPacketSize-PACKET_HEADER_SIZE);
		memcpy(m_strBuf+PACKET_HEADER_SIZE, pIn, nLen);
		m_nPacketSize += nLen;
		_end();
		return true;
	}
	// 写入一个变量
	bool _writezero(void)
	{
		if((m_nPacketSize + 1) > PACKET_BUFFER_SIZE)
			return false ;
		memset(m_strBuf+m_nPacketSize, '\0', sizeof(char)) ;
		m_nPacketSize ++;
		return true;
	}
	// readHeader
	void _readHeader(char *pOut, int nLen, int nPos)
	{
		if(nPos >= 0 && nPos+nLen <= PACKET_HEADER_SIZE && nLen > 0)
		{
			memcpy(pOut, m_strBuf+nPos, nLen) ;
		}
		else
		{
			//ErrMsg("Fatal Error , nLen:%d , nPos:%d",nLen,nPos);
		}
	}
	// writeHeader
	void _writeHeader(char *pIn, int nLen, int nPos)
	{
		if(nPos >= 0 && nPos+nLen <= PACKET_HEADER_SIZE && nLen > 0)
		{
			memcpy(m_strBuf+nPos, pIn, nLen) ;
		}
		else
		{
			//ErrMsg("Fatal Error , nLen:%d , nPos:%d",nLen,nPos);
		}
	}
};

template <int _buffer_size>
class InputPacket: public PacketBase<_buffer_size>
{
public:
	typedef PacketBase<_buffer_size> base;

	int ReadInt(void)		{int nValue = -1; base::_Read((char*)&nValue, sizeof(int)); return ntohl(nValue);} //这里必需初始化
	_u64_ ReadInt64(void)		{_u64_ nValue = -1;base::_Read((char*)&nValue, sizeof(_u64_));return ntohll(nValue);}
	unsigned long ReadULong(void) {unsigned long nValue = -1; base::_Read((char*)&nValue, sizeof(unsigned long)); return ntohl(nValue);}
	int ReadIntDel(void)	{int nValue = -1; base::_ReadDel((char*)&nValue, sizeof(int)); return ntohl(nValue);} 
	short ReadShort(void)	{short nValue = -1; base::_Read((char*)&nValue, sizeof(short)); return ntohs(nValue);}
	BYTE ReadByte(void)		{BYTE nValue = -1; base::_Read((char*)&nValue, sizeof(BYTE)); return nValue;}
	bool ReadString(char *pOutString, int nMaxLen)
	{
		int nLen = ReadInt();
		if(nLen < 0)  //这里必需判断
			return false;
		if(nLen > nMaxLen)
		{
			base::_readundo(sizeof(short));
			return false;
		}
		return base::_Read(pOutString, nLen);
	}
	char *ReadChar(void)
	{
		int nLen = ReadInt();
		if(nLen < 0) 
			return NULL;
		return base::_readpoint(nLen);
	}

	string ReadString(void)
	{
		char *p = ReadChar();
		return (p == NULL ? "" : p);
	}

	int ReadBinary(char *pBuf, int nMaxLen)
	{
		int nLen = ReadInt();
		if(nLen < 0) 
		{
			//ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]%s: ReadBinary nLen == -1\r\n"),__FUNCTION__));
			return -1;
		}
		if(nLen > nMaxLen)
		{
			base::_readundo(sizeof(int));
			//ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]%s: ReadBinary nLen > nMaxLen\r\n"),__FUNCTION__));
			return -1;
		}
		if(base::_Read(pBuf, nLen))
			return nLen ;
		return 0;
	}
	
	void Reset(void)
	{
		base::_reset();
	}
	bool Copy(const void *pInBuf, int nLen)
	{
		return base::_copy(pInBuf, nLen);
	}
	bool WriteBody(const char *pIn, int nLen)
	{
		return base::_Write(pIn, nLen);
	}
	////用于伪造接收包
	void Begin(int nCommand)
	{
		base::_begin(nCommand, base::m_HeadInfo.version, base::m_HeadInfo.gameid,base::m_HeadInfo.regionid,base::m_HeadInfo.deviceid);
	}
	void End(void)
	{
		base::_end();
	}
};

template <int BUFFER_SIZE>
class OutputPacket: public PacketBase<BUFFER_SIZE>
{
	bool m_isCheckCode;
public:
	OutputPacket(void){m_isCheckCode = false;}
public:
	typedef PacketBase<BUFFER_SIZE> base;
	bool WriteInt(int nValue)		{int value = htonl(nValue); return base::_Write((char*)&value, sizeof(int));}
	bool WriteInt64(_u64_ nValue)		{_u64_ value = htonll(nValue);return base::_Write((char*)&value, sizeof(_u64_));}
	bool WriteULong(unsigned long nValue) {unsigned long value = htonl(nValue);return base::_Write((char*)&value, sizeof(unsigned long));}
	bool WriteByte(BYTE nValue)		{return base::_Write((char*)&nValue, sizeof(BYTE));}
	bool WriteShort(short nValue)	{short value = htons(nValue); return base::_Write((char*)&value, sizeof(short));}
	//在正文首插入数据
	bool InsertInt(int nValue)		{int value = htonl(nValue); return base::_Insert((char*)&value, sizeof(int));}
	bool InsertByte(BYTE nValue)	{return base::_Insert((char*)&nValue, sizeof(BYTE));}
	bool WriteString(const char *pString)
	{
		int nLen = (int)strlen(pString) ;
		WriteInt(nLen + 1) ;
		if ( nLen > 0 )
		{
			return base::_Write(pString, nLen) && base::_writezero();
		}
		else
		{
			return base::_writezero();
		}
	}

	bool WriteString(const string &strDate)
	{
		int nLen = (int)strDate.size();
		if ( nLen > 0 )
		{
			WriteInt(nLen + 1) ;
			return base::_Write(strDate.c_str(), nLen) && base::_writezero();
		}
		else
		{
			WriteInt(1) ;
			return base::_writezero();
		}
	}

	bool WriteBinary(const char *pBuf, int nLen)
	{
		if(nLen > 0)
		{
			WriteInt(nLen) ;
			return base::_Write(pBuf, nLen) ;
		}
		return false;
	}
	bool Copy(const void *pInBuf, int nLen)
	{
		return base::_copy(pInBuf, nLen);
	}
	void Begin(int nCommand)
	{
		base::_begin(nCommand, base::m_HeadInfo.version, base::m_HeadInfo.gameid,base::m_HeadInfo.regionid,0);
		m_isCheckCode = false;
	}
	void End(void)
	{
		m_isCheckCode = false;
		base::_end();
	}
	//增加
	void SetBegin(short nCommand)
	{
		base::_SetBegin(nCommand);
	}
	//效验码
	void WritecbCheckCode(BYTE nValue)
	{
		base::_writeHeader((char*)&nValue, sizeof(BYTE), 17); //效验码
		m_isCheckCode = true;
	}

	bool IsWritecbCheckCode(void)
	{
		return m_isCheckCode;
	}
};

typedef InputPacket<LUA_CCPACKET_LEN>	NETInputPacket;
typedef OutputPacket<LUA_CCPACKET_LEN>	NETOutputPacket;
typedef OutputPacket<LUA_CCPACKET_LEN>		NETMINOutputPacket;

