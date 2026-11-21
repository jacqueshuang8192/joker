#ifndef DIRTY_WORDS_FILTER_H_04_15_H
#define  DIRTY_WORDS_FILTER_H_04_15_H

#include <string>
#include <list>
#include <regex.h>

typedef std::list<std::string> WildcardUnitList;
typedef std::list< WildcardUnitList > WildcardList;
//typedef std::list<std::string> DirtyWordsList;
#define REGEX_MAX_LINE 3000

class CDirtyWordsFilter
{
public:
	int doFilter(const char * msg);
	int init();
	void filterOff();
	int filterRestart();

	static CDirtyWordsFilter * Instance();
	static std::string Code2UTF8(const std::string & str);

	std::string m_wildcardWordsPath;
	std::string m_dirtyWordsPath;
	std::string m_regexPath;

protected:
	CDirtyWordsFilter();
	CDirtyWordsFilter(const CDirtyWordsFilter &);
	~CDirtyWordsFilter();
	
private:
	int _initWildcard();
	int _initDirtyWords();
	int _initRegex();

	int _filterWildcard(const char * msg);
	int _filterDirtyWords(const char * msg);	
	int _filterRegex(const char * msg);

private:
	WildcardList m_wildcardList;
	//DirtyWordsList m_dirtyWordsList;
	int m_nFilterSwitch;

	regex_t m_regArray[REGEX_MAX_LINE+1];
	int m_nCurrentDirtyLine;
private:
	static CDirtyWordsFilter * _ins;
};

#endif
