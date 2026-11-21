////////////////////////////////////////////////////////////////////////////////
// ichatlib.h
// 
// Global Macro define header file
//
// Zhang Wei modifyed 2006-10-24
////////////////////////////////////////////////////////////////////////////////
#pragma once

#ifndef USE_ICHAT_NAMESPACE	
#	define	USE_ICHAT_NAMESPACE
#endif

#ifndef USE_ICHAT_NAMESPACE
#	define	BEGIN_ICHAT_NAMESPACE
#	define	END_ICHAT_NAMESPACE
#	define USING_ICHAT_NAMESPACE
#else
#	define	BEGIN_ICHAT_NAMESPACE	namespace ichat {
#	define	END_ICHAT_NAMESPACE		};
#	define USING_ICHAT_NAMESPACE	using namespace ichat;
#endif


#ifndef	ICHAT_DEBUG_IO		// IO层调试信息
#	define ICHAT_DEBUG_IO	ACE_DEBUG//ACE_TRACE
#endif

#ifndef	ICHAT_DEBUG_HTTP	// HTTP协议调试信息
#	define	ICHAT_DEBUG_HTTP	ACE_TRACE
#endif

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
#endif

#if WIN32
typedef long long		int64_t;
#endif

#ifndef WIN32
#	define _atoi64 atoll
#endif

// STL头文件定义
#include <string>
#include <queue>
#include <vector>
#include <deque>
#include <list>
#include <iostream>
using namespace std;

void globalbreak(void);
