#pragma once
#include "ace/OS.h"
#include "ace/ACE.h"
#include "ace/Configuration.h"
#include "ace/Configuration_Import_Export.h"

class ICHAT_HTTP_Config
{
public:
	ICHAT_HTTP_Config(size_t default_map_size = ACE_DEFAULT_CONFIG_SECTION_SIZE);
	virtual ~ICHAT_HTTP_Config(void);

	// 打开配置文件
	int Open(const char *filename);
	// 保存已经修改的配置文件
	int Save();
	// 保存到别的配置文件中
	int SaveTo(const char *filename);
	// 返回当前配置文件名
	const char* GetConfigFileName();

	// 建立或打开一个Section
	int OpenSection(const char* sub_section, ACE_Configuration_Section_Key& result);
	// 删除一个Section
	int RemoveSection (const ACE_Configuration_Section_Key& key,
                              const char *sub_section,
                              int recursive);
	//
	// 设置操作
	int set_section_string(const ACE_Configuration_Section_Key& key, const char* name, const char *value);
	int set_section_integer(const ACE_Configuration_Section_Key& key, const char* name, int value);
	int set_section_binary(const ACE_Configuration_Section_Key& key, const char* name, const void* data, size_t length);
	
	// 获取操作
	void get_section_string (ACE_Configuration_Section_Key& SectionKey, const char* pszName, char* pszVariable, int nMaxLength);
	void get_section_integer (ACE_Configuration_Section_Key& SectionKey,
		const char* pszName, int& nVariable, int nMinValue, int nMaxValue);
	void get_section_boolean (ACE_Configuration_Section_Key& SectionKey, const char* pszName, int* pVariable);


private:
	ACE_Configuration_Heap m_Config_Handler;
	ACE_Configuration_Section_Key m_Root;
	int m_Error;
	char *m_iniFileName;
};
