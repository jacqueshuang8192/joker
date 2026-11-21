#include "DirtyWordsFilter.h"
#include "DictTreeDW.h"

#include <stdio.h>
#include <string.h>
#include <string>
#include <time.h>
#include <sys/time.h>

#include "clib_log.h"

extern clib_log * g_pDebugLog;

static const char * mask = "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ";
static const size_t mask_len = 256;

int GetTickCount1()
{
	timeval timesnow;
	struct timezone tmpzone;
	gettimeofday(&timesnow,&tmpzone);
	//return ((DWORD)(timesnow.tv_sec*1000) + (DWORD)(timesnow.tv_usec/1000));
	return timesnow.tv_sec * 1000 * 1000 + timesnow.tv_usec;
}


CDirtyWordsFilter * CDirtyWordsFilter::_ins = NULL;

CDirtyWordsFilter * CDirtyWordsFilter::Instance()
{
	if(_ins == NULL)
	{
		_ins = new CDirtyWordsFilter;
	}

	return _ins;
}

static unsigned char UCS2toUTF8Code(unsigned short ucs2_code, unsigned char * utf8_code)
{
	  unsigned char length = 0;
	  unsigned char * out = utf8_code;
	  if(!utf8_code){
		   return length;
	  }
	  if(0x0080 > ucs2_code){
	  /* 1 byte UTF-8 Character.*/
		  *out = (unsigned char)ucs2_code;
		  length++;   
	  }
	  else if(0x0800 > ucs2_code){
	  /*2 bytes UTF-8 Character.*/
	   *out = ((unsigned char)(ucs2_code >> 6)) | 0xc0;
	   *(out+1) = ((unsigned char)(ucs2_code & 0x003F)) | 0x80;
	   length += 2;
	 }
	 else{
	 /* 3 bytes UTF-8 Character .*/
		 *out = ((unsigned char)
(ucs2_code >> 12)) | 0xE0;
		 *(out+1) = ((unsigned char)((ucs2_code & 0x0FC0)>> 6)) | 0x80;
		 *(out+2) = ((unsigned char)(ucs2_code & 0x003F)) | 0x80;
		length += 3;			   
	}
	return length;

}

std::string CDirtyWordsFilter::Code2UTF8(const std::string & msg)
{
	std::string resPacket;
	std::string str = msg;	
	int nBeginIndex = str.find("\\u");
	resPacket += str.substr(0, nBeginIndex);
	while(nBeginIndex != -1)
	{
		std::string strTemp = str.substr(nBeginIndex+2, 4);
		unsigned short n;
		char * stop;
		n = strtol(strTemp.c_str(), &stop, 16);
		unsigned char buf[10] = {0};
		UCS2toUTF8Code(n, buf);
		resPacket += (char *)buf;
		str = str.substr(nBeginIndex+6, str.size()-nBeginIndex-6);
		nBeginIndex = str.find("\\u");		
		if(nBeginIndex != -1)
		{
			resPacket += str.substr(0, nBeginIndex);
		}
		else
		{
			resPacket += str;
		}
	}

	return resPacket;
}


CDirtyWordsFilter::CDirtyWordsFilter() : m_nFilterSwitch(1), m_nCurrentDirtyLine(0)
{

}

CDirtyWordsFilter::~CDirtyWordsFilter()
{

}

void CDirtyWordsFilter::filterOff()
{
	m_nFilterSwitch = 0;
}

int CDirtyWordsFilter::filterRestart()
{
	m_nFilterSwitch = 1;
	return init();
}


int CDirtyWordsFilter::init()
{
	if(_initWildcard() < 0)
		return -1;

	if(_initDirtyWords() < 0)
		return -2;
	
	return 0;
}


int CDirtyWordsFilter::_initWildcard()
{
	FILE * f = fopen(m_wildcardWordsPath.c_str(), "r");
	if(f == NULL)
		return -1;

	m_wildcardList.clear();

	char line[512] = {0};

	WildcardUnitList unit;
	while(fgets(line, sizeof(line), f))
	{
		line[sizeof(line)-1] = 0;

		int len = strlen(line);
		if(len <= 1)
		{
			memset(line, 0, sizeof(line));
			if(!unit.empty())
			{
				m_wildcardList.push_back(unit);
				unit.clear();
			}
			continue;
		}

		line[len-1] = 0;
		unit.push_back(line);
	}

	fclose(f);

	return 0;
}

int CDirtyWordsFilter::_initDirtyWords()
{
	return DictTreeDW::Instance()->Init(m_dirtyWordsPath.c_str());
}

int CDirtyWordsFilter::_initRegex()
{
	FILE * f = fopen(m_regexPath.c_str(), "r");
	if(f == NULL)
		return -1;

	char line[512] = {0};

	if(m_nCurrentDirtyLine != 0) 
	{
		for(int i=0; i<m_nCurrentDirtyLine; ++i) 
		{
			regfree(&m_regArray[i]);
		}
	}

	m_nCurrentDirtyLine = 0;

	while(fgets(line, sizeof(line), f))
	{
		if(m_nCurrentDirtyLine >= REGEX_MAX_LINE)
			break;

		if(line[sizeof(line)-1] != 0)
		{
			memset(line, 0, sizeof(line));
			continue;
		}

		int len = strlen(line);
		if(len < 1)
		{
			memset(line, 0, sizeof(line));
			continue;
		}

		line[len-1] = 0;
		int ret = regcomp(&m_regArray[m_nCurrentDirtyLine], line, 0);
		if(ret != 0)
		{
			memset(line, 0, sizeof(line));
			continue;
		}
		else
		{
			++ m_nCurrentDirtyLine;
		}

	}

	fclose(f);

	return 0;
}


int CDirtyWordsFilter::doFilter(const char * msg)
{
	if(m_nFilterSwitch == 0)
		return 0;
	
	if(msg == NULL)
		return 0;

	if(_filterWildcard(msg) > 0)
		return 1;
	
	if(_filterDirtyWords(msg) > 0)
		return 1;

	return 0;
}


int CDirtyWordsFilter::_filterDirtyWords(const char * msg)
{
	return DictTreeDW::Instance()->FilterMsg(msg);
}

int CDirtyWordsFilter::_filterWildcard(const char * msg)
{
	WildcardList::iterator it = m_wildcardList.begin();
	while(it != m_wildcardList.end())
	{
		WildcardUnitList::iterator itu = it->begin();
		
		std::string msgDup = msg;
		int obsStartPos = 0;
		
		for(; itu != it->end(); ++itu)
		{
			size_t pos = msgDup.find(*itu);
			if(pos == std::string::npos)
			{
				break;
			}
			else
			{
				obsStartPos += pos;
				msgDup = msgDup.substr(pos + itu->length(), std::string::npos);
				obsStartPos += itu->length();
			}
		}

		if(itu == it->end())	//匹配到一个完整的
		{
			return 1;
		}

		++ it;
	}

	return 0;
}

int CDirtyWordsFilter::_filterRegex(const char * msg)
{
	if(m_nCurrentDirtyLine == 0)  //no words need to be filtered
		return 0;

	if(msg == NULL)
		return 0;

	for(int i=0; i<m_nCurrentDirtyLine; ++i)
	{
		regmatch_t pmatch[2];

		int ret = regexec(&m_regArray[i], msg, 2, pmatch, 0);

		if(ret == 0)
		{
			if(pmatch[0].rm_so != -1 && pmatch[0].rm_eo != -1)
			{
				return 1;
			}
		}
	}

	return 0;

}

