#include "ICHAT_HTTP_Config.h"
#include "ace/SString.h"

ICHAT_HTTP_Config::ICHAT_HTTP_Config(size_t default_map_size)
{
	m_Error = 0;
	m_iniFileName = NULL;
	m_Error = m_Config_Handler.open(default_map_size);
	m_Root = m_Config_Handler.root_section();
}

ICHAT_HTTP_Config::~ICHAT_HTTP_Config(void)
{
	if(m_iniFileName != NULL)
		ACE::strdelete(m_iniFileName); 
}

////////////////////////////////////////////////////////////////////////////////
// 打开配置文件
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::Open(const char *filename)
{
	ACE_Ini_ImpExp importExport(m_Config_Handler);

	m_Error = importExport.import_config(filename);
	if (m_Error != 0)
		return -1;
	
	if(m_iniFileName != NULL)
		ACE::strdelete(m_iniFileName);

	m_iniFileName = ACE::strnew(filename);

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// 保存已经修改的配置文件
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::Save()
{
	return SaveTo(m_iniFileName);
}

////////////////////////////////////////////////////////////////////////////////
// 保存到别的配置文件中
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::SaveTo(const char *filename)
{
	ACE_Ini_ImpExp importExport(m_Config_Handler);

	m_Error = importExport.export_config(filename);
	if (m_Error != 0)
		ACE_ERROR_RETURN ((LM_ERROR, ACE_TEXT ("Error Exporting (%d)\n"), m_Error), -1);
	return m_Error;
}

////////////////////////////////////////////////////////////////////////////////
// 返回当前配置文件名
////////////////////////////////////////////////////////////////////////////////
const char* ICHAT_HTTP_Config::GetConfigFileName()
{
	return m_iniFileName;
}

////////////////////////////////////////////////////////////////////////////////
// 建立或打开一个Section
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::OpenSection(const char* sub_section, ACE_Configuration_Section_Key& result)
{
	return m_Config_Handler.open_section(m_Root, sub_section, 1, result);
}

////////////////////////////////////////////////////////////////////////////////
// 删除一个Section
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::RemoveSection (const ACE_Configuration_Section_Key& key,
				   const char *sub_section,
				   int recursive)
{
	return m_Config_Handler.remove_section(key, sub_section, recursive);
}

////////////////////////////////////////////////////////////////////////////////
// 设置字符串值
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::set_section_string(const ACE_Configuration_Section_Key& key, const char* name, const char *value)
{
	return m_Config_Handler.set_string_value(key, name, value);
}

////////////////////////////////////////////////////////////////////////////////
// 设置数值
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::set_section_integer(const ACE_Configuration_Section_Key& key, const char* name, int value)
{
	char buf[256];
	ACE_OS::sprintf(buf, "%d", value);
	return set_section_string(key, name, buf);
}

////////////////////////////////////////////////////////////////////////////////
// 设置二进制数据
////////////////////////////////////////////////////////////////////////////////
int ICHAT_HTTP_Config::set_section_binary(const ACE_Configuration_Section_Key& key, const char* name, const void* data, size_t length)
{
	return m_Config_Handler.set_binary_value(key, name, data, length);
}

////////////////////////////////////////////////////////////////////////////////
// 获取字符串
////////////////////////////////////////////////////////////////////////////////
void ICHAT_HTTP_Config::get_section_string(ACE_Configuration_Section_Key& SectionKey, const char* pszName, char* pszVariable, int nMaxLength)
{
	ACE_TString StringValue;

	if(m_Config_Handler.get_string_value (SectionKey,
						pszName,
						StringValue) == 0)
	{
		ACE_OS::strncpy(pszVariable, StringValue.c_str(), nMaxLength);
	}
}

////////////////////////////////////////////////////////////////////////////////
// 获取数值
////////////////////////////////////////////////////////////////////////////////
void ICHAT_HTTP_Config::get_section_integer(ACE_Configuration_Section_Key& SectionKey,
						  const char* pszName, int& nVariable, int nMinValue, int nMaxValue)

{
	ACE_TString StringValue;
	ACE_TCHAR pszString[30];
	ACE_OS::strcpy (pszString, ACE_TEXT("0"));
	int IntegerValue = 0;

	if(m_Config_Handler.get_string_value (SectionKey,
						pszName,
						StringValue) == 0)
	{
		ACE_OS::strncpy (pszString,
			StringValue.c_str(),
			30);
	}

	IntegerValue = ACE_OS::atoi(pszString);
	IntegerValue = (IntegerValue < nMinValue) ? nMinValue : IntegerValue;
	IntegerValue = (IntegerValue > nMaxValue) ? nMaxValue : IntegerValue;
	nVariable = IntegerValue;
}

////////////////////////////////////////////////////////////////////////////////
// 获取布尔值
////////////////////////////////////////////////////////////////////////////////
void ICHAT_HTTP_Config::get_section_boolean(ACE_Configuration_Section_Key& SectionKey, const char* pszName, int* pVariable)
{
	ACE_TString StringValue ;
	ACE_TCHAR pszString[10];
	ACE_OS::strcpy (pszString, ACE_TEXT ("0"));

	if(m_Config_Handler.get_string_value (SectionKey,
								pszName,
								StringValue) == 0)
	{
		ACE_OS::strncpy (pszString, StringValue.c_str (), 10);

		for(ACE_TCHAR* pSrc = pszString; *pSrc != ACE_TEXT('\0'); pSrc++)
		{
			if (ACE_OS::ace_islower(*pSrc))
				*pSrc = ACE_OS::ace_toupper(*pSrc);
		}

		if(ACE_OS::strcmp(pszString, ACE_TEXT ("TRUE")) == 0)
			*pVariable = 1;
		else if (ACE_OS::strcmp (pszString, ACE_TEXT ("FALSE")) == 0)
			*pVariable = 0;
	}
}









/* // 测试写入配置
	ICHAT_HTTP_Config conf;

	ACE_Configuration_Section_Key subkey;
	conf.OpenSection("VQQ Web Server", subkey);
	conf.set_section_string(subkey, "WebRoot", "/usr/local/www");
	conf.set_section_integer(subkey, "Port", 8080);
	conf.set_section_integer(subkey, "Threads", 32);

	ACE_Configuration_Section_Key subkey2;
	conf.OpenSection("Socket Config", subkey);
	conf.set_section_string(subkey, "Mode", "Select");	// TP or EPoll
	conf.set_section_integer(subkey, "Threads", 32);
	conf.set_section_integer(subkey, "HighWaterMark", 1000);
	conf.set_section_integer(subkey, "LowWaterMark", 128);
	conf.set_section_integer(subkey, "WarnWaterMark", 900);


	conf.SaveTo("WebConfig.ini");

	// 测试读取
		ICHAT_HTTP_Config conf;

	conf.Open("WebConfig.ini");

	ACE_Configuration_Section_Key subkey;
	conf.OpenSection("VQQ Web Server", subkey);

	char webpath[256];
	conf.get_section_string(subkey, "WebRoot", webpath, 256);

	ACE_DEBUG((LM_DEBUG, "WebRoot = %s\r\n", webpath));

	int nprot;
	conf.get_section_integer(subkey, "Port", nprot, 0, 65535);
	ACE_DEBUG((LM_DEBUG, "Prot = %d\r\n", nprot));

	int autoload;
	conf.get_section_boolean(subkey, "AutoLoad", &autoload);
	ACE_DEBUG((LM_DEBUG, "AutoLoad = %d\r\n", autoload)); 
*/


