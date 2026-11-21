#include "GameServer.h"
#include "CommandType.h"
#include "MainServer.h"
#include "GameMatch.h"
#include "GameGroup.h"
#include "TableList.h"
#include "WebServer.h"
#include <cmath>
#include "DirtyWordsFilter.h"
#include "GroupCmd.h"
#include "MarkupSTL.h"
#ifndef WIN32
#include <time.h>
#include <sys/time.h>
static bool Less_Server_TableCount(const CGameTable* s1, const CGameTable* s2)
{
	return s1->numTable > s2->numTable;
}
int GetTickCount()
{
    timeval timesnow;
    struct timezone tmpzone;
    gettimeofday(&timesnow,&tmpzone);
    return timesnow.tv_sec * 1000 * 1000 + timesnow.tv_usec;
}

int GetDelayTime()
{
    time_t timep;
    struct tm *p;
    int delaytime = 0;
    time(&timep);
    p=localtime(&timep);
    delaytime = 86400- p->tm_hour*3600 - p->tm_min*60 - p->tm_sec;
    return delaytime;
}


static string ToLower(const string & str)
{
    if(str.length() == 0)
        return "";

    char buf[512] = {0};
    snprintf(buf, sizeof(buf), "%s", str.c_str());
    int len = strlen(buf);
    for(int i=0; i<len; ++i)
    {
        if(buf[i] >= 'A' && buf[i] <= 'Z')
            buf[i] += ('a'-'A');
    }

    return string(buf);
}
#endif

#define ROOM_MAX_USER 360
#define CHECK_HALL_CORE 1

const int MATCHCOUNT = 36;


#ifndef WIN32
#include "clib_log.h"
extern clib_log *g_pDebugLog;
extern clib_log *g_pErrorLog;
#endif

#ifndef WIN32
int split_str(const char* ps_str , char* ps_sp , vector<std::string> &v_ret)
{
    char* ps_temp;
    char* p;
    int i_len = (int)strlen(ps_str);
    std::string st_str;
    ps_temp = new char[i_len+2];
    snprintf(ps_temp , i_len+1 , "%s" , ps_str);
    char *last = NULL;
    p = strtok_r(ps_temp , ps_sp , &last);
    if(NULL == p)
    {
        delete ps_temp;
        return 0;
    }
    st_str = (std::string)p;
    v_ret.push_back(st_str);
    while( NULL != ( p=strtok_r(NULL , ps_sp , &last) ) )
    {
        st_str = (std::string)p;
        v_ret.push_back(st_str);
    }
    delete ps_temp;
    return 0;
}
#endif

#define SYS_CTRL_KEY "sys_ctrl_key_alloc"

static bool Less_TableUserCount(const TABLEINFO &t1, const TABLEINFO &t2)
{
    return t1.userCount > t2.userCount;
}

bool Less_ServerUserCount(const SERVERINFO &s1, const SERVERINFO &s2)
{
    return s1.userCount < s2.userCount;
}

static bool More_ServerUserCount(const SERVERINFO &s1, const SERVERINFO &s2)
{
    return s1.userCount > s2.userCount;
}

static bool Max_MatchCount(const MATCHINFO &s1,const MATCHINFO &s2)
{
    return s1.usercount > s2.usercount;
}
static double  calculateDistanceInfo(double lat1, double lng1, double lat2, double lng2) {
	double  PI = 3.14159265358979323846;
	double radLat1 = (lat1 * PI / 180.0);
	double radLat2 = (lat2 * PI / 180.0);
	double a = radLat1 - radLat2;
	double b = (lng1 - lng2) * PI / 180.0;
	double s = 2 * asin(sqrt(pow(sin(a / 2), 2)
		+ cos(radLat1) * cos(radLat2)
		* pow(sin(b / 2), 2)));
	s = s * 637813.70;
	s = round(s * 10000) / 10000;
	return s;
}
CMemDataServer* CGameServer::GetMemDataServer(int id)
{
	CMemDataServer *pServer = NULL;
	MemDataServerMap::iterator iter = m_MemDataServerMap.find(id);
	if (iter != m_MemDataServerMap.end())
	{
		pServer = iter->second;
	}
	return pServer;
}

BOOL CGameServer::ReadCommonConf(const char* pszConfPath)
{
	ICHAT_HTTP_Config ConfigReader;
	int nRet = ConfigReader.Open(pszConfPath);
	if (nRet == -1)
	{
		g_pDebugLog->logMsg("[%D] Open file error [%s] \r\n", pszConfPath);
		return FALSE;
	}

	ACE_Configuration_Section_Key subkey;
	ConfigReader.OpenSection("MemDataServer", subkey);
	char szMemBuf[100] = { 0 };
	ConfigReader.get_section_string(subkey, "ServerCount", szMemBuf, sizeof(szMemBuf));
	int memServerCount = atoi(szMemBuf);

	char szKey[100];
	for (int i = 0; i < memServerCount; i++)
	{
		memset(szKey, 0, sizeof(szKey));
		memset(szMemBuf, 0, sizeof(szMemBuf));
		snprintf(szKey, sizeof(szKey), "MemDataServer_%d", i);
		ConfigReader.get_section_string(subkey, szKey, szMemBuf, sizeof(szMemBuf));
		vector<string> v;
		split_str(szMemBuf, ":", v);
		CMemDataServer *pServer = new CMemDataServer();
		
		if (pServer != NULL)
		{
pServer->InitConnect((char*)v[0].c_str(), atoi(v[1].c_str()));
			m_MemDataServerMap[i] = pServer;
		}
		
	}
	
	/*if (m_nLevel > 2) {
		ACE_Configuration_Section_Key subkey2;
		ConfigReader.OpenSection("AllocServer", subkey2);
		char szAllocBuf[100] = { 0 };
		ConfigReader.get_section_string(subkey2, "ServerCount", szAllocBuf, sizeof(szAllocBuf));
		int AllocServerCount = atoi(szAllocBuf);
		char allocKey[100];
		for (int i = 0; i < AllocServerCount; i++)
		{
			memset(allocKey, 0, sizeof(allocKey));
			memset(szAllocBuf, 0, sizeof(szAllocBuf));
			snprintf(allocKey, sizeof(allocKey), "AllocServer_%d", i);
			ConfigReader.get_section_string(subkey2, allocKey, szAllocBuf, sizeof(szAllocBuf));
			vector<string> v;
			split_str(szAllocBuf, ":", v);
			g_pDebugLog->logMsg("v[1]==%s  v[2]==%s", v[1].c_str(), v[2].c_str());
			CAllocServer *aServer = new CAllocServer();
			allocServer = aServer;
			allocServer->InitConnect(v[1].c_str(), atoi(v[2].c_str()));
			NETOutputPacket resPacket;
			resPacket.Begin(0x523);
			resPacket.WriteInt(1);
			resPacket.WriteInt(4);
			resPacket.End();
			allocServer->Send(&resPacket);
		}
	}*/
	

	ACE_Configuration_Section_Key subkey1;
	ConfigReader.OpenSection("BackStageServer", subkey1);

	char url[100] = { 0 };
	ConfigReader.get_section_string(subkey1, "URL", url, sizeof(url));
	GameGroup::Instance()->backServerUrl = url;

	char request[100] = { 0 };
	ConfigReader.get_section_string(subkey1, "REQUEST", request, sizeof(request));
	GameGroup::Instance()->backServerRequest = request;

	char group_request[100] = { 0 };
	ConfigReader.get_section_string(subkey1, "CARD_CANCEL_GROUP_REQUEST", request, sizeof(request));
	GameGroup::Instance()->backServerCancelGroupRequest = group_request;

	char divide_request[100] = { 0 };
	ConfigReader.get_section_string(subkey1, "DIVIDE_REQUEST", divide_request, sizeof(divide_request));
	GameGroup::Instance()->divideMoneyRequest = divide_request;

	char cost_card_request[100] = { 0 };
	ConfigReader.get_section_string(subkey1, "COST_CARD_REQUEST", cost_card_request, sizeof(cost_card_request));
	GameGroup::Instance()->costCardRequest = cost_card_request;
	/*char A2IcreateFreeGame[100] = { 0 };
	ConfigReader.get_section_string(subkey1, "A2IcreateFreeGame", A2IcreateFreeGame, sizeof(A2IcreateFreeGame));
	GameGroup::Instance()->costCardRequest = A2IcreateFreeGame;*/
	GameGroup::Instance()->A2IcreateFreeGame = "hbiInterface/freeGame/A2IcreateFreeGame?clubId=%d&level=%d";
	g_pDebugLog->logMsg("ReadCommonConf||[%s] [%s]\n", url, request);

	ConfigReader.get_section_integer(subkey1, "PORT", GameGroup::Instance()->backServerPort, 0, 100000);

	//是否使用桌子列表配置 neo
	ACE_Configuration_Section_Key subkey2;
	snprintf(szKey, sizeof(szKey), "TABLE_LIST_%d", m_nLevel);
	ConfigReader.OpenSection(szKey, subkey2);

	int flag = 0;
	ConfigReader.get_section_integer(subkey2, "USE_FLAG", flag, 0, 100000);
	if (flag > 0)
		CTableList::Instance()->setUserTableList(true);
	else
		CTableList::Instance()->setUserTableList(false);
	ACE_Configuration_Section_Key subkey4;
	ConfigReader.OpenSection("TIME", subkey4);
	ConfigReader.get_section_integer(subkey4, "joinGame", joinGame, 6, 120);
	ConfigReader.get_section_integer(subkey4, "checkeTable", checkeTable, 3, 120);
	//ConfigReader.get_section_integer(subkey4, "tableUser", tableUser, 3, 10);
	
	/*---------------------------- by neo ------------------------------*/
	CWebServer::Instance()->init(pszConfPath);
	/*---------------------------- by neo ------------------------------*/

	return TRUE;
}

void CGameServer:: SortVector(vector<CGameTable*>&first)
{
    int size = first.size();
    for (int i = 0; i < size; i++)
    {
        for (int j = i+1; j < size; j++)
        {
            if (first[i]->m_nRoomIndex > first[j]->m_nRoomIndex)
            {
                 CGameTable* pTable = first[i];
                 first[i] = first[j];
                 first[j] = pTable;
            }
        }
    }
}

void CGameServer::SortTabeList(vector<CGameTable*>&list)
{
    vector<CGameTable*>loveGirlTableList;
    vector<CGameTable*>tableList;
    tableList.clear();
    loveGirlTableList.clear();
    int size = list.size();
    for (int i = 0; i <  size; i++)
    {
        if (list[i]->m_nIsLoveGirl == 1)
        {
            loveGirlTableList.push_back(list[i]);
        } else {
            tableList.push_back(list[i]);
        }
    }
    SortVector(loveGirlTableList);
    SortVector(tableList);
    list.clear();
    for (int i = 0; i < loveGirlTableList.size(); i++)
    {
        list.push_back(loveGirlTableList[i]);
    }

    for (int i = 0; i < tableList.size(); i++)
    {
        list.push_back(tableList[i]);
    }
}


void CGameServer::RandVector(vector<CGameTable*>first, vector<CGameTable*>&second)
{
    second.clear();
   
	int RandCount = 0, Position = 0;
    int Count = first.size();
    if (Count < m_nMaxListPriRoomCount)
    {
        for (int i = 0; i <  Count; i++)
        {
            second.push_back(first[i]);
        }
      
    } else {
    	do
    	{
    		Position = rand()%(Count-RandCount);
            second.push_back(first[Position]);
            RandCount++;
    		first[Position] = first[Count-RandCount];
    	}
    	while (RandCount < Count);
    }
}


CGameServer::CGameServer()
{
	numTable = 0;
	status_Watch.clear();
	tableUser = 8;
	tableUser_rend = 8;
	joinGame = 6;
	checkeTable = 3;
    m_nMaxTableUserCount = 0;
    m_nMaxServerUserCount = 450;
    m_nMaxListPriRoomCount = 50;
	m_nServerId = -1;
	m_nMaxRoomCreateCount = 10;
	m_nSelfMaxListCount = 5;
	testInt = 1;
    m_nTableIdList.clear();
    m_nTableIndexList.clear();
    m_nMatchIndexList.clear();
    m_nMatchIDList.clear();
	groupPlayer.clear();
	userOnClub.clear();
	userListTable.clear();
	//m_clubTableList.clear();
	m_tidClubList.clear();
	m_userRobotTable.clear();
	m_userRobotTableLst.clear();
	groupRobotMap.clear();
	m_userRobotMap.clear();
	groupLevel.clear();
	m_GroupCreatorDict.clear();
	m_GroupServerDict.clear();
	m_GroupTidCreatorDict.clear();
	m_GroupActivityCreatorDict.clear();
	
	m_GroupTableDict_TID.clear();
	m_GroupTableDict_AcitiveId.clear();
	m_Table_PlayerJoin.clear();
	m_Table_PlayerSit.clear();
	m_Table_Distance.clear();
	userIsWatch.clear();
	cardJiFenList.clear();
	groupOwerMap.clear();
	tableTempList.clear(); //假桌子
	list_false.clear();
}

CGameServer::~CGameServer()
{
}

int CGameServer::ProcessClose(SocketHandler *pSocket)
{
    if(pSocket != NULL)
    {
        if(pSocket->m_pLogicServer != NULL)
        {
            ProcessLogicClose(pSocket->m_pLogicServer);
            pSocket->m_pLogicServer = NULL;
        }
        else if(pSocket->m_pHallServer != NULL)
        {
            ProcessHallClose(pSocket->m_pHallServer);
            pSocket->m_pHallServer = NULL;
        }
    }
    return SocketServer::ProcessClose(pSocket);
}
void CGameServer::split(const string& s, vector<int>& sv, const char flag) {
	sv.clear();
	istringstream iss(s);
	string temp;

	while (getline(iss, temp, flag)) {
		sv.push_back(atoi(temp.c_str()));
	}
	return;
}
BOOL CGameServer::InitServer(CRedisManagerClient* pRedisManagerClient, CDbPart* pDBClient, int level, int svid/*, char* szMemCacheServer*/)
{
    m_nLevel = level;
    m_nSvid = svid;
	
    if(!InitUserServer())
    {
        return FALSE;
    }

	int nRet = ReadCommonConf();
	if (nRet == 0)
	{
		ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] Init ReadCommonConf failed. \r\n")));
		return FALSE;
	}
	ACE_INET_Addr* the_addr_array;
	size_t count = 0;
	int rc = ACE::get_ip_interfaces(count, the_addr_array);
	char address[30];
	
	int i = 0;
	long ip1 = 0;
	//unsigned long yip = MAKEIPHOSTORDER(103,8,222,172);//fp
	
	//unsigned long yip = MAKEIPHOSTORDER(127,0,0,1);//cs2
	
	//unsigned long yip = MAKEIPHOSTORDER(103, 216, 154, 231);//jx
	//unsigned long yip = MAKEIPHOSTORDER(103,216,154,231);
	//unsigned long yip = MAKEIPHOSTORDER(172,31,204,163);//cs_new
	unsigned long yip = MAKEIPHOSTORDER(127,0,0,1);//ys
	
	
	
	
	
	bool flag = false;
        flag = true;
	while (i < count)
	{

		(the_addr_array + i)->addr_to_string(address, sizeof(address));
		//g_pDebugLog->logMsg("hoset addr  %s", address);
		vector<string> mArr;
		split_str(address, ".", mArr);

		if (mArr.size() == 4)
		{
			int m1 = atoi(mArr[0].c_str());
			int m2 = atoi(mArr[1].c_str());
			int m3 = atoi(mArr[2].c_str());
			int m4 = atoi(mArr[3].c_str());
			ip1 = MAKEIPHOSTORDER(m1, m2, m3, m4);
			//g_pDebugLog->logMsg("chke ip==[%ld]", ip1);
			
			if (ip1 == yip) {
				//g_pDebugLog->logMsg("yip ip==[%ld]", yip);
				flag = true;
			}
		}
		i++;
	}
	delete[] the_addr_array;
	if (false) {  // bypass IP check
		return FALSE;
	}
	
	//m_pRedisManagerClient = pRedisManagerClient;
    if(level==0 || level==4001)//如果是私人房
    {
        CDirtyWordsFilter::Instance()->m_wildcardWordsPath = "dirtyWords/WildcardWords.conf";
        CDirtyWordsFilter::Instance()->m_dirtyWordsPath = "dirtyWords/DirtyWordsRegular.conf";
        CDirtyWordsFilter::Instance()->m_regexPath = "dirtyWords/Regulars.conf";
        if(CDirtyWordsFilter::Instance()->init() < 0)
        {
            ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] Init Dirty Words filter failed. \r\n")));
            return FALSE;
        }
    }
    if (!ReadPrivateRoomConf())
    {
        ACE_DEBUG((LM_INFO, ACE_TEXT("(%P|%t) Init PrivateRoom error\r\n")));
        return FALSE;
    }
	m_pRedisManagerClient = pRedisManagerClient;
	m_pDBClient = pDBClient;
	m_pRedisManagerClient->Init();
	m_pDBClient->Init();
	//m_pRedisManagerClient->GetGroupPlayer();
	InitConfig();
	
	m_pDBClient->GetGroupPlayerList(this,groupPlayer, groupRobotMap, m_userRobotMap, robotConfig);
	g_pDebugLog->logMsg("groupPlayer.size()%d", groupPlayer.size());
	for (map<int, map<int, CUserBalanceInfo*> >::iterator itr = groupRobotMap.begin(); itr != groupRobotMap.end(); itr++)
	{
		for (map<int, CUserBalanceInfo*>::iterator itrItem = itr->second.begin(); itrItem != itr->second.end(); itrItem++)
		{
			if (itrItem->second->isRobot == 1) {
				m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(itrItem->second->m_uid, 0, 0);
				string str;
				if (m_pRedisManagerClient->GetRobotStatus(itrItem->second->m_uid, str) > 0) {
					
					vector<int> sv;
					split(str, sv, '_');
					//g_pDebugLog->logMsg("itr->first[%d] itrItem->second->m_uid[%d] str[%s]", itr->first, itrItem->second->m_uid, str.c_str());
					if (sv.size() >= 4) {
						m_pRedisManagerClient->ROBOT_STATUS(itr->first,itrItem->second->m_uid, 0, 0, sv[3]);
					}
					else {
						if (sv.size() >= 3) {
							m_pRedisManagerClient->ROBOT_STATUS(itr->first, itrItem->second->m_uid, 0, 0, 0);
						}
						
					}
				}
				else {
					m_pRedisManagerClient->ROBOT_STATUS(itr->first, itrItem->second->m_uid, 0, 0, 0);
				}
			}
		}
	}
	g_pDebugLog->logMsg("end===============================[%d]", m_nLevel);
    if(ReadPrivateRoomMaxListCount() == FALSE)
    {
        return FALSE;
    }
	
	m_logOpenTimer.SetTimeEventObj(this, CHANGE_LOG_FILE_TIMER);
    m_logOpenTimer.StartTimer(GetDelayTime());
	m_autoTableTimer.SetTimeEventObj(this, TIME_AOUT_TABLE);
	m_autoAddTableTimer.SetTimeEventObj(this, TIME_AOUT_ADD_TABLE);

	if (m_nLevel == 1 && robotYs ==1) {
		StartTableAutoTimer();
		if (list_false.size() > 0) {
			StartAddTableAutoTimer(6);
		}
		
	}
	
    ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] InitServer OK...\r\n")));
    return TRUE;
}

BOOL CGameServer::InitUserServer()
{
#ifndef WIN32
    m_nPrivateRoomConf.clear();
    ICHAT_HTTP_Config ConfigReader;
    int nRet = ConfigReader.Open("config.ini");
    if(nRet == -1)
    {
        ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] Open config.ini error!")));
        return FALSE;
    }

    ACE_Configuration_Section_Key key;
    ConfigReader.OpenSection("UserServer", key);
    char szTemp[100]= {0};
    ConfigReader.get_section_string(key, "ServerCount", szTemp, sizeof(szTemp));
    int userServerCount = atoi(szTemp);
    char szKey[100];
    for(int i=0; i<userServerCount; i++)
		{
	        memset(szKey, 0, sizeof(szKey));
	        memset(szTemp, 0, sizeof(szTemp));
	        snprintf(szKey, sizeof(szKey), "UserServer_%d", i);
	        ConfigReader.get_section_string(key, szKey, szTemp, sizeof(szTemp));
	        vector<string> v;
	        split_str(szTemp, ":", v);
	        CUserServer *pUserServer = new CUserServer(this);
	        if(pUserServer != NULL)
	        {
	            int nRet = pUserServer->InitConnect(v[0].c_str(), v[1].c_str());
	            if(nRet != 0)
	            {
	                g_pDebugLog->logMsg("InitUserServer||Connect to UserServer [%s:%s] failed, ret[%d]", v[0].c_str(), v[1].c_str(), nRet);
	            }
	            else
	            {
	                g_pDebugLog->logMsg("InitUserServer||Connect to UserServer [%s:%s] success", v[0].c_str(), v[1].c_str());
	            }
	            m_UserServerList[i] = pUserServer;
	        }
	    }

    char szMemCacheServer[100]= {0};
    ConfigReader.OpenSection("MEMCACHED", key);
    ConfigReader.get_section_string(key, "SERVER_MC", szMemCacheServer, sizeof(szMemCacheServer));
    m_pMemCacheClient = new CMemcacheClient();
    if(!m_pMemCacheClient->Init(szMemCacheServer))
    {
        ACE_DEBUG((LM_INFO, ACE_TEXT("(%P|%t) Init mc error\r\n")));
        return FALSE;
    }
#endif
    return TRUE;
}

BOOL CGameServer::ReadPrivateRoomConf()
{

	ICHAT_HTTP_Config ConfigReader;
	int nRet = ConfigReader.Open("config.ini");
	if (nRet == -1)
	{
		ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] Open config.ini error!")));
		return FALSE;
	}
	ACE_Configuration_Section_Key key;
	ConfigReader.OpenSection("PRIVATEROOM", key);

	int count = 0;
	ConfigReader.get_section_integer(key, "COUNT", count, 0, 60);

	char baseStr[32] = { 0 };
	char lowMoneyStr[32] = { 0 };
	char tableCostStr[32] = { 0 };
	char outMoneyStr[32] = { 0 };
	char levelStr[32] = { 0 };

	int baseChip = 0;
	int outMoney = 0;
	int tableCost = 0;
	int lowMoney = 0;  //出局金币数
	int level = m_nLevel;
	for (int i = 1; i <= count; i++)
	{

		sprintf(baseStr, "BASE_CHIP_%d", i);
		sprintf(lowMoneyStr, "LOW_MONEY_%d", i);
		sprintf(tableCostStr, "TABLE_COST_%d", i);
		sprintf(outMoneyStr, "OUT_MONEY_%d", i);
		sprintf(levelStr, "LEVEL_%d", i);

		ConfigReader.get_section_integer(key, baseStr, baseChip, 0, 1000000000);
		ConfigReader.get_section_integer(key, lowMoneyStr, lowMoney, 0, 1000000000);
		ConfigReader.get_section_integer(key, tableCostStr, tableCost, 0, 1000000000);
		ConfigReader.get_section_integer(key, outMoneyStr, outMoney, 0, 1000000000);
		ConfigReader.get_section_integer(key, levelStr, level, 0, 1000000000);

		TPrivateRoomConf conf;
		conf.nBaseChip = baseChip;
		conf.nOutMoney = outMoney;
		conf.nTableCost = tableCost;
		conf.nLowMoney = lowMoney;
		conf.nLevel = level;
		m_nPrivateRoomConf[baseChip] = conf;
		g_pDebugLog->logMsg("ReadPrivateRoomConf||[%d] level=[%d] baseChip=[%d] lowMoney=[%d] tableCast=[%d] outMoney=[%d]", i, level, baseChip, lowMoney, tableCost, outMoney);
	}

	return TRUE;
}

BOOL CGameServer::ReadPrivateRoomMaxListCount(ICHAT_HTTP_Config * p)
{
    ICHAT_HTTP_Config ConfigReader;
    if(p == NULL)
    {
        int nRet = ConfigReader.Open("config.ini");
        if(nRet == -1)
        {
            return FALSE;
        }
        p = &ConfigReader;
    }

    ACE_Configuration_Section_Key subkey;
    p->OpenSection("PRIVATEROOM_MAX_LIST",subkey);

    p->get_section_integer(subkey,"COUNT",m_nMaxListPriRoomCount,0,100);
    p->get_section_integer(subkey,"LOVEGIRL_COUNT",m_nMaxListLoveGirlRoomCount,0,100);
    ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] PRIVATEROOM_MAX_LIST COUNT=[%d]\n"), m_nMaxListPriRoomCount));
    ACE_DEBUG((LM_INFO, ACE_TEXT("[%D] PRIVATEROOM_LOVEGRIL_MAX_LIST COUNT=[%d]\n"), m_nMaxListLoveGirlRoomCount));

    return TRUE;
}


int CGameServer::ProcessHallClose(CHallServer* pHallServer)//处理某个大厅断开连接
{
    if(pHallServer == NULL)
        return 0;
    //启动一个定时器去检测HallServer有没有挂
    pHallServer->m_pSocketHandler = NULL;//置链接为空
    pHallServer->StartCheckCoreTimer();
    return 0;
}

int CGameServer::ProcessLogicClose(CLogicServer *pLogicServer)
{
    if(pLogicServer == NULL)
        return 0;
    pLogicServer->m_pSocketHandler = NULL;//置链接为空
    //启动定时器去检测GameServer有没有挂
    pLogicServer->StartCheckCoreTimer();
    return 0;
}
void CGameServer::UpdateRobotIsGame(int isGame,int club_id,int uid) {
	map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.find(club_id);
	if (ite != groupRobotMap.end()) {
		if (ite->second.find(uid) != ite->second.end()) {
			ite->second[uid]->is_game = isGame;
			
		}
	}
}
//后台修改机器人状态
void CGameServer::BG2UpdateRobotStatus(int club_id, int uid, int status) {
	map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.find(club_id);
	if (ite != groupRobotMap.end()) {
		if (ite->second.find(uid) != ite->second.end()) {
			string str;
			int ret = m_pRedisManagerClient->GetRobotStatus(uid, str);
			if (ret > 0) {
				vector<int> sv;
				split(str, sv, '_'); //sv[0] level  sv[1]uid sv[2] 状态
 				if (sv.size() >= 4) {
					if (sv[1] == club_id) {
						if (status == 1) {
							m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, 1, sv[0], sv[3]);
						}
						else if (status == 0 && sv[0] > 0) {
							m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, 2, sv[0], sv[3]);
						}
						else if (status == 0 && sv[0] <= 0) {
							m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, 0, 0, sv[3]);
						}
					}
				}
			}
			g_pDebugLog->logMsg("%s   [%d]", __FUNCTION__, ret);
		}
	}
}
int CGameServer::getRobotStatus(int club_id, int uid) {
	map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.find(club_id);
	if (ite != groupRobotMap.end()) {
		if (ite->second.find(uid) != ite->second.end()) {
			string str;
			int ret = m_pRedisManagerClient->GetRobotStatus(uid, str);
			if (ret > 0) {
				vector<int> sv;
				split(str, sv, '_');
				if (sv.size() >= 2) {
					return sv[2];
				}
			}
			g_pDebugLog->logMsg("%s   [%d]", __FUNCTION__, ret);
		}
	}
	return -1;
}
void CGameServer::UpdateClearRobotStatus(int uid) {
	string str;
	int ret = m_pRedisManagerClient->GetRobotStatus(uid, str);
	if (ret > 0) {
		vector<int> sv;
		split(str, sv, '_');
		if (sv.size() >= 4) {
			m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, sv[2], 0, sv[3]);
		}
	}
}
void CGameServer::UpdateClearRobotStatus(int uid,int level) {
	string str;
	int ret = m_pRedisManagerClient->GetRobotStatus(uid, str);
	if (ret > 0) {
		vector<int> sv;
		split(str, sv, '_');
		if (sv.size() >= 4) {
			if (sv[0] == level) {
				m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, sv[2], 0, sv[3]);
			}
			
		}
	}
}
void CGameServer::UpdateRobotStatus(int club_id, int uid,int status,int level) {
	string str;
	int ret = m_pRedisManagerClient->GetRobotStatus(uid, str);
	if (ret > 0) {
		vector<int> sv;
		split(str, sv, '_');
		if (sv.size() >= 4) {
			if (club_id == sv[1]) {
				if (sv[2] == 2 && sv[0] > 0) {
					m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, 0, 0, sv[3]);
				}
				else if (sv[2] == 1) {
					m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, sv[2], level, sv[3]);
				}
				else if (sv[2] == 2 && sv[0] <= 0) {
					m_pRedisManagerClient->ROBOT_STATUS(sv[1], uid, 0, 0, sv[3]);
				}
			}
		}
	}
	g_pDebugLog->logMsg("%s   [%d]", __FUNCTION__, ret);
	
}
int CGameServer::getRobotList() {
	srand((unsigned)time(0));
	for (map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.begin(); ite != groupRobotMap.end(); ite++) {
		int countRobot = 0;
		int _level = 0;
		int cdx = 0;
		map<int, clubTableList>::iterator cjList = cardJiFenList.find(2);
		if (cjList != cardJiFenList.end()) {
			clubTableList::iterator clbuIter = cjList->second.find(ite->first);
			if (clbuIter != cjList->second.end()) {
				
				for (map<int, CGameTable* >::iterator tableItre = clbuIter->second.begin(); tableItre != clbuIter->second.end(); tableItre++)
				{
					CGameTable *pTable = tableItre->second;
					if (pTable != NULL) {

						if (groupLevel.find(pTable->m_nLevel) != groupLevel.end()) {
							Json::Reader reader;
							Json::Value root;

							int maxSeatCount = 0;

							if (reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
							{
								if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
								{
									maxSeatCount = root["maxSeatCount"].asInt();
								}
							}
							
							/*if (pTable->m_nLevel == 368 && pTable->userList.size() < maxSeatCount) {
								_level = pTable->m_nLevel;
							}*/
							g_pDebugLog->logMsg("pTable->jsonConfig %s pTable->userList.size[%d]", pTable->jsonConfig.c_str(), pTable->userList.size());
							if (pTable->userList.size() < maxSeatCount) {
								AddRobotUser(pTable);
							}
						}
					}
				}
			}

		}
		//clubTableList::iterator clbuIter = m_clubTableList.find(ite->first);
		//if (clbuIter != m_clubTableList.end()) {
		//	for (map<int, CGameTable* >::iterator tableItre = clbuIter->second.begin(); tableItre != clbuIter->second.end(); tableItre++)
		//	{
		//		CGameTable *pTable = tableItre->second;
		//		if (pTable != NULL) {
		//			
		//			if (groupLevel.find(pTable->m_nLevel) != groupLevel.end()) {
		//				Json::Reader reader;
		//				Json::Value root;
		//			
		//				int maxSeatCount = 0;
		//				
		//				if (reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
		//				{
		//					if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
		//					{
		//						maxSeatCount = root["maxSeatCount"].asInt();
		//					}
		//				}
		//				if (pTable->m_nLevel == 368 && pTable->userList.size() < maxSeatCount) {
		//					_level = pTable->m_nLevel;
		//				}
		//				g_pDebugLog->logMsg("pTable->jsonConfig %s pTable->userList.size[%d]", pTable->jsonConfig.c_str(), pTable->userList.size());
		//				if (pTable->userList.size() < maxSeatCount) {
		//					AddRobotUser(pTable);
		//				}
		//			}
		//		}
		//	}
		//}
		//
		//g_pDebugLog->logMsg("getRobotList  ite->first[%d] countRobot[%d]", ite->first, countRobot);
		
			
		vector<int> testLevel;
		for (map<int,int>::iterator itr = groupLevel.begin(); itr != groupLevel.end(); itr++)
		{
			
			if (itr->first == 101) {
				continue;
			}
			testLevel.push_back(itr->first);
		}
		if (testLevel.size() > 0) {
			srand(time(NULL));
			int m = rand() % testLevel.size();
			int level = testLevel[m];
			for (map<int, CUserBalanceInfo*>::iterator it = ite->second.begin(); it != ite->second.end(); it++)
			{
				if (it->second->m_tid > 0) {
					continue;
				}
				string tempStr;
				int ret = m_pRedisManagerClient->GET_TEMP_ROBOT_STATUS(it->second->m_uid, tempStr);
				//g_pDebugLog->logMsg("%s ret ===[%d] it->second->m_uid[%d]", __FUNCTION__, ret, it->second->m_uid);
				if (ret > 0) {
					vector<int> sv;
					split(tempStr, sv, '_');
					if (sv.size() >= 2) {
						if (sv[1] > 0 || sv[0] > 0) {
							continue;
						}
					}
					string str;
					ret = m_pRedisManagerClient->GetRobotStatus(it->second->m_uid, str);
					if (ret > 0) {
						vector<int> sv2;
						split(str, sv2, '_');
						if (sv2.size() >= 4) {
							
							if (sv2[2] != 1 || sv2[0] > 0 || sv2[3] != level) {
								continue;
							}
							countRobot++;
						}
					}
				}
			}
			
			bool flagTable = CheckTableMaxUser(ite->first, level);
			g_pDebugLog->logMsg("getRobotList level[%d] ite->first[%d] countRobot[%d] flagTable[%d]", level, ite->first, countRobot, flagTable);
			if (countRobot > 2 && flagTable) {
				if (level != 373) {
					GameGroup::Instance()->PerfromSendTableCreate(ite->first, level);
				}
				//g_pDebugLog->logMsg("==================getRobotList level[%d] ite->first[%d] countRobot[%d]", level, ite->first, countRobot);
				
			}
			
		}
	}
	return 0;
}
bool CGameServer::CheckTableMaxUser(int club_id, int level,int cpmfigId) {
	bool flag = true;
	map<int, clubTableList>::iterator cjList = cardJiFenList.find(2);
	//检测当前level桌子人数是否满人
	if (cjList != cardJiFenList.end()) {
		clubTableList::iterator clbuIter = cjList->second.find(club_id);
		if (clbuIter != cjList->second.end()) {
			for (map<int, CGameTable* >::iterator tableItre = clbuIter->second.begin(); tableItre != clbuIter->second.end(); tableItre++)
			{
				CGameTable* pTable = tableItre->second;
				if (pTable != NULL && pTable->m_nLevel == level) {
					Json::Reader reader;
					Json::Value root;

					int maxSeatCount = 0;

					if (reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
					{
						if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
						{
							maxSeatCount = root["maxSeatCount"].asInt();
						}
					}
					if (pTable->userList.size() <= 0) {
						flag = false;
					}
				}
			}
		}
	}
	return flag;
}
bool CGameServer::CheckTableMaxUser(int club_id, int level) {
	bool flag = true;
	map<int, clubTableList>::iterator cjList = cardJiFenList.find(2);
	//检测当前level桌子人数是否满人
	if (cjList != cardJiFenList.end()) {
		clubTableList::iterator clbuIter = cjList->second.find(club_id);
		if (clbuIter != cjList->second.end()) {
			for (map<int, CGameTable* >::iterator tableItre = clbuIter->second.begin(); tableItre != clbuIter->second.end(); tableItre++)
			{
				CGameTable *pTable = tableItre->second;
				if (pTable != NULL && pTable->m_nLevel == level) {
					Json::Reader reader;
					Json::Value root;

					int maxSeatCount = 0;

					if (reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
					{
						if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
						{
							maxSeatCount = root["maxSeatCount"].asInt();
						}
					}
					if (pTable->userList.size() <= 0) {
						flag = false;
					}
				}
			}
		}
	}
	return flag;
}
void CGameServer::AddRobotUser(CGameTable *pTable) {
	if (pTable == NULL || pTable->groupType == 3) {
		return;
	}
	g_pDebugLog->logMsg("%s activityId ===[%d] club_id[%d]", __FUNCTION__, pTable->m_activityID, pTable->club_id);
	g_pDebugLog->logMsg("%s tid ===[%d]",__FUNCTION__ , pTable->m_nTid);
	
	int maxUser = 0;
	int joinGamePoint = 0;
	int readyPoint = 0;
	int maxSeatCount = 0;
	Json::Reader reader;
	Json::FastWriter fastWriter;
	Json::Value root;
	Json::Value uInfJson;
	g_pDebugLog->logMsg("pTable->jsonConfig %s", pTable->jsonConfig.c_str());
	if (reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
	{
		if (!root["joinGamePoint"].isNull() && root["joinGamePoint"].isInt())
		{
			joinGamePoint = root["joinGamePoint"].asInt();
		}
		if (!root["readyPoint"].isNull() && root["readyPoint"].isInt())
		{
			readyPoint = root["readyPoint"].asInt();

		}
		if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
		{
			maxSeatCount = root["maxSeatCount"].asInt();

		}

	}
	
	int countPlayer = 0;
	if (tableUser > 0) {
		maxSeatCount = maxSeatCount > 0 ? maxSeatCount : 8;
		
		countPlayer = (rand() % (tableUser_rend - tableUser + 1)) + tableUser;
	}
	g_pDebugLog->logMsg("%s maxSeatCount ===[%d] countPlayer[%d]", __FUNCTION__, maxSeatCount, countPlayer);
	map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.find(pTable->club_id);
	if(ite != groupRobotMap.end()){
		
		for (map<int, CUserBalanceInfo*>::iterator  it = ite->second.begin(); it!= ite->second.end(); it++)
		{
			if (countPlayer == 0) {
				if (pTable->userList.size() >= maxSeatCount || maxUser >= maxSeatCount) {
					break;
				}
			}
			else {
				if (pTable->userList.size() >= maxSeatCount || maxUser >= countPlayer) {
					break;
				}
			}
			g_pDebugLog->logMsg("%s it->second->m_uid[%d] it->second->m_tid[%d]", __FUNCTION__, it->second->m_uid, it->second->m_tid);
			if (it->second->m_tid > 0) {
				continue;
			}
			string str;
			int ret = -1;
			string tempStr;
			ret = m_pRedisManagerClient->GET_TEMP_ROBOT_STATUS(it->second->m_uid, tempStr);
			g_pDebugLog->logMsg("%s ret ===[%d] it->second->m_uid[%d] it->second->m_tid[%d]", __FUNCTION__, ret, it->second->m_uid, it->second->m_tid);
			if (ret > 0) {
				vector<int> sv;
				split(tempStr, sv, '_');
				if (sv.size() >= 2) {
					
					if (sv[1] > 0 || sv[0] > 0) {
						//g_pDebugLog->logMsg("it->second->status[%d] level[%d]", sv[1], sv[0]);
						continue;
					}
				}
			}
			else {
				continue;
			}
			ret = m_pRedisManagerClient->GetRobotStatus(it->second->m_uid, str);
			//g_pDebugLog->logMsg("%s ret ===[%d]it->second->m_uid==[%d] str==[%s]", __FUNCTION__, ret, it->second->m_uid,str.c_str());
			if (ret > 0) {
				vector<int> sv;
				split(str, sv, '_');
				//g_pDebugLog->logMsg("%s sv.size() ===[%d]", __FUNCTION__, sv.size());
				if (sv.size() >= 3) {
					if (sv[2] != 1 || sv[3] != pTable->m_nLevel) {
						continue;
					}
					if (sv[2] == 1 && sv[0] <= 0) {
						
						int chips = getUserChips(pTable->club_id, it->second->m_uid);
						//g_pDebugLog->logMsg("%s chips[%d] it->second->m_uid[%d]", __FUNCTION__, chips, it->second->m_uid);
						if (chips > 0 && chips > joinGamePoint &&  chips > readyPoint) {
							
							maxUser++;
							it->second->m_tid = pTable->m_nTid;
							it->second->serverId = pTable->m_nServerId;
							it->second->m_activityId = pTable->m_activityID;
							m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(it->second->m_uid, 1, pTable->m_nLevel);
							
							int time2 = rand() % joinGame + 1;
							if (maxUser == 1) {
								time2 = 2;
							}
							g_pDebugLog->logMsg("StartAutoTimer serverId[%d] activityId[%d] tid[%d] level[%d] joinGame[%d] it->second->m_uid[%d] maxUser[%d]", pTable->m_nServerId, pTable->m_activityID, pTable->m_nTid, pTable->m_nLevel, joinGame, it->second->m_uid, maxUser);

							it->second->StartAutoTimer(time2);
						}
						/*else {
							m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(it->second->m_uid, 1, pTable->m_nLevel);
						}*/
					}
				}
			}
		}
	}
}
int CGameServer::ReleaseRobot(int club_id,int uid,int level,int tid) {
	g_pDebugLog->logMsg("ReleaseRobot club_id[%d] uid[%d] level[%d]", club_id, uid, level);
	m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(uid, 0, 0);
	map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.find(club_id);
	if (ite != groupRobotMap.end()) {
		map<int, CUserBalanceInfo*>::iterator it = ite->second.find(uid);
		if (it != ite->second.end()) {
			if (it->second->m_tid == tid) {
				it->second->reset();
			}
		}
	}
	return 0;
}
int CGameServer::ReleaseRobot(int level) {
	for (map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.begin(); ite != groupRobotMap.end(); ite++) {
		for (map<int, CUserBalanceInfo*>::iterator it = ite->second.begin(); it != ite->second.end(); it++)
		{
			string tempStr;
		
			int ret = m_pRedisManagerClient->GET_USER_GAME_STATUS(it->second->m_uid, tempStr);
			UpdateClearRobotStatus(it->second->m_uid, level);
			//g_pDebugLog->logMsg("%s ret ===[%d] it->second->m_uid[%d]", __FUNCTION__, ret, it->second->m_uid);
			if (ret > 0) {
				vector<int> sv;
				split(tempStr, sv, '_');
				if (sv.size() >= 3) {
					if (sv[0] == level) {
						m_pRedisManagerClient->HSET_USER_STATUS(it->second->m_uid, level, 0, 0);
						it->second->reset();
						
						//m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(it->second->m_uid, 0, 0);
					}
				}
			}
			string tempStr2;
			ret = m_pRedisManagerClient->GET_TEMP_ROBOT_STATUS(it->second->m_uid, tempStr2);
			//g_pDebugLog->logMsg("%s ret ===[%d] it->second->m_uid[%d]", __FUNCTION__, ret, it->second->m_uid);
			if (ret > 0) {
				vector<int> sv;
				split(tempStr2, sv, '_');
				if (sv.size() >= 2) {
					if (sv[0] == level) {
						//UpdateClearRobotStatus(it->second->m_uid);
						m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(it->second->m_uid, 0, 0);
					}
				}
			}
		}
	}
}
int CGameServer::getUserChips(int club_id, int uid) {
	
	int chips = 0;
	int ret = -1;
	string tempStr;
	
	ret = m_pRedisManagerClient->HGET_GROUP_USER_CHIPS(uid, club_id, tempStr);
	if (ret > 0) {
		chips = atoi(tempStr.c_str());
	}
	else {
		int rets = -1;
		chips = m_pDBClient->GetUserClubPoint(club_id, uid, rets);
		g_pDebugLog->logMsg("SQL_======[%d] chips[%d]", rets, chips);
		if (rets > 0) {
			m_pRedisManagerClient->writeUserChips(uid, club_id, chips);
		}
		else {
			g_pDebugLog->logMsg("SQL_ERR===");
		}
	}
	return chips;
}
int CGameServer::ProcessRobot(CUserBalanceInfo * balanceInfo) {
	g_pDebugLog->logMsg("ProcessRobot[%d]", balanceInfo->m_tid);
	if (balanceInfo && balanceInfo->m_tid > 0) {
		//m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(balanceInfo->m_uid, 0, 0);
		NETOutputPacket resPacketTemp;
		resPacketTemp.Begin(A2G_ROBOT_LOGIN); //ALLOW_PACKET 自己定义 协议号
		resPacketTemp.WriteInt(balanceInfo->serverId);
		resPacketTemp.WriteInt(balanceInfo->club_id);
		resPacketTemp.WriteInt(balanceInfo->m_activityId);
		resPacketTemp.WriteInt(balanceInfo->m_tid);
		resPacketTemp.WriteInt(balanceInfo->m_uid);
		resPacketTemp.WriteString(balanceInfo->m_nickname);
		resPacketTemp.WriteString(balanceInfo->m_portrait);
		resPacketTemp.WriteByte(balanceInfo->m_sex);
		resPacketTemp.WriteString(balanceInfo->latitude);
		resPacketTemp.WriteString(balanceInfo->longitude);
		resPacketTemp.WriteString(balanceInfo->otherInfo);
		resPacketTemp.WriteString(balanceInfo->ip);
		resPacketTemp.End();
		g_pDebugLog->logMsg("ProcessRobot.([%d])|| accept ", balanceInfo->serverId);

		CAllocServer* alloc = listAllocServer[balanceInfo->serverId];
		if (alloc) {
			g_pDebugLog->logMsg("ProcessRobot.([%d])|| ==== ", balanceInfo->serverId);
			
			map<int, vector<int> >::iterator testTier = m_userRobotTableLst.find(balanceInfo->m_tid);
			vector<int> testUserId;

			if (testTier != m_userRobotTableLst.end()) {

				testTier->second.push_back(balanceInfo->m_uid);
			}
			else
			{
				testUserId.push_back(balanceInfo->m_uid);
				m_userRobotTableLst[balanceInfo->m_tid] = testUserId;
			}
			//m_userRobotTableLst[tid]
			alloc->Send(&resPacketTemp);
		}
	}
	
	return 0;
}
int CGameServer::ProcessPacket(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    int nCmdType = pPacket->GetCmdType();
	g_pDebugLog->logMsg("ProcessPacket|| accept cmd:[0x%02x]", nCmdType);
    switch (nCmdType)
    {
        case CLIENT_PACKET:
        {
            int uid = pPacket->ReadInt();//用户id
            int svid = pPacket->ReadInt();//大厅serverId  hallserver
			
			//int svid = 1;//大厅serverId  hallserver
			g_pDebugLog->logMsg("-----11111---serverId[%d] uid[%d]", svid, uid);
			//g_pDebugLog->logMsg("m_clubTableList==[%d]", m_clubTableList.size());
			g_pDebugLog->logMsg("testInt==[%d]", testInt);
			
            char szTemp[10240];
            int nLen = pPacket->ReadBinary(szTemp, sizeof(szTemp));
			int ip = pPacket->ReadInt();//用户的ip
			//
			/*char * ipaddr = NULL;
			char addr[20];
			in_addr inaddr;
			inaddr.s_addr = ip;
			ipaddr = inet_ntoa(inaddr);
			strcpy(addr, ipaddr);

			g_pDebugLog->logMsg("%s|| ip=%s", __FUNCTION__, addr);*/

            if(nLen < 0)
            {
#ifndef WIN32
                g_pErrorLog->logMsg("ProcessPacket||pPacket->ReadBinary error, nLen<0");
#endif
                return 0;
            }
            NETInputPacket tempPacket;
            if(!tempPacket.Copy(szTemp, nLen))
            {
#ifndef WIN32
                g_pErrorLog->logMsg("ProcessPacket||tempPacket.Copy error");
#endif
                return 0;
            }

            HallServerList::iterator iter = m_HallServerList.find(svid);
            if(iter == m_HallServerList.end())
            {
				g_pDebugLog->logMsg("m_HallServerList new");
                CHallServer* pHallServer = new CHallServer(svid, pSocket, this);
                m_HallServerList[svid] = pHallServer;
                pSocket->m_pHallServer = pHallServer;
            }
            else
            {
                CHallServer* pHallServer = iter->second;
                if(pHallServer != NULL)
                {
                    if(pHallServer->m_pSocketHandler != NULL)
                    {
                        pHallServer->m_pSocketHandler->m_pHallServer = NULL;//清除先前连接的的指针
                    }
                    pHallServer->m_pSocketHandler = pSocket;
                    pSocket->m_pHallServer = pHallServer;
                    pHallServer->StopCheckCoreTimer();
                }
            }		
			
			userHallServiceId[uid] = svid;
			//SendAllowPacket(uid, svid, 317, &resPacketTemp,pSocket);
			//ProcBroadToAllows(uid, svid, 0);
			
			GameGroup::Instance()->userHallsvidMap[uid] = svid;
            int cmd = tempPacket.GetCmdType();	
			g_pDebugLog->logMsg("tempPacket.GetCmdType cmd:[0x%02x]", cmd);
            if( cmd == CMD_GET_MATCH_HUODONG_ROOM
				|| cmd==CMD_GET_APPLY_SERVER 
				|| cmd ==CMD_GET_MATCH_QUICK_ROOM
				|| cmd==CMD_GET_NEW_ROOM 
				|| cmd==CLIENT_CMD_JOIN_GAME  
                || cmd== CMD_REQUIRE_IP_PORT
				|| cmd == SERVER_COMMAND_CHANGE_LEVEL_TO_LOGIN
				|| cmd == CLIENT_CMD_CREATE_PRIVATE_ROOM 
				|| cmd == CLIENT_CMD_ENTRE_PRIVATE_ROOM
                || cmd == CLIENT_CMD_LIST_PRIVATE_ROOM 
				|| cmd == CLIENT_CMD_FIND_PRIVATE_ROOM 
				|| cmd == CLIENT_CMD_REFRESH_PRIVATE_ROOM
                || cmd == CLIENT_CMD_CREATE_MATCH 
				|| cmd == CLIENT_CMD_ENTER_MATCH 
				|| cmd == CLIENT_CMD_FIND_MATCH 
				|| cmd == CLIENT_CMD_LIST_MATCH 
				|| cmd == CLUB_DATA 
				|| cmd == CLIENT_USER_GAME_STATUS
				|| cmd == B2A_REMOVE_GROUP_TABLE 
				|| cmd == CLIENT_DISABLE_USER_GAME 
				|| cmd == CLIENT_COMMAND_USER_ONLINE
				|| cmd == CLIENT_CMD_JOIN_TABLE)//本地处理
				
            {
				g_pDebugLog->logMsg("CLIENT_DISABLE_USER_GAME %d", cmd);
				ProcessClientPacket(uid, svid, &tempPacket, pSocket, ip);
			}
			
            else//转发给UserServer进行处理
            {
                ProcessTransferPacket(uid, pPacket);
            }
        }
        break;
        //allow pack
        //接受其他allow发过来的消息
		case SERVER_CREATE_ROBOT: {  //添加机器人
			int group_uid = pPacket->ReadInt();				//用户id
			if (group_uid <= 0) {
				break;
			}
			
			int group_sex = pPacket->ReadInt();				//性别
			string group_nick = pPacket->ReadString();		//名称
			string group_port = pPacket->ReadString();//头像
			string latitude = pPacket->ReadString();//经度
			string longitude = pPacket->ReadString();//纬度
			string group_ip = pPacket->ReadString();//ip
			int chips = pPacket->ReadInt();//用户金币
			int group_robot = pPacket->ReadInt();//用户是否机器人
			int grobot_status = pPacket->ReadInt();//机器人状态  0  未使用, 1正在使用,3已经回收
			string grobot_config = pPacket->ReadString();//机器人胜率
			g_pDebugLog->logMsg("SERVER_CREATE_ROBOT [%d]", grobot_status);
			g_pDebugLog->logMsg("chips== [%d] group_uid[%d]", chips, group_uid);
			CUserBalanceInfo *result = NULL;

			map<int, CUserBalanceInfo*>::iterator ite = m_userRobotMap.find(group_uid);

			if (ite != m_userRobotMap.end())
			{
				m_userRobotMap[group_uid]->m_sex = group_sex;
				m_userRobotMap[group_uid]->m_nickname = group_nick.c_str();
				m_userRobotMap[group_uid]->isRobot = group_robot;
				m_userRobotMap[group_uid]->latitude = latitude.c_str();
				m_userRobotMap[group_uid]->longitude = longitude.c_str();
				m_userRobotMap[group_uid]->ip = group_ip.c_str();
				m_userRobotMap[group_uid]->isRobot = 0;
				m_userRobotMap[group_uid]->m_tid = 0;
				result = m_userRobotMap[group_uid];
			}
			else {
				result = new CUserBalanceInfo(this, group_uid, group_sex, group_nick, group_port, 1, longitude, latitude, group_ip, grobot_config, 0, 0, chips);
			}
			m_userRobotMap[group_uid] = result;
			break;
		}
		
		case SERVER_GROUP_ADD_LEVEL: {
			g_pDebugLog->logMsg("SERVER_GROUP_ADD_LEVEL m_nLevel[%d]", m_nLevel);
			if (m_nLevel > 2) {
				NETOutputPacket resPacketTemp;
				resPacketTemp.Begin(SERVER_GROUP_ADD_LEVEL);
				resPacketTemp.WriteShort(m_nLevel);
				resPacketTemp.End();
				if (allocServer) {
					allocServer->Send(&resPacketTemp);
				}
			}
			else {
				int levelTemp = pPacket->ReadShort();				//用户id
				g_pDebugLog->logMsg("level---==[%d]", levelTemp);
				groupLevel[levelTemp] = levelTemp;
			}
			break;
		}
		case SERVER_GROUP_USER_STATUS: {//是否锁住机器人
			int club_id = pPacket->ReadInt();  //俱乐部
			int level = pPacket->ReadInt();  //游戏level  如果没有传0
			int uid = pPacket->ReadInt();  //用户id
			int status = pPacket->ReadInt(); //状态  0,关闭,1解放,2,登入失败,3,登入成功
			g_pDebugLog->logMsg("SERVER_GROUP_USER_STATUS club_id[%d] uid[%d] status[%d] level[%d]", club_id, uid, status, level);
			int ret = -1;
			if (m_nLevel > 2) {
				
				if (status == 2) {
					ret = m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(uid, 1, m_nLevel);
				}
			}
			else {
				if (status == 1) {
					ret = m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(uid, 0, 0);
				}
				g_pDebugLog->logMsg("[%s] ret[%d] status[%d] level[%d]", __FUNCTION__, ret, status, level);
			} 
			
			break;
		}
		case SERVER_COMMAND_SET_TABLE_COUNT: {
			int table_cunt = pPacket->ReadInt();  //桌子进入的人数
			int tableUser_rend2 = pPacket->ReadInt();  //桌子进入的人数
			tableUser = table_cunt;
			tableUser_rend = tableUser_rend2;
			g_pDebugLog->logMsg("tableUser_rend %d  tableUser %d", tableUser_rend, tableUser);
			break;
		}
		case SERVER_ROBOT_REDIS_STATUS: {
			int club_id = pPacket->ReadInt();  //俱乐部
			int level = pPacket->ReadInt();  //游戏level  如果没有传0
			int uid = pPacket->ReadInt();  //用户id
			g_pDebugLog->logMsg("SERVER_ROBOT_REDIS_STATUS club_id[%d],uid[%d],level[%d]", club_id, uid, level);
			string str;
			if (m_pRedisManagerClient->GetRobotStatus(uid, str) > 0) {
				vector<int> sv;
				split(str, sv, '_');
				if (sv.size() >= 4) {
					m_pRedisManagerClient->ROBOT_STATUS(club_id, uid, sv[2], 0, level);
				}
				/*else {
					m_pRedisManagerClient->ROBOT_STATUS(club_id, uid, 0, 0, level);
				}*/
				//m_pRedisManagerClient->ROBOT_STATUS(club_id, uid, 0, 0, sv[3]);
			}
			break;
		}
		case SERVER_GROUP_ROBOT_LOGIN: {// 登入失败 解锁机器人
			
			int uid = pPacket->ReadInt();  //用户id
			
			g_pDebugLog->logMsg("SERVER_GROUP_ROBOT_LOGIN  uid[%d] ", uid);
			int ret = m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(uid, 0, 0);
			if (m_nLevel > 2) {
				NETOutputPacket resPacketTemp;
				resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
				resPacketTemp.WriteInt(uid);
				resPacketTemp.End();
				if (allocServer) {
					allocServer->Send(&resPacketTemp);
				}
			}
			else {
				for (map<int, map<int, CUserBalanceInfo*> >::iterator ite = groupRobotMap.begin(); ite!= groupRobotMap.end(); ite++)
				{
					for (map<int, CUserBalanceInfo*>::iterator itUser = ite->second.begin(); itUser!= ite->second.end(); itUser++)
					{
						if (uid == itUser->second->m_uid) {
							for (map<int,vector<int> >::iterator uidIter = m_userRobotTableLst.begin(); uidIter != m_userRobotTableLst.end(); uidIter++)
							{
								for (vector<int>::iterator iyy = uidIter->second.begin(); iyy != uidIter->second.end(); iyy++)
								{
									if ((*iyy) == uid) {
										uidIter->second.erase(iyy);
										break;
									}
								}
							}
							itUser->second->reset();
						}
					}
				}

			}
			break;
		}
		case SERVER_ADD_GROUP_ROBOT: {  //把机器人加入到俱乐部
			int group_Id = pPacket->ReadInt();   //俱乐部id
			int group_uid = pPacket->ReadInt();
			g_pDebugLog->logMsg("SERVER_ADD_GROUP_ROBOT [%d] group_Id[%d]", group_uid, group_Id);
			if (group_uid <= 0 || group_Id <= 0) {
				break;
			}
			CUserBalanceInfo *result = NULL;
			map<int, CUserBalanceInfo*>::iterator ite = m_userRobotMap.find(group_uid);
			if (groupRobotMap.find(group_Id) != groupRobotMap.end()) {
				if (ite != m_userRobotMap.end()) {
					m_userRobotMap[group_uid]->club_id = group_Id;
					groupRobotMap.find(group_Id)->second[group_uid] = m_userRobotMap[group_uid];
					
				}
				else
				{
					m_pDBClient->GE_TUSER_INGFO(this, group_uid, m_userRobotMap, groupRobotMap);
					
				}
			}
			else {
				if (ite != m_userRobotMap.end())
				{
					m_userRobotMap[group_uid]->club_id = group_Id;
					map<int, CUserBalanceInfo*> test;
					test[group_uid] = m_userRobotMap[group_uid];
					groupRobotMap[group_Id] = test;
				}
			}
			if (ite != m_userRobotMap.end()) {
				m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(group_uid, 0, 0);
			}
			else {
				m_pRedisManagerClient->SET_TEMP_ROBOT_STATUS(group_uid, 0, 0);
			}
			m_pRedisManagerClient->ROBOT_STATUS(group_Id,group_uid, 0, 0, 0);
			break;
		}
		case SERVER_UPDATE_ROBOT: {  //修改机器人信息
			int group_uid = pPacket->ReadInt();				//用户id
			g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT group_uid[%d]", group_uid);
			int group_sex = pPacket->ReadInt();				//性别
			string group_nick = pPacket->ReadString();		//名称
			string group_port = pPacket->ReadString();//头像
			string latitude = pPacket->ReadString();//经度
			string longitude = pPacket->ReadString();//纬度
			string group_ip = pPacket->ReadString();//ip
			CUserBalanceInfo *result = NULL;
			g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT m_userRobotMap[%d]", m_userRobotMap.size());
			g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT---------------");
			if (m_userRobotMap.find(group_uid) != m_userRobotMap.end())
			{
				g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT group_sex[%d]", group_sex);

				m_userRobotMap[group_uid]->m_sex = group_sex;
				g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT group_nick[%s]", group_nick.c_str());
				m_userRobotMap[group_uid]->m_nickname = group_nick.c_str();
				g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT latitude[%s]", latitude.c_str());
				m_userRobotMap[group_uid]->latitude = latitude.c_str();
				g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT longitude[%s]", longitude.c_str());
				m_userRobotMap[group_uid]->longitude = longitude.c_str();
				m_userRobotMap[group_uid]->ip = group_ip.c_str();
				//result = m_userRobotMap[group_uid];
				//m_userRobotMap[group_uid] = result;
				g_pDebugLog->logMsg("m_userRobotMap[group_uid]->club_id[%d]", m_userRobotMap[group_uid]->club_id);
				if (m_userRobotMap[group_uid]->club_id > 0) {
					g_pDebugLog->logMsg("SERVER_UPDATE_ROBOT ite->second->club_id[%d]", m_userRobotMap[group_uid]->club_id);
					if (groupRobotMap.find(m_userRobotMap[group_uid]->club_id) != groupRobotMap.end()) {
						
						groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->m_sex = group_sex;
						groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->m_nickname = group_nick.c_str();
						groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->latitude = latitude.c_str();
						groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->longitude = longitude.c_str();
						groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->ip = group_ip.c_str();
						groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->m_portrait = group_port.c_str();
						g_pDebugLog->logMsg("groupRobotMap ip[%s]", groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->ip.c_str());
						g_pDebugLog->logMsg("groupRobotMap m_portrait[%s]", groupRobotMap[m_userRobotMap[group_uid]->club_id][group_uid]->m_portrait.c_str());
					}
					
				}
			}
			break;
		}
		case SERVER_UPDATE_GROUP_ROBOT_SR:{
			int group_id = pPacket->ReadInt();  //俱乐部id
			string grobot_config = pPacket->ReadString();//机器人配置
			CUserBalanceInfo *result = NULL;
			
			map<int, string>::iterator ite = robotConfig.find(group_id);
			if (ite != robotConfig.end())
			{
				robotConfig[group_id] = grobot_config;
			}
			CLogicServer *logicServer = GetServer(m_nServerId);
			if (logicServer != NULL && logicServer->m_pSocketHandler != NULL) {
				g_pDebugLog->logMsg("SERVER_UPDATE_GROUP_ROBOT_SR--group_id[%d]  grobot_config[%s]", group_id, grobot_config.c_str());
				NETOutputPacket resPacketTemp;
				resPacketTemp.Begin(SERVER_UPDATE_GROUP_ROBOT_SR); //ALLOW_PACKET 自己定义 协议号
				resPacketTemp.WriteInt(group_id);
				resPacketTemp.WriteString(grobot_config.c_str());
				resPacketTemp.End();
				logicServer->m_pSocketHandler->Send(&resPacketTemp);
			}
			break;
		}
		case SERVER_STATUS_ROBOT: {  //修改机器人状态
			int group_uid = pPacket->ReadInt();				//用户id
			int grobot_status = pPacket->ReadInt();//机器人状态  0  未使用, 1正在使用,3已经回收
			g_pDebugLog->logMsg("SERVER_STATUS_ROBOT   grobot_status [%d]   group_uid[%d]  ", grobot_status, group_uid);
			CUserBalanceInfo *result = NULL;
			map<int, CUserBalanceInfo*>::iterator ite = m_userRobotMap.find(group_uid);
			if (ite != m_userRobotMap.end())
			{
				result = ite->second;
				m_userRobotMap[group_uid] = result;
				if (ite->second->club_id > 0) {
					map<int, map<int, CUserBalanceInfo*> >::iterator ited = groupRobotMap.find(ite->second->club_id);
					if (ited != groupRobotMap.end()) {
						if (ited->second.find(group_uid) != ited->second.end()) {
							BG2UpdateRobotStatus(ite->second->club_id, group_uid, grobot_status);
						}
					}

				}
			}
			break;
		}
        case ALLOW_PACKET: {
			
			int uid = pPacket->ReadInt();//用户id
			int svid = pPacket->ReadInt();//大厅serverId  hallserver
			int sLevel = pPacket->ReadInt();//LEVEL
			char szTemp[10240];
			int nLen = pPacket->ReadBinary(szTemp, sizeof(szTemp));
			NETInputPacket tempPacketA;
			tempPacketA.Copy(szTemp, nLen);
			ProcessHandleAllow(uid, svid, sLevel, &tempPacketA, pSocket);
			g_pDebugLog->logMsg("ALLOW_PACKET svid[%d] uid[%d] sLevel[%d]", svid, uid, sLevel);
			//xxx
			break;
		}
		case B2A_CLEAR_CLUB_TABLE_SEND_ALLOW:
		{
			int level = pPacket->ReadInt();
			g_pDebugLog->logMsg("B2A_CLEAR_CLUB_TABLE_SEND_ALLOW level=[%d]", level);
			
			if (level > 2) {
				ReleaseRobot(level);
				clearClubTableInfo(level);
			}
			
		}
		break;
		case SERVER_CREATE_ROBOT_CLEAN:
		{
			int level = pPacket->ReadInt();
			g_pDebugLog->logMsg("B2A_CLEAR_CLUB_TABLE_SEND_ALLOW level=[%d]", level);

			if (level > 2) {
				ReleaseRobot(level);
				clearClubTableInfo(level);
			}

		}
		break;
		case SERVER_COMMAND_UPDATE_GAME_ROUND:
		{
			if (m_nLevel > 2) {
				NETOutputPacket resPacketTemp;
				//resPacketTemp.Begin(G2A_BROADCAST_TABLE_INFO); //ALLOW_PACKET 自己定义 协议号
				resPacketTemp.Copy(pPacket->packet_buf(), pPacket->packet_size());
				resPacketTemp.WriteInt(groupType);
				resPacketTemp.End();
				if (allocServer) {
					allocServer->Send(&resPacketTemp);
				}
			}
			else {
				int club_id = pPacket->ReadInt();
				int level = pPacket->ReadShort();
				int m_nTableId = pPacket->ReadInt();
				int currRound = pPacket->ReadInt();
				int groupTypeTemp = pPacket->ReadInt();
				g_pDebugLog->logMsg("SERVER_COMMAND_UPDATE_GAME_ROUND [%d] groupTypeTemp[%d]", club_id, groupTypeTemp);
				map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupTypeTemp);
				if (cjList != cardJiFenList.end()) {
					clubTableList::iterator clbuIter = cjList->second.find(club_id);
					if (clbuIter != cjList->second.end()) {
						if (clbuIter->second.find(m_nTableId) != clbuIter->second.end()) {
							CGameTable *pTable = clbuIter->second[m_nTableId];
							if (pTable != NULL) {
								pTable->currRound = currRound;
							}
						}
					}
				}
				
				NETOutputPacket resPacketTemp;
				resPacketTemp.Copy(pPacket->packet_buf(), pPacket->packet_size());
				resPacketTemp.End();
				for (HallServerList::iterator iterHall = m_HallServerList.begin(); iterHall != m_HallServerList.end(); iterHall++)
				{
					map<int, vector<int> >::iterator playerUser = groupPlayer.find(club_id);
					if (playerUser != groupPlayer.end()) {
						for (int k = 0; k < playerUser->second.size(); k++)
						{
							if (iterHall->second->m_pSocketHandler != NULL)
							{
								map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
								if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
									SendClientPacket(playerUser->second[k], iterHall->first, &resPacketTemp, iterHall->second->m_pSocketHandler);
								}

							}
						}
					}
				}
			}
		}
		break;
		case B2A_CREATE_CARD_GROUP_TABLE_SEND_ALLOW:
		{

			int m_nOwnerUid = pPacket->ReadInt();
			short servid = pPacket->ReadShort();
			short m_nLevel = pPacket->ReadShort();
			int m_nTid = pPacket->ReadInt();
			int max_plaery_count = pPacket->ReadInt();
			string m_strInviteCode = pPacket->ReadString();
			string jsonConfig = pPacket->ReadString();
			int m_nBaseChip = pPacket->ReadInt();
			int m_activityID = pPacket->ReadInt();
			int club_id = pPacket->ReadInt();
			int isStart = pPacket->ReadInt();
			int currRound = pPacket->ReadInt();
			int gameType = pPacket->ReadInt();
			int configId = pPacket->ReadInt();
			int groupTypeTemp = pPacket->ReadInt();
			string m_strRoomName = pPacket->ReadString();
			string groupName = pPacket->ReadString();
			CGameTable* pTable = new CGameTable(m_nTid, servid, m_nLevel, club_id);
			g_pDebugLog->logMsg("B2A_CREATE_CARD_GROUP_TABLE_SEND_ALLOW m_nTid[%d] club_id[%d] groupTypeTemp[%d]", m_nTid, club_id, groupTypeTemp);
			pTable->isStart = 0;
			pTable->m_strInviteCode = m_strInviteCode;
			pTable->jsonConfig = jsonConfig;
			pTable->configId = configId;
			pTable->gameType = gameType;
			pTable->groupType = groupTypeTemp;
			pTable->max_plaery_count = max_plaery_count;
			pTable->m_activityID = m_activityID;
			pTable->m_nLevel = m_nLevel;
			pTable->m_strRoomName = m_strRoomName;
			pTable->m_nBaseChip = m_nBaseChip;
			pTable->currRound = currRound;
			pTable->groupName = groupName;
			pTable->numTable = numTable++;
			g_pDebugLog->logMsg("pTable->numTable[%d]", pTable->numTable);
			map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupTypeTemp);
			if (cjList != cardJiFenList.end()) {
				clubTableList::iterator it = cjList->second.find(club_id);
				if (it != cjList->second.end()) {
					TableList& tableMap = it->second;
					tableMap[m_nTid] = pTable;
					
					cardJiFenList[groupTypeTemp][pTable->club_id] = tableMap;
				}
				else {
					
					TableList tableMap;
					tableMap[pTable->m_nTid] = pTable;
					cardJiFenList[groupTypeTemp][pTable->club_id] = tableMap;
				}
			}
			else {
				clubTableList clist;
				TableList tableMap;
				tableMap[m_nTid] = pTable;
				clist[club_id] = tableMap;
				cardJiFenList[groupTypeTemp] = clist;
				g_pDebugLog->logMsg("cardJiFenList size[%d]", cardJiFenList.size());
			}
			m_tidClubList[m_nTid] = club_id;
			/*clubTableList::iterator it = m_clubTableList.find(club_id);
			if (it != m_clubTableList.end()) {
				TableList& tableMap = it->second;
				tableMap[m_nTid] = pTable;
				m_clubTableList[pTable->club_id] = tableMap;
			}
			else {
				g_pDebugLog->logMsg("2222AddClubTable");
				TableList tableMap;
				tableMap[pTable->m_nTid] = pTable;
				m_clubTableList[pTable->club_id] = tableMap;
			}*/
			break;
		}
        case SYS_REPORT_SERVER_DATA:
        {
            ProcessReportServerData(pPacket, pSocket);
        }
        break;
        case SYS_UPDATE_ROOM_USER_COUNT:
        {
            ProcessUpdateRoomUserCount(pPacket, pSocket);
        }
        break;
        case SYS_UPDATE_MATCH_USER_COUNT:
        {
            ProcessUpdateMatchUserCount(pPacket, pSocket);
        }
        break;
        case SYS_UPDATE_PRIVATE_MATCH_USER_COUNT:
        {
            ProcessUpdatePrivateMatchInfo(pPacket, pSocket);
            break;
        }
        case SYS_REPORT_SERVER_PORTIP:
        {
            ProcessSendServerPortIp(pPacket, pSocket);
        }
        break;
        case CMD_SET_SERVER_RETIRED:
        {
            ProcessSetServerRetired(pPacket, pSocket);
        }
        break;
        case CMD_SET_SERVER_ADDR_MC://工具程序发送
        {
            ProcessSetServerAddrToMC();
        }
        break;
        case CMD_RESET_FILL_FLAG:
            ProcessResetFillFlag(pPacket);
            break;
        case CMD_REPORT_PRIVATE_ROOM_DATA:
            ProcessReportPrivateRoomData(pPacket, pSocket);
        break;
		case SERVER_CLOSE_PACKET: {
			int uid = pPacket->ReadInt();
			g_pDebugLog->logMsg("SERVER_CLOSE_PACKET ===%d", uid);
			userOnClub[uid] = false;
		}
		break;
        case CLIENT_CLOSE_PACKET:
        case SYS_USER_LEAVE_ROOM:
        case SYS_USER_ENTER_ROOM:
        case SYS_ONLOOK_ENTER_ROOM:
        case SYS_ONLOOK_LEAVE_ROOM:
        {
			
			int uid = pPacket->ReadInt();
			
			
			g_pDebugLog->logMsg("nCmdType=%d uid[%d]", nCmdType, uid);
			if (nCmdType == SYS_USER_LEAVE_ROOM)
			{
				
				
				map<int, int>::iterator tableIter = userTableMap.find(uid);
				if (tableIter != userTableMap.end())
				{
					/*NETOutputPacket resPacketTT;
					resPacketTT.Begin(SYS_USER_LEAVE_ROOM);
					resPacketTT.WriteInt(uid);
					resPacketTT.WriteInt(tableIter->second);
					resPacketTT.WriteInt(m_nLevel);
					resPacketTT.WriteInt(0);
					resPacketTT.End();*/
					
					//ProcessTransferPacketTemp(uid, &resPacketTT);
					m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, 0, 0);
					g_pDebugLog->logMsg("enter room SYS_USER_LEAVE_ROOM tableId[%d] m_nLevel[%d]", tableIter->second, m_nLevel);
					userTableMap.erase(tableIter);
				}
				g_pDebugLog->logMsg("enter room SYS_USER_LEAVE_ROOM");
				m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, 0, 0);
				return 0;
				
			}
			else if (nCmdType == SYS_USER_ENTER_ROOM)
			{
				int tableId = pPacket->ReadInt();
				int activityId = 0;
				for (map<int, int>::iterator iterS= m_GroupTableDict.begin(); iterS != m_GroupTableDict.end(); iterS++)
				{
					if (iterS->second == tableId) {
						activityId = iterS->first;
					}
				}
				
				userTableMap[uid] = tableId;
				//NETOutputPacket resPacketTT;
				//resPacketTT.Begin(SYS_USER_ENTER_ROOM);
				//resPacketTT.WriteInt(uid);
				//resPacketTT.WriteInt(tableId);
				//resPacketTT.WriteInt(m_nLevel);
				//resPacketTT.WriteInt(activityId);
				//resPacketTT.End();
				
				//ProcessTransferPacketTemp(uid, &resPacketTT);
				m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, tableId, activityId);
				g_pDebugLog->logMsg("enter room send tableId[%d] m_nLevel[%d]", tableId, m_nLevel);
				return 0;
				
					
			}
			else if (nCmdType == CLIENT_CLOSE_PACKET)
			{
				g_pDebugLog->logMsg("CLIENT_CLOSE_PACKET ===%d", uid);
				userOnClub[uid] = false;

			}
            ProcessTransferPacket(uid, pPacket);
        }
        break;

		
 	case CMD_CHECK_SERVER_STATUS:
		ProcessCheckServerStatus(pPacket, pSocket);
		break;
	case B2A_GAME_MSG_TO_SERVER: {
		int port = pPacket->ReadInt();//用户数量
		int serverId = pPacket->ReadInt();//用户数量
		int level_m = pPacket->ReadInt();//用户数量
		CAllocServer *aServer = new CAllocServer(port);
		aServer->m_level = level_m;
		listAllocServer[serverId] = aServer;
		if (level_m > 2) {
			clearClubTableInfo(level_m);
		}
		g_pDebugLog->logMsg("B2A_GAME_MSG_TO_SERVER[%d] serverId[%d] level_m[%d]", port, serverId, level_m);

	}
	break;
	case B2A_HALL_GAME_PLAY_TO_SERVER: {
		int status = pPacket->ReadInt();//
		int club_id = pPacket->ReadInt();//
		int configId = pPacket->ReadInt();//
		int gameType = pPacket->ReadInt();//
		string name = pPacket->ReadString();//
		string jsonConfig = pPacket->ReadString();//
		g_pDebugLog->logMsg("status =====  [%d]", status);
		g_pDebugLog->logMsg("name =====  [%s]", name.c_str());
		g_pDebugLog->logMsg("club_id =====  [%d]", club_id);
		g_pDebugLog->logMsg("configId =====  [%d]", configId);
		g_pDebugLog->logMsg("gameType =====  [%d]", gameType);
		g_pDebugLog->logMsg("jsonConfig =====  [%s]", jsonConfig.c_str());
		NETOutputPacket resPacket;
		resPacket.Begin(B2A_HALL_GAME_PLAY_TO_SERVER);
		resPacket.WriteInt(club_id);
		resPacket.WriteInt(configId);
		resPacket.WriteInt(gameType);
		resPacket.WriteString(jsonConfig.c_str());
		resPacket.WriteByte(status);
		resPacket.WriteString(name.c_str());
		resPacket.End();
		for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
		{
			if (iter->second != NULL)
			{
				if (iter->second->m_pSocketHandler != NULL)
				{
					g_pDebugLog->logMsg("B2A_HALL_GAME_PLAY_TO_SERVER111");

					map<int, vector<int> >::iterator playerUser = groupPlayer.find(club_id);
					if (playerUser != groupPlayer.end()) {
						for (int k = 0; k < playerUser->second.size(); k++)
						{
							g_pDebugLog->logMsg("B2A_HALL_GAME_PLAY_TO_SERVER2222", playerUser->second[k]);
							SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
						}
					}

				}
			}
		}
	}
	break;
	case G2A_GAME_MSG_TO_SERVER:
	{
		
		int serverId = pPacket->ReadInt();//
		g_pDebugLog->logMsg("G2A_GAME_MSG_TO_SERVER[%d]", serverId);
		CLogicServer* logicServer = GetServer(serverId);
		if (logicServer != NULL && logicServer->m_pSocketHandler != NULL) {
			if (pPacket->packet_size() > 0) {
				NETOutputPacket resPacketTemp;
				resPacketTemp.Copy(pPacket->packet_buf(), pPacket->packet_size());
				resPacketTemp.End();
				logicServer->m_pSocketHandler->Send(&resPacketTemp);
			}
			
		}
	}
	break;
	case A2G_ROBOT_LOGIN:
	{

		int serverId = pPacket->ReadInt();//
		g_pDebugLog->logMsg("A2G_ROBOT_LOGIN  [%d]", serverId);
		CLogicServer* logicServer = GetServer(serverId);
		if (logicServer != NULL && logicServer->m_pSocketHandler) {
			g_pDebugLog->logMsg("A2G_ROBOT_LOGIN--------  [%d]", serverId);
			NETOutputPacket resPacketTemp;
			if (pPacket->packet_size() > 0) {
				resPacketTemp.Copy(pPacket->packet_buf(), pPacket->packet_size());
				resPacketTemp.End();
				logicServer->m_pSocketHandler->Send(&resPacketTemp);
			}
			
		}
	}
	break;
	case B2A_HALL_SEND_MSG_TO_SERVER:
	{
		int countUser = pPacket->ReadInt();//用户数量
		g_pDebugLog->logMsg("B2A_HALL_SEND_MSG_TO_SERVER countUser[%d]", countUser);
		vector<int> userList;
		if (countUser > 0) {
			string str = "";
			for (int i = 0; i < countUser; i++)
			{
				int uidUser = pPacket->ReadInt();//用户id
				userList.push_back(uidUser);
				
			}
			str = pPacket->ReadString();//用户id
			Json::Reader json_reader;
			Json::Value jsonValue;
			json_reader.parse(str, jsonValue);
			string typeS = "";
			g_pDebugLog->logMsg("str.c_str[%s]", str.c_str());
			if (!jsonValue["type"].isNull())
			{
				typeS = jsonValue["type"].asString();

			}
			for (int i = 0; i < userList.size(); i++)
			{
				NETOutputPacket resPacketRRR;
				resPacketRRR.Begin(B2A_HALL_SEND_MSG_TO_SERVER);
				resPacketRRR.WriteInt(userList[i]);
				resPacketRRR.WriteString(str.c_str());
				resPacketRRR.End();
				
				g_pDebugLog->logMsg("typeS[i]===[%s]", typeS.c_str());
				
				if (typeS == "updatePoint") {
					g_pDebugLog->logMsg("send----------%d", userList[i]);
					int chip = jsonValue["coins"].asInt();
					if (chip < 0) {
						string tempStr;
						int ret = m_pRedisManagerClient->GET_USER_GAME_STATUS(userList[i], tempStr);
						//g_pDebugLog->logMsg("GET_USER_GAME_STATUS ret[%d]  c_str[%s]", ret, tempStr.c_str());

						if (ret > 0) {
							vector<int> sv;
							split(tempStr, sv, '_');
							if (sv.size() >= 3) {
								if (sv[1] > 0 && sv[2] > 0 && sv[0] > 0) {
									int serverId = sv[0] * 20;
									CAllocServer* alloc = listAllocServer[serverId];
									if (alloc) {
										g_pDebugLog->logMsg("serverId ret[%d]  sv[1][%d] alloc->m_level[%d]", serverId, sv[1], alloc->m_level);
										NETOutputPacket resPacket2;
										resPacket2.Begin(G2A_GAME_MSG_TO_SERVER);
										resPacket2.WriteInt(serverId);
										resPacket2.WriteShort(alloc->m_level);
										resPacket2.WriteInt(sv[1]);
										resPacket2.WriteInt(userList[i]);
										resPacket2.WriteInt(jsonValue["coins"].asInt());
										resPacket2.End();
										alloc->Send(&resPacket2);
									}
								}
							}
						}
					}
					

					//end
					//if (m_GroupServerUid.find(userList[i]) != m_GroupServerUid.end()) {
					//	g_pDebugLog->logMsg("m_GroupServerUid[userList[i]][%d]  userList[i][%d]", m_GroupServerUid[userList[i]], userList[i]);
					//	if (listAllocServer.find(m_GroupServerUid[userList[i]]) != listAllocServer.end()) {
					//		g_pDebugLog->logMsg("m_GroupServerUid[userList[i]][%d]", m_GroupServerUid[userList[i]]);
					//		CAllocServer* alloc = listAllocServer[m_GroupServerUid[userList[i]]];
					//		if (m_GroupServerTid.find(userList[i]) != m_GroupServerTid.end()) {
					//			//g_pDebugLog->logMsg("send----------");
					//			NETOutputPacket resPacket2;
					//			resPacket2.Begin(G2A_GAME_MSG_TO_SERVER);
					//			resPacket2.WriteInt(m_GroupServerUid[userList[i]]);
					//			resPacket2.WriteShort(alloc->m_level);
					//			resPacket2.WriteInt(m_GroupServerTid[userList[i]]);
					//			resPacket2.WriteInt(userList[i]);
					//			resPacket2.WriteInt(jsonValue["coins"].asInt());
					//			resPacket2.End();
					//			alloc->Send(&resPacket2);
					//		}

					//	}
					//}
				}
				
				CHallServer *pHallServer = GetHallServer(userHallServiceId[userList[i]]);
				
				if (pHallServer != NULL)
				{

					if (pHallServer->m_pSocketHandler != NULL)
					{
						if (GET_USER_GAME_STATUS(userList[i]) < 0) {
							SendClientPacket(userList[i], userHallServiceId[userList[i]], &resPacketRRR, pHallServer->m_pSocketHandler);
						}
						//g_pDebugLog->logMsg("B2A_HALL_SEND_MSG_TO_SERVER uid[%d]", userHallServiceId[userList[i]]);
						

					}
				}
				
			}
			
		}
	}
	break;
	case B2A_HALL_SEND_PLAYER_MSG_TO_SERVER:{
		int club_id = pPacket->ReadInt();//俱乐部ID
		string str = pPacket->ReadString();//
		NETOutputPacket resPacket;
		resPacket.Begin(B2A_HALL_SEND_PLAYER_MSG_TO_SERVER);
		resPacket.WriteInt(club_id);
		resPacket.WriteString(str.c_str());
		resPacket.End();
		g_pDebugLog->logMsg("B2A_HALL_SEND_PLAYER_MSG_TO_SERVER[%d]", club_id);
		for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
		{
			if (iter->second != NULL)
			{
				if (iter->second->m_pSocketHandler != NULL)
				{
					g_pDebugLog->logMsg("B2A_HALL_SEND_PLAYER_MSG_TO_SERVER");

					map<int, vector<int> >::iterator playerUser = groupPlayer.find(club_id);
					if (playerUser != groupPlayer.end()) {
						for (int k = 0; k < playerUser->second.size(); k++)
						{
							g_pDebugLog->logMsg("4444B2A_HALL_SEND_PLAYER_MSG_TO_SERVER", playerUser->second[k]);
							SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
						}
					}

				}
			}
		}
	}

	break;
	case B2A_CREATE_GROUP_TABLE:
		g_pDebugLog->logMsg("readyPoint========333=========[%d] ", 1);
		//GameGroup::Instance()->PerfromBeforeCreateGroupCheck(pPacket, pSocket, this);
		//GameGroup::Instance()->PerfromCreateGroupTable(pPacket, pSocket, this);
		break;
	
	case B2A_CREATE_CARD_GROUP_TABLE:
		GameGroup::Instance()->PerfromCreateCardGroupTable(pPacket, pSocket, this);
		break;
	case B2A_SET_CLUB_INFO:
		sendCluUpdatebAlloc(pPacket, pSocket);
		
		break;
	case B2A_REMOVE_GROUP_TABLE:
		GameGroup::Instance()->PerfromB2ARemoveGroup(pPacket, pSocket, this);
		break;

	case G2A_REPORT_END_GROUNP:
		GameGroup::Instance()->PerfromStopGroup(pPacket, pSocket, this);
		break;
	case G2A_FINISH_FIRST_ROUND:
		GameGroup::Instance()->PerfromCostCard(pPacket, pSocket, this);
		break;

	case G2A_REQUEST_END_GROUNP: {
		
		GameGroup::Instance()->PerfromRequestStopGroup(pPacket, pSocket, this);
	}
		
		break;
	
	case G2A_REQUEST_END_CARD_GROUNP:
		GameGroup::Instance()->PerfromRequestStopCardGroup(pPacket, pSocket, this);
		break;
	case G2A_BROADCAST_TABLE_INFO:
		//PerfromBroadcastTableInfo(pPacket, pSocket);
		PerfromTableInfoAllow(pPacket, pSocket);
		break;

    case SYS_CTRL_READ_PIVATEROOM_CONFIG:
        ProcessReadPrivateConf(pPacket,pSocket);
        break;
    
    default:
        g_pDebugLog->logMsg("ProcessPacket||Invalid cmd:[0x%02x]", nCmdType);
        break;
    }
    return 0;
}

int CGameServer::ProcessReadPrivateConf(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    ReadPrivateRoomConf();
    return 0;
}

//清理桌子
int CGameServer::clearClubTable(int level) {
	g_pDebugLog->logMsg("clearClubTable-level[%d]", level);
	NETOutputPacket resPacketTemp;
	resPacketTemp.Begin(B2A_CLEAR_CLUB_TABLE_SEND_ALLOW); //ALLOW_PACKET 自己定义 协议号
	resPacketTemp.WriteInt(level);
	resPacketTemp.End();
	allocServer->Send(&resPacketTemp);

	/*CHallServer *pHallServer = NULL;
	g_pDebugLog->logMsg("%s m_HallServerList [%d]", __FUNCTION__, m_HallServerList.size());
	for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
	{
		if (iter->second != NULL)
		{
			if (iter->second->m_pSocketHandler != NULL)
			{
				CHallServer *pHallServer = iter->second;
				break;
			}
		}
	}
	if (pHallServer != NULL) {
		g_pDebugLog->logMsg("%s clearClubTable-NOT NULL", __FUNCTION__);
		SendClientAllocPacket(0, pHallServer->m_nServerId, 1, &resPacketTemp, pHallServer->m_pSocketHandler);
	}*/
	return 0;
}

void CGameServer::SendAllowCreateTable(int svid,CGameTable * pTable) {
	NETOutputPacket resPacketTemp;
	resPacketTemp.Begin(B2A_CREATE_CARD_GROUP_TABLE_SEND_ALLOW); //ALLOW_PACKET 自己定义 协议号
									   //发的数据
	resPacketTemp.WriteInt(pTable->m_nOwnerUid);
	resPacketTemp.WriteShort(pTable->m_nServerId);
	resPacketTemp.WriteShort(pTable->m_nLevel);
	resPacketTemp.WriteInt(pTable->m_nTid);
	resPacketTemp.WriteInt(pTable->max_plaery_count);
	resPacketTemp.WriteString(pTable->m_strInviteCode.c_str());
	resPacketTemp.WriteString(pTable->jsonConfig.c_str());
	resPacketTemp.WriteInt(pTable->m_nBaseChip);
	resPacketTemp.WriteInt(pTable->m_activityID);
	resPacketTemp.WriteInt(pTable->club_id);
	resPacketTemp.WriteInt(pTable->isStart);
	resPacketTemp.WriteInt(pTable->currRound);
	resPacketTemp.WriteInt(pTable->gameType);
	resPacketTemp.WriteInt(pTable->configId);
	resPacketTemp.WriteInt(pTable->groupType);
	resPacketTemp.WriteString(pTable->m_strRoomName.c_str());
	resPacketTemp.WriteString(pTable->groupName.c_str());
	resPacketTemp.End();
	if (allocServer) {
		allocServer->Send(&resPacketTemp);
	}
	
	/*CHallServer *pHallServer = GetHallServer(svid);
	if (pHallServer != NULL) {
		if (pHallServer->m_pSocketHandler != NULL) {
			g_pDebugLog->logMsg("SendAllowCreateTable");
			SendClientAllocPacket(pTable->m_nOwnerUid, svid, 1, &resPacketTemp, pHallServer->m_pSocketHandler);
		}
	}*/
	return ;
}
//处理allow 发过来的消息
void CGameServer::ProcessHandleAllow(int uid, int svid, int sLevel, NETInputPacket *pPacket, SocketHandler *pSocket) {
	

	int nCmdType = pPacket->GetCmdType();
	g_pDebugLog->logMsg("ProcessHandleAllow|| accept cmd:[0x%02x]", nCmdType);
	switch (nCmdType)
	{
		case ALLOW_GAME_SVID_PACKET:
		{
			HallServerList::iterator iter = m_HallServerList.find(svid);
			if (iter == m_HallServerList.end())
			{
				g_pDebugLog->logMsg("m_HallServerList new");
				CHallServer* pHallServer = new CHallServer(svid, pSocket, this);
				m_HallServerList[svid] = pHallServer;
				pSocket->m_pHallServer = pHallServer;
			}
			else
			{
				CHallServer* pHallServer = iter->second;
				if (pHallServer != NULL)
				{
					if (pHallServer->m_pSocketHandler != NULL)
					{
						pHallServer->m_pSocketHandler->m_pHallServer = NULL;//清除先前连接的的指针
					}
					pHallServer->m_pSocketHandler = pSocket;
					pSocket->m_pHallServer = pHallServer;
					pHallServer->StopCheckCoreTimer();
				}
			}
			userHallServiceId[uid] = svid;
			
		}
		break;
		
		case B2A_CLEAR_CLUB_TABLE_TID: {
			int tid = pPacket->ReadInt();
			g_pDebugLog->logMsg("B2A_CLEAR_CLUB_TABLE_TID [%d]", tid);
			clearTidbleInfo(tid);
		}
		break;
		
		case B2A_SET_CLUB_INFO:
		{
			int type = pPacket->ReadByte();
			int cludIdTemp = pPacket->ReadInt();
			int clubUid = pPacket->ReadInt();

			g_pDebugLog->logMsg("uid=%d cludId=%d] type[%d]", clubUid, cludIdTemp, type);
			SetClubID(groupPlayer, clubUid, cludIdTemp, type);
		}
		break;
		default:
			g_pDebugLog->logMsg("ProcessPacket||Invalid cmd:[0x%02x]", nCmdType);
		break;
	}
}

int CGameServer::clearTidbleInfo(int m_nTid) {
	g_pDebugLog->logMsg("clearClubTableInfo tid%d", m_nTid);
	for (map<int, clubTableList>::iterator cjList = cardJiFenList.begin(); cjList!= cardJiFenList.end(); cjList++)
	{
		for (clubTableList::iterator clubIte = cjList->second.begin(); clubIte!= cjList->second.end(); clubIte++)
		{
			map<int, CGameTable*>::iterator tableIter = clubIte->second.find(m_nTid);
			if (tableIter != clubIte->second.end()) {

				CGameTable *pTable = tableIter->second;
				if (pTable != NULL) {
					pTable->userList.clear();
					clubIte->second[pTable->m_nTid] = pTable;
					clubIte->second.erase(tableIter);
				}

			}
		}

	}
}
int  CGameServer::clearClubTableInfo(int level) {
	for (map<int, clubTableList>::iterator cjList = cardJiFenList.begin(); cjList != cardJiFenList.end(); cjList++)
	{
		for (clubTableList::iterator clubIte = cjList->second.begin(); clubIte != cjList->second.end(); clubIte++)
		{
			for (TableList::iterator tableIter = clubIte->second.begin(); tableIter != clubIte->second.end(); tableIter++) {
				CGameTable* pTable = tableIter->second;
				if (pTable != NULL) {
					if (pTable->m_nLevel == level) {
						for (map<int,string>::iterator trei = pTable->userList.begin(); trei!= pTable->userList.end(); trei++)
						{
							m_pRedisManagerClient->HSET_USER_STATUS(trei->first, level, 0, 0);

						}
						pTable->userList.clear();
						clubIte->second[pTable->m_nTid] = pTable;
						clubIte->second.erase(tableIter);
						NETOutputPacket resPacket;
						resPacket.Begin(TABLE_DATA_CHANGE);
						resPacket.WriteByte(7);
						resPacket.WriteInt(pTable->m_nTid);
						resPacket.WriteInt(pTable->club_id);
						resPacket.WriteInt(pTable->m_nLevel);
						resPacket.WriteByte(pTable->isStart);
						resPacket.WriteInt(pTable->configId);
						resPacket.WriteInt(pTable->gameType);
						resPacket.WriteInt(pTable->currRound);
						resPacket.WriteString(pTable->jsonConfig.c_str());
						resPacket.WriteString("");
						resPacket.WriteString(pTable->groupName.c_str());
						resPacket.WriteString(pTable->m_strInviteCode.c_str());
						resPacket.End();
						for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
						{
							if (iter->second != NULL)
							{
								if (iter->second->m_pSocketHandler != NULL)
								{
									g_pDebugLog->logMsg("TABLE_INFO_TYPE_STAND");

									map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
									if (playerUser != groupPlayer.end()) {
										for (int k = 0; k < playerUser->second.size(); k++)
										{
											g_pDebugLog->logMsg("TABLE_INFO_TYPE_CLOSE_GAME", playerUser->second[k]);
											SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
										}
									}
								}
							}
						}
					}
				}
			}
			
			
		}
	}
	
}

void CGameServer::ProcessResetFillFlag(NETInputPacket *pPacket)
{
    m_nFillFlag = pPacket->ReadInt();
    g_pDebugLog->logMsg("%s||m_nFillFlag:[%d]", __FUNCTION__, m_nFillFlag);
}

CUserServer* CGameServer::GetUserServer(int id)
{
    //CUserServer* pServer = NULL;
    UserServerList::iterator iter = m_UserServerList.find(id);
    if(iter != m_UserServerList.end())
    {
		return iter->second;
    }
    return NULL;
}
int CGameServer::ProcessTransferPacketTemp(int uid, NETOutputPacket transPacket)
{
	
	int userServerId = uid % (int)m_UserServerList.size();
	CUserServer* pUserServer = GetUserServer(userServerId);
	if (pUserServer != NULL)
	{
		pUserServer->TransferPacket(&transPacket);
	}
	else
	{
#ifndef WIN32
		g_pErrorLog->logMsg("pUserServer NULL  uid[%d]", uid);
#endif
	}
	return 0;
}

int CGameServer::ProcessTransferPacket(int uid, NETInputPacket *pPacket)
{
    NETOutputPacket transPacket;
    transPacket.Copy(pPacket->packet_buf(), pPacket->packet_size());
    int userServerId = uid%(int)m_UserServerList.size();
    CUserServer* pUserServer = GetUserServer(userServerId);
    if(pUserServer != NULL)
    {
        pUserServer->TransferPacket(&transPacket);
    }
    else
    {
#ifndef WIN32
        g_pErrorLog->logMsg("pUserServer NULL  uid[%d]", uid);
#endif
    }
    return 0;
}

int CGameServer::ProcessSetServerAddrToMC()
{
    CLogicServer* pLogicServer = NULL;
    ServerList::iterator iter = m_ServerList.begin();
    for(; iter!=m_ServerList.end(); iter++)
    {
        pLogicServer = iter->second;
        if(pLogicServer == NULL)
            continue;
        //写入mc
#ifndef WIN32
        char szKey[10]= {0};
        snprintf(szKey, sizeof(szKey), "%d", pLogicServer->m_nServerId);
        char szValue[100]= {0};
        snprintf(szValue, sizeof(szValue), "%d,%s,%d", pLogicServer->m_nLevel, pLogicServer->m_strIp.c_str(), pLogicServer->m_nPort);
        int setTimes = 0;
        while(!m_pMemCacheClient->SetRecord(szKey, szValue, strlen(szValue)))//3次不成功，退出
        {
            setTimes++;
            if(setTimes == 3)
                break;
        }

        if(setTimes == 3)
        {
            g_pErrorLog->logMsg("ProcessSetServerAddrToMC||SetRecord error, serverId:[%d]", pLogicServer->m_nServerId);
        }
        else
        {
            g_pDebugLog->logMsg("ProcessSetServerAddrToMC||serverId:[%d],ip:[%s],port:[%d]", pLogicServer->m_nServerId, pLogicServer->m_strIp.c_str(), pLogicServer->m_nPort);
        }
#endif
    }
    return 0;
}

int CGameServer::ProcessSetServerRetired(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    (void)pSocket;
    short flag = pPacket->ReadShort();
    short serverIdCount = pPacket->ReadShort();
    for(int i=0; i<serverIdCount; i++)
    {
        short serverId = pPacket->ReadShort();
        CLogicServer *pServer = GetServer(serverId);
        if(pServer != NULL)
        {
            pServer->m_nRetire = flag;

            g_pDebugLog->logMsg("ProcessSetServerRetired||flag:[%d],serverId:[%d]", flag, serverId);

            if(pServer->m_pSocketHandler != NULL)
            {
                //增加通知server退休
                NETOutputPacket reqPacket;
                reqPacket.Begin(CMD_SET_SERVER_RETIRED);
                reqPacket.WriteShort(flag);
                reqPacket.End();
                pServer->m_pSocketHandler->Send(&reqPacket);
            }
        }
    }
    return 0;
}


int CGameServer::ProcessReportPrivateRoomData(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    short serverId = pPacket->ReadShort();
    short level = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();
    int tableCount = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pErrorLog->logMsg("%s||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", __FUNCTION__, serverId, level, m_nLevel);
        return 0;
    }

    g_pDebugLog->logMsg("%s||serverId:[%d],level:[%d],userCount:[%d],tableCount:[%d]", __FUNCTION__, serverId, level, userCount, tableCount);
    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        if(pLogicServer->m_pSocketHandler != NULL)
        {
            pLogicServer->m_pSocketHandler->m_pLogicServer = NULL;
        }

        pLogicServer->m_nLevel = level;
        pLogicServer->m_nUserCount = userCount;
        pLogicServer->m_nTableCount = tableCount;
        pLogicServer->m_pSocketHandler = pSocket;
        pSocket->m_pLogicServer = pLogicServer;
        pLogicServer->StopCheckCoreTimer();
        pLogicServer->ResetLogicServer();
    }
    else
    {
        pLogicServer = new CLogicServer(serverId, userCount, tableCount, level, pSocket, this);
        if(pLogicServer != NULL)
        {
            m_ServerList[serverId] = pLogicServer;
            pSocket->m_pLogicServer = pLogicServer;
        }
    }

    if(pLogicServer != NULL)
    {
        pLogicServer->m_nRetire = 0;
        for(int i=0; i<tableCount; i++)
        {
            int tid = pPacket->ReadInt();
            int tableType = pPacket->ReadInt();
            short tableUserCount = pPacket->ReadShort();
            int baseChip = pPacket->ReadInt();
            string roomName = pPacket->ReadString();
            string password = pPacket->ReadString();
            int roomIndex = pPacket->ReadInt();
            int isLoveGirl = pPacket->ReadInt();
            int createtime = pPacket->ReadInt();
            if((tid>>16) == serverId)//满足serverId与tid的匹配
            {
                CGameTable *pTable = pLogicServer->GetTable(tid);
                if(pTable != NULL)
                {
                    if(pTable->m_nUserCount != tableUserCount)
                    {
                        CountTableList::iterator iterCount = m_CountTableList.find(pTable->m_nUserCount);
                        if(iterCount != m_CountTableList.end())
                        {
                            TableList& tableMap = iterCount->second;
                            TableList::iterator iterTable = tableMap.find(tid);
                            if(iterTable != tableMap.end())
                            {
                                tableMap.erase(iterTable);
                            }
                        }
                    }

                    CountTableList::iterator iterNewCount = m_CountTableList.find(tableUserCount);
                    if(iterNewCount != m_CountTableList.end())
                    {
                        TableList& tableMap = iterNewCount->second;
                        tableMap[tid] = pTable;
                    }
                    else
                    {
                        TableList& tableMap = m_CountTableList[tableUserCount];
                        tableMap[tid] = pTable;
                    }
                    pTable->m_nUserCount = tableUserCount;

                    pTable->m_nServerId = serverId;
                    pTable->m_nBaseChip = baseChip;
                    pTable->m_strRoomName = roomName;
                    pTable->m_strPassword = password;
                    pTable->m_nRoomType = tableType;
                    pTable->m_nRoomIndex = roomIndex;
                    pTable->m_nIsLoveGirl = isLoveGirl;
                    pTable->m_nCreateTime = createtime;
                    pTable->m_pServer = pLogicServer;
                    m_nTableIndexList[roomIndex]=tid;
                    m_nTableIdList[tid] = roomIndex;
                }
                else
                {
                    pTable = new CGameTable(tid, serverId, 0,0);
                    if(pTable != NULL)
                    {
                        pTable->m_nUserCount = tableUserCount;
                        pTable->m_nBaseChip = baseChip;
                        pTable->m_strRoomName = roomName;
                        pTable->m_bDirtyRoomName = (CDirtyWordsFilter::Instance()->doFilter(ToLower(roomName).c_str()) > 0) ? 1 : 0;
                        pTable->m_strPassword = password;
                        pTable->m_nRoomType = tableType;
                        pTable->m_nRoomIndex = roomIndex;
                        pTable->m_nIsLoveGirl = isLoveGirl;
                        pTable->m_pServer = pLogicServer;
                        m_nTableIndexList[roomIndex]=tid;
                        m_nTableIdList[tid] = roomIndex;
                        pLogicServer->m_TableList[tid] = pTable;
                        pTable->m_nCreateTime = createtime;
                        CountTableList::iterator iterCount = m_CountTableList.find(tableUserCount);
                        if(iterCount != m_CountTableList.end())
                        {
                            TableList& tableMap = iterCount->second;
                            tableMap[tid] = pTable;
                        }
                        else
                        {
                            TableList& tableMap = m_CountTableList[tableUserCount];
                            tableMap[tid] = pTable;
                        }
                    }
                }
            }
        }
    }
    return 0;
}




int CGameServer::ProcessSendServerPortIp(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    if(pSocket->m_pLogicServer == NULL)
        return 0;
    string ip = pPacket->ReadString();
    int port = pPacket->ReadInt();
    short serverId = pPacket->ReadShort();
    CLogicServer *pLogicServer = GetServer(serverId);

    g_pDebugLog->logMsg("ProcessSendServerPortIp||serverId:[%d],ip:[%s],port:[%d]", serverId, ip.c_str(), port);

    if(pLogicServer != NULL)
    {
        pLogicServer->m_strIp = ip;
        pLogicServer->m_nPort = port;

		//printf("-----------ProcessSendServerPortIp [%s] [%d]\n", pLogicServer->m_strIp.c_str(),pLogicServer->m_nPort);
		//fflush(stdout);

        //写入mc
#ifndef WIN32
        char szKey[10]= {0};
        snprintf(szKey, sizeof(szKey), "%d", serverId);
        char szValue[100]= {0};
        snprintf(szValue, sizeof(szValue), "%d,%s,%d", pLogicServer->m_nLevel, ip.c_str(), port);
        if(!m_pMemCacheClient->SetRecord(szKey, szValue, strlen(szValue)))
        {
            g_pErrorLog->logMsg("ProcessSendServerPortIp||SetRecord error, serverId:[%d]", serverId);
        }
        g_pDebugLog->logMsg("ProcessSendServerPortIp||serverId:[%d],ip:[%s],port:[%d]", serverId, ip.c_str(), port);
#endif
    }
    return 0;
}

int CGameServer::ProcessUpdateRoomUserCount(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    if(pSocket->m_pLogicServer == NULL)
        return 0;
    short serverId = pPacket->ReadShort();
    int tid = pPacket->ReadInt();
    short level = pPacket->ReadShort();
    short tableUserCount = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();

    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pDebugLog->logMsg("ProcessReportServerData||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
#endif
        return 0;
    }

     g_pDebugLog->logMsg("ProcessUpdateRoomUserCount||serverId:[%d],tid:[%d],level:[%d],tableUserCount:[%d],userCount:[%d]", serverId, tid, level, tableUserCount, userCount);


    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        pLogicServer->m_nUserCount = userCount;
        if((tid>>16) == serverId)//满足serverId与tid匹配
        {
            CGameTable *pTable = pLogicServer->GetTable(tid);
            if(pTable != NULL)
            {
                if(pTable->m_nUserCount != tableUserCount)
                {
                    
                   // g_pDebugLog->logMsg("pTable->m_nUserCount=[%d] tableUserCount=[%d]",pTable->m_nUserCount, tableUserCount);
                    
                    CountTableList::iterator iterCount = m_CountTableList.find(pTable->m_nUserCount);
                    if(iterCount != m_CountTableList.end())
                    {
                        TableList& tableMap = iterCount->second;
                        TableList::iterator iterTable = tableMap.find(tid);
                        if(iterTable != tableMap.end())
                        {
                            tableMap.erase(iterTable);
                        }
                    }
                }

                CountTableList::iterator iterNewCount = m_CountTableList.find(tableUserCount);
                if(iterNewCount != m_CountTableList.end())
                {
                    TableList& tableMap = iterNewCount->second;
                    tableMap[tid] = pTable;
                }
                else
                {
                    TableList& tableMap = m_CountTableList[tableUserCount];
                    tableMap[tid] = pTable;
                }
                pTable->m_nUserCount = tableUserCount;
            }
            else
            {
                g_pDebugLog->logMsg("ProcessUpdateRoomUserCount||table not exist tid:[%d],serverId:[%hd],level:[%hd]", tid, serverId, level);

                pTable = new CGameTable(tid, serverId, level,0);//游戏server创建的房间
                if(pTable != NULL)
                {
                    pLogicServer->m_TableList[tid] = pTable;
                    pLogicServer->m_nTableCount++;
                    CountTableList::iterator iterCount = m_CountTableList.find(tableUserCount);
                    if(iterCount != m_CountTableList.end())
                    {
                        TableList& tableMap = iterCount->second;
                        tableMap[tid] = pTable;
                    }
                    else
                    {
                        TableList& tableMap = m_CountTableList[tableUserCount];
                        tableMap[tid] = pTable;
                    }
                    pTable->m_nUserCount = tableUserCount;
                }
            }
        }
    }
    return 0;
}

int CGameServer::ProcessReportServerData(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    short serverId = pPacket->ReadShort();
    short level = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();
    int tableCount = pPacket->ReadInt();
//#ifndef WIN32
    g_pDebugLog->logMsg("ProcessReportServerData||serverId:[%d],level:[%d],userCount:[%d],tableCount:[%d]", serverId, level, userCount, tableCount);
//#endif
    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessReportServerData||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
#endif
        return 0;
    }
	CAllocServer *aServer = new CAllocServer(40020);
	allocServer = aServer;
	m_nServerId = serverId;
    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        if(pLogicServer->m_pSocketHandler != NULL)
        {
            pLogicServer->m_pSocketHandler->m_pLogicServer = NULL;
        }

        pLogicServer->m_nLevel = level;
        pLogicServer->m_nUserCount = userCount;
        pLogicServer->m_nTableCount = tableCount;
        pLogicServer->m_pSocketHandler = pSocket;
        pSocket->m_pLogicServer = pLogicServer;
        pLogicServer->StopCheckCoreTimer();
    }
    else
    {
        pLogicServer = new CLogicServer(serverId, userCount, tableCount, level, pSocket, this);
        if(pLogicServer != NULL)
        {
            m_ServerList[serverId] = pLogicServer;
            pSocket->m_pLogicServer = pLogicServer;
        }
    }
	
    if(pLogicServer != NULL)
    {
		NETOutputPacket resPacket2;
		resPacket2.Begin(B2A_GAME_MSG_TO_SERVER);
		resPacket2.WriteInt(serverId+40000);
		resPacket2.WriteInt(serverId);
		resPacket2.WriteInt(level);
		resPacket2.End();
		allocServer->Send(&resPacket2);
		
		NETOutputPacket resPacket;
		resPacket.Begin(CLIENT_PACKET);
		resPacket.WriteInt(0);
		resPacket.WriteInt(1);
		resPacket.WriteBinary(pPacket->packet_buf(), pPacket->packet_size());
		resPacket.End();
		pSocket->Send(&resPacket);
        pLogicServer->m_nRetire = 0;
        for(int i=0; i<tableCount; i++)
        {
            int tid = pPacket->ReadInt();
            int tableType = pPacket->ReadInt();
            short tableUserCount = pPacket->ReadShort();
//#ifndef WIN32
          g_pDebugLog->logMsg("ProcessReportServerData||serverId:[%d],level:[%d],tid:[%d],tableType:[%d],tableUserCount:[%d]", serverId, level, tid, tableType, tableUserCount);
//#endif
            if((tid>>16) == serverId)//解决server上报错误桌子信息
            {
                CGameTable *pTable = pLogicServer->GetTable(tid);
                if(pTable != NULL)
                {
                    if(pTable->m_nUserCount != tableUserCount)//如果当前桌子人数和上报人数不同，那就更新以usercount和键值的列表
                    {
                        CountTableList::iterator iterCount = m_CountTableList.find(pTable->m_nUserCount);
                        if(iterCount != m_CountTableList.end())
                        {
                            TableList& tableMap = iterCount->second;
                            TableList::iterator iterTable = tableMap.find(tid);
                            if(iterTable != tableMap.end())
                            {
                                tableMap.erase(iterTable);
                            }
                        }

                        CountTableList::iterator iterNewCount = m_CountTableList.find(tableUserCount);
                        if(iterNewCount != m_CountTableList.end())
                        {
                            TableList& tableMap = iterNewCount->second;
                            tableMap[tid] = pTable;
                        }
                        else
                        {
                            TableList& tableMap = m_CountTableList[tableUserCount];
                            tableMap[tid] = pTable;
                        }
                        pTable->m_nUserCount = tableUserCount;
                        if (pTable->m_nUserCount == 0){
                            pTable->m_nOwnerUid = -1;
                        }
                    }
                }
                else
                {
                    pTable = new CGameTable(tid, serverId, level,0);
                    if(pTable != NULL)
                    {
                        pLogicServer->m_TableList[tid] = pTable;
                        CountTableList::iterator iterCount = m_CountTableList.find(tableUserCount);
                        if(iterCount != m_CountTableList.end())
                        {
                            TableList& tableMap = iterCount->second;
                            tableMap[tid] = pTable;
                        }
                        else
                        {
                            TableList& tableMap = m_CountTableList[tableUserCount];
                            tableMap[tid] = pTable;
                        }
                        pTable->m_nUserCount = tableUserCount;
                        pTable->m_pServer = pLogicServer;
                        if (pTable->m_nUserCount == 0){
                            pTable->m_nOwnerUid = -1;
                        }
                    }
                }
            }
        }

		/*----------------- 扩展协议 更新房间列表 neo-----------------*/
		int table_count = pPacket->ReadInt();
		if (table_count > 0)
		{
			int game_sub_type = pPacket->ReadInt();
			CTableList::Instance()->init(this, pLogicServer, table_count, game_sub_type);
		}
		/*----------------- 扩展协议 更新房间列表 neo-----------------*/
		for (map<int, string>::iterator ite = robotConfig.begin(); ite != robotConfig.end(); ite++)
		{
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_UPDATE_GROUP_ROBOT_SR); //ALLOW_PACKET 自己定义 协议号
			resPacketTemp.WriteInt(ite->first);
			resPacketTemp.WriteString(ite->second.c_str());
			resPacketTemp.End();
			pLogicServer->m_pSocketHandler->Send(&resPacketTemp);
		}
    }
	/*if (m_nLevel == 373) {
		for (map<int, string>::iterator itrTest = robotConfig.begin(); itrTest != robotConfig.end(); itrTest++)
		{
			GameGroup::Instance()->PerfromSendTableCreate(itrTest->first, m_nLevel);
		}
	}*/
    return 0;
}

int CGameServer::ProcessClientPacket(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket,  int ip)
{
    if(pSocket->CrevasseBuffer(pPacket) < 0)
    {

        g_pErrorLog->logMsg("ProcessClientPacket||CrevasseBuffer error");

        return -1;
    }

    int cmd = pPacket->GetCmdType();
	g_pDebugLog->logMsg("*******************CGameServer::ProcessClientPacket----%d,%d,cmd:0x%x \n", uid, svid, cmd);
	//printf("*******************CGameServer::ProcessClientPacket----%d,%d,%d\n", uid, svid, cmd);//zswx
	//fflush(stdout);
    switch(cmd)
    {
        case CLIENT_CMD_JOIN_GAME:	//用户请求进入三人游戏场
			ProcessUserJoinGame(uid, svid, pPacket, pSocket, ip);
            break;
        case CMD_GET_NEW_ROOM:
            ProcessGetNewRoom(uid, svid, pPacket, pSocket);
            break;
        case CMD_REQUIRE_IP_PORT:
            ProcessRequireIpAndPort(uid, svid, pPacket, pSocket);
            break;
        case CMD_GET_MATCH_QUICK_ROOM:		//玩家请求超快赛
        	ProcessCheckUserTable(uid, svid, cmd, pPacket, pSocket);
//            ProcessUserJoinMatch(uid, svid, pPacket, pSocket);
            break;
        case CMD_GET_MATCH_HUODONG_ROOM:	//玩家请求进入活动赛
            ProcessUserJoinHuodongMatch(uid, svid, (short)cmd, pSocket);
            break;
        case CMD_GET_APPLY_SERVER:			//玩家请求报名Server
            ProcessUserApplyMatch(uid, svid, (short)cmd, pSocket);
            break;
        case SERVER_COMMAND_CHANGE_LEVEL_TO_LOGIN:
            ProcessChangeLevelToLogin(uid, svid, pPacket, pSocket);
            break;
        case CLIENT_CMD_CREATE_PRIVATE_ROOM:
            ProcessPrivateRoomCreate(uid,svid,pPacket,pSocket);
            break;
        case CLIENT_CMD_ENTRE_PRIVATE_ROOM:
            ProcessPrivateRoomEnter(uid,svid,pPacket,pSocket);
            break;
        case CLIENT_CMD_LIST_PRIVATE_ROOM:
            ProcessPrivateRoomList(uid,svid,pPacket,pSocket);
            break;
        case CLIENT_CMD_FIND_PRIVATE_ROOM:
            ProcessPrivateRoomFind(uid,svid,pPacket,pSocket);
            break;
        case CLIENT_CMD_REFRESH_PRIVATE_ROOM:
            ProcessPrivateRoomRefreshCount(uid,svid,pPacket,pSocket);
            break;

		//自办比赛相关
		case CLIENT_CMD_CREATE_MATCH:
            ProcessCreateMatch(uid, svid, pPacket, pSocket);
            break;
		case CLIENT_CMD_ENTER_MATCH:
            ProcessEnterMatch(uid, svid, pPacket, pSocket);
            break;
		case CLIENT_CMD_FIND_MATCH:
            ProcessFindMatch(uid, svid, pPacket, pSocket);
            break;
		case CLIENT_CMD_LIST_MATCH:
			ProcessListMatch(uid, svid, pPacket, pSocket);
			break;
		case CLUB_DATA:
			ProcessRequireClubData(uid, svid, pPacket, pSocket);
			break;
		case CLIENT_CMD_JOIN_TABLE:
			ProcessFastJoinTable(uid, svid, pPacket, pSocket);
			break;
		case CLIENT_DISABLE_USER_GAME:
			ProcessDisableUser(uid, svid, pPacket, pSocket);
			break;
		case B2A_REMOVE_GROUP_TABLE:
			GameGroup::Instance()->PerfromB2ARemoveGroup(pPacket, pSocket, this);
			break;
		case  CLIENT_USER_GAME_STATUS:
			sendUserGameStatus(uid, svid, pSocket);
			break;
		case  CLIENT_COMMAND_USER_ONLINE:
		{
			userOnClub[uid] = false;
		}
			break;
        default:
        {
#ifndef WIN32
            g_pErrorLog->logMsg("ProcessClientPacket||Invalid cmd:[0x%02x]", cmd);
#endif
         }
        break;
    }
    return 0;
}
int CGameServer::sendUserGameStatus(int uid, int svid, SocketHandler *pSocket)
{
	string tempStr;
	int ret = m_pRedisManagerClient->GET_USER_GAME_STATUS(uid, tempStr);
	//g_pDebugLog->logMsg("GET_USER_GAME_STATUS ret[%d]  c_str[%s]", ret, tempStr.c_str());
	NETOutputPacket resPacket;
	if (ret > 0) {
		int isWatch = 1;
		if (status_Watch.find(uid) != status_Watch.end()) {
			isWatch = status_Watch[uid];
		}
		vector<int> sv;
		split(tempStr, sv, '_');
		if (sv.size() >= 3) {
			if (sv[1] > 0 && sv[2] > 0) {
				resPacket.Begin(SERVER_USER_GAME_STATUS);
				resPacket.WriteShort(sv[0]);
				resPacket.WriteInt(sv[1]);
				resPacket.WriteInt(sv[2]);
				resPacket.WriteInt(10);
				resPacket.WriteByte(isWatch);
				resPacket.End();
			}
			else {
				resPacket.Begin(SERVER_USER_GAME_STATUS);
				resPacket.WriteShort(0);
				resPacket.WriteInt(0);
				resPacket.WriteInt(0);
				resPacket.WriteInt(0);
				resPacket.WriteByte(0);
				resPacket.End();
			}
		}
		else {
			resPacket.Begin(SERVER_USER_GAME_STATUS);
			resPacket.WriteShort(0);
			resPacket.WriteInt(0);
			resPacket.WriteInt(0);
			resPacket.WriteInt(0);
			resPacket.WriteByte(0);
			resPacket.WriteByte(isWatch);
			resPacket.End();
		}
	}
	else {
		
		resPacket.Begin(SERVER_USER_GAME_STATUS);
		resPacket.WriteShort(0);
		resPacket.WriteInt(0);
		resPacket.WriteInt(0);
		resPacket.WriteInt(0);
		resPacket.WriteByte(0);
		resPacket.End();
	}
	CHallServer *pHallServer = GetHallServer(svid);
	if (pHallServer != NULL)
	{

		if (pHallServer->m_pSocketHandler != NULL)
		{
			SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
		}
	}
	return 0;
}
int CGameServer::sendCluUpdatebAlloc(NETInputPacket *pPacket, SocketHandler *pSocket) {
	int ClubType = pPacket->ReadByte();
	int groupIdT = pPacket->ReadInt();
	int uidT = pPacket->ReadInt();
	g_pDebugLog->logMsg("B2A_SET_CLUB_INFO uid%d groupId[%d] ClubType[%d]", uidT, groupIdT, ClubType);
	SetClubID(groupPlayer, uidT, groupIdT, ClubType);
	//g_pDebugLog->logMsg("B2A_SET_CLUB_INFO uid%d groupId[%d] ClubType[%d]", uidT, groupIdT, ClubType);
	//NETOutputPacket resPacketcClub;
	//resPacketcClub.Begin(B2A_SET_CLUB_INFO); //ALLOW_PACKET 自己定义 协议号	
	//resPacketcClub.WriteByte(ClubType);
	//resPacketcClub.WriteInt(uidT);
	//resPacketcClub.WriteInt(groupIdT);
	//resPacketcClub.End();
	//if (userHallServiceId.find(uidT) != userHallServiceId.end()) {
	//	CHallServer *pHallServer = GetHallServer(userHallServiceId[uidT]);
	//	if (pHallServer != NULL) {
	//		if (pHallServer->m_pSocketHandler != NULL) {
	//			g_pDebugLog->logMsg("B2A_SET_CLUB_INFO");
	//			SendClientAllocPacket(uidT, userHallServiceId[uidT], 0, &resPacketcClub, pHallServer->m_pSocketHandler);
	//		}
	//	}
	//}
}
int CGameServer::PerfromTableInfoAllow(NETInputPacket *pPacket, SocketHandler *pSocket) {
	int type = pPacket->ReadByte();
	int level = pPacket->ReadShort();
	int m_nTableId = pPacket->ReadInt();
	int code = pPacket->ReadInt();
	 
	//g_pDebugLog->logMsg("PerfromTableInfoAllow m_nTableId[%d] type[%d] m_nLevel[%d]", m_nTableId, type, m_nLevel);
	if (m_nLevel > 2) {

		if (type == TABLE_INFO_TYPE_SIT) {
			int uid = pPacket->ReadInt();
			if (uid > 0) {
				if (m_GroupTableDict_AcitiveId.find(m_nTableId) != m_GroupTableDict_AcitiveId.end()) {
					//g_pDebugLog->logMsg("PerfromTableInfoAllow uid[%], m_nLevel[%], m_nTableId[%], m_GroupTableDict_AcitiveId[m_nTableId][%]", uid, m_nLevel, m_nTableId, m_GroupTableDict_AcitiveId[m_nTableId]);
					m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, m_nTableId, m_GroupTableDict_AcitiveId[m_nTableId]);
				}
				if (count(m_Table_PlayerSit[m_nTableId].begin(), m_Table_PlayerSit[m_nTableId].end(), uid)<=0) {
					m_Table_PlayerSit[m_nTableId].push_back(uid);
				}
				
				ProcessUpdateTablelist(m_nTableId, 0);
			}
		}
		else if (type == TABLE_INFO_TYPE_JOIN_TABLE) {
			int uid = pPacket->ReadInt();
			if (m_GroupTableDict_AcitiveId.find(m_nTableId) != m_GroupTableDict_AcitiveId.end()) {
				m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, m_nTableId, m_GroupTableDict_AcitiveId[m_nTableId]);
			}
			if (count(m_Table_PlayerJoin[m_nTableId].begin(), m_Table_PlayerJoin[m_nTableId].end(), uid) <= 0) {
				m_Table_PlayerJoin[m_nTableId].push_back(uid);
			}
		}
		else if (type == TABLE_INFO_TYPE_STAND || type == TABLE_INFO_TYPE_QUIT_GAME)
		{
			if (m_Table_PlayerSit.find(m_nTableId) != m_Table_PlayerSit.end()) {
				int uid = pPacket->ReadInt();
				for (vector<int>::iterator itre = m_Table_PlayerSit[m_nTableId].begin(); itre != m_Table_PlayerSit[m_nTableId].end(); itre++)
				{
					if ((*itre) == uid) {
						m_Table_PlayerSit[m_nTableId].erase(itre);
						break;
					}

				}
				if (m_Table_Distance.find(m_nTableId) != m_Table_Distance.end()) {
					for (map<int, distanceInfo>::iterator itre = m_Table_Distance[m_nTableId].begin(); itre != m_Table_Distance[m_nTableId].end(); itre++)
					{
						if (itre->first == uid) {
							m_Table_Distance[m_nTableId].erase(itre);
							break;
						}
					}
				}
				
				for (vector<int>::iterator itre = m_Table_PlayerJoin[m_nTableId].begin(); itre != m_Table_PlayerJoin[m_nTableId].end(); itre++)
				{
					if ((*itre) == uid) {
						m_Table_PlayerJoin[m_nTableId].erase(itre);
						break;
					}
				}
				ProcessUpdateTablelist(m_nTableId, 1);
				m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, 0, 0);
				
			}
		}
		else if (type == TABLE_INFO_TYPE_CLOSE_GAME)
		{
			g_pDebugLog->logMsg("TABLE_INFO_TYPE_CLOSE_GAME m_nTableId %d",m_nTableId);
			for (vector<int>::iterator itre = m_Table_PlayerJoin[m_nTableId].begin(); itre != m_Table_PlayerJoin[m_nTableId].end(); itre++)
			{
				m_pRedisManagerClient->HSET_USER_STATUS((*itre), m_nLevel, 0, 0);
			}
			/*for (vector<int>::iterator itre = m_Table_PlayerSit[m_nTableId].begin(); itre != m_Table_PlayerSit[m_nTableId].end(); itre++)
			{
				m_pRedisManagerClient->HSET_USER_STATUS((*itre), m_nLevel, 0, 0);
			}*/
			if (m_Table_PlayerJoin.find(m_nTableId) != m_Table_PlayerJoin.end()) {
				m_Table_PlayerJoin[m_nTableId].clear();
				m_Table_PlayerJoin.erase(m_Table_PlayerJoin.find(m_nTableId));
			}
			if (m_Table_PlayerSit.find(m_nTableId) != m_Table_PlayerSit.end()) {
				m_Table_PlayerSit[m_nTableId].clear();
				m_Table_PlayerSit.erase(m_Table_PlayerSit.find(m_nTableId));
			}
			if (m_Table_Distance.find(m_nTableId) != m_Table_Distance.end()) {
				m_Table_Distance.erase(m_Table_Distance.find(m_nTableId));
				
			}
			ProcessUpdateTablelist(m_nTableId, 3);
		}
		NETOutputPacket resPacketTemp;
		//resPacketTemp.Begin(G2A_BROADCAST_TABLE_INFO); //ALLOW_PACKET 自己定义 协议号
		resPacketTemp.Copy(pPacket->packet_buf(), pPacket->packet_size());
		resPacketTemp.WriteInt(groupType);
		
		resPacketTemp.End();
		if (allocServer) {
			allocServer->Send(&resPacketTemp);
		}
	}
	else {
		srand((unsigned)time(0));
		if (type == TABLE_INFO_TYPE_CREATE_TABLE) {
			int groupType = pPacket->ReadInt();
			//g_pDebugLog->logMsg("TABLE_INFO_TYPE_CREATE_TABLE groupType[%d]", groupType);
			map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupType);
			if (cjList != cardJiFenList.end()) {
				map<int, int>::iterator clubList = m_tidClubList.find(m_nTableId);
				if (clubList != m_tidClubList.end()) {
					clubTableList::iterator clbuIter = cjList->second.find(clubList->second);
					if (clbuIter != cjList->second.end()) {
						if (clbuIter->second.find(m_nTableId) != clbuIter->second.end()) {
							CGameTable* pTable = clbuIter->second[m_nTableId];
							if (pTable != NULL) {
								NETOutputPacket resPacket;
								resPacket.Begin(TABLE_DATA_CHANGE);
								resPacket.WriteByte(type);
								resPacket.WriteInt(m_nTableId);
								resPacket.WriteInt(pTable->club_id);
								resPacket.WriteInt(pTable->m_nLevel);
								resPacket.WriteByte(pTable->isStart);
								resPacket.WriteInt(pTable->configId);
								resPacket.WriteInt(pTable->gameType);
								resPacket.WriteInt(pTable->currRound);
								resPacket.WriteString(pTable->jsonConfig.c_str());
								resPacket.WriteString("");
								resPacket.WriteString(pTable->groupName.c_str());
								resPacket.WriteString(pTable->m_strInviteCode.c_str());
								resPacket.End();
								//g_pDebugLog->logMsg("pTable->club_id[%d] m_nTableId[%d]", pTable->club_id, m_nTableId);
								for (HallServerList::iterator iterHall = m_HallServerList.begin(); iterHall != m_HallServerList.end(); iterHall++)
								{
									map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
									if (playerUser != groupPlayer.end()) {
										for (int k = 0; k < playerUser->second.size(); k++)
										{
											//g_pDebugLog->logMsg("pTable->01xx[%d] playerUser->second[%d]", m_nTableId, playerUser->second[k]);
											if (iterHall->second->m_pSocketHandler != NULL)
											{
												//g_pDebugLog->logMsg("pTable->0xx[%d] playerUser->second[%d]", m_nTableId, playerUser->second[k]);
												if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
													//g_pDebugLog->logMsg("pTable->1xx[%d] playerUser->second[%d]", m_nTableId, playerUser->second[k]);
													if (userGroupType.find(playerUser->second[k])->second == groupType) {
														//g_pDebugLog->logMsg("pTable->2xx[%d] playerUser->second[%d]", m_nTableId, playerUser->second[k]);
														map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
														if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub!= userOnClub.end() && itOnClub->second == true) {
															//g_pDebugLog->logMsg("pTable->3xx[%d] playerUser->second[%d]", m_nTableId, playerUser->second[k]);
															SendClientPacket(playerUser->second[k], iterHall->first, &resPacket, iterHall->second->m_pSocketHandler);
														}
													}
												}
											}
											//SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
										}
									}
								}
								//g_pDebugLog->logMsg("pTable->m_nLevel---[%d]", pTable->m_nLevel);
								if (groupLevel.find(pTable->m_nLevel) != groupLevel.end()) {
									g_pDebugLog->logMsg("pTable->m_nLevel[%d]", pTable->m_nLevel);
									AddRobotUser(pTable);
								}
							}
						}
					}
				}

			}
		}
		else if (type == TABLE_INFO_TYPE_START_GAME) {

		}
		else if (type == TABLE_INFO_TYPE_END_GAME) {

		}
		else if (type == TABLE_INFO_TYPE_JOIN_TABLE) {
			int uid = pPacket->ReadInt();
			int groupType = pPacket->ReadInt();
			//g_pDebugLog->logMsg("TABLE_INFO_TYPE_JOIN_TABLE groupType[%d] uid[%d]", groupType, uid);
			map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupType);
			if (cjList != cardJiFenList.end()) {
				map<int, int>::iterator clubList = m_tidClubList.find(m_nTableId);
				if (clubList != m_tidClubList.end()) {
					clubTableList::iterator clbuIter = cjList->second.find(clubList->second);
					if (clbuIter != cjList->second.end()) {
						if (clbuIter->second.find(m_nTableId) != clbuIter->second.end()) {
							CGameTable *pTable = clbuIter->second[m_nTableId];
							if (pTable != NULL) {
								//g_pDebugLog->logMsg("TABLE_INFO_TYPE_JOIN_TABLE pTable->m_nServerId[%d] uid[%d]", pTable->m_nServerId, uid);
								
								NETOutputPacket resPacket;
								resPacket.Begin(TABLE_DATA_CHANGE);
								resPacket.WriteByte(type);
								resPacket.WriteInt(m_nTableId);
								resPacket.WriteInt(pTable->club_id);
								resPacket.WriteInt(pTable->m_nLevel);
								resPacket.WriteByte(pTable->isStart);
								resPacket.WriteInt(pTable->configId);
								resPacket.WriteInt(pTable->gameType);
								resPacket.WriteInt(pTable->currRound);
								resPacket.WriteString("");
								resPacket.WriteString("");
								resPacket.WriteString(pTable->groupName.c_str());
								resPacket.WriteString(pTable->m_strInviteCode.c_str());
								resPacket.End();

								for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
								{
									if (iter->second != NULL)
									{
										if (iter->second->m_pSocketHandler != NULL)
										{
											map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
											if (playerUser != groupPlayer.end()) {
												for (int k = 0; k < playerUser->second.size(); k++)
												{
													if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
														if (userGroupType.find(playerUser->second[k])->second == groupType) {
															map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
															if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
																SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
															}
														}
													}
													

												}
											}

										}
									}
								}

							}
						}
					}
				}
			}
		}
		else if (type == TABLE_INFO_TYPE_SIT) {
			int uid = pPacket->ReadInt();
			if (uid > 0) {

				//g_pDebugLog->logMsg("TABLE_INFO_TYPE_SIT");
				int seatid = pPacket->ReadInt();
				string m_nickname = pPacket->ReadString();
				string m_portrait = pPacket->ReadString();
				/*g_pDebugLog->logMsg("m_tidClubList.size%d", m_tidClubList.size());
				g_pDebugLog->logMsg("m_HallServerList.size[%d]", m_HallServerList.size());
				*/
				int zhuan_id = 0;
				if (level == 101 || level == 102 || level == 103) {
					zhuan_id = pPacket->ReadByte();
				}
				//int groupType = pPacket->ReadInt();
				g_pDebugLog->logMsg("TABLE_INFO_TYPE_SIT groupType[%d] zhuan_id[%d]", groupType, zhuan_id);
				map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupType);
				if (cjList != cardJiFenList.end()) {
					map<int, int>::iterator clubList = m_tidClubList.find(m_nTableId);
					if (clubList != m_tidClubList.end()) {
						clubTableList::iterator clbuIter = cjList->second.find(clubList->second);
						if (clbuIter != cjList->second.end()) {
							if (clbuIter->second.find(m_nTableId) != clbuIter->second.end()) {
								CGameTable *pTable = clbuIter->second[m_nTableId];
								if (pTable != NULL) {
									//g_pDebugLog->logMsg("TABLE_INFO_TYPE_SIT pTable->m_nServerId[%d] uid[%d]", pTable->m_nServerId, uid);
									
									//g_pDebugLog->logMsg("TABLE_INFO_TYPE_SIT pTable->club_id[%d],uid[%d]", pTable->club_id, uid);
									UpdateRobotStatus(pTable->club_id, uid, 1, pTable->m_nLevel);
									/*NETOutputPacket resPacketTT;
									resPacketTT.Begin(SYS_USER_ENTER_ROOM);
									resPacketTT.WriteInt(uid);
									resPacketTT.WriteInt(m_nTableId);
									resPacketTT.WriteInt(pTable->m_nLevel);
									resPacketTT.WriteInt(pTable->m_activityID);

									resPacketTT.End();
									ProcessTransferPacketTemp(uid, resPacketTT);*/
									Json::Reader reader;
									Json::FastWriter fastWriter;

									Json::Value uInfJson;

									uInfJson["uid"] = uid;
									uInfJson["seatId"] = seatid;
									uInfJson["profit"] = m_portrait.c_str();
									uInfJson["zhuan_id"] = zhuan_id;
									string resultStr = fastWriter.write(uInfJson);
									
									pTable->userList[uid] = resultStr.c_str();

									clbuIter->second[m_nTableId] = pTable;
									NETOutputPacket resPacket;
									resPacket.Begin(TABLE_DATA_CHANGE);
									resPacket.WriteByte(type);
									resPacket.WriteInt(m_nTableId);
									resPacket.WriteInt(pTable->club_id);
									resPacket.WriteInt(pTable->m_nLevel);
									resPacket.WriteByte(pTable->isStart);
									resPacket.WriteInt(pTable->configId);
									resPacket.WriteInt(pTable->gameType);
									resPacket.WriteInt(pTable->currRound);
									resPacket.WriteString("");
									resPacket.WriteString(resultStr.c_str());
									resPacket.WriteString(pTable->groupName.c_str());
									resPacket.WriteString(pTable->m_strInviteCode.c_str());
									resPacket.End();
									for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
									{
										if (iter->second != NULL)
										{
											if (iter->second->m_pSocketHandler != NULL)
											{
												map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
												if (playerUser != groupPlayer.end()) {
													for (int k = 0; k < playerUser->second.size(); k++)
													{
														if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
															if (userGroupType.find(playerUser->second[k])->second == groupType) {
																map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
																if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
																	//g_pDebugLog->logMsg("GET_USER_GAME_STATUS type=4   uid =%d", playerUser->second[k]);
																	SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
																}
															}
														}
													}
												}

											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		else if (type == TABLE_INFO_TYPE_START_GAME) {
			int uid = pPacket->ReadInt();
			if (uid > 0) {

			}
		}
		else if (type == TABLE_INFO_TYPE_STAND) {
			int uid = pPacket->ReadInt();
			if (uid > 0) {
				int groupType = pPacket->ReadInt();
				//g_pDebugLog->logMsg("TABLE_INFO_TYPE_STAND groupType[%d]", groupType);
				map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupType);
				if (cjList != cardJiFenList.end()) {
					map<int, int>::iterator clubList = m_tidClubList.find(m_nTableId);
					if (clubList != m_tidClubList.end()) {
						clubTableList::iterator clbuIter = cjList->second.find(clubList->second);
						if (clbuIter != cjList->second.end()) {
							if (clbuIter->second.find(m_nTableId) != clbuIter->second.end()) {
								CGameTable *pTable = clbuIter->second[m_nTableId];
								if (pTable != NULL) {
									//g_pDebugLog->logMsg("TABLE_INFO_TYPE_STAND pTable->club_id[%d],uid[%d]", pTable->club_id, uid);
									UpdateRobotStatus(pTable->club_id, uid, 1, 0);
									//m_pRedisManagerClient->HSET_USER_STATUS(uid, pTable->m_nLevel, 0, 0);
									//UpdateRobotIsGame(0, pTable->club_id, uid);
									if (pTable->userList.find(uid) == pTable->userList.end()) {
										return 0;
									}
									ReleaseRobot(pTable->club_id, uid, pTable->m_nLevel, m_nTableId);
									
									NETOutputPacket resPacket;
									resPacket.Begin(TABLE_DATA_CHANGE);
									resPacket.WriteByte(type);
									resPacket.WriteInt(m_nTableId);
									resPacket.WriteInt(pTable->club_id);
									resPacket.WriteInt(pTable->m_nLevel);
									resPacket.WriteByte(pTable->isStart);
									resPacket.WriteInt(pTable->configId);
									resPacket.WriteInt(pTable->gameType);
									resPacket.WriteInt(pTable->currRound);
									resPacket.WriteString("");
									resPacket.WriteString(pTable->userList.find(uid)->second.c_str());
									resPacket.WriteString(pTable->groupName.c_str());
									resPacket.WriteString(pTable->m_strInviteCode.c_str());
									resPacket.End();
									if (pTable->userList.find(uid) != pTable->userList.end()) {
										pTable->userList.erase(pTable->userList.find(uid));
									}
									clbuIter->second[m_nTableId] = pTable;
									for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
									{
										if (iter->second != NULL)
										{
											if (iter->second->m_pSocketHandler != NULL)
											{
												map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
												if (playerUser != groupPlayer.end()) {
													for (int k = 0; k < playerUser->second.size(); k++)
													{
														if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
															if (userGroupType.find(playerUser->second[k])->second == groupType) {
																map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
																if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
																	SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
																}
															}
														}
													}
												}

											}
										}
									}

								}
								
							}
						}
					}
				}
			}
		}
		else if (type == TABLE_INFO_TYPE_QUIT_GAME) {
			int uid = pPacket->ReadInt();
			if (uid > 0) {
				int groupType = pPacket->ReadInt();
				//g_pDebugLog->logMsg("TABLE_INFO_TYPE_QUIT_GAME groupType[%d]", groupType);
				map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupType);
				if (cjList != cardJiFenList.end()) {
					map<int, int>::iterator clubList = m_tidClubList.find(m_nTableId);
					if (clubList != m_tidClubList.end()) {
						clubTableList::iterator clbuIter = cjList->second.find(clubList->second);
						if (clbuIter != cjList->second.end()) {
							if (clbuIter->second.find(m_nTableId) != clbuIter->second.end()) {
								CGameTable *pTable = clbuIter->second[m_nTableId];
								if (pTable != NULL) {
									//g_pDebugLog->logMsg("TABLE_INFO_TYPE_QUIT_GAME pTable->club_id[%d],uid[%d]", pTable->club_id, uid);
									//UpdateRobotIsGame(0, pTable->club_id, uid);
									UpdateRobotStatus(pTable->club_id, uid, 1, 0);
									/*NETOutputPacket resPacketTT;
									resPacketTT.Begin(SYS_USER_LEAVE_ROOM);
									resPacketTT.WriteInt(uid);
									resPacketTT.WriteInt(m_nTableId);
									resPacketTT.WriteInt(pTable->m_nLevel);
									resPacketTT.End();
									ProcessTransferPacketTemp(uid, resPacketTT);
									if (pTable->userList.find(uid) == pTable->userList.end()) {
										return 0;
									}*/
									if (pTable->userList.find(uid) == pTable->userList.end()) {
										return 0;
									}
									ReleaseRobot(pTable->club_id, uid, pTable->m_nLevel, m_nTableId);
									//m_pRedisManagerClient->HSET_USER_STATUS(uid, pTable->m_nLevel, 0, 0);
									
									NETOutputPacket resPacket;
									resPacket.Begin(TABLE_DATA_CHANGE);
									resPacket.WriteByte(type);
									resPacket.WriteInt(m_nTableId);
									resPacket.WriteInt(pTable->club_id);
									resPacket.WriteInt(pTable->m_nLevel);
									resPacket.WriteByte(pTable->isStart);
									resPacket.WriteInt(pTable->configId);
									resPacket.WriteInt(pTable->gameType);
									resPacket.WriteInt(pTable->currRound);
									resPacket.WriteString("");
									resPacket.WriteString(pTable->userList.find(uid)->second.c_str());
									resPacket.WriteString(pTable->groupName.c_str());
									resPacket.WriteString(pTable->m_strInviteCode.c_str());
									resPacket.End();
									if (pTable->userList.find(uid) != pTable->userList.end()) {
										pTable->userList.erase(pTable->userList.find(uid));
									}
									clbuIter->second[m_nTableId] = pTable;
									for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
									{
										if (iter->second != NULL)
										{
											if (iter->second->m_pSocketHandler != NULL)
											{

												map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
												if (playerUser != groupPlayer.end()) {
													for (int k = 0; k < playerUser->second.size(); k++)
													{
														if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
															if (userGroupType.find(playerUser->second[k])->second == groupType) {
																map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
																if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
																	SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
																}
															}
														}
													}
												}

											}
										}
									}

								}
							}
						}
					}
				}
			}
				
		}
		else if (type == TABLE_INFO_TYPE_CLOSE_GAME) {
			int groupType = pPacket->ReadInt();
			//g_pDebugLog->logMsg("TABLE_INFO_TYPE_CLOSE_GAME groupType[%d]", groupType);
			map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupType);
			if (cjList != cardJiFenList.end()) {
				map<int, int>::iterator clubList = m_tidClubList.find(m_nTableId);
				if (clubList != m_tidClubList.end()) {
					clubTableList::iterator clbuIter = cjList->second.find(clubList->second);
					if (clbuIter != cjList->second.end()) {
						map<int, CGameTable*>::iterator tableIter = clbuIter->second.find(m_nTableId);
						if (tableIter != clbuIter->second.end()) {
							CGameTable *pTable = tableIter->second;
							if (pTable != NULL) {
						
								if (m_userRobotTableLst.find(m_nTableId) != m_userRobotTableLst.end()) {
									for (int b = 0; b < m_userRobotTableLst[m_nTableId].size(); b++)
									{
										UpdateRobotStatus(pTable->club_id, m_userRobotTableLst[m_nTableId][b], 1, 0);
										ReleaseRobot(pTable->club_id, m_userRobotTableLst[m_nTableId][b], pTable->m_nLevel, m_nTableId);
										m_pRedisManagerClient->HSET_USER_STATUS(m_userRobotTableLst[m_nTableId][b], pTable->m_nLevel, 0, 0);
									}
									m_userRobotTableLst.erase(m_userRobotTableLst.find(m_nTableId));
								}
								//
								pTable->userList.clear();
								clbuIter->second[m_nTableId] = pTable;
								clbuIter->second.erase(tableIter);
								NETOutputPacket resPacket;
								resPacket.Begin(TABLE_DATA_CHANGE);
								resPacket.WriteByte(type);
								resPacket.WriteInt(m_nTableId);
								resPacket.WriteInt(pTable->club_id);
								resPacket.WriteInt(pTable->m_nLevel);
								resPacket.WriteByte(pTable->isStart);
								resPacket.WriteInt(pTable->configId);
								resPacket.WriteInt(pTable->gameType);
								resPacket.WriteInt(pTable->currRound);
								resPacket.WriteString("");
								resPacket.WriteString("");
								resPacket.WriteString(pTable->groupName.c_str());
								resPacket.WriteString("");
								resPacket.End();

								for (HallServerList::iterator iter = m_HallServerList.begin(); iter != m_HallServerList.end(); iter++)
								{
									if (iter->second != NULL)
									{
										if (iter->second->m_pSocketHandler != NULL)
										{
											map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
											if (playerUser != groupPlayer.end()) {
												for (int k = 0; k < playerUser->second.size(); k++)
												{
													if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
														if (userGroupType.find(playerUser->second[k])->second == groupType) {
															map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
															if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
																SendClientPacket(playerUser->second[k], iter->second->m_nServerId, &resPacket, iter->second->m_pSocketHandler);
															}
														}
													}
												}
											}

										}
									}
								}

							}
						}
					}
					m_tidClubList.erase(clubList);
				}
			}
		}
		else if (type == TABLE_INFO_TYPE_BONUS) {

		}
		//PerfromBroadcastTableInfo(pPacket, pSocket);
	}
	
	return 0;
}
//int CGameServer::PerfromClearTid(int tid,int uid) {
//	g_pDebugLog->logMsg("PerfromClearTid send tid[%d] uid[%d]", tid, uid);
//	NETOutputPacket resPacketTemp;
//	resPacketTemp.Begin(B2A_CLEAR_CLUB_TABLE_TID); //ALLOW_PACKET 自己定义 协议号
//	resPacketTemp.WriteInt(tid);
//	resPacketTemp.End();
//	int svid = userHallServiceId[uid];
//	CHallServer *pHallServer = GetHallServer(svid);
//	if (pHallServer != NULL)
//	{
//
//		if (pHallServer->m_pSocketHandler != NULL)
//		{
//			g_pDebugLog->logMsg("PerfromClearTid send");
//			SendClientAllocPacket(uid, svid, 1, &resPacketTemp, pHallServer->m_pSocketHandler);
//		}
//	}
//	return 0;
//}

int CGameServer::ProcessClubInfo() {

	return 0;
}

//发送到allow
int CGameServer::SendAllowPacket(int uid, int svid,int slevel, NETOutputPacket *pPacket, SocketHandler *pSocket)
{
    if(pSocket != NULL)
    {
        pSocket->EncryptBuffer(pPacket);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_PACKET);
        resPacket.WriteInt(uid);
        resPacket.WriteInt(svid);
		resPacket.WriteInt(slevel);
		resPacket.WriteBinary(pPacket->packet_buf(), pPacket->packet_size());
        resPacket.End();
        pSocket->Send(&resPacket);
    }
    return 0;
}



//广播allows数据
//void CGameServer::ProcBroadToAllows(int uid,int svid,int revlevel)
//{
//    NETOutputPacket resPacketTemp;
//	resPacketTemp.Begin(ALLOW_GAME_SVID_PACKET); //ALLOW_PACKET 自己定义 协议号
//    //发的数据
//	resPacketTemp.WriteInt(uid);
//	resPacketTemp.WriteInt(svid);
//	resPacketTemp.WriteInt(revlevel);
//	resPacketTemp.End();
//	CHallServer *pHallServer = GetHallServer(svid);
//	if (pHallServer != NULL)
//	{
//
//		if (pHallServer->m_pSocketHandler != NULL)
//		{
//			SendClientAllocPacket(uid,svid, revlevel,&resPacketTemp, pHallServer->m_pSocketHandler);
//		}
//	}
//}

void CGameServer::ProcessDisableUser(int uid, int svid, NETInputPacket * pPacket, SocketHandler * pSocket) {
	int club_id = pPacket->ReadInt();
	int ohetUid = pPacket->ReadInt();
	int st = pPacket->ReadInt();
	m_pRedisManagerClient->SET_DISABLE_USER(ohetUid, st, club_id);
	g_pDebugLog->logMsg("st [%d] ohetUid[%d] club_id[%d]  uid[%d]", st, ohetUid, club_id, uid);
	NETOutputPacket resPacket;
	resPacket.Begin(CLIENT_DISABLE_USER_GAME);
	resPacket.WriteInt(1);
	resPacket.End();
	CHallServer *pHallServer = GetHallServer(svid);
	if (pHallServer != NULL)
	{

		if (pHallServer->m_pSocketHandler != NULL)
		{
			SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);

		}
	}
}
int CGameServer::ProcessUpdateTablelist(int tid,int updateCode) {  //更新tablelist 桌子人数或者接关闭
	ServerList::iterator iterServer = m_ServerList.begin();
	for (; iterServer != m_ServerList.end(); iterServer++)
	{
		CLogicServer* pServer = iterServer->second;

		if (pServer != NULL)
		{

			
			TableList::iterator iterTable = pServer->m_TableList.find(tid);
			if (iterTable != pServer->m_TableList.end()) {
				CGameTable*& pTempTable = iterTable->second;
				if (pTempTable != NULL) {
					if (updateCode == 0) { //用户加入
						pTempTable->user_add_count++;
					}
					else if (updateCode == 1) {//用户退出
						pTempTable->user_add_count--;
					}
					else if (updateCode == 3) {  //桌子关闭
						pServer->m_TableList.erase(iterTable);
					}
					break;
				}
			}
			
		}

	}
	
	return 0;
}
int CGameServer::ProcessFastJoinTable(int uid, int svid, NETInputPacket* pPacket, SocketHandler* pSocket) {  //快速开始检测
	short level = pPacket->ReadShort();
	int club_id = pPacket->ReadInt();
	int configid = pPacket->ReadInt();
	ServerList::iterator iterServer = m_ServerList.begin();
	g_pDebugLog->logMsg("ProcessFastJoinTable-----pLogicServer->m_ServerList[%d]", m_ServerList.size());
	g_pDebugLog->logMsg("ProcessFastJoinTable-----level[%d]  club_id[%d] configid[%d]", level, club_id, configid);
	for (; iterServer != m_ServerList.end(); iterServer++)
	{
		CLogicServer* pServer = iterServer->second;

		if (pServer != NULL)
		{
			
			vector<TABLEINFO> vecTable;
			TableList::iterator iterTable = pServer->m_TableList.begin();
			for (; iterTable != pServer->m_TableList.end(); iterTable++)
			{
				CGameTable* pTempTable = iterTable->second;
				if (pTempTable != NULL)
				{
					if (pTempTable->club_id == club_id && pTempTable->m_nLevel == level && pTempTable->configId == configid) {
						g_pDebugLog->logMsg("pTempTable->user_add_count[%d]", pTempTable->user_add_count);
						if (pTempTable->user_add_count < pTempTable->max_plaery_count) {
							ProcessUserJoinGame(uid,  level, pTempTable->m_nTid, pTempTable->m_nBaseChip, pTempTable->m_activityID, 1,  svid, pSocket);
							return 0;
						}
					}
				}
			}
			break;
		}
		
	}
	NETOutputPacket resPacket;
	resPacket.Begin(CLIENT_CMD_JOIN_TABLE);
	resPacket.WriteShort(level);
	resPacket.WriteInt(club_id);
	resPacket.WriteInt(configid);
	resPacket.End();
	CHallServer* pHallServer = GetHallServer(svid);
	if (pHallServer != NULL)
	{

		if (pHallServer->m_pSocketHandler != NULL)
		{
			SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);

		}
	}
	return 0;
}
void CGameServer::ProcessRequireClubData(int uid, int svid, NETInputPacket * pPacket, SocketHandler * pSocket) {
	userOnClub[uid] = true;
	int club_id = pPacket->ReadInt();
	int groupTypeTemp = pPacket->ReadInt();
	int page = pPacket->ReadInt();
	int num = pPacket->ReadInt();
	int gmeType = pPacket->ReadInt();
	int configId = pPacket->ReadInt();
	string nickName = pPacket->ReadString();
	string portrait = pPacket->ReadString();
	userGroupType[uid] = groupTypeTemp;
	TableList tableList;
	if (page == 0) {
		userListTable[uid].clear();
	}
	g_pDebugLog->logMsg("club_id[%d]  uid[%d] cardJiFenList[%d] groupType[%d] gmeType[%d] configId[%d]", club_id, uid, cardJiFenList.size(), groupTypeTemp, gmeType, configId);
	map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupTypeTemp);
	if (cjList != cardJiFenList.end()) {
		clubTableList::iterator clbuIter = cjList->second.find(club_id);
		if (clbuIter != cjList->second.end()) {
			TableList &tableListTemp = clbuIter->second;
			for (TableList::iterator it = tableListTemp.begin(); it != tableListTemp.end(); it++) {
				CGameTable *pTable = it->second;
				if (pTable != NULL)
				{
					
					//g_pDebugLog->logMsg("iterLove");
					if (pTable->club_id == club_id) {
						if (userListTable[uid].size() > 0) {
							int flagId = std::count(userListTable[uid].begin(), userListTable[uid].end(), pTable->m_nTid);
							if (flagId > 0) {
								continue;
							}
						}
						if (gmeType > -1 && configId > -1) {
							if (pTable->configId == configId && pTable->gameType == gmeType) {
								tableList[pTable->m_nTid] = pTable;
							}
						}
						else if (gmeType > -1) {
							if (pTable->gameType == gmeType) {
								tableList[pTable->m_nTid] = pTable;
							}
						}
						else if (configId > -1) {
							if (pTable->configId == configId) {
								tableList[pTable->m_nTid] = pTable;
							}
						}
						else
						{
							tableList[pTable->m_nTid] = pTable;
						}
						
						
					}
				}
			}
		}
	}
	vector<CGameTable*> vtMpa;
	for (TableList::iterator it = tableList.begin(); it != tableList.end(); it++) {
		CGameTable* pTable = it->second;
		if (pTable!=NULL) {
			vtMpa.push_back(it->second);
		}
		
	}
	std::sort(vtMpa.begin(), vtMpa.end(), Less_Server_TableCount);
	int sumTable = vtMpa.size();
	int pageTable = page * num;
	
	int i_num = 0;
	
	for (int i = 0; i < sumTable; i++)
	{
		/*if (i >= (pageTable + num)) {
			break;
		}*/
		if (i >= num) {
			break;
		}
		CGameTable* pTable = vtMpa[i];
		
		if (pTable != NULL) {
			
			userListTable[uid].push_back(pTable->m_nTid);
			NETOutputPacket resPacketPP;
			resPacketPP.Begin(TABLE_DATA_TEST);
			resPacketPP.WriteInt(pTable->club_id);
			resPacketPP.WriteInt(pTable->typeTable);
			resPacketPP.WriteInt(pTable->m_nTid);

			resPacketPP.WriteInt(pTable->m_nLevel);
			resPacketPP.WriteInt(pTable->configId);
			resPacketPP.WriteInt(pTable->gameType);
			resPacketPP.WriteInt(pTable->currRound);
			vector<string> userList;
			for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
			{
				userList.push_back(itTemp->second);
			}
			resPacketPP.WriteByte(userList.size());
			for (int i = 0; i < userList.size(); i++)
			{
				resPacketPP.WriteString(userList[i].c_str());
			}
			//for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
			//{
			//	//nUserCount++;
			//	resPacket.WriteString(itTemp->second.c_str());
			//}
			//resPacketPP.WriteString(pTable->jsonConfig.c_str());
			resPacketPP.WriteString(pTable->groupName.c_str());
			resPacketPP.WriteString(pTable->m_strInviteCode.c_str());
			resPacketPP.End();
			CHallServer* pHallServer = GetHallServer(svid);
			if (pHallServer != NULL)
			{

				if (pHallServer->m_pSocketHandler != NULL)
				{
					
					SendClientPacket(uid, svid, &resPacketPP, pHallServer->m_pSocketHandler);

				}
			}
		}
	}
	

	/*g_pDebugLog->logMsg("club_id[%d]  uid[%d] m_clubTableList[%d]", club_id, uid, m_clubTableList.size());
	clubTableList::iterator clbuIter = m_clubTableList.find(club_id);
	if (clbuIter != m_clubTableList.end()) {
		TableList &tableListTemp = clbuIter->second;
		for (TableList::iterator it = tableListTemp.begin(); it != tableListTemp.end(); it++) {
			CGameTable *pTable = it->second;
			if (pTable != NULL)
			{
				g_pDebugLog->logMsg("iterLove");
				if (pTable->club_id == club_id) {
					tableList[pTable->m_nTid] = pTable;

				}
			}
		}
	}*/
	
	//g_pDebugLog->logMsg("CGameTable svid[%d]", svid);
	NETOutputPacket resPacket;
	resPacket.Begin(TABLE_DATA);
	resPacket.WriteByte(1);
	resPacket.WriteByte(0);
	/*for (TableList::iterator it = tableList.begin(); it != tableList.end(); it++)
	{
		CGameTable *pTable = it->second;
		if (pTable != NULL) {
			g_pDebugLog->logMsg("CGameTable *table = *it");
			resPacket.WriteInt(pTable->m_nTid);
			resPacket.WriteInt(pTable->club_id);
			resPacket.WriteShort(pTable->m_nLevel);
			resPacket.WriteByte(pTable->isStart);
			resPacket.WriteByte(pTable->max_plaery_count);
			resPacket.WriteInt(pTable->gameType);
			resPacket.WriteInt(pTable->configId);
			resPacket.WriteString(pTable->jsonConfig.c_str());
			resPacket.WriteString(pTable->groupName.c_str());
			resPacket.WriteByte(pTable->userList.size());
			for (map<int,string>::iterator itTemp = pTable->userList.begin();itTemp!= pTable->userList.end(); itTemp++)
			{
				resPacket.WriteString(itTemp->second.c_str());
			}
		}
	}*/
	resPacket.End();
	CHallServer *pHallServer = GetHallServer(svid);
	if (pHallServer != NULL)
	{

		if (pHallServer->m_pSocketHandler != NULL)
		{
			SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
			
		}
	}
	//map<int, int> testTid;
	//for (TableList::iterator it = tableList.begin(); it != tableList.end(); it++)
	//{
	//	CGameTable *pTable = it->second;
	//	if (pTable != NULL) {
	//		NETOutputPacket resPacketPP;
	//		resPacketPP.Begin(TABLE_DATA_TEST);
	//		resPacketPP.WriteInt(pTable->club_id);
	//		resPacketPP.WriteInt(0);
	//		resPacketPP.WriteInt(pTable->m_nTid);
	//	
	//		resPacketPP.WriteInt(pTable->m_nLevel);
	//		resPacketPP.WriteInt(pTable->configId);
	//		resPacketPP.WriteInt(pTable->gameType);
	//		resPacketPP.WriteInt(pTable->currRound);
	//		vector<string> userList;
	//		for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//		{
	//			userList.push_back(itTemp->second);
	//		}
	//		resPacketPP.WriteByte(userList.size());
	//		for (int i = 0; i < userList.size(); i++)
	//		{
	//			resPacketPP.WriteString(userList[i].c_str());
	//		}
	//		//for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//		//{
	//		//	//nUserCount++;
	//		//	resPacket.WriteString(itTemp->second.c_str());
	//		//}
	//		//resPacketPP.WriteString(pTable->jsonConfig.c_str());
	//		resPacketPP.WriteString(pTable->groupName.c_str());
	//		resPacketPP.End();
	//		CHallServer *pHallServer = GetHallServer(svid);
	//		if (pHallServer != NULL)
	//		{

	//			if (pHallServer->m_pSocketHandler != NULL)
	//			{
	//				testTid[pTable->m_nTid] = pTable->m_nTid;
	//				SendClientPacket(uid, svid, &resPacketPP, pHallServer->m_pSocketHandler);

	//			}
	//		}
	//	}
	//}
	//testTid.clear();
	//if (tableTempList.find(club_id) != tableTempList.end()) {
	//	vector<CGameTable*> vtMpa2;
	//	for (TableList::iterator itr = tableTempList.find(club_id)->second.begin(); itr != tableTempList.find(club_id)->second.end(); itr++)
	//	{
	//		vtMpa2.push_back(itr->second);
	//	}
	//	std::sort(vtMpa2.begin(), vtMpa2.end(), Less_Server_TableCount);
	//	int sumTable2 = vtMpa2.size();
	//	int pageTable2 = page * num;

	//	int i_num = 0;

	//	for (int i = pageTable2; i < sumTable2; i++)
	//	{
	//		if (i >= (pageTable2 + num)) {
	//			break;
	//		}
	//		CGameTable* pTable = vtMpa2[i];
	//		if (pTable != NULL) {
	//			NETOutputPacket resPacketPP;
	//			resPacketPP.Begin(TABLE_DATA_TEST);
	//			resPacketPP.WriteInt(pTable->club_id);
	//			resPacketPP.WriteInt(1);
	//			resPacketPP.WriteInt(pTable->m_nTid);

	//			resPacketPP.WriteInt(pTable->m_nLevel);
	//			resPacketPP.WriteInt(pTable->configId);
	//			resPacketPP.WriteInt(pTable->gameType);
	//			resPacketPP.WriteInt(pTable->currRound);

	//			vector<string> userList;
	//			for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//			{
	//				userList.push_back(itTemp->second);
	//			}
	//			resPacketPP.WriteByte(userList.size());
	//			for (int i = 0; i < userList.size(); i++)
	//			{
	//				resPacketPP.WriteString(userList[i].c_str());
	//			}
	//			//for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//			//{
	//			//	//nUserCount++;
	//			//	resPacket.WriteString(itTemp->second.c_str());
	//			//}
	//			//resPacketPP.WriteString(pTable->jsonConfig.c_str());
	//			resPacketPP.WriteString(pTable->groupName.c_str());
	//			resPacketPP.End();
	//			CHallServer* pHallServer = GetHallServer(svid);
	//			if (pHallServer != NULL)
	//			{

	//				if (pHallServer->m_pSocketHandler != NULL)
	//				{
	//					SendClientPacket(uid, svid, &resPacketPP, pHallServer->m_pSocketHandler);
	//				}
	//			}
	//		}
	//	}
	//	//for (TableList::iterator itr = tableTempList.find(club_id)->second.begin(); itr != tableTempList.find(club_id)->second.end(); itr++)
	//	//{
	//	//	CGameTable *pTable = itr->second;
	//	//	if (pTable != NULL) {
	//	//		NETOutputPacket resPacketPP;
	//	//		resPacketPP.Begin(TABLE_DATA_TEST);
	//	//		resPacketPP.WriteInt(pTable->club_id);
	//	//		resPacketPP.WriteInt(1);
	//	//		resPacketPP.WriteInt(pTable->m_nTid);
	//	//		
	//	//		resPacketPP.WriteInt(pTable->m_nLevel);
	//	//		resPacketPP.WriteInt(pTable->configId);
	//	//		resPacketPP.WriteInt(pTable->gameType);
	//	//		resPacketPP.WriteInt(pTable->currRound);

	//	//		vector<string> userList;
	//	//		for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//	//		{
	//	//			userList.push_back(itTemp->second);
	//	//		}
	//	//		resPacketPP.WriteByte(userList.size());
	//	//		for (int i = 0; i < userList.size(); i++)
	//	//		{
	//	//			resPacketPP.WriteString(userList[i].c_str());
	//	//		}
	//	//		//for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//	//		//{
	//	//		//	//nUserCount++;
	//	//		//	resPacket.WriteString(itTemp->second.c_str());
	//	//		//}
	//	//		//resPacketPP.WriteString(pTable->jsonConfig.c_str());
	//	//		resPacketPP.WriteString(pTable->groupName.c_str());
	//	//		resPacketPP.End();
	//	//		CHallServer *pHallServer = GetHallServer(svid);
	//	//		if (pHallServer != NULL)
	//	//		{

	//	//			if (pHallServer->m_pSocketHandler != NULL)
	//	//			{
	//	//				SendClientPacket(uid, svid, &resPacketPP, pHallServer->m_pSocketHandler);
	//	//			}
	//	//		}
	//	//	}
	//	//}
	//}
	
}

int CGameServer::ProcessRequireIpAndPort(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket)
{
    short serverId = pPacket->ReadShort();
    CLogicServer *pServer = GetServer(serverId);
    if(pServer != NULL)
    {
        NETOutputPacket resPacket;
        resPacket.Begin(CMD_REQUIRE_IP_PORT);
        resPacket.WriteString(pServer->m_strIp.c_str());
        resPacket.WriteInt(pServer->m_nPort);
        resPacket.WriteInt(pServer->m_nLevel);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);

#ifndef WIN32
        g_pDebugLog->logMsg("ProcessRequireIpAndPort||uid:[%d],serverId:[%hd],ip:[%s],port:[%d]", uid, serverId, pServer->m_strIp.c_str(), pServer->m_nPort);
#endif
    }
    else
    {
        NETOutputPacket resPacket;
        resPacket.Begin(CMD_REQUIRE_IP_PORT);
        resPacket.WriteString("");
        resPacket.WriteInt(0);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
    }
    return 0;
}

CLogicServer* CGameServer::GetServer(short serverId)
{
    CLogicServer *pServer = NULL;
	g_pDebugLog->logMsg("GetServer serverId[%d]", serverId);
    ServerList::iterator iterServer = m_ServerList.find(serverId);
    if(iterServer != m_ServerList.end())
    {
        pServer = iterServer->second;
    }
    return pServer;
}


int CGameServer::ProcessGetNewRoom(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket)
{
    short level = pPacket->ReadShort();
    short serverId = pPacket->ReadShort();
    /*if(level != m_nLevel)
    {
    #ifndef WIN32
            g_pErrorLog->logMsg("ProcessGetNewRoom||level error, uid:[%d], level:[%d]", uid, level);
    #endif
            return 0;
    }*/

    int tid = 0;
    CLogicServer *pServer = GetServer(serverId);
    if(pServer != NULL)
    {
        if(pServer->m_nRetire == 0)
        {
            CGameTable *pTable = GetGameRoom(pServer);
            if(pTable != NULL)
            {
                tid = pTable->m_nTid;
                pTable->m_nUserCount++;
            }
        }

        NETOutputPacket resPacket;
        resPacket.Begin(CMD_GET_NEW_ROOM);
        resPacket.WriteInt(tid);
        resPacket.WriteString(pServer->m_strIp.c_str());
        resPacket.WriteInt(pServer->m_nPort);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
    }
    return 0;
}

int CGameServer::ProcessUserJoinGame(int uid, int level, int tid, int baseChip, int activityID, int isWatch,int svid, SocketHandler* pSocket){
	if (level == 0)
	{
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_PASSWORD);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket);
		return 0;
	}
	
	map<int, int>::iterator serverIter = m_GroupServerDict.find(tid);
	if (serverIter == m_GroupServerDict.end())
	{
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		g_pDebugLog->logMsg("CGameServer serverIter == pGameServer->m_GroupServerDict\n");
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_ROOM_NOT_EXIST);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket);
		return 0;

	}

	int serverID = serverIter->second;
	CLogicServer* logicServer = GetServer(serverID);
	if (logicServer == NULL) {
		g_pDebugLog->logMsg("--------NULL");
	}
	CGameTable* pTable = logicServer->GetTable(tid);
	if (NULL == pTable) {
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		g_pDebugLog->logMsg("----------(activityID == 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())\n");
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_ROOM_NOT_EXIST);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket);
		return 0;
	}
	if (activityID == 0) {

		activityID = pTable->m_activityID;


	}
	if (activityID != 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())
	{
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		g_pDebugLog->logMsg("----------(activityID == 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())\n");
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_ROOM_NOT_EXIST);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket);
		return 0;
	}
	Json::Reader json_reader;
	Json::Value root;
	int joinGamePoint = 0;
	int readyPoint = 0;
	int maxSeatCount = 0;
	//g_pDebugLog->logMsg("pTable->jsonConfig %s", pTable->jsonConfig.c_str());
	if (json_reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
	{
		if (!root["joinGamePoint"].isNull() && root["joinGamePoint"].isInt())
		{
			joinGamePoint = root["joinGamePoint"].asInt();
		}
		if (!root["readyPoint"].isNull() && root["readyPoint"].isInt())
		{
			readyPoint = root["readyPoint"].asInt();

		}
		if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
		{
			maxSeatCount = root["maxSeatCount"].asInt();

		}
	}
	string tempStr;

	int SIS = m_pRedisManagerClient->GET_SISMEMBER_USER(pTable->club_id, uid);//是否有同桌限制
	if (SIS > 0) {
		for (vector<int>::iterator itre = m_Table_PlayerSit[tid].begin(); itre != m_Table_PlayerSit[tid].end(); itre++)
		{
			int SIS_FIND = m_pRedisManagerClient->GET_SISMEMBER(pTable->club_id, uid, (*itre));
			if (SIS_FIND > 0) {
				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_USER_SISMEMBER);
				resPacket.End();
				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;
			}
		}
	}
	int retRed = m_pRedisManagerClient->GET_DISABLE_USER(pTable->club_id, uid, tempStr);
	//g_pDebugLog->logMsg("GET_DISABLE_USER  retRed[%d]  %s", retRed, tempStr.c_str());
	if (retRed > 0) {
		int status_ret = atoi(tempStr.c_str());
		//g_pDebugLog->logMsg("GET_DISABLE_USER  status_ret[%d] uid %d  pTable->club_id[%d]", status_ret,uid, pTable->club_id);
		if (status_ret == 1) {  //1的话锁定用户
			NETOutputPacket resPacket;
			resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
			resPacket.WriteShort(0);
			resPacket.WriteShort(ERROR_USER_DISABLE);
			resPacket.End();
			SendClientPacket(uid, svid, &resPacket, pSocket);
			return 0;
		}
	}
	if (groupType != 3) {
		if (GET_USER_GAME_STATUS(uid) <= 0 && isWatch == 1) {
			map<int, vector<int> >::iterator PlayerSit = m_Table_PlayerSit.find(tid);
			int chips = getUserChips(pTable->club_id, uid);
			if ((readyPoint > chips || joinGamePoint > chips)) {
				if (m_nLevel > 2) {
					NETOutputPacket resPacketTemp;
					resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
					resPacketTemp.WriteInt(uid);
					resPacketTemp.End();
					if (allocServer) {
						allocServer->Send(&resPacketTemp);
					}
				}
				g_pDebugLog->logMsg("----------(activityID == 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())\n");

				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_JOIN_CHIPS);
				resPacket.End();

				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;

			}
			if (PlayerSit->second.size() >= maxSeatCount) {
				if (m_nLevel > 2) {
					NETOutputPacket resPacketTemp;
					resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
					resPacketTemp.WriteInt(uid);
					resPacketTemp.End();
					if (allocServer) {
						allocServer->Send(&resPacketTemp);
					}
				}
				//g_pDebugLog->logMsg("2222itTid->[%d]  maxSeatCount[%d] itTid->first[%d]", PlayerSit->second.size(), maxSeatCount, PlayerSit->first);
				/*for (int i = 0; i < PlayerSit->second.size(); i++)
				{
					g_pDebugLog->logMsg("PlayerSit->secon[%d]", PlayerSit->second[i]);
				}*/
				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_MAX_USERCOUNT);
				resPacket.End();
				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;
			}
		}
	}
	else {
		if (GET_USER_GAME_STATUS(uid) <= 0 && isWatch == 1) {
			map<int, vector<int> >::iterator PlayerSit = m_Table_PlayerSit.find(tid);
			if (PlayerSit->second.size() >= maxSeatCount) {
				if (m_nLevel > 2) {
					NETOutputPacket resPacketTemp;
					resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
					resPacketTemp.WriteInt(uid);
					resPacketTemp.End();
					if (allocServer) {
						allocServer->Send(&resPacketTemp);
					}
				}
				//g_pDebugLog->logMsg("PlayerSit->[%d]  maxSeatCount[%d] PlayerSit->first[%d]", PlayerSit->second.size(), maxSeatCount, PlayerSit->first);
				/*for (int i = 0; i < PlayerSit->second.size(); i++)
				{
					g_pDebugLog->logMsg("PlayerSit->secon[%d]", PlayerSit->second[i]);
				}*/

				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_MAX_USERCOUNT);
				resPacket.End();
				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;
			}
		}
	}
	userIpMap[uid] = 0;
	m_GroupTidCreatorDict[uid] = tid;
	NETOutputPacket resPacket;
	resPacket.Begin(SERVER_CMD_JOIN_GAME);
	resPacket.WriteInt(tid);
	//resPacket.WriteByte(isWatch);
	resPacket.WriteShort(serverID);
	resPacket.WriteString(logicServer->m_strIp.c_str());
	resPacket.WriteInt(logicServer->m_nPort);
	resPacket.WriteInt(svid);
	resPacket.WriteShort(level);
	resPacket.WriteByte(pTable->max_plaery_count);
	resPacket.WriteInt(pTable->m_activityID);
	resPacket.WriteString(pTable->jsonConfig.c_str());
	resPacket.WriteString(pTable->m_strPassword.c_str());
	resPacket.WriteByte(isWatch);
	resPacket.End();
	status_Watch[uid] = isWatch;
	//g_pDebugLog->logMsg("SERVER_CMD_JOIN_GAME svid [%d]", svid);
	CHallServer* pHallServer = GetHallServer(svid);


	//printf("----------------CGameServer::ProcessUserJoinGameffff:activityID [%d] uid[%d] svid [%d] tid[%d] serverId[%d] ip[%s] port[%d] res[%d] level[%d] pHallServer[%p]\n", activityID, uid, svid, tid, serverId, ip.c_str(), port, res, level, pHallServer);
	//fflush(stdout);

	if (pHallServer != NULL)
	{
		//printf("----------------pHallServer->m_pSocketHandler uid[%d] m_pSocketHandler[%p]\n", uid, pHallServer->m_pSocketHandler);
		//fflush(stdout);

		if (pHallServer->m_pSocketHandler != NULL)
		{
			SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
		}
	}
}
int CGameServer::ProcessUserJoinGame(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket, int ip)
{

    short level = pPacket->ReadShort();

    if(level == 0)
    {
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
        resPacket.WriteShort(0);
        resPacket.WriteShort(ERROR_PASSWORD);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }

    int chip = pPacket->ReadInt();
    int sid = pPacket->ReadInt();
	//string cur_activityID = pPacket->ReadInt();

	
	int tid = pPacket->ReadInt();
	int activityID = pPacket->ReadInt();
	int baseChip = pPacket->ReadInt();
	int isWatch = pPacket->ReadByte();
	int juli = pPacket->ReadInt();
	string latitude = pPacket->ReadString();
	string longitude = pPacket->ReadString();
	g_pDebugLog->logMsg("svid %d", svid);
	g_pDebugLog->logMsg("ProcessUserJoinGame|| level[%d] uid[%d] chip[%d] sid[%d] cur_activityID[%d] tid[%d] isWatch[%d]latitude %s Longitude %s juli%d", level, uid, chip, sid, activityID, tid, isWatch, latitude.c_str(), longitude.c_str(), juli);
	map<int, int>::iterator serverIter = m_GroupServerDict.find(tid);
	if (serverIter == m_GroupServerDict.end())
	{
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		g_pDebugLog->logMsg("CGameServer serverIter == pGameServer->m_GroupServerDict\n");
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_ROOM_NOT_EXIST);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket); 
		return 0;
		
	}

	int serverID = serverIter->second;
	CLogicServer *logicServer = GetServer(serverID);
	if (logicServer == NULL) {
		g_pDebugLog->logMsg("--------NULL");
	}
	CGameTable * pTable = logicServer->GetTable(tid);
	if (NULL == pTable) {
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		g_pDebugLog->logMsg("----------(activityID == 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())\n");
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_ROOM_NOT_EXIST);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket);
		return 0;
	}
	if (activityID == 0) {
		
		activityID = pTable->m_activityID;


	}
	/*if (cur_activityID.length() == 0)
	{
		activityID = 0;
	}
	else
	{
		activityID = atoi(cur_activityID.c_str());
	}
*/
	g_pDebugLog->logMsg("----------CGameServer::ProcessUserJoinGame--xxxxxxxxxxxxxxx-[%d][%d]\n", uid, activityID);
	
	if (activityID != 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())
	{
		if (m_nLevel > 2) {
			NETOutputPacket resPacketTemp;
			resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
			resPacketTemp.WriteInt(uid);
			resPacketTemp.End();
			if (allocServer) {
				allocServer->Send(&resPacketTemp);
			}
		}
		g_pDebugLog->logMsg("----------(activityID == 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())\n");
		NETOutputPacket resPacket;
		resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
		resPacket.WriteShort(0);
		resPacket.WriteShort(ERROR_ROOM_NOT_EXIST);
		resPacket.End();
		SendClientPacket(uid, svid, &resPacket, pSocket);
		return 0;
	}
	Json::Reader json_reader;
	Json::Value root;
	int joinGamePoint = 0;
	int readyPoint = 0;
	int maxSeatCount = 0;
	//g_pDebugLog->logMsg("pTable->jsonConfig %s", pTable->jsonConfig.c_str());
	if (json_reader.parse(pTable->jsonConfig, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
	{
		if (!root["joinGamePoint"].isNull() && root["joinGamePoint"].isInt())
		{
			joinGamePoint = root["joinGamePoint"].asInt();
		}
		if (!root["readyPoint"].isNull() && root["readyPoint"].isInt())
		{
			readyPoint = root["readyPoint"].asInt();

		}
		if (!root["maxSeatCount"].isNull() && root["maxSeatCount"].isInt())
		{
			maxSeatCount = root["maxSeatCount"].asInt();

		}
	}
	string tempStr;

	int SIS = m_pRedisManagerClient->GET_SISMEMBER_USER(pTable->club_id, uid);//是否有同桌限制
	if (SIS > 0) {
		for (vector<int>::iterator itre = m_Table_PlayerJoin[tid].begin(); itre != m_Table_PlayerJoin[tid].end(); itre++)
		{
			int SIS_FIND = m_pRedisManagerClient->GET_SISMEMBER(pTable->club_id, uid, (*itre));
			if (SIS_FIND > 0) {
				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_USER_SISMEMBER);
				resPacket.End();
				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;
			}
		}
	}
	int retRed = m_pRedisManagerClient->GET_DISABLE_USER(pTable->club_id, uid, tempStr);
	//g_pDebugLog->logMsg("GET_DISABLE_USER  retRed[%d]  %s", retRed, tempStr.c_str());
	if (retRed > 0) {
		int status_ret = atoi(tempStr.c_str());
		//g_pDebugLog->logMsg("GET_DISABLE_USER  status_ret[%d] uid %d  pTable->club_id[%d]", status_ret,uid, pTable->club_id);
		if (status_ret == 1) {  //1的话锁定用户
			NETOutputPacket resPacket;
			resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
			resPacket.WriteShort(0);
			resPacket.WriteShort(ERROR_USER_DISABLE);
			resPacket.End();
			SendClientPacket(uid, svid, &resPacket, pSocket);
			return 0;
		}
	}
	if (groupType != 3) {
		if (GET_USER_GAME_STATUS(uid) <= 0 && isWatch == 1) {
			map<int, vector<int> >::iterator PlayerSit = m_Table_PlayerSit.find(tid);
			int chips = getUserChips(pTable->club_id, uid);
			if ((readyPoint > chips || joinGamePoint > chips)) {
				if (m_nLevel > 2) {
					NETOutputPacket resPacketTemp;
					resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
					resPacketTemp.WriteInt(uid);
					resPacketTemp.End();
					if (allocServer) {
						allocServer->Send(&resPacketTemp);
					}
				}
				g_pDebugLog->logMsg("----------(activityID == 0 && m_GroupTableDict.find(activityID) == m_GroupTableDict.end())\n");
				
				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_JOIN_CHIPS);
				resPacket.End();

				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;

			}
			if (PlayerSit->second.size() >= maxSeatCount) {
				if (m_nLevel > 2) {
					NETOutputPacket resPacketTemp;
					resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
					resPacketTemp.WriteInt(uid);
					resPacketTemp.End();
					if (allocServer) {
						allocServer->Send(&resPacketTemp);
					}
				}
				//g_pDebugLog->logMsg("2222itTid->[%d]  maxSeatCount[%d] itTid->first[%d]", PlayerSit->second.size(), maxSeatCount, PlayerSit->first);
				/*for (int i = 0; i < PlayerSit->second.size(); i++)
				{
					g_pDebugLog->logMsg("PlayerSit->secon[%d]", PlayerSit->second[i]);
				}*/
				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_MAX_USERCOUNT);
				resPacket.End();
				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;
			}
		}
	}
	else {
		if (GET_USER_GAME_STATUS(uid) <= 0 && isWatch == 1) {
			map<int, vector<int> >::iterator PlayerSit = m_Table_PlayerSit.find(tid);
			if (PlayerSit->second.size() >= maxSeatCount) {
				if (m_nLevel > 2) {
					NETOutputPacket resPacketTemp;
					resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
					resPacketTemp.WriteInt(uid);
					resPacketTemp.End();
					if (allocServer) {
						allocServer->Send(&resPacketTemp);
					}
				}
				//g_pDebugLog->logMsg("PlayerSit->[%d]  maxSeatCount[%d] PlayerSit->first[%d]", PlayerSit->second.size(), maxSeatCount, PlayerSit->first);
				/*for (int i = 0; i < PlayerSit->second.size(); i++)
				{
					g_pDebugLog->logMsg("PlayerSit->secon[%d]", PlayerSit->second[i]);
				}*/
				
				NETOutputPacket resPacket;
				resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
				resPacket.WriteShort(0);
				resPacket.WriteShort(ERROR_MAX_USERCOUNT);
				resPacket.End();
				SendClientPacket(uid, svid, &resPacket, pSocket);
				return 0;
			}
		}
	}
	if (juli > 0) {
		map<int, map<int, distanceInfo> >::iterator ireDis = m_Table_Distance.find(tid);
		if (ireDis != m_Table_Distance.end()) {
			double la1 = atof(latitude.c_str());
			double lo1 = atof(longitude.c_str());
			g_pDebugLog->logMsg("latitude %f", la1);

			for (map<int, distanceInfo>::iterator iter = ireDis->second.begin(); iter != ireDis->second.end(); iter++) {
				double la2 = atof(iter->second.Latitude.c_str());
				double lo2 = atof(iter->second.Longitude.c_str());
				double juli2 = calculateDistanceInfo(la1, lo1, la2, lo2);
				g_pDebugLog->logMsg("juli2 %f ,,, juli %d", juli2, juli);
				if (juli2 < juli) {
					if (m_nLevel > 2) {
						NETOutputPacket resPacketTemp;
						resPacketTemp.Begin(SERVER_GROUP_ROBOT_LOGIN);
						resPacketTemp.WriteInt(uid);
						resPacketTemp.End();
						if (allocServer) {
							allocServer->Send(&resPacketTemp);
						}
					}
					g_pDebugLog->logMsg("juli2 %f ,,, juli %d", juli2, juli);
					NETOutputPacket resPacket;
					resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
					resPacket.WriteShort(0);
					resPacket.WriteShort(ERROR_USER_JULI);
					resPacket.End();
					SendClientPacket(uid, svid, &resPacket, pSocket);
					return 0;
				}
				g_pDebugLog->logMsg("juli2 %f ,,, juli %d", juli2, juli);
			}
			distanceInfo dInfo;
			dInfo.Latitude = latitude;
			dInfo.Longitude = longitude;

			m_Table_Distance[tid][uid] = dInfo;
		}
	}
	map<int, distanceInfo> distance;
	distanceInfo dInfo;
	dInfo.Latitude = latitude;
	dInfo.Longitude = longitude;
	distance[uid] = dInfo;
	double la1 = atof(latitude.c_str());

	g_pDebugLog->logMsg("latitude %f", la1);
	m_Table_Distance[tid] = distance;
	if (std::count(m_Table_PlayerJoin[tid].begin(), m_Table_PlayerJoin[tid].end(), uid) <= 0) {
		m_Table_PlayerJoin[tid].push_back(uid);
	}
	m_pRedisManagerClient->HSET_USER_STATUS(uid, m_nLevel, tid, activityID);
	userIpMap[uid] = ip;
	m_GroupTidCreatorDict[uid] = tid;
	NETOutputPacket resPacket;
	resPacket.Begin(SERVER_CMD_JOIN_GAME);
	resPacket.WriteInt(tid);
	//resPacket.WriteByte(isWatch);
	resPacket.WriteShort(serverID);
	resPacket.WriteString(logicServer->m_strIp.c_str());
	resPacket.WriteInt(logicServer->m_nPort);
	resPacket.WriteInt(svid);
	resPacket.WriteShort(level);
	resPacket.WriteByte(pTable->max_plaery_count);
	resPacket.WriteInt(pTable->m_activityID);
	resPacket.WriteString(pTable->jsonConfig.c_str());
	resPacket.WriteString(pTable->m_strPassword.c_str());
	resPacket.WriteByte(isWatch);
	resPacket.End();
	status_Watch[uid] = isWatch;
	//g_pDebugLog->logMsg("SERVER_CMD_JOIN_GAME svid [%d]", svid);
	CHallServer *pHallServer = GetHallServer(svid);


	//printf("----------------CGameServer::ProcessUserJoinGameffff:activityID [%d] uid[%d] svid [%d] tid[%d] serverId[%d] ip[%s] port[%d] res[%d] level[%d] pHallServer[%p]\n", activityID, uid, svid, tid, serverId, ip.c_str(), port, res, level, pHallServer);
	//fflush(stdout);

	if (pHallServer != NULL)
	{
		//printf("----------------pHallServer->m_pSocketHandler uid[%d] m_pSocketHandler[%p]\n", uid, pHallServer->m_pSocketHandler);
		//fflush(stdout);

		if (pHallServer->m_pSocketHandler != NULL)
		{
			SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
		}
	}
    //先去请求UserServer，用户是否存在桌子
//    NETOutputPacket reqPacket;
//    reqPacket.Begin(SYS_GET_USER_TABLE);
//    reqPacket.WriteInt(uid);
//    reqPacket.WriteInt(svid);//大厅server id
//    reqPacket.WriteShort(level);
//    reqPacket.WriteInt(sid);
//	reqPacket.WriteInt(activityID);
//	reqPacket.WriteInt(ip);
//    reqPacket.End();
//
//	g_pDebugLog->logMsg("----------CGameServer::ProcessUserJoinGame----[%d][%d][%d]\n", uid, activityID, ip);
//
//    int userServerId = uid%(int)m_UserServerList.size();
//    CUserServer* pUserServer = GetUserServer(userServerId);
//    if(pUserServer != NULL)
//    {
//        pUserServer->TransferPacket(&reqPacket);
//    }
//    else
//    {
//#ifndef WIN32
//        g_pErrorLog->logMsg("ProcessUserJoinGame||pUserServer==NULL,uid:[%d]", uid);
//#endif
//    }
    return 0;
}

int CGameServer::ProcessUserJoinMatch(int uid, int svid, short level, SocketHandler* pSocket)
{
//    short level = pPacket->ReadShort();
 //   int chip = pPacket->ReadInt();
//    (void)chip;
//    int sid = pPacket->ReadInt();
    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessUserJoinMatch||level!=m_nLevel, level:[%d], m_nLevel:[%d]", level, m_nLevel);
#endif
        return 0;
    }

    int matchid = 0;
    short serverId = 0;
    string ip = "";
    int port = 0;
    GetQuiteMatchRoom(level, matchid, serverId);
    CGameMatch* pMatch = GetMatch(matchid);
    if (NULL != pMatch)
    {
        CLogicServer *pServer = GetServer(serverId);
        if(NULL != pServer)
        {
            pServer->m_nUserCount++;
            ip = pServer->m_strIp;
            port = pServer->m_nPort;
            pMatch->m_nCurrentNum++;
        }
    }
    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_JOIN_MATCH);
    resPacket.WriteInt(matchid);
    resPacket.WriteShort(serverId);
    resPacket.WriteString(ip.c_str());
    resPacket.WriteInt(port);
    resPacket.End();
    SendClientPacket(uid, svid, &resPacket, pSocket);
    return 0;
}

int CGameServer::ProcessUserJoinHuodongMatch(int uid, int svid, short level, SocketHandler *pSocket)//处理用户进入活动赛
{
//    short level = pPacket->ReadShort();


    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessUserJoinHuodongMatch||level!=m_nLevel, level:[%d], m_nLevel:[%d]", level, m_nLevel);
#endif
        return 0;
    }

    int matchId = 0;
    short serverId = 0;
    string ip = "";
    int port = 0;
    GetHuodongMatchRoom(level, matchId, serverId);
    CLogicServer *pServer = GetServer(serverId);
    if(NULL != pServer)
    {
        pServer->m_nUserCount++;
        ip = pServer->m_strIp;
        port = pServer->m_nPort;
    }
    matchId = (level<<16);

    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_JOIN_MATCH);
    resPacket.WriteInt(matchId);
    resPacket.WriteShort(serverId);
    resPacket.WriteString(ip.c_str());
    resPacket.WriteInt(port);
    resPacket.End();

    SendClientPacket(uid, svid, &resPacket, pSocket);
    return 0;

}


CHallServer* CGameServer::GetHallServer(int svid)
{
    CHallServer *pSever = NULL;
	/*g_pDebugLog->logMsg("m_HallServerList.size(%d)", m_HallServerList.size());
	g_pDebugLog->logMsg("GetHallServer svid [%d]", svid);*/
    HallServerList::iterator iter = m_HallServerList.find(svid);
    if(iter != m_HallServerList.end())
    {
        pSever = iter->second;
    }
    return pSever;
}

int CGameServer::ProcessUserTable(NETInputPacket *pPacket)
{
	int uid = pPacket->ReadInt();
	int svid = pPacket->ReadInt();
	int cmd = pPacket->ReadInt();
	short flag = pPacket->ReadShort();
	int res = pPacket->ReadInt();

	g_pDebugLog->logMsg("ProcessUserTable|| uid[%d] svid[%d] cmd[%x] flag[%d] res[%d]", uid, svid, cmd, flag, res);

	//重练用户
	if(res == 1)
	{
		int onlookId = pPacket->ReadInt();
        int tid = pPacket->ReadInt();
        short serverId = pPacket->ReadShort();
        string ip = pPacket->ReadString();
        int port = pPacket->ReadInt();
        short serverLevel = pPacket->ReadShort();
		int type = pPacket->ReadInt();

		NETOutputPacket resPacket;
        //围观玩家重连
        if(onlookId > 0)
        {
            resPacket.Begin(SERVER_ONLOOK_ENTER_ROOM);

        }
        else
        {
            resPacket.Begin(SERVER_CMD_JOIN_MATCH);
        }
        resPacket.WriteInt(tid);
        resPacket.WriteShort(serverId);
        resPacket.WriteString(ip.c_str());
        resPacket.WriteInt(port);
        //新增扩张信息
        resPacket.WriteInt(res);
        resPacket.WriteShort(serverLevel);
        if(onlookId > 0)
        {
            resPacket.WriteInt(onlookId); //被围观玩家ID
        }

		
		resPacket.WriteInt(type);
		
        resPacket.End();
        CHallServer *pHallServer = GetHallServer(svid);
        if(pHallServer != NULL)
        {
            if(pHallServer->m_pSocketHandler != NULL)
            {
                SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
            }
        }
	}
	else
	{

		
		CHallServer *pHallServer = GetHallServer(svid);
		if(pHallServer == NULL)
		{
			g_pErrorLog->logMsg("%s|  HallServer == NULL", __FUNCTION__);
		}
		short level = pPacket->ReadShort();
		switch(cmd)
		{
		case 0x120:
			{
				if(flag == 1)
				{
					ProcessUserJoinMatch(uid, svid, level, pHallServer->m_pSocketHandler);				
				}
				else if(flag == 2)
				{
					ProcessUserApplyMatch(uid, svid, level, pHallServer->m_pSocketHandler);
				}
				else if(flag == 3)
				{
					ProcessUserJoinHuodongMatch(uid, svid, level, pHallServer->m_pSocketHandler);
				}
			}
			
			break;
		case 0x121:
			break;
		case 0x122:
			break;
		default:
			g_pErrorLog->logMsg("unkonw cmd[%x] ", cmd);
			break;
		}
	}
	
}



int CGameServer::ProcessUserJoinGame(NETInputPacket *pPacket)
{
    int uid = pPacket->ReadInt();
    int svid = pPacket->ReadInt();
    int res = pPacket->ReadInt();

	g_pDebugLog->logMsg("------------------------ProcessUserJoinGame uid[%d] svid[%d] res[%d]", uid, svid, res);

	//printf("************************************CGameServer::ProcessUserJoinGame(NETInputPacket *pPacket %d ***********************************\n", res);
	//fflush(stdout);

    if(res)
    {
        int onlookId = pPacket->ReadInt();
        int tid = pPacket->ReadInt();
        short serverId = pPacket->ReadShort();
        string ip = pPacket->ReadString();
        int port = pPacket->ReadInt();
        short serverLevel = pPacket->ReadShort();
		int type = pPacket->ReadInt();

#ifndef WIN32
        g_pErrorLog->logMsg("ProcessUserJoinGame||res:[%d], tid:[%d], ip:[%s], port:[%d], level:[%d]\n", res, tid, ip.c_str(), port, serverLevel);
#endif
        NETOutputPacket resPacket;
        //围观玩家重连
        if(onlookId > 0)
        {
            resPacket.Begin(SERVER_ONLOOK_ENTER_ROOM);

        }
        else
        {
            resPacket.Begin(SERVER_CMD_JOIN_GAME);
        }
        resPacket.WriteInt(tid);
        resPacket.WriteShort(serverId);
        resPacket.WriteString(ip.c_str());
        resPacket.WriteInt(port);
        //新增扩张信息
        resPacket.WriteInt(res);
        resPacket.WriteShort(serverLevel);
        if(onlookId > 0)
        {
            resPacket.WriteInt(onlookId); //被围观玩家ID
        }

		
		resPacket.WriteInt(type);
		
        resPacket.End();
        CHallServer *pHallServer = GetHallServer(svid);
        if(pHallServer != NULL)
        {
            if(pHallServer->m_pSocketHandler != NULL)
            {
                SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
            }
        }
    }
    else
    {
        short level = pPacket->ReadShort();
        int sid = pPacket->ReadInt();
		int activityID = pPacket->ReadInt();
		int userIp = pPacket->ReadInt();

		g_pDebugLog->logMsg("xxxxxCGameServer::ProcessUserJoinGame|| level[%d] sid[%d] activityID[%d] userIp[%d]", level, sid, activityID, userIp);

        /*if(sid > 0)//pc刷新重连
        {
            CLogicServer *pServer = GetServer(sid);
            if(pServer != NULL)
            {
                NETOutputPacket resPacket;
                resPacket.Begin(SERVER_CMD_JOIN_GAME);
                resPacket.WriteInt(0);
                resPacket.WriteShort((short)sid);
                resPacket.WriteString(pServer->m_strIp.c_str());
                resPacket.WriteInt(pServer->m_nPort);
                resPacket.WriteInt(res);
                resPacket.End();
                CHallServer *pHallServer = GetHallServer(svid);
                if(pHallServer != NULL)
                {
                    if(pHallServer->m_pSocketHandler != NULL)
                    {
                        SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
                    }
                }
            }
        }
        else
        {*/
        if(level != m_nLevel)  //是否是当前alloc配房的等级
        {
#ifndef WIN32
            g_pErrorLog->logMsg("ProcessUserJoinGame||level error, uid:[%d], level:[%d]\n", uid, level);
#endif
            return 0;
        }
        int tid = 0;
        short serverId = 0;
        string ip = "";
        int port = 0;
        CGameTable* pTable = NULL;

		if (activityID > 0)//假如是组局类型 zsw
		{
			map<int,int>::iterator iter = m_GroupTableDict.find(activityID);
			if (iter != m_GroupTableDict.end())
			{
				serverId = iter->second >> 16;
			//	printf("----------------CGameServer::ProcessUserJoinGame:serverId---[%d] [%d]\n", serverId, iter->second);
				//fflush(stdout);
				vector<SERVERINFO> vecServer;
				ServerList::iterator iterServer = m_ServerList.begin();
				for (; iterServer != m_ServerList.end(); iterServer++)
				{
					CLogicServer *pLogicServer = iterServer->second;

					//printf("----------------pLogicServer->m_nServerId:serverId---[%d]\n", pLogicServer->m_nServerId);
					//fflush(stdout);
					if (serverId == pLogicServer->m_nServerId)
					{
						pTable = pLogicServer->GetTable(iter->second);
						
						//printf("----------------xxxxxxxx pLogicServer->m_nServerId:serverId---[%p]\n", pTable);
						//fflush(stdout);
					}

					if (pTable)
					{
						//printf("----------------if (pTable)    :serverId---[%d]\n", pTable->m_nTid);
						//fflush(stdout);
						break;
					}
				}
			}
		}
		else
		{
			//前端给的tid
			int logicId = (sid >> 16);
			CLogicServer *pServer = GetServer(logicId);
			if (pServer)
			{
				pTable = pServer->GetTable(sid);
			}
			else {
				if (m_nFillFlag)
				{
					pTable = GetFillRoom();
				}
				else
				{
					pTable = GetGameRoom();
				}
			}
		}

		userIpMap[uid] = userIp;

        if(pTable != NULL)
        {
            tid = pTable->m_nTid;
            serverId = pTable->m_nServerId;
            CLogicServer *pServer = GetServer(pTable->m_nServerId);

			//printf("----------------if (pTable)    :uid[%d] userIp[%d]\n", uid, userIp);
			//fflush(stdout);

            if(pServer != NULL)
            {
				
                ip = pServer->m_strIp;
                port = pServer->m_nPort;

				//printf("----------------CGameServer::ProcessUserJoinGamessss:ip[%s] port[%d]\n", ip.c_str(), port);
				//fflush(stdout);
            }
        }

//#ifndef WIN32
//          g_pErrorLog->logMsg("ProcessUserJoinGame||res:[%d], tid:[%d], ip:[%s], port:[%d]", res, tid, ip.c_str(), port);
//#endif

		g_pDebugLog->logMsg("------------------------ProcessUserJoinGame tid[%d] serverId[%d] level[%d]", tid, serverId, level);

        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_JOIN_GAME);
        resPacket.WriteInt(tid);
        resPacket.WriteShort(serverId);
        resPacket.WriteString(ip.c_str());
        resPacket.WriteInt(port);
        resPacket.WriteInt(res);
		resPacket.WriteShort(level);
		resPacket.WriteByte(pTable->max_plaery_count);
		resPacket.WriteInt(pTable->m_activityID);
		resPacket.WriteString(pTable->jsonConfig.c_str());
		resPacket.WriteString(pTable->m_strPassword.c_str());
        resPacket.End();
        CHallServer *pHallServer = GetHallServer(svid);


		//printf("----------------CGameServer::ProcessUserJoinGameffff:activityID [%d] uid[%d] svid [%d] tid[%d] serverId[%d] ip[%s] port[%d] res[%d] level[%d] pHallServer[%p]\n", activityID, uid, svid, tid, serverId, ip.c_str(), port, res, level, pHallServer);
		//fflush(stdout);

        if(pHallServer != NULL)
        {
			//printf("----------------pHallServer->m_pSocketHandler uid[%d] m_pSocketHandler[%p]\n", uid, pHallServer->m_pSocketHandler);
			//fflush(stdout);

            if(pHallServer->m_pSocketHandler != NULL)
            {
                SendClientPacket(uid, svid, &resPacket, pHallServer->m_pSocketHandler);
            }
        }
        //}
    }
    return 0;
}


CGameTable* CGameServer::GetGameRoom(CLogicServer* pServer)
{
    if(pServer == NULL)
    {
        return NULL;
    }
    CGameTable *pTable = NULL;
    vector<TABLEINFO> vecTable;
    TableList::iterator iterTable = pServer->m_TableList.begin();
    for(; iterTable!=pServer->m_TableList.end(); iterTable++)
    {
        CGameTable *pTempTable = iterTable->second;
        if(pTempTable != NULL)
        {
            if(pTempTable->m_nUserCount < m_nMaxTableUserCount/*MAX_TABLE_USER_COUNT*/)
            {
                TABLEINFO tableInfo;
                tableInfo.tid = pTempTable->m_nTid;
                tableInfo.userCount = pTempTable->m_nUserCount;
                vecTable.push_back(tableInfo);
            }
        }
    }

    if(vecTable.size() > 0)
    {
        std::sort(vecTable.begin(), vecTable.end(), Less_TableUserCount);
        TABLEINFO &tInfo = vecTable[0];
        pTable = pServer->GetTable(tInfo.tid);
    }
    else
    {
        int sid = pServer->m_nServerId;
        int newTableId = (sid<<16) + pServer->m_nTableCount;
        pTable = new CGameTable(newTableId, pServer->m_nServerId, pServer->m_nLevel,0);
        if(pTable != NULL)
        {
            pServer->m_TableList[newTableId] = pTable;
            pServer->m_nTableCount++;
            pServer->m_nUserCount++;
            CountTableList::iterator iterCount = m_CountTableList.find(1);
            if(iterCount != m_CountTableList.end())
            {
                TableList& tableMap = iterCount->second;
                tableMap[newTableId] = pTable;
            }
            else
            {
                TableList& tableMap = m_CountTableList[1];
                tableMap[newTableId] = pTable;
            }
        }
    }
    return pTable;
}
//CGameTable* CGameServer::GetGameRoom(short serverId)
//{
//  CGameTable *pTable = GetTable(serverId, 2);
//  if(pTable != NULL)
//  {
//      return pTable;
//  }
//
//  pTable = GetTable(serverId, 1);
//  if(pTable != NULL)
//  {
//      return pTable;
//  }
//
//  pTable = GetTable(serverId, 0);
//  if(pTable != NULL)
//  {
//      return pTable;;
//  }
//
//  CLogicServer *pServer = GetServer(serverId);
//  if(pServer != NULL)
//  {
//      int sid = serverId;
//      int newTableId = (sid<<16) + pServer->m_nTableCount;
//      pTable = new CGameTable(newTableId, serverId, m_nLevel);
//      if(pTable != NULL)
//      {
//          pServer->m_TableList[newTableId] = pTable;
//          pServer->m_nTableCount++;
//          CountTableList::iterator iterCount = m_CountTableList.find(1);
//          if(iterCount != m_CountTableList.end())
//          {
//              TableList& tableMap = iterCount->second;
//              tableMap[newTableId] = pTable;
//          }
//          else
//          {
//              TableList& tableMap = m_CountTableList[1];
//              tableMap[newTableId] = pTable;
//          }
//      }
//  }
//  return pTable;
//}

//CGameTable* CGameServer::GetTable(short serverId, int count)
//{
//  int userCount2Tid = 0;
//  int userCount1Tid = 0;
//  int userCount0Tid = 0;
//  CLogicServer *pServer = GetServer(serverId);
//  if(pServer != NULL)
//  {
//      if(pServer->m_nRetire==0 && pServer->m_nUserCount<=m_nMaxServerUserCount)
//      {
//          TableList::iterator iter = pServer->m_TableList.begin();
//          for(; iter!=pServer->m_TableList.end(); iter++)
//          {
//              CGameTable* pTempTable = iter->second;
//              if(pTempTable->m_nUserCount == 2)
//              {
//                  userCount2Tid = iter->first;
//                  break;
//              }
//
//              if(userCount1Tid==0 && pTempTable->m_nUserCount==1)
//              {
//                  userCount1Tid = iter->first;
//              }
//
//              if(userCount0Tid==0 && pTempTable->m_nUserCount==0)
//              {
//                  userCount0Tid = iter->first;
//              }
//          }
//      }
//  }
//
//  CGameTable* pTable = NULL;
//  if(pServer != NULL)
//  {
//      if(userCount2Tid)
//      {
//          return pServer->GetTable(userCount2Tid);
//      }
//      else if(userCount1Tid)
//      {
//          return pServer->GetTable(userCount1Tid);
//      }
//      else if(userCount0Tid)
//      {
//          return pServer->GetTable(userCount0Tid);
//      }
//  }
//  return pTable;
//}

CGameTable* CGameServer::GetTable(int count)
{
    CGameTable *pTable = NULL;
    CountTableList::iterator iterCount = m_CountTableList.find(count);
    if(iterCount != m_CountTableList.end())
    {
        TableList& tableMap = iterCount->second;
        TableList::iterator iterTable = tableMap.begin();
        for(; iterTable!=tableMap.end(); )
        {
            CGameTable* pTempTable = iterTable->second;
            if(pTempTable != NULL)
            {
                CLogicServer *pServer = GetServer(pTempTable->m_nServerId);
                if(pServer != NULL)
                {
                    if(pServer->m_nRetire==1 || pServer->m_nUserCount>=m_nMaxServerUserCount)
                    {
                        iterTable++;
                    }
                    else
                    {
                        pTable = pTempTable;
                        tableMap.erase(iterTable++);
                        pTable->m_nUserCount = count+1;
                        pServer->m_nUserCount++;
                        TableList& tableNewMap = m_CountTableList[pTable->m_nUserCount];
                        tableNewMap[pTable->m_nTid] = pTable;
                        break;
                    }
                }
                else
                {
                    tableMap.erase(iterTable++);
                }
            }
            else
            {
                tableMap.erase(iterTable++);
            }
        }
    }
    return pTable;
}


CGameTable* CGameServer::GetFillRoom()
{
    CGameTable* pTable = NULL;
    //先对所有的server进行排序
    vector<SERVERINFO> vecServer;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!=m_ServerList.end(); iterServer++)
    {
        CLogicServer *pLogicServer =  iterServer->second;
        if(pLogicServer != NULL)
        {
            if(pLogicServer->m_nRetire==0 && pLogicServer->m_nUserCount<m_nMaxServerUserCount)//加入server人数上限控制
            {
                SERVERINFO serverInfo;
                serverInfo.serverId = pLogicServer->m_nServerId;
                serverInfo.userCount = pLogicServer->m_nUserCount;
                vecServer.push_back(serverInfo);
            }
        }

    }

    if(vecServer.size() > 0)
    {
        std::sort(vecServer.begin(), vecServer.end(), More_ServerUserCount);
        SERVERINFO &sInfo = vecServer[0];
        CLogicServer *pServer = GetServer(sInfo.serverId);
        if(pServer != NULL)
        {
            pTable = GetGameRoom(pServer);
        }
    }
    return pTable;
}

CGameTable* CGameServer::GetGameRoom()
{
    //CGameTable *pTable = GetTable(2);
    //if(pTable != NULL)
    //{
    //  return pTable;
    //}

    //pTable = GetTable(1);
    //if(pTable != NULL)
    //{
    //  return pTable;
    //}

    //pTable = GetTable(0);
    //if(pTable != NULL)
    //{
    //  return pTable;
    //}
    CGameTable *pTable = NULL;

    for(int i=m_nMaxTableUserCount-1; i>=0; i--)
    {
        pTable = GetTable(i);
        if(pTable != NULL)
        {
            return pTable;
        }
    }

    vector<SERVERINFO> vecServer;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!=m_ServerList.end(); iterServer++)
    {
        CLogicServer *pLogicServer =  iterServer->second;
        if(pLogicServer != NULL)
        {
            if(pLogicServer->m_nRetire==0 && pLogicServer->m_nUserCount<m_nMaxServerUserCount)//加入server人数上限控制
            {
                SERVERINFO serverInfo;
                serverInfo.serverId = pLogicServer->m_nServerId;
                serverInfo.userCount = pLogicServer->m_nUserCount;
                vecServer.push_back(serverInfo);
            }
        }

    }

    if(vecServer.size() > 0)
    {
        std::sort(vecServer.begin(), vecServer.end(), Less_ServerUserCount);
        SERVERINFO &sInfo = vecServer[0];
        CLogicServer *pServer = GetServer(sInfo.serverId);
        if(pServer != NULL)
        {
            int sid = sInfo.serverId;
            int newTableId = (sid<<16) + pServer->m_nTableCount;
            pTable = new CGameTable(newTableId, sInfo.serverId, pServer->m_nLevel,0);
            if(pTable != NULL)
            {
                pServer->m_TableList[newTableId] = pTable;
                pServer->m_nTableCount++;
                pServer->m_nUserCount++;
                CountTableList::iterator iterCount = m_CountTableList.find(1);
                if(iterCount != m_CountTableList.end())
                {
                    TableList& tableMap = iterCount->second;
                    tableMap[newTableId] = pTable;
                }
                else
                {
                    TableList& tableMap = m_CountTableList[1];
                    tableMap[newTableId] = pTable;
                }
            }
        }
    }
    return pTable;
}



int CGameServer::SendClientAllocPacket(int uid, int svid,int level, NETOutputPacket *pPacket, SocketHandler *pSocket)
{
	if (pSocket != NULL)
	{
		//pSocket->EncryptBuffer(pPacket);
		NETOutputPacket resPacket;
		resPacket.Begin(ALLOW_PACKET);
		resPacket.WriteInt(uid);
		resPacket.WriteInt(svid);
		resPacket.WriteInt(level);
		resPacket.WriteBinary(pPacket->packet_buf(), pPacket->packet_size());
		resPacket.End();
		pSocket->Send(&resPacket);
	}
	return 0;
}
int  CGameServer::GET_USER_GAME_STATUS(int uid) {
	int ret = -1;
	string tempStr;
	ret = m_pRedisManagerClient->GET_USER_GAME_STATUS(uid, tempStr);
	//g_pDebugLog->logMsg("GET_USER_GAME_STATUS ret[%d]  c_str[%s]", ret, tempStr.c_str());
	if (ret > 0) {
		vector<string> pickVec;
		split_str(tempStr.c_str(), "_", pickVec);
		
		if (pickVec.size() >= 3) {
			if (std::atoi(pickVec[1].c_str()) > 0  && std::atoi(pickVec[2].c_str()) > 0) {
				return 1;
			}
		}
	}
	return -1;
}
int CGameServer::SendClientPacket(int uid, int svid, NETOutputPacket *pPacket, SocketHandler *pSocket)
{
	
   if(pSocket != NULL)
    {
        pSocket->EncryptBuffer(pPacket);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_PACKET);
        resPacket.WriteInt(uid);
        resPacket.WriteInt(svid);
        resPacket.WriteBinary(pPacket->packet_buf(), pPacket->packet_size());
        resPacket.End();
        pSocket->Send(&resPacket);
    }
    return 0;
}

int CGameServer::ProcessOnTimerOut(int timerId)
{
    switch(timerId)
    {
        case CHANGE_LOG_FILE_TIMER:
            ProcLogFileTimer();
            break;
		case TIME_AOUT_TABLE:
		{
			getRobotList();
			break;
		}
		
		case TIME_AOUT_ADD_TABLE:{
			for (map<int, int>::iterator itre = list_false.begin();itre!= list_false.end(); itre++)
			{
				checkTableList(itre->first, itre->second,2);
			}
			break;
			//checkTableListTest();
		}
			
			
    }
    
    return 0;
}

int CGameServer::ProcLogFileTimer()
{
    m_logOpenTimer.StopTimer();
    m_logOpenTimer.StartTimer(GetDelayTime());
    OpenFileLog(m_nLevel);
    return 0;
}

int CGameServer::ProcessLogicCore(CLogicServer* pLogicServer)
{
	g_pDebugLog->logMsg("ProcessLogicCore");
    if(pLogicServer == NULL)
        return 0;
    pLogicServer->StopCheckCoreTimer();
	clearClubTable(pLogicServer->m_nLevel);
    //先清除server中的桌子信息
    TableList::iterator iterTable = pLogicServer->m_TableList.begin();
    for(; iterTable!=pLogicServer->m_TableList.end(); iterTable++)
    {
        CGameTable *pTable = iterTable->second;
        if(pTable != NULL)
        {
			if (m_Table_PlayerSit.find(pTable->m_nTid) != m_Table_PlayerSit.end()) {
				m_Table_PlayerSit[pTable->m_nTid].clear();
				m_Table_PlayerSit.erase(m_Table_PlayerSit.find(pTable->m_nTid));
			}
			g_pDebugLog->logMsg("ProcessLogicCore====  %d %d %d\n", pTable->m_nTid, pTable->m_activityID, 1);
			if (m_pRedisManagerClient->WIN_CLOS_GROUP(pTable->m_nTid, pTable->m_activityID, 1) == -1) {
				g_pDebugLog->logMsg("ProcessLogicCore====  %s", __FUNCTION__);
			}
            /*CountTableList::iterator iterCount = m_CountTableList.find(pTable->m_nUserCount);
            if(iterCount != m_CountTableList.end())
            {
                TableList& tableMap = iterCount->second;
                TableList::iterator iter = tableMap.find(pTable->m_nTid);
                if(iter != tableMap.end())
                {
                    tableMap.erase(iter);
                }
            }*/
            //如果server挂，为了保险，防止出现野指针，如下在每个CountTableList里面查找并除去除去该桌子
            for(int i=0; i<=m_nMaxTableUserCount/*MAX_TABLE_USER_COUNT*/; i++)
            {
                CountTableList::iterator iterCount = m_CountTableList.find(i);
                if(iterCount != m_CountTableList.end())
                {
                    TableList& tableMap = iterCount->second;
                    TableList::iterator iter = tableMap.find(pTable->m_nTid);
                    if(iter != tableMap.end())
                    {
						vector<int> vTableUser;
						for (map<int, int>::iterator tableIter = userTableMap.begin(); tableIter != userTableMap.end(); tableIter++)
						{
							g_pDebugLog->logMsg("___ProcessLogicCore tid:[%d], tableIter->second:[%d]", pTable->m_nTid, tableIter->second);
							if (tableIter->second == pTable->m_nTid) {
								vTableUser.push_back(tableIter->first);
							}
						}
						g_pDebugLog->logMsg("_____ProcessLogicCore||Remove table, tid:[%d], userCount:[%d] vTableUser.size:%d", pTable->m_nTid, i, vTableUser.size());
						for (size_t j = 0; j < vTableUser.size(); j++)
						{
							map<int, int>::iterator tableIter2 = userTableMap.find(vTableUser[j]);
							if (tableIter2 != userTableMap.end())
							{
								NETOutputPacket pPacket2;
								pPacket2.Begin(SYS_USER_LEAVE_ROOM);
								pPacket2.WriteInt(tableIter2->first);
								pPacket2.WriteInt(pTable->m_nTid);
								pPacket2.WriteInt(m_nLevel);
								pPacket2.End();
								int userServerId2 = vTableUser[j] % (int)m_UserServerList.size();
								CUserServer* pUserServer = GetUserServer(userServerId2);
								if (pUserServer != NULL)
								{
									g_pDebugLog->logMsg("pUserServer!=null||");
									pUserServer->TransferPacket(&pPacket2);
								}
								g_pDebugLog->logMsg("userTableMap||");
								
								userTableMap.erase(tableIter2);
							}
						}
						
						GameGroup::Instance()->CancelGroupTable(this, iter->second->m_activityID);
                        tableMap.erase(iter);
                    }
                }
            }

            delete pTable;
            pTable = NULL;
        }
    }

    pLogicServer->m_TableList.clear();

    TableList::iterator iterLove = pLogicServer->m_TableLoveGirlList.begin();
    for(; iterLove!=pLogicServer->m_TableLoveGirlList.end(); iterLove++)
    {
        CGameTable *pTable = iterLove->second;
        if(pTable != NULL)
        {
			if (m_Table_PlayerSit.find(pTable->m_nTid) != m_Table_PlayerSit.end()) {
				m_Table_PlayerSit[pTable->m_nTid].clear();
				m_Table_PlayerSit.erase(m_Table_PlayerSit.find(pTable->m_nTid));
			}
			g_pDebugLog->logMsg("ProcessLogicCore====  %d %d %d\n", pTable->m_nTid, pTable->m_activityID, 1);
			if (m_pRedisManagerClient->WIN_CLOS_GROUP(pTable->m_nTid, pTable->m_activityID, 1) == -1) {
				g_pDebugLog->logMsg("ProcessLogicCore====%s \n", __FUNCTION__);
			}
            //如果server挂，为了保险，防止出现野指针，如下在每个CountTableList里面查找并除去除去该桌子
            for(int i=0; i<=m_nMaxTableUserCount/*MAX_TABLE_USER_COUNT*/; i++)
            {
                CountTableList::iterator iterCount = m_CountTableList.find(i);
                if(iterCount != m_CountTableList.end())
                {
                    TableList& tableMap = iterCount->second;
                    TableList::iterator iter = tableMap.find(pTable->m_nTid);
                    if(iter != tableMap.end())
                    {
						vector<int> vTableUser;
						for (map<int, int>::iterator tableIter  = userTableMap.begin();  tableIter!=userTableMap.end(); tableIter++)
						{
							g_pDebugLog->logMsg("ProcessLogicCore tid:[%d], tableIter->first:[%d]", pTable->m_nTid, tableIter->second);
							
							if (tableIter->second == pTable->m_nTid) {
								vTableUser.push_back(tableIter->first);
							}
						}
                        g_pDebugLog->logMsg("ProcessLogicCore||Remove table, tid:[%d], userCount:[%d] vTableUser.size(%d)", pTable->m_nTid, i, vTableUser.size());
						for (size_t j = 0; j < vTableUser.size(); j++)
						{
							map<int, int>::iterator tableIter = userTableMap.find(vTableUser[j]);
							if (tableIter != userTableMap.end())
							{
								NETOutputPacket pPacket2;
								pPacket2.Begin(SYS_USER_LEAVE_ROOM);
								pPacket2.WriteInt(tableIter->first);
								pPacket2.WriteInt(pTable->m_nTid);
								pPacket2.WriteInt(m_nLevel);
								pPacket2.End();
								int userServerId2 = vTableUser[j] % (int)m_UserServerList.size();
								CUserServer* pUserServer = GetUserServer(userServerId2);
								if (pUserServer != NULL)
								{
									g_pDebugLog->logMsg("pUserServer!=null||");
									pUserServer->TransferPacket(&pPacket2);
								}
								g_pDebugLog->logMsg("userTableMap||");

								userTableMap.erase(tableIter);
							}
						}
						
						tableMap.erase(iter);
                    }
                }
            }

            delete pTable;
            pTable = NULL;
        }
    }
    pLogicServer->m_TableLoveGirlList.clear();
    //告诉用户server，逻辑server断开连接了
    NETOutputPacket reqPacket;
    reqPacket.Begin(SYS_LOGIC_CORE);
    reqPacket.WriteShort(pLogicServer->m_nServerId);
    reqPacket.End();
    UserServerList::iterator iter = m_UserServerList.begin();
    for(; iter!=m_UserServerList.end(); iter++)
    {
        CUserServer* pUserServer = iter->second;
        if(pUserServer != NULL)
        {
            pUserServer->TransferPacket(&reqPacket);
        }
    }
	//userTableMap
    ServerList::iterator iterServer = m_ServerList.find(pLogicServer->m_nServerId);
    if(iterServer != m_ServerList.end())
    {
        m_ServerList.erase(iterServer);
    }
	m_CountTableList.clear();
    delete pLogicServer;
    pLogicServer = NULL;
    return 0;
}

int CGameServer::ProcessHallCore(CHallServer* pHallServer)
{
    if(pHallServer == NULL)
        return 0;
    pHallServer->StopCheckCoreTimer();

    NETOutputPacket reqPacket;
    reqPacket.Begin(SYS_HALL_CORE);
    reqPacket.WriteInt(pHallServer->m_nServerId);
    reqPacket.End();
    //广播给所有UserServer,大厅server挂了
    UserServerList::iterator iter = m_UserServerList.begin();
    for(; iter!=m_UserServerList.end(); iter++)
    {
        CUserServer* pUserServer = iter->second;
        if(pUserServer != NULL)
        {
            pUserServer->TransferPacket(&reqPacket);
        }
    }
	g_pDebugLog->logMsg("ProcessHallCore");
    HallServerList::iterator iterHall = m_HallServerList.find(pHallServer->m_nServerId);
    if(iterHall != m_HallServerList.end())
    {
        m_HallServerList.erase(iterHall);
    }
    delete pHallServer;
    pHallServer = NULL;
    return 0;
}

int CGameServer::ProcessBackPacket(NETInputPacket *pPacket)//处理UserServer发过来的包
{
	int cmd = pPacket->GetCmdType();
	g_pDebugLog->logMsg("[%s function:%s] ===> cmd[0x%x]", __FILE__, __FUNCTION__, cmd);

    if(cmd == SYS_GET_USER_TABLE)
    {
        ProcessUserJoinGame(pPacket);
    }
	else if(cmd == SYS_GET_USER_TABLE_COMMON)
	{
		ProcessUserTable(pPacket);
	}
	else if (cmd == SYS_UPDATE_TABLE_LIST)
	{
		ProcessUpdateTableList(pPacket);
	}
    else
    {
        int uid = pPacket->ReadInt();
        int svid = pPacket->ReadInt();//大厅serverId
		
		//int svid = 1;//大厅serverId
		g_pDebugLog->logMsg("--------serverId[%d]", svid);
        CHallServer *pHallServer = GetHallServer(svid);
        if(pHallServer != NULL)
        {
            if(pHallServer->m_pSocketHandler != NULL)
            {
                if(cmd == CLIENT_PACKET)
                {
                    char szTemp[10240];
                    int rLen = pPacket->ReadBinary(szTemp, sizeof(szTemp));
                    if(rLen != -1)
                    {
						int ip = pPacket->ReadInt();//用户的ip
						NETInputPacket tempPacket;
						tempPacket.Copy(szTemp, rLen);
						int subCmd = tempPacket.GetCmdType();
						g_pDebugLog->logMsg("ProcessBackPacket cmd:[0x%02x]", subCmd);
 						/*
                        NETInputPacket tempPacket;
                        tempPacket.Copy(szTemp, rLen);
                        if(pHallServer->m_pSocketHandler->CrevasseBuffer(&tempPacket) < 0)
                        {
                            g_pErrorLog->logMsg("ProcessBackPacket||CrevasseBuffer error");
                            return 0;
                        }

                        int subCmd = tempPacket.GetCmdType();
                        if(subCmd == SERVER_CMD_LOGIN_SUCCESS || SERVER_ONLOOK_RECONNECT_ROOM == subCmd)
                        {
                            
                            NETOutputPacket outTemp;
                            if(subCmd == SERVER_CMD_LOGIN_SUCCESS)
                            {
                                outTemp.Begin(SERVER_CMD_LOGIN_SUCCESS);
                            }
                            else if(subCmd ==SERVER_ONLOOK_RECONNECT_ROOM)
                            {
                                outTemp.Begin(SERVER_ONLOOK_RECONNECT_ROOM);
                            }
                            int ver = tempPacket.ReadInt();
                            outTemp.WriteInt(ver);
                            int levelCount = tempPacket.ReadInt();
                            outTemp.WriteInt(levelCount);
                            for(int i=0; i<levelCount; ++i)
                            {
                                int userCount = tempPacket.ReadInt();
                                outTemp.WriteInt(userCount);
                            }

                            int friendCount = tempPacket.ReadInt();
                            outTemp.WriteInt(friendCount);

                            int tid = tempPacket.ReadInt();
                            outTemp.WriteInt(tid);

                            string strIP = tempPacket.ReadString();
                            outTemp.WriteString(strIP.c_str());

                            int port = tempPacket.ReadInt();
                            outTemp.WriteInt(port);

                            short level = tempPacket.ReadShort();
                            outTemp.WriteShort(level);

                            //围观玩家重连
                            int onlookId = 0;
                            if(subCmd == SERVER_ONLOOK_RECONNECT_ROOM)
                            {
                                onlookId = tempPacket.ReadInt();
                                outTemp.WriteInt(onlookId);
                            }

                            if(level == 0 || level == 4001)
                            {
                                int tidmapped = GetTidMappedFromTid(tid);
                                outTemp.WriteInt(tidmapped);
                            }

                            outTemp.End();

                            if(pHallServer->m_pSocketHandler->EncryptBuffer(&outTemp) < 0)
                            {
                                g_pErrorLog->logMsg("ProcessBackPacket||EncryptBuffer error");
                                return 0;
                            }
                            

                        }
                        */
                        NETOutputPacket resPacket;
                        resPacket.Begin(CLIENT_PACKET);
                        resPacket.WriteInt(uid);
                        resPacket.WriteInt(svid);
                        resPacket.WriteBinary(szTemp, rLen);
						resPacket.WriteInt(ip);
                        resPacket.End();

                        pHallServer->m_pSocketHandler->Send(&resPacket);
                        return 0;
                    }

                    NETOutputPacket resPacket;
                    resPacket.Copy(pPacket->packet_buf(), pPacket->packet_size());
                    pHallServer->m_pSocketHandler->Send(&resPacket);
                    return 0;
                }
                else
                {
                    NETOutputPacket resPacket;
                    resPacket.Copy(pPacket->packet_buf(), pPacket->packet_size());
                    pHallServer->m_pSocketHandler->Send(&resPacket);
                }
            }
        }
    }
    return 0;
}

//获取超快赛server
CGameMatch* CGameServer::GetQuiteMatchRoom(int level,int &matchId,short& serverId)
{
    vector<MATCHINFO> vecMatch;
    MatchList::iterator iter = m_MatchList.begin();
    for(; iter!=m_MatchList.end(); iter++)  //先遍历所有的比赛场  查看有没有还没满的比赛场
    {
        CGameMatch *pMatch = iter->second;

        if(NULL != pMatch)
        {
            CLogicServer* pServer = GetServer(pMatch->m_nServerId);
            if(pServer != NULL)
            {
                if(0==pServer->m_nRetire && pMatch->m_nCurrentNum<m_nMaxTableUserCount && pServer->m_nUserCount<m_nMaxServerUserCount)
                {
                    MATCHINFO matchinfo;
                    matchinfo.matchId = pMatch->m_nMatchId;
                    matchinfo.usercount = pMatch->m_nCurrentNum;
                    matchinfo.serverId = pMatch->m_nServerId;
                    vecMatch.push_back(matchinfo);
                }
            }
        }
    }
    if((int)vecMatch.size() >0)
    {
        std::sort(vecMatch.begin(), vecMatch.end(), Max_MatchCount);
        MATCHINFO &minfo = vecMatch[0];
        matchId = minfo.matchId;
        serverId = minfo.serverId;
    }
    else
    {
        vector<SERVERINFO> serverInfo;
        ServerList::iterator iterServer = m_ServerList.begin();
        for(; iterServer!=m_ServerList.end(); iterServer++)//查找所有的server 找出人数最少的一个server创建比赛场
        {
            CLogicServer* pServer = iterServer->second;
            if(NULL!=pServer && 0==pServer->m_nRetire && pServer->m_nUserCount<m_nMaxServerUserCount)
            {
                SERVERINFO sinfo;
                sinfo.serverId = pServer->m_nServerId;
                sinfo.userCount = pServer->m_nUserCount;
                serverInfo.push_back(sinfo);
            }
        }
        if((int)serverInfo.size() > 0)
        {
            std::sort(serverInfo.begin(), serverInfo.end(), Less_ServerUserCount);
            SERVERINFO &sInfo = serverInfo[0];
            CLogicServer *pLogicServer = m_ServerList[sInfo.serverId];
            if(pLogicServer != NULL)
            {
                int newMatchId = (sInfo.serverId<<16) + pLogicServer->m_nMatchCount + 1;
                CGameMatch *pNewMatch = new CGameMatch(sInfo.serverId, newMatchId);
                if(pNewMatch != NULL)
                {
                    pLogicServer->m_nMatchCount++;
                    matchId = newMatchId;
                    serverId = pNewMatch->m_nServerId;
                    m_MatchList[newMatchId] = pNewMatch;
                }
            }
        }
    }
    return NULL;
}

//获取活动赛server
CGameMatch* CGameServer::GetHuodongMatchRoom(int level, int &matchId, short& serverId)
{
    vector<SERVERINFO> serverInfo;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!=m_ServerList.end(); iterServer++)//查找所有的server 找出人数最少的一个server创建比赛场
    {
        CLogicServer* pServer = iterServer->second;
        if(NULL!=pServer && 0==pServer->m_nRetire && pServer->m_nUserCount<m_nMaxServerUserCount)
        {
            SERVERINFO sinfo;
            sinfo.serverId = pServer->m_nServerId;
            sinfo.userCount = pServer->m_nUserCount;
            serverInfo.push_back(sinfo);
        }
    }
    if((int)serverInfo.size() > 0)
    {
        std::sort(serverInfo.begin(), serverInfo.end(), Less_ServerUserCount);
        SERVERINFO &sInfo = serverInfo[0];
        CLogicServer *pLogicServer = GetServer(sInfo.serverId);
        if(pLogicServer != NULL)
        {
            serverId = pLogicServer->m_nServerId;
        }
    }
    return NULL;
}

CGameMatch* CGameServer::GetMatch(int matchId)
{
    CGameMatch* pMatch = NULL;
    MatchList::iterator iter = m_MatchList.find(matchId);
    if(iter != m_MatchList.end())
    {
        pMatch= iter->second;
    }
    return pMatch;
}


int CGameServer::ProcessUpdateMatchUserCount(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    (void)pSocket;
    short serverId = pPacket->ReadShort();
    int matchId = pPacket->ReadInt();
    short level = pPacket->ReadShort();
    short tableUserCount = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();

    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessUpdateMatchUserCount||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
#endif
        return 0;
    }

    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        pLogicServer->m_nUserCount = userCount;
        if((matchId>>16) == serverId)
        {
            CGameMatch *pMatch = GetMatch(matchId);
            if(pMatch != NULL)
            {
                pMatch->m_nCurrentNum = tableUserCount;
            }
            else
            {
                pMatch = new CGameMatch(serverId, matchId);
                if(pMatch != NULL)
                {
                    m_MatchList[matchId] = pMatch;
                    pMatch->m_nCurrentNum = tableUserCount;
                    pLogicServer->m_nMatchCount++;
                }
            }
        }
    }
    return 0;
}


int CGameServer::ProcessUserApplyMatch(int uid, int svid, short level, SocketHandler *pSocket)
{
//    short level = pPacket->ReadShort();
    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessUserApplyMatch||level!=m_nLevel, level:[%d], m_nLevel:[%d]", level, m_nLevel);
#endif
        return 0;
    }

    int matchId = 0;
    short serverId = 0;
    string ip = "";
    int port = 0;

    ServerList::iterator iter = m_ServerList.begin();
    for(; iter!=m_ServerList.end(); iter++)
    {
        CLogicServer* pServer = iter->second;
        if(pServer!=NULL && pServer->m_nUserCount<m_nMaxServerUserCount && 0==pServer->m_nRetire)
        {
            serverId = pServer->m_nServerId;
            ip = pServer->m_strIp;
            port = port = pServer->m_nPort;
            break;
        }
    }

    matchId = (level<<16);

    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_JOIN_MATCH);
    resPacket.WriteInt(matchId);
    resPacket.WriteShort(serverId);
    resPacket.WriteString(ip.c_str());
    resPacket.WriteInt(port);
    resPacket.End();
    SendClientPacket(uid, svid, &resPacket, pSocket);
    return 0;
}
int CGameServer::ProcessChangeLevelToLogin(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket)
{
    short level = pPacket->ReadShort();
    int mid = pPacket->ReadInt();

    char temp_buf[10240] = {0};

    int nLen = pPacket->ReadBinary(temp_buf, sizeof(temp_buf));

    /*  string mtk = pPacket->ReadString();
        string strInfo = pPacket->ReadString();
        int flag = pPacket->ReadInt();
    */
    if(level != m_nLevel)  //是否是当前alloc配房的等级
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessChangeLevelToLogin||level error, uid:[%d], level:[%d]", uid, level);
#endif
        return 0;
    }
    int tid = 0;
    short serverId = 0;
    string ip = "";
    int port = 0;
    CGameTable* pTable = NULL;
    if(m_nFillFlag)
    {
        pTable = GetFillRoom();
    }
    else
    {
        pTable = GetGameRoom();
    }

    if(pTable != NULL)
    {
        tid = pTable->m_nTid;
        serverId = pTable->m_nServerId;
        CLogicServer *pServer = GetServer(pTable->m_nServerId);
        if(pServer != NULL)
        {
            ip = pServer->m_strIp;
            port = pServer->m_nPort;
        }
    }

    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_COMMAND_CHANGE_LEVEL_TO_LOGIN);
    resPacket.WriteInt(tid);
    resPacket.WriteString(ip.c_str());
    resPacket.WriteInt(port);

    resPacket.WriteBinary(temp_buf, nLen);
//  resPacket.WriteString(temp_buf);
    resPacket.End();

    SendClientPacket(uid, svid, &resPacket, pSocket);
    return 0;
}


int CGameServer::ProcessCheckUserTable(int uid, int svid, int cmd,NETInputPacket *pPacket, SocketHandler *pSocket)
{
	short level = pPacket->ReadShort();
	short flag = pPacket->ReadShort();
	NETOutputPacket reqPacket;
    reqPacket.Begin(SYS_GET_USER_TABLE_COMMON);
    reqPacket.WriteInt(uid);
    reqPacket.WriteInt(svid);//大厅server id
	reqPacket.WriteShort(level);
    reqPacket.WriteInt(cmd);
	reqPacket.WriteShort(flag);
    reqPacket.End();

	g_pDebugLog->logMsg("ProcessCheckUserTable||uid[%d] level[%d] cmd[%x] flag[%d]", uid, level, cmd, flag);
	
    int userServerId = uid%(int)m_UserServerList.size();
    CUserServer* pUserServer = GetUserServer(userServerId);
    if(pUserServer != NULL)
    {
        pUserServer->TransferPacket(&reqPacket);
    }
    else
    {
#ifndef WIN32
        g_pErrorLog->logMsg("ProcessUserJoinGame||pUserServer==NULL,uid:[%d]", uid);
#endif
    }
}


int CGameServer::ProcessCheckServerStatus(NETInputPacket *pPacket, SocketHandler *pSocket)
{
	CLogicServer *pLogicServer = NULL;
	vector<CLogicServer*>  serverList;
	ServerList::iterator iter = m_ServerList.begin();
	for(; iter!=m_ServerList.end(); iter++)
	{
		pLogicServer = iter->second;
		if(pLogicServer != NULL)
			serverList.push_back(pLogicServer);
	}

	NETOutputPacket outPkg;
	outPkg.Begin(CMD_CHECK_SERVER_STATUS);
	outPkg.WriteInt(m_nLevel);		
	outPkg.WriteInt(serverList.size());	
	for (int i=0; i<serverList.size(); i++)
	{
		outPkg.WriteInt(serverList[i]->m_nServerId);	
		outPkg.WriteInt(serverList[i]->m_nPort);	
		outPkg.WriteInt(serverList[i]->m_nRetire);
		outPkg.WriteInt(serverList[i]->m_nUserCount);
		outPkg.WriteInt(serverList[i]->m_nCreateTime);
		//ACE_DEBUG((LM_ERROR, ACE_TEXT("[%D]CheckServerStatus size=%d, svid=%d, port=%d, userCount=%d retire=%d, #######  \n"), 
		//	serverList.size(), serverList[i]->m_nServerId, serverList[i]->m_nPort, serverList[i]->m_nUserCount, serverList[i]->m_nRetire));
	}
	outPkg.End();

	if(pSocket)
		pSocket->Send(&outPkg);
	return 0;
}

CGameTable* CGameServer::FindCreateTable(int uid)
{
    CGameTable* table = NULL;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!= m_ServerList.end(); iterServer++)
    {
       CLogicServer *pServer = iterServer->second;
       TableList::iterator iterTable = pServer->m_TableLoveGirlList.begin();
       for(; iterTable!=pServer->m_TableLoveGirlList.end(); iterTable++)
       {
           CGameTable * pTable = iterTable->second;
           if(pTable != NULL &&pTable->m_nUserCount !=0 && pTable->m_nOwnerUid == uid)
           {
               return  pTable;
           }
       }
       TableList::iterator itTable = pServer->m_TableList.begin();
       for(; itTable!=pServer->m_TableList.end(); itTable++)
       {
           CGameTable * pTable = itTable->second;
           if(pTable != NULL && pTable->m_nUserCount !=0 && pTable->m_nOwnerUid == uid)
           {
                return pTable;
           }
       }
    }
    return NULL;
}



int CGameServer::ProcessPrivateRoomCreate(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
       g_pDebugLog->logMsg("ProcessPrivateRoomCreate|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
       return 0;
    }

    int roomType = pPacket->ReadInt();
    int baseChip = pPacket->ReadInt();
   /* map<int, TPrivateRoomConf>::iterator it =m_nPrivateRoomConf.find(baseChip);
    if (it == m_nPrivateRoomConf.end())
    {
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_CREATE_PRIVATEROOM);
        resPacket.WriteInt(-1);
        resPacket.End();
        return 0;
    }
*/
    int money = pPacket->ReadInt();
    string roomName = pPacket->ReadString();
    string password = pPacket->ReadString();
    int isLoveGirl = pPacket->ReadInt();
    string loveGirlStr="";
    loveGirlStr = pPacket->ReadString();

    int ret = 1;
    int tid = 0;
    int serverId = 0;
    string ip = "";
    int port = 0;
    int roomIndex = 0;
    int createTime = time(NULL);

    CGameTable* pTable = FindCreateTable(uid);
    if (pTable != NULL)
    {
          NETOutputPacket resPacket;
          resPacket.Begin(SERVER_CMD_CREATE_PRIVATEROOM);
          resPacket.WriteInt(ret);
          resPacket.WriteInt(pTable->m_nServerId);
          resPacket.WriteInt(pTable->m_nTid);
          resPacket.WriteString(pTable->m_pServer->m_strIp.c_str());
          resPacket.WriteInt(pTable->m_pServer->m_nPort);
          resPacket.WriteInt(pTable->m_nRoomIndex);
          resPacket.WriteInt(pTable->m_nCreateTime);
          resPacket.End();
          SendClientPacket(uid, svid, &resPacket, pSocket);
          return 0;
    }

    CountTableList::iterator iterCount = m_CountTableList.find(0);//找人数为0的房间给他
    if(iterCount != m_CountTableList.end())
    {
        TableList& tableMap = iterCount->second;
        TableList::iterator iterTable = tableMap.begin();
        for(; iterTable!=tableMap.end(); )
        {
            pTable = iterTable->second;
            if(pTable != NULL)
            {
                CLogicServer *pServer = GetServer(pTable->m_nServerId);
                if(pServer != NULL)
                {
                    if(pServer->m_nRetire==1 || pServer->m_nUserCount>=m_nMaxServerUserCount)
                    {
                        iterTable++;
                    }
                    else
                    {
                        tableMap.erase(iterTable);
                        TableList& tableNewMap = m_CountTableList[1];
                        tableNewMap[pTable->m_nTid] = pTable;
                        pTable->m_nOwnerUid = uid;
                        pTable->m_nUserCount = 1;
                        pTable->m_nRoomType = roomType;
                        pTable->m_nBaseChip = baseChip;
                        pTable->m_strPassword = password;
                        pTable->m_strRoomName = roomName;
                        pTable->m_nIsLoveGirl = isLoveGirl;
                        pTable->m_nLoveGirlStr = loveGirlStr;
                        pTable->m_nCreateTime = createTime;
                        pTable->m_pServer = pServer;
                       
                     //   pTable->m_strRoomNameLow = ToLower(roomName);
                        pTable->m_bDirtyRoomName = (CDirtyWordsFilter::Instance()->doFilter(ToLower(roomName).c_str()) > 0) ? 1 : 0;
                        if (pTable->m_bDirtyRoomName == 1)
                        {
                            pTable->m_strRoomName="*****";
                        }

                        tid = pTable->m_nTid;
                        ip = pServer->m_strIp;
                        port = pServer->m_nPort;
                        serverId = pTable->m_nServerId;

                        pTable->m_nRoomIndex = GetPrivateRoomIndex(tid);
                        
                        if (pTable->m_nRoomIndex == 0) //一般不可能出现
                        {
                            AddPrivateRoomIndex(tid);
                            pTable->m_nRoomIndex = GetPrivateRoomIndex(tid);
                        }
                        if (isLoveGirl) 
                        {
                            pServer->AddLoveTable(tid);
                        } else {
                            pServer->RemoveLoveTable(tid);
                        }
                        roomIndex = pTable->m_nRoomIndex;
                        
                        if(pServer->m_pSocketHandler != NULL)
                        {
                            NETOutputPacket reqPacket;
                            reqPacket.Begin(CMD_PUSH_CREATE_PRIVATE_ROOM);
                            reqPacket.WriteInt(tid);
                            reqPacket.WriteInt(roomType);
                            reqPacket.WriteInt(baseChip);
                            reqPacket.WriteString(roomName.c_str());
                            reqPacket.WriteString(password.c_str());
                            reqPacket.WriteInt(uid);
                            reqPacket.WriteInt(isLoveGirl);
                            reqPacket.WriteInt(pTable->m_nRoomIndex);
                            reqPacket.WriteInt(pTable->m_nCreateTime);
                            reqPacket.End();
                            pServer->m_pSocketHandler->Send(&reqPacket);
                        }
                        break;
                    }
                }
                else
                {
                    iterTable++;
                }
            }
            else
            {
                tableMap.erase(iterTable++);
            }
        }
    }
    
    if(tid == 0)
    {
        //新建一个私人房间
        vector<SERVERINFO> vecServer;
        ServerList::iterator iterServer = m_ServerList.begin();
        for(; iterServer!=m_ServerList.end(); iterServer++)
        {
            CLogicServer *pLogicServer =  iterServer->second;
            if(pLogicServer != NULL)
            {
                if(pLogicServer->m_nRetire==0 && pLogicServer->m_nUserCount<m_nMaxServerUserCount)
                {
                    SERVERINFO serverInfo;
                    serverInfo.serverId = pLogicServer->m_nServerId;
                    serverInfo.userCount = pLogicServer->m_nUserCount;
                    vecServer.push_back(serverInfo);
                }
            }
        }
        if(vecServer.size() > 0)
        {
            std::sort(vecServer.begin(), vecServer.end(), Less_ServerUserCount);
            SERVERINFO &sInfo = vecServer[0];
            CLogicServer *pServer = m_ServerList[sInfo.serverId];
            if(pServer != NULL)
            {
                int sid = sInfo.serverId;
                int newTableId = (sid<<16) + pServer->m_nTableCount;
                CGameTable *pNewTable = new CGameTable(newTableId, sInfo.serverId, 0,0);
                if(pNewTable != NULL)
                {                 
                    pServer->m_nTableCount++;
                    pServer->m_nUserCount++;
                    tid = newTableId;
                    ip = pServer->m_strIp;
                    port = pServer->m_nPort;
                    serverId = pNewTable->m_nServerId;
                    pServer->m_TableList[newTableId] = pNewTable;
                    pNewTable->m_nUserCount++;
                    pNewTable->m_nRoomType = roomType;
                    pNewTable->m_nBaseChip = baseChip;
                    pNewTable->m_strPassword = password;
                    pNewTable->m_strRoomName = roomName;
                    pNewTable->m_nIsLoveGirl = isLoveGirl;
                    pNewTable->m_nLoveGirlStr = loveGirlStr;
                    pNewTable->m_nCreateTime  = createTime;
                    pNewTable->m_pServer = pServer;
                 
                    pNewTable->m_bDirtyRoomName = (CDirtyWordsFilter::Instance()->doFilter(ToLower(roomName).c_str()) > 0) ? 1 : 0;
                    if (pNewTable->m_bDirtyRoomName == 1)
                    {
                        pNewTable->m_strRoomName="*****";
                    }

                    AddPrivateRoomIndex(tid);
                    pNewTable->m_nRoomIndex = GetPrivateRoomIndex(tid);
                    if (isLoveGirl) 
                    {
                        pServer->AddLoveTable(tid);
                    } else {
                        pServer->RemoveLoveTable(tid);
                    }
                    roomIndex = pNewTable->m_nRoomIndex;
                    
                    CountTableList::iterator iterCount = m_CountTableList.find(pNewTable->m_nUserCount);
                    if(iterCount != m_CountTableList.end())
                    {
                        TableList& tableMap = iterCount->second;
                        tableMap[newTableId] = pNewTable;
                    }
                    else
                    {
                        TableList& tableMap = m_CountTableList[pNewTable->m_nUserCount];
                        tableMap[newTableId] = pNewTable;
                    }
                }

                if(pServer->m_pSocketHandler != NULL)
                {
                    NETOutputPacket reqPacket;
                    reqPacket.Begin(CMD_PUSH_CREATE_PRIVATE_ROOM);
                    reqPacket.WriteInt(tid);
                    reqPacket.WriteInt(roomType);
                    reqPacket.WriteInt(baseChip);
                    reqPacket.WriteString(roomName.c_str());
                    reqPacket.WriteString(password.c_str());
                    reqPacket.WriteInt(uid);
                    reqPacket.WriteInt(isLoveGirl);
                    reqPacket.WriteInt(pNewTable->m_nRoomIndex);
                    reqPacket.WriteInt(pNewTable->m_nCreateTime);
                    reqPacket.End();
                    pServer->m_pSocketHandler->Send(&reqPacket);
                }
            }
        } else {
            ret = 0; //创建失败
        }
    }

    if (ret == 1)
    {
        g_pDebugLog->logMsg("%s|uid=[%d] tid=[%d] roomType=[%d] baseChip=[%d] money=[%d] roomName=[%s] password[%s] isLoveGirl=[%d] roomIndex=[%d] success!", __FUNCTION__, uid,tid, roomType, baseChip, money, roomName.c_str(), password.c_str(), isLoveGirl, roomIndex);
    }
    else {
        g_pDebugLog->logMsg("%s|uid=[%d] tid=[%d] roomType=[%d] baseChip=[%d] money=[%d] roomName=[%s] password[%s] isLoveGirl=[%d] error", __FUNCTION__, uid, tid, roomType, baseChip, money, roomName.c_str(), password.c_str(), isLoveGirl);
    }
    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_CREATE_PRIVATEROOM);
    resPacket.WriteInt(ret);
    resPacket.WriteInt(serverId);
    resPacket.WriteInt(tid);
    resPacket.WriteString(ip.c_str());
    resPacket.WriteInt(port);
    resPacket.WriteInt(roomIndex);
    resPacket.WriteInt(createTime);
    resPacket.End();
    SendClientPacket(uid, svid, &resPacket, pSocket);

    return 0;
}


int CGameServer::ProcessPrivateRoomEnter(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessPrivateRoomEnter|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
  
    int roomIndex = pPacket->ReadInt();
    string password = pPacket->ReadString();
    int createTime = pPacket->ReadInt();
    map<int,int>::iterator it = m_nTableIndexList.find(roomIndex);
    if (it == m_nTableIndexList.end())
    {
        g_pDebugLog->logMsg("ProcessPrivateRoomEnter|| error, uid:[%d], roomIndex=[%d]",uid, roomIndex);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int tid = it->second;
   
    int serverId = (tid>>16);
    CLogicServer *pServer = GetServer(serverId);
    if(pServer != NULL)
    {
        CGameTable *pTable = pServer->GetTable(tid);
        int errorCode = 0;
        if(pTable != NULL)
        {
            if(pTable->m_nUserCount == 0 || pTable->m_nCreateTime != createTime)
            {
                errorCode = ERROR_ROOM_NOT_EXIST;
            }
            else if(password != pTable->m_strPassword)
            {
                errorCode = ERROR_PASSWORD;
            }
            else if(pTable->m_nUserCount == m_nMaxTableUserCount)
            {
                errorCode = ERROR_MAX_USERCOUNT;
            }
        }
        else
        {
            errorCode = ERROR_ROOM_NOT_EXIST;
        }
        g_pDebugLog->logMsg("ProcessPrivateRoomEnter||uid:[%d], tid=[%d]  password=[%s]  createTime[%d] errorCode=[%d] ",uid, tid,password.c_str(),createTime, errorCode);

        if(errorCode)
        {
            NETOutputPacket resPacket;
            resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
            resPacket.WriteShort(0);  //大厅用
            resPacket.WriteInt(errorCode);
            resPacket.End();
            SendClientPacket(uid, svid, &resPacket, pSocket);
        }
        else
        {
            string ip = "";
            int port = 0;
            if(pServer->m_nRetire == 0)
            {
                ip = pServer->m_strIp;
                port = pServer->m_nPort;
            }
            NETOutputPacket resPacket;
            resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
            resPacket.WriteShort(1);   //大厅用
            resPacket.WriteString(ip.c_str());
            resPacket.WriteInt(port);
            resPacket.WriteInt(tid);
            resPacket.WriteInt(pTable->m_nRoomIndex);
            resPacket.WriteString(pTable->m_nLoveGirlStr);
            resPacket.End();
            SendClientPacket(uid, svid, &resPacket, pSocket);
        }
    } else {
        g_pDebugLog->logMsg("ProcessPrivateRoomEnter||uid:[%d], tid=[%d] pServer= NULL",uid, tid);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_ENTER_PRIVATEROOM);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
    }
    return 0;
}

int CGameServer::ProcessPrivateRoomFind(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessPrivateRoomFind|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_FIND_PRIVATE_ROOM);
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
       return 0;
    }

    int roomIndex = pPacket->ReadInt();

    map<int,int>::iterator it = m_nTableIndexList.find(roomIndex);
    if (it == m_nTableIndexList.end())
    {
        g_pDebugLog->logMsg("ProcessPrivateRoomFind|| error, uid:[%d], roomIndex=[%d]",uid, roomIndex);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_FIND_PRIVATE_ROOM);
        resPacket.WriteInt(0);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;

    }
    int tid = it->second;
    int serverID  = (tid >> 16);
    CGameTable* pTable =  NULL;
    ServerList::iterator iterServer = m_ServerList.find(serverID);
    if(iterServer!= m_ServerList.end())
    {
        CLogicServer *pServer = iterServer->second;
        if(pServer!=NULL && pServer->m_nRetire==0)
        {
            pTable = pServer->GetTable(tid);
        }
    }
    if (pTable == NULL || pTable->m_nUserCount == 0)
    {
        g_pDebugLog->logMsg("ProcessFindPrivateRoom|| uid=[%d] tid=[%d] svid=[%d] not find", uid, tid);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_FIND_PRIVATE_ROOM);
        resPacket.WriteInt(0);  //没有这个房间
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    g_pDebugLog->logMsg("ProcessFindPrivateRoom|| uid=[%d] tid=[%d] svid=[%d] find success", uid, tid);
    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_FIND_PRIVATE_ROOM);
    resPacket.WriteInt(1);
    resPacket.WriteInt(pTable->m_nTid);
    resPacket.WriteInt(pTable->m_nRoomType);
    resPacket.WriteInt(pTable->m_nBaseChip);
    resPacket.WriteInt(pTable->m_nUserCount);
    short hasPassword = 0;
    if(pTable->m_strPassword != "")
    {
        hasPassword = 1;
    }
    resPacket.WriteInt(hasPassword);
    resPacket.WriteString(pTable->m_strRoomName.c_str());
    resPacket.WriteInt(pTable->m_nOwnerUid);
    resPacket.WriteInt(pTable->m_nIsLoveGirl);
    resPacket.WriteInt(pTable->m_nRoomIndex);
    resPacket.WriteString(pTable->m_nLoveGirlStr);
    resPacket.WriteInt(pTable->m_nCreateTime);
    resPacket.End();
    SendClientPacket(uid, svid, &resPacket, pSocket);
    return 0;
}


int CGameServer::ProcessPrivateRoomList(int uid, int svid, NETInputPacket *pPacket, SocketHandler *pSocket)
{
    int level = pPacket->ReadInt();
    if(m_nLevel != level)//server不是私人房等级
    {
        g_pDebugLog->logMsg("ProcessPrivateRoomList||level error, uid:[%d], level:[%d]", uid, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(SERVER_CMD_LIST_PRIVATE_ROOM);
        resPacket.WriteInt(0);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }

    vector<CGameTable*> list;
    list.clear();
    vector<CGameTable*> mlist;
    mlist.clear();
    int index = 0;
    int mIndex = 0;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!= m_ServerList.end(); iterServer++)
    {
        CLogicServer *pServer = iterServer->second;
        if(pServer!=NULL && pServer->m_nRetire==0)
        {
            TableList::iterator iterTable = pServer->m_TableLoveGirlList.begin();
            for(; iterTable!=pServer->m_TableLoveGirlList.end(); iterTable++)
            {
                CGameTable * pTable = iterTable->second;
                if(pTable != NULL)
                {
                    if(pTable->m_nUserCount>0 && pTable->m_nUserCount< m_nMaxTableUserCount)
                    {
                        list.push_back(pTable);
                        index++;
                        if(index >= m_nMaxListLoveGirlRoomCount)
                            break;
                    } else if (pTable->m_nUserCount ==  m_nMaxTableUserCount && mIndex < m_nMaxListPriRoomCount) {
                        mlist.push_back(pTable);
                        mIndex++;
                    }
                }
            }
        }

        if(index >= m_nMaxListLoveGirlRoomCount)
            break;
    }
    g_pDebugLog->logMsg("ProcessPrivateRoomList|| uid:[%d] index=[%d]  m_nMaxListLoveGirlRoomCount=[%d] m_nMaxListPriRoomCount=[%d]", uid,index,m_nMaxListLoveGirlRoomCount,m_nMaxListPriRoomCount );
    
    if (index < m_nMaxListPriRoomCount)
    {
        int rand_index = 0;
        int max_index = 20; //每次最多刷新20个
        vector<CGameTable*> rand_list;
        rand_list.clear();
        
        iterServer = m_ServerList.begin();
        for(; iterServer!= m_ServerList.end(); iterServer++)
        {
            CLogicServer *pServer = iterServer->second;
            if(pServer!=NULL && pServer->m_nRetire==0)
            {
                TableList::iterator iterTable = pServer->m_TableList.begin();
                for(; iterTable!=pServer->m_TableList.end(); iterTable++)
                {
                    CGameTable * pTable = iterTable->second;
                    if(pTable != NULL)
                    {
                        if(pTable->m_nUserCount>0 && pTable->m_nUserCount< m_nMaxTableUserCount/*MAX_TABLE_USER_COUNT*/)
                        {
                            rand_list.push_back(pTable);
                            rand_index++;
                            if(rand_index >= max_index) 
                                break;
                        } else if (pTable->m_nUserCount == m_nMaxTableUserCount && mIndex < m_nMaxListPriRoomCount) {
                            mlist.push_back(pTable);
                            mIndex++;
                        }
                    }
                }
            }
            if(rand_index >= max_index)
                break;
        }
        int size = rand_list.size();
        vector<CGameTable*>Result;
        Result.clear();
        RandVector(rand_list,Result);
        for (int i = 0; i < size; i++)
        {
            CGameTable * pTable = Result[i];
            list.push_back(pTable);
            index++;
            if(index >= m_nMaxListPriRoomCount)
            break;
        }
    }
   g_pDebugLog->logMsg("ProcessPrivateRoomList|| uid:[%d] index=[%d] mIndex[%d]  m_nMaxListLoveGirlRoomCount=[%d] m_nMaxListPriRoomCount=[%d]", uid,index,mIndex, m_nMaxListLoveGirlRoomCount,m_nMaxListPriRoomCount );
  
 
    SortTabeList(list);
    int size = list.size();
    int msize = mlist.size();
    if (size > m_nMaxListPriRoomCount)
    {
       SortTabeList(mlist);
       msize = 0;
    }
    int total = size + msize;
    g_pDebugLog->logMsg("size=[%d] msize=[%d] total=[%d]", size, msize, total);

    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_LIST_PRIVATE_ROOM);
    resPacket.WriteInt(1);
    resPacket.WriteInt(total);
   
    for(int i = 0; i < size; i++)
    {
        CGameTable *pTable =  list[i];
        if(pTable != NULL)
        {
            resPacket.WriteInt(pTable->m_nTid);
            resPacket.WriteInt(pTable->m_nRoomType);
            resPacket.WriteInt(pTable->m_nBaseChip);
            resPacket.WriteInt(pTable->m_nUserCount);
            int hasPassword = 0;
            if(pTable->m_strPassword != "")
            {
                hasPassword = 1;
            }
            resPacket.WriteInt(hasPassword);
            resPacket.WriteString(pTable->m_strRoomName.c_str());
            resPacket.WriteInt(pTable->m_nOwnerUid);
            resPacket.WriteInt(pTable->m_nIsLoveGirl);
            resPacket.WriteInt(pTable->m_nRoomIndex);
            resPacket.WriteString(pTable->m_nLoveGirlStr);
            resPacket.WriteInt(pTable->m_nCreateTime);
          // g_pDebugLog->logMsg("%s|uid=[%d] tid=[%d] isLoveGirl=[%d] roomIndex=[%d] CreateTime[%d]", __FUNCTION__, uid,pTable->m_nTid,pTable->m_nIsLoveGirl,pTable->m_nRoomIndex,pTable->m_nCreateTime);
        }
    }

    for(int i = 0; i < msize; i++)
    {
        CGameTable *pTable =  mlist[i];
        if(pTable != NULL)
        {
            resPacket.WriteInt(pTable->m_nTid);
            resPacket.WriteInt(pTable->m_nRoomType);
            resPacket.WriteInt(pTable->m_nBaseChip);
            resPacket.WriteInt(pTable->m_nUserCount);
            int hasPassword = 0;
            if(pTable->m_strPassword != "")
            {
                hasPassword = 1;
            }
            resPacket.WriteInt(hasPassword);
            resPacket.WriteString(pTable->m_strRoomName.c_str());
            resPacket.WriteInt(pTable->m_nOwnerUid);
            resPacket.WriteInt(pTable->m_nIsLoveGirl);
            resPacket.WriteInt(pTable->m_nRoomIndex);
            resPacket.WriteString(pTable->m_nLoveGirlStr);
            resPacket.WriteInt(pTable->m_nCreateTime);
          // g_pDebugLog->logMsg("%s|uid=[%d] tid=[%d] isLoveGirl=[%d] roomIndex=[%d] CreateTime[%d]", __FUNCTION__, uid,pTable->m_nTid,pTable->m_nIsLoveGirl,pTable->m_nRoomIndex,pTable->m_nCreateTime);
        }
    }
    g_pDebugLog->logMsg("pack size=[%d] ",resPacket.packet_size());
    resPacket.End();
    SendClientPacket(uid, svid, &resPacket, pSocket);
    return 0;
}

int CGameServer::ProcessPrivateRoomRefreshCount(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();

    TableList list;
    list.clear();
    int index = 0;

    int count = pPacket->ReadInt();
  //  if (count > 10) count = 10;   //暂时限制10个
    for (int i = 0; i < count; i++)
    {
        int tid = pPacket->ReadInt();
        int serverID  = (tid >> 16);
       
        CGameTable* pTable =  NULL;
        ServerList::iterator iterServer = m_ServerList.find(serverID);
        if(iterServer!= m_ServerList.end())
        {
            CLogicServer *pServer = iterServer->second;
            if(pServer!=NULL)
            {
                pTable = pServer->GetTable(tid);
            }
        }
        if (pTable != NULL)
        {
            list[tid] = pTable;
        }
    }
    NETOutputPacket resPacket;
    resPacket.Begin(SERVER_CMD_REFRESH_PRIVATE_ROOM);
    resPacket.WriteInt((int)list.size());
    TableList::iterator iterTable = list.begin();
    for(; iterTable!=list.end(); iterTable++)
    {
        CGameTable *pTable = iterTable->second;
        if(pTable != NULL)
        {
            resPacket.WriteInt(pTable->m_nTid);
            resPacket.WriteInt(pTable->m_nRoomType);
            int serverId = pTable->m_nServerId;
            resPacket.WriteInt(serverId);
            resPacket.WriteInt(pTable->m_nBaseChip);
            resPacket.WriteInt(pTable->m_nUserCount);
            int hasPassword = 0;
            if(pTable->m_strPassword != "")
            {
                hasPassword = 1;
            }
            resPacket.WriteInt(hasPassword);
            resPacket.WriteString(pTable->m_strRoomName.c_str());
            resPacket.WriteInt(pTable->m_nOwnerUid);
            resPacket.WriteInt(pTable->m_nIsLoveGirl);
            resPacket.WriteInt(pTable->m_nRoomIndex);
            resPacket.WriteString(pTable->m_nLoveGirlStr);
            char szCreateTime[32]; sprintf(szCreateTime, "%d", pTable->m_nCreateTime); resPacket.WriteString(szCreateTime);
        }
    }
    resPacket.End();
    SendClientPacket(uid, svid, &resPacket, pSocket);


return 0;
}

void CGameServer::AddPrivateRoomIndex(int tid)
{ 
    int index = GetPrivateRoomIndex(tid);
    if (index == 0)
    {
        while (1)
        {
            index++;
            map<int, int>::iterator it = m_nTableIndexList.find(index);
            if (it == m_nTableIndexList.end())
            {
                break;
            }
        }
    }

	//printf("----------------CGameServer::AddPrivateRoomIndex---[%d] [%d]\n", tid, index);
	//fflush(stdout);
    m_nTableIdList[tid] = index;
    m_nTableIndexList[index] = tid; 
}

int CGameServer::GetPrivateRoomIndex(int tid)
{
    int index = 0;
    map<int,int>::iterator it = m_nTableIdList.find(tid);
    if (it != m_nTableIdList.end())
    {
       index = it->second;
    }
    return index;   
}



int CGameServer::ProcessUpdatePrivateMatchInfo(NETInputPacket *pPacket, SocketHandler *pSocket)
{
    (void)pSocket;
    int serverId = pPacket->ReadInt();
    int matchId = pPacket->ReadInt();
    short level = pPacket->ReadShort();
    short tableUserCount = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();
    int status = pPacket->ReadInt();
    int roomType = pPacket->ReadInt();
    int index = pPacket->ReadInt();
    int total = pPacket->ReadInt();
    int roomUid = pPacket->ReadInt();
    int createTime = pPacket->ReadInt();
    string matchName = pPacket->ReadString();
    string passWord = pPacket->ReadString();

    if(level != m_nLevel)
    {
#ifndef WIN32
        g_pDebugLog->logMsg("ProcessUpdatePrivateMatchInfo||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
#endif
        return 0;
    }
    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        pLogicServer->m_nUserCount = userCount;
        if((matchId>>16) == serverId)
        {
            CGameMatch *pMatch = GetMatch(matchId);
            if(pMatch != NULL)
            {
                pMatch->m_nCurrentNum = tableUserCount;
            }
            else
            {
                pMatch = new CGameMatch(serverId, matchId);
                if(pMatch != NULL)
                {
                    m_MatchList[matchId] = pMatch;
                    pMatch->m_nCurrentNum = tableUserCount;
                    pLogicServer->m_nMatchCount++;
                }
            }
            if (pMatch != NULL)
            {
                pMatch->m_nCreateTime = createTime;
                pMatch->m_nIndex = index;
                pMatch->m_nName = matchName;
                pMatch->m_nPassWord = passWord;
                pMatch->m_nRoomUid = roomUid;
                pMatch->m_nTotal = total;
                pMatch->m_nRoomType= roomType;
                pMatch->m_nStatus = status;
            }
            g_pDebugLog->logMsg("ProcessUpdatePrivateMatchInfo|| serverId[%d] matchId[%d] level[%d] tableUser[%d] userCount[%d] matchType[%d]",serverId, matchId, level, tableUserCount, userCount, roomType);
            g_pDebugLog->logMsg("ProcessUpdatePrivateMatchInfo|| index[%d] total[%d] roomuid[%d] createTime[%d] matchName[%s] password[%s]",index, total, roomUid, createTime, matchName.c_str(), passWord.c_str());
  
        }
    }
    return 0;
}
int CGameServer::ProcessUpdatePrivateMatchUserCount(NETInputPacket * pPacket,SocketHandler * pSocket)
{
    (void)pSocket;
    short serverId = pPacket->ReadShort();
    int matchId = pPacket->ReadInt();
    short level = pPacket->ReadShort();
    short tableUserCount = pPacket->ReadShort();
    int userCount = pPacket->ReadInt();
    int status = pPacket->ReadInt();

    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessUpdateMatchUserCount||server level error, serverId:[%hd], level:[%hd], serverLv:[%hd]", serverId, level, m_nLevel);
        return 0;
    }

    CLogicServer *pLogicServer = GetServer(serverId);
    if(pLogicServer != NULL)
    {
        pLogicServer->m_nUserCount = userCount;
        if((matchId>>16) == serverId)
        {
            CGameMatch *pMatch = GetMatch(matchId);
            if(pMatch != NULL)
            {
                pMatch->m_nCurrentNum = tableUserCount;
                pMatch->m_nStatus = status;
            }
            else
            {
                pMatch = new CGameMatch(serverId, matchId);
                if(pMatch != NULL)
                {
                    m_MatchList[matchId] = pMatch;
                    pMatch->m_nStatus = status;
                    pMatch->m_nCurrentNum = tableUserCount;
                    pLogicServer->m_nMatchCount++;
                }
            }
        }
    }
    return 0;
}


void CGameServer::AddMatchIndex(int matchID)
{ 
    int index = GetMatchIndex(matchID);
    if (index == 0)
    {
        while (1)
        {
            index++;
            map<int, int>::iterator it = m_nMatchIndexList.find(index);
            if (it == m_nMatchIndexList.end())
            {
                break;
            }
        }
    }
    m_nMatchIDList[matchID] = index;
    m_nMatchIndexList[index] = matchID; 
}

int CGameServer::GetMatchIndex(int matchID)
{
    int index = 0;
    map<int,int>::iterator it = m_nMatchIDList.find(matchID);
    if (it != m_nMatchIDList.end())
    {
       index = it->second;
    }
    return index;   
}

CGameMatch* CGameServer::CreateNewMatch()
{
    MatchList::iterator iter = m_MatchList.begin();
    for(; iter!=m_MatchList.end(); iter++)  //先遍历所有的比赛场  
    {
        CGameMatch *pMatch = iter->second;
        if(NULL != pMatch)
        {
            CLogicServer* pServer = GetServer(pMatch->m_nServerId);
            if(pServer != NULL)
            {
                if(0==pServer->m_nRetire && pMatch->m_nCurrentNum == 0 && pServer->m_nUserCount<m_nMaxServerUserCount)
                {
                    int matchID = pMatch->m_nMatchId;
                    pMatch->m_nCreateTime = time(NULL);
                    AddMatchIndex(matchID);
                    pMatch->m_nIndex  = GetMatchIndex(matchID);
                    return pMatch;
                }
            }
        }
    }
    vector<SERVERINFO> serverInfo;
    ServerList::iterator iterServer = m_ServerList.begin();
    for(; iterServer!=m_ServerList.end(); iterServer++)//查找所有的server 找出人数最少的一个server创建比赛场
    {
        CLogicServer* pServer = iterServer->second;
        if(NULL!=pServer && 0==pServer->m_nRetire && pServer->m_nUserCount<m_nMaxServerUserCount)
        {
            SERVERINFO sinfo;
            sinfo.serverId = pServer->m_nServerId;
            sinfo.userCount = pServer->m_nUserCount;
            serverInfo.push_back(sinfo);
        }
    }
    if((int)serverInfo.size() > 0)
    {
        std::sort(serverInfo.begin(), serverInfo.end(), Less_ServerUserCount);
        SERVERINFO &sInfo = serverInfo[0];
        CLogicServer *pLogicServer = m_ServerList[sInfo.serverId];
        if(pLogicServer != NULL)
        {
            int newMatchId = (sInfo.serverId<<16) + pLogicServer->m_nMatchCount + 1;
            CGameMatch *pNewMatch = new CGameMatch(sInfo.serverId, newMatchId);
            if(pNewMatch != NULL)
            {
                pLogicServer->m_nMatchCount++;
                pNewMatch->m_nCreateTime = time(NULL);
                AddMatchIndex(newMatchId);
                pNewMatch->m_nIndex  = GetMatchIndex(newMatchId);
                m_MatchList[newMatchId] = pNewMatch;
                return pNewMatch;
            }
        }
    }
    
    return NULL;
}

int CGameServer::ProcessCreateMatch(int uid, int svid, NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    int roomType = pPacket->ReadInt();
    int num = pPacket->ReadInt();
    string matchName = pPacket->ReadString();
    string passWord = pPacket->ReadString();

    int matchID = 0;
    int serverId = 0;
    string ip = "";
    int port = 0;

	//检查创建房间的类型是否正确
	if(-1 == CheckRoomType(roomType))
	{
		NETOutputPacket outpkg;
        outpkg.Begin(CLIENT_CMD_CREATE_MATCH);
        outpkg.WriteInt(0);
		outpkg.WriteInt(ERROR_CREATE_ROOMTYPE);
        outpkg.End();
        SendClientPacket(uid, svid, &outpkg, pSocket);
        return 0;
	}

	if(-1 == CheckRoomCreateFull())
	{
		NETOutputPacket outpkg;
        outpkg.Begin(CLIENT_CMD_CREATE_MATCH);
        outpkg.WriteInt(0);
		outpkg.WriteInt(ERROR_CREATE_MAX_ROOMCOUNT);
        outpkg.End();
        SendClientPacket(uid, svid, &outpkg, pSocket);
        return 0;
	}
	
    CGameMatch* pMatch = CreateNewMatch();
    if (pMatch == NULL)
    {
        NETOutputPacket outpkg;
        outpkg.Begin(CLIENT_CMD_CREATE_MATCH);
        outpkg.WriteInt(0);
		outpkg.WriteInt(ERROR_CREATE_FAILED);
        outpkg.End();
        SendClientPacket(uid, svid, &outpkg, pSocket);
        return 0;
    }
    pMatch->m_nRoomUid = uid;
    pMatch->m_nCurrentNum = 1;
    pMatch->m_nPassWord = passWord;
    pMatch->m_nName = matchName;
    pMatch->m_nTotal = num;
    pMatch->m_nRoomType= roomType;
    pMatch->m_nStatus = WAITING;
	
    g_pDebugLog->logMsg("[ProcessCreateMatch] uid[%d] matchId[%d] index[%d] matchType[%d] total[%d] level[%d] matchName[%s] \
		passWord[%s]", uid,pMatch->m_nMatchId,pMatch->m_nIndex, roomType, num, level, matchName.c_str(), passWord.c_str());

	ServerList::iterator it = m_ServerList.find(pMatch->m_nServerId);
    if (it != m_ServerList.end())
    {
        CLogicServer* pLogServer = it->second;
         
        serverId = pLogServer->m_nServerId;
        ip = pLogServer->m_strIp;
        port = pLogServer->m_nPort;
        matchID = pMatch->m_nMatchId;
        
        NETOutputPacket outpkg;
        outpkg.Begin(SERVER_CREATE_MATCH);
        outpkg.WriteInt(pMatch->m_nMatchId);
        outpkg.WriteInt(pMatch->m_nRoomUid);
        outpkg.WriteInt(pMatch->m_nRoomType);
        outpkg.WriteInt(pMatch->m_nTotal);
        outpkg.WriteInt(pMatch->m_nCreateTime);
        outpkg.WriteInt(pMatch->m_nIndex);
        outpkg.WriteString(pMatch->m_nName.c_str());
        outpkg.WriteString(pMatch->m_nPassWord.c_str());
        outpkg.End();
        pLogServer->m_pSocketHandler->Send(&outpkg);
       
    }

    NETOutputPacket response;
    response.Begin(CLIENT_CMD_CREATE_MATCH);
    response.WriteInt(1);
    response.WriteInt(serverId);
    response.WriteInt(matchID);
    response.WriteString(ip.c_str());
    response.WriteInt(port);
    response.WriteInt(pMatch->m_nIndex);
    response.WriteInt(pMatch->m_nCreateTime);
    response.End();
    SendClientPacket(uid, svid, &response, pSocket);

	return 0;
}


int CGameServer::ProcessEnterMatch(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessEnterMatch|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
  
    int roomIndex = pPacket->ReadInt();
    string password = pPacket->ReadString();
    int createTime = pPacket->ReadInt();
    map<int,int>::iterator it = m_nMatchIndexList.find(roomIndex);
    if (it == m_nMatchIndexList.end())
    {
        g_pDebugLog->logMsg("ProcessEnterMatch|| error, uid:[%d], roomIndex=[%d]",uid, roomIndex);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int matchId = it->second;
    CGameMatch* pMatch = GetMatch(matchId);
    if (pMatch == NULL)
    {
        g_pDebugLog->logMsg("ProcessEnterMatch|| error, uid:[%d], roomIndex=[%d] matchID[%d]",uid, roomIndex, matchId);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    if (pMatch->m_nStatus == MATCHING)
    {
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_MATCH_BEGIN);                        
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        g_pDebugLog->logMsg("ProcessEnterMatch|| error, uid:[%d], roomIndex=[%d] matchID[%d] matchbegin",uid, roomIndex, matchId);
        return 0;
    }
   
    int serverId = pMatch->m_nServerId;
    CLogicServer *pServer = GetServer(serverId);
    if(pServer != NULL)
    {
       
        int errorCode = 0;
       
        if(pMatch->m_nCurrentNum == 0 || pMatch->m_nCreateTime != createTime)
        {
            errorCode = ERROR_ROOM_NOT_EXIST;
        }
        else if(password != pMatch->m_nPassWord)
        {
            errorCode = ERROR_PASSWORD;
        }
        else if(pMatch->m_nCurrentNum == pMatch->m_nTotal)
        {
            errorCode = ERROR_MAX_USERCOUNT;
        }
       
        g_pDebugLog->logMsg("ProcessEnterMatch||uid:[%d], matchId=[%d]  password=[%s]  createTime[%d] errorCode=[%d] ",uid, matchId,password.c_str(),createTime, errorCode);

        if(errorCode)
        {
            NETOutputPacket resPacket;
            resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
            resPacket.WriteShort(0);  //大厅用
            resPacket.WriteInt(errorCode);
            resPacket.End();
            SendClientPacket(uid, svid, &resPacket, pSocket);
        }
        else
        {
            string ip = "";
            int port = 0;
            if(pServer->m_nRetire == 0)
            {
                ip = pServer->m_strIp;
                port = pServer->m_nPort;
            }
            NETOutputPacket resPacket;
            resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
            resPacket.WriteShort(1);   //大厅用
            resPacket.WriteString(ip.c_str());
            resPacket.WriteInt(port);
            resPacket.WriteInt(matchId);
            resPacket.WriteInt(pMatch->m_nIndex);
            resPacket.WriteInt(pMatch->m_nRoomType);
            resPacket.WriteInt(pMatch->m_nStatus);
            resPacket.End();
            SendClientPacket(uid, svid, &resPacket, pSocket);
        }
    } 
	else 
	{
        g_pDebugLog->logMsg("ProcessEnterMatch||uid:[%d], matchId=[%d] pServer= NULL",uid, matchId);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_ENTER_MATCH);
        resPacket.WriteShort(0);  //大厅用
        resPacket.WriteInt(ERROR_ROOM_NOT_EXIST);
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
    }
    return 0;
}

int CGameServer::ProcessFindMatch(int uid, int svid, NETInputPacket * pPacket,SocketHandler * pSocket)
{
    int level = pPacket->ReadInt();
    if(level != m_nLevel)
    {
        g_pDebugLog->logMsg("ProcessFindMatch|| level error, uid:[%d], level:[%d] m_nLevel=[%d]",uid, level, m_nLevel);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_FIND_MATCH);
        resPacket.WriteInt(0);            
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int roomIndex = pPacket->ReadInt();
    map<int,int>::iterator it = m_nMatchIndexList.find(roomIndex);
    if (it == m_nMatchIndexList.end())
    {
        g_pDebugLog->logMsg("ProcessFindMatch|| error, uid:[%d], roomIndex=[%d]",uid, roomIndex);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_FIND_MATCH);
        resPacket.WriteInt(0);   
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }
    int matchId = it->second;
    CGameMatch* pMatch = GetMatch(matchId);
    if (pMatch == NULL)
    {
        g_pDebugLog->logMsg("ProcessFindMatch|| error, uid:[%d], roomIndex=[%d] matchID[%d]",uid, roomIndex, matchId);
        NETOutputPacket resPacket;
        resPacket.Begin(CLIENT_CMD_FIND_MATCH);
        resPacket.WriteInt(0);              
        resPacket.End();
        SendClientPacket(uid, svid, &resPacket, pSocket);
        return 0;
    }

     NETOutputPacket outpkg;
     outpkg.Begin(CLIENT_CMD_FIND_MATCH);
     outpkg.WriteInt(1);           
     outpkg.WriteInt(pMatch->m_nMatchId);
     outpkg.WriteInt(pMatch->m_nRoomUid);
     outpkg.WriteInt(pMatch->m_nRoomType);
     outpkg.WriteInt(pMatch->m_nTotal);
     outpkg.WriteInt(pMatch->m_nCreateTime);
     outpkg.WriteInt(pMatch->m_nIndex);
     outpkg.WriteInt(pMatch->m_nStatus);
     outpkg.WriteString(pMatch->m_nName.c_str());
     outpkg.End();   
     SendClientPacket(uid, svid, &outpkg, pSocket);
return 0;
}


int CGameServer::ProcessListMatch(int uid,int svid,NETInputPacket * pPacket,SocketHandler * pSocket)
{
    vector<CGameMatch*> list;
    list.clear();
    int num = 0;
    MatchList::iterator iter = m_MatchList.begin();
    for (;iter != m_MatchList.end(); iter++)
    {
        CGameMatch* pMatch = iter->second;
        if (pMatch != NULL && pMatch->m_nRoomType == MATCH_FOR_ENTERPRISE && pMatch->m_nStatus == WAITING)
        {
            if (num == m_nSelfMaxListCount)	//默认最多5个
				break;
            list.push_back(pMatch);
            num++;
        }
    }

    NETOutputPacket outpkg;
    outpkg.Begin(CLIENT_CMD_LIST_MATCH);
    outpkg.WriteInt(num);        
    for (int i = 0; i < num; i++)
    {
        CGameMatch* pMatch = list[i];
        outpkg.WriteInt(pMatch->m_nMatchId);
        outpkg.WriteInt(pMatch->m_nRoomUid);
        outpkg.WriteInt(pMatch->m_nRoomType);
        outpkg.WriteInt(pMatch->m_nTotal);
        outpkg.WriteInt(pMatch->m_nCreateTime);
        outpkg.WriteInt(pMatch->m_nIndex);
        outpkg.WriteInt(pMatch->m_nStatus);
        outpkg.WriteString(pMatch->m_nName.c_str());
    }
    outpkg.End();   
    SendClientPacket(uid, svid, &outpkg, pSocket);

return 0;
}

int CGameServer::CheckRoomType(int nRoomType)
{
	if(nRoomType != MATCH_FOR_PEESONAL && nRoomType != MATCH_FOR_ENTERPRISE)
	{
		return -1;
	}

	return 0;
}

int CGameServer::CheckRoomCreateFull()
{
	int nCurCount = m_MatchList.size();
	if(nCurCount >= m_nMaxRoomCreateCount)
	{
		return -1;
	}

	return 0;
}
void  CGameServer::SetClubID(map<int, vector<int> > &testGroupList,int player_id,int group_id,int type) {
	if (type == 0 || type == 2) {
		if (testGroupList.find(group_id) != testGroupList.end()) {
			map<int, vector<int> >::iterator it = testGroupList.find(group_id);
			vector<int>::iterator uidIte = find(it->second.begin(), it->second.end(), player_id);
			if (uidIte == it->second.end()) {
				it->second.push_back(player_id);
			}
		}
		else {
			vector<int> v;
			v.push_back(player_id);
			testGroupList[group_id] = v;
		}
	}
	else if (type == 1) {
		if (testGroupList.find(group_id) != testGroupList.end()) {
			testGroupList.erase(testGroupList.find(group_id));

		}
	}
	else if (type == 3) {
		if (testGroupList.find(group_id) != testGroupList.end()) {
			
			map<int, vector<int> >::iterator it = testGroupList.find(group_id);
			vector<int>::iterator uidIte = find(it->second.begin(), it->second.end(), player_id);
			if (uidIte != it->second.end()) {
				g_pDebugLog->logMsg("player_id[%d] uidIte[%d]", player_id, uidIte);
				it->second.erase(uidIte);
			}
		}
	}
	
}

/*---------------------------- by neo ------------------------------*/
int CGameServer::ProcessUpdateTableList(NETInputPacket *pPacket)
{
	int level = pPacket->ReadInt();
	int tid = pPacket->ReadInt();
	int nUid = pPacket->ReadInt();
	int	game_type = pPacket->ReadInt();

	CWebServer::Instance()->httpUpdateTableList(level, tid, nUid, game_type);

	return 0;
}
int CGameServer::checkTableListTest(int levelC, int club_id, int groupTypeTemp) {
	vector<groupConfigInfo> listConfig = m_pDBClient->GetConfigList(club_id, levelC);
	
	/*for (int i = 0; i < 3; i++)
	{*/
		int m_nCreateTime = time(NULL);
		int tid = m_nCreateTime + 1;
		int serverId = levelC * 20 + 40000;
		int randa = (rand() % (90 - 60)) + 60;
		CGameTable* table = new CGameTable(tid, serverId, levelC, club_id);

		table->m_pGameServer = this;
		table->gameType = 90;
		 int randConfig = rand() % listConfig.size();
		table->configId = listConfig[randConfig].mid;
		table->groupName = listConfig[randConfig].Name;
		
		table->totalRound = 8;
		Json::Value tableInfo;
		Json::FastWriter fastWriter;
		Json::Reader reader;

		Json::Value m_tableInfo;
		Json::FastWriter m_fastWriter;
		m_tableInfo["baseChip"] = 1;
		m_tableInfo["inviteCode"] = 012461;
		m_tableInfo["joinGamePoint"] = 10;
		m_tableInfo["maxSeatCount"] = 8;
		m_tableInfo["readyPoint"] = 1;
		m_tableInfo["round"] = 8;
		m_tableInfo["choupai"] = 0;
		m_tableInfo["huxi_score"] = 1;
		m_tableInfo["back_score"] = 2;
		string info = fastWriter.write(m_tableInfo);
		table->jsonConfig = info;
		

		for (int i = 0; i < listConfig.size(); i++)
		{
			CUserBalanceInfo* userinfo = new CUserBalanceInfo();
			userinfo->m_sex = 0;
			userinfo->m_nickname = "rtery";
			userinfo->latitude = "0";
			userinfo->longitude = "0";
			userinfo->ip = "127.0.0.1";
			userinfo->m_portrait = "https://c-ssl.duitang.com/uploads/blog/202107/19/20210719150601_4401e.jpg";
			userinfo->m_tid = tid;
			userinfo->club_id = club_id;
			userinfo->m_uid = GetTickCount()+i;
			Json::Reader reader;
			Json::FastWriter fastWriter2;

			Json::Value uInfJson;

			uInfJson["uid"] = userinfo->m_uid;
			uInfJson["seatId"] = i;
			uInfJson["profit"] = userinfo->m_portrait;
			string resultStr = fastWriter2.write(uInfJson);
			//g_pDebugLog->logMsg("user->info  [%s]", resultStr.c_str());
			table->userList[userinfo->m_uid] = resultStr;
			table->listBakanceInfo.push_back(userinfo);
			map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupTypeTemp);
			if (cjList != cardJiFenList.end()) {
				clubTableList::iterator it = cjList->second.find(club_id);
				if (it != cjList->second.end()) {
					TableList& tableMap = it->second;
					tableMap[table->m_nTid] = table;

					cardJiFenList[groupTypeTemp][table->club_id] = tableMap;
				}
				else {
					g_pDebugLog->logMsg("Temp2222AddClubTable");
					TableList tableMap;
					tableMap[tid] = table;
					cardJiFenList[groupTypeTemp][table->club_id] = tableMap;
				}
			}
			else {
				clubTableList clist;
				TableList tableMap;
				tableMap[table->m_nTid] = table;
				clist[club_id] = tableMap;
				cardJiFenList[groupTypeTemp] = clist;
				g_pDebugLog->logMsg("cardJiFenList Temp== size[%d]", cardJiFenList.size());
			}
		}
		joinTableTemp(table, 1);
		table->StartAutoTimer(randa);
	//}
	return 0;
}
int CGameServer::checkTableList(int levelC,int gameType,int groupTypeTemp) {
	srand(unsigned(time(NULL)));
	for (map<int, map<int, CUserBalanceInfo*> >::iterator itr = groupRobotMap.begin(); itr != groupRobotMap.end(); itr++)
	{
		 
		Json::Value tableInfo;
		Json::FastWriter fastWriter;
		Json::Reader reader;

		Json::Value m_tableInfo;
		Json::FastWriter m_fastWriter;
		int clubId = itr->first;
		vector<CUserBalanceInfo* > listTemp;
		int configId = 0;
		g_pDebugLog->logMsg("checkTableList_clubId_%d", clubId);
		vector<groupConfigInfo> listConfig = m_pDBClient->GetConfigList(clubId, levelC);
		g_pDebugLog->logMsg("listConfig.size()[%d] clubId[%d] levelC %d  gameType %d ", listConfig.size(),clubId, levelC, gameType);
		int randConfig = 0;
		vector<string> tempList;
		int max_player = 2;
		if (listConfig.size() > 0) {
			randConfig = rand() % listConfig.size();
			//g_pDebugLog->logMsg("randConfig[%d]", randConfig);
			string info = listConfig[randConfig].Config;
			
			g_pDebugLog->logMsg("groupName ===%s", listConfig[randConfig].Name.c_str());
			string infoTable;
			if (reader.parse(info, tableInfo))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
			{
				max_player = tableInfo["maxSeatCount"]["optionValue"].asInt();
				m_tableInfo["baseChip"] = tableInfo["baseChip"].asInt();
				m_tableInfo["inviteCode"] = 012461;
				m_tableInfo["joinGamePoint"] = tableInfo["joinGamePoint"].asInt();
				m_tableInfo["maxSeatCount"] = max_player;
				m_tableInfo["readyPoint"] = tableInfo["readyPoint"].asInt();
				m_tableInfo["round"] = tableInfo["round"]["optionValue"].asInt();
				//m_tableInfo["wanfa"] == tableInfo["wanfa"]["optionValue"].asInt();
				
				g_pDebugLog->logMsg("maxi uuuu===%d", tableInfo["maxSeatCount"]["optionValue"].asInt());
			}
		}
		else
		{
			continue;
		}
		
	
		for (map<int, CUserBalanceInfo*>::iterator itrItem = itr->second.begin(); itrItem != itr->second.end(); itrItem++)
		{
			if (itrItem->second->isRobot == 1) {
				if (itrItem->second->m_tid <= 0) {
					//g_pDebugLog->logMsg("itrItem->second->m_uid %d", itrItem->second->m_uid);
					string str;
					if (m_pRedisManagerClient->GetRobotStatus(itrItem->second->m_uid, str) > 0) {

						vector<int> sv;
						split(str, sv, '_');
						if (sv.size() >= 4) {
							//g_pDebugLog->logMsg("itrItem->levelC->isRobot %d levelC %d  sv[]%d", sv[3], levelC, sv[2]);
							if (sv[3] == levelC && sv[2] == 1) {
								
								listTemp.push_back(itrItem->second);
								if (listTemp.size() >= max_player) {
									break;
								}
							}
						}
					}
				}
			}
		}
		g_pDebugLog->logMsg("listTemp.size()%d  max_player %d", listTemp.size(), max_player);
		if (listTemp.size() >= max_player && (max_player > 0)) {
			int m_nCreateTime = time(NULL);
			int tid = m_nCreateTime+1;
			int serverId = levelC * 20 + 40000;
			int randa = (rand() % (90 - 60)) + 60;
			CGameTable *table = new CGameTable(tid, serverId, levelC, clubId);

			table->m_pGameServer = this;
			table->gameType = gameType;
		
			table->configId = listConfig[randConfig].mid;
			table->groupName = listConfig[randConfig].Name;
			
			
			table->totalRound = m_tableInfo["round"].asInt();
			string info = fastWriter.write(m_tableInfo);
			table->jsonConfig = info;
			

			for (int i = 0; i < listTemp.size(); i++)
			{
				CUserBalanceInfo *userinfo = listTemp[i];
				userinfo->m_tid = tid;
				userinfo->club_id = clubId;
				Json::Reader reader;
				Json::FastWriter fastWriter2;

				Json::Value uInfJson;

				uInfJson["uid"] = userinfo->m_uid;
				uInfJson["seatId"] = i;
				uInfJson["profit"] = userinfo->m_portrait;
				string resultStr = fastWriter2.write(uInfJson);
				g_pDebugLog->logMsg("user->info  [%s]", resultStr.c_str());
				table->userList[userinfo->m_uid] = resultStr;
				table->listBakanceInfo.push_back(userinfo);
			}
			table->typeTable = 1;
			table->numTable = numTable++;
			map<int, clubTableList>::iterator cjList = cardJiFenList.find(groupTypeTemp);
			if (cjList != cardJiFenList.end()) {
				clubTableList::iterator it = cjList->second.find(clubId);
				if (it != cjList->second.end()) {
					TableList& tableMap = it->second;
					tableMap[table->m_nTid] = table;
					g_pDebugLog->logMsg("Temp2222AddClubTabl66e");
					cardJiFenList[groupTypeTemp][table->club_id] = tableMap;
				}
				else {
					g_pDebugLog->logMsg("Temp2222AddClubTable");
					TableList tableMap;
					tableMap[tid] = table;
					cardJiFenList[groupTypeTemp][table->club_id] = tableMap;
				}
			}
			else {
				clubTableList clist;
				TableList tableMap;
				tableMap[table->m_nTid] = table;
				clist[clubId] = tableMap;
				cardJiFenList[groupTypeTemp] = clist;
				g_pDebugLog->logMsg("cardJiFenList Temp== size[%d]", cardJiFenList.size());
			}
			joinTableTemp(table, 1);
			table->StartAutoTimer(randa);
		}
		
	}
	return 0;
}
int CGameServer::joinTableTemp(CGameTable *pTable, int type) {
	g_pDebugLog->logMsg("joinTableTemp");
	NETOutputPacket resPacket;
	resPacket.Begin(TABLE_DATA_TEST);
	resPacket.WriteInt(pTable->club_id);
	resPacket.WriteInt(pTable->typeTable);
	resPacket.WriteInt(pTable->m_nTid);
	
	resPacket.WriteInt(pTable->m_nLevel);
	resPacket.WriteInt(pTable->configId);
	resPacket.WriteInt(pTable->gameType);
	resPacket.WriteInt(pTable->currRound);
	vector<string> userList;
	for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	{
		userList.push_back(itTemp->second);
	}
	resPacket.WriteByte(userList.size());
	for (int i = 0; i < userList.size(); i++)
	{
		resPacket.WriteString(userList[i].c_str());
	}
	//for (map<int, string>::iterator itTemp = pTable->userList.begin(); itTemp != pTable->userList.end(); itTemp++)
	//{
	//	//nUserCount++;
	//	resPacket.WriteString(itTemp->second.c_str());
	//}
	//resPacket.WriteString(pTable->jsonConfig.c_str());
	resPacket.WriteString(pTable->groupName.c_str());
	resPacket.WriteString(pTable->m_strInviteCode.c_str());
	resPacket.End();
	for (HallServerList::iterator iterHall = m_HallServerList.begin(); iterHall != m_HallServerList.end(); iterHall++)
	{
		map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
		if (playerUser != groupPlayer.end()) {
			for (int k = 0; k < playerUser->second.size(); k++)
			{
				if (iterHall->second->m_pSocketHandler != NULL)
				{
					if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
						if (userGroupType.find(playerUser->second[k])->second == 2) {
							map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
							if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
								SendClientPacket(playerUser->second[k], iterHall->first, &resPacket, iterHall->second->m_pSocketHandler);
							}
						}
					}
				}
			}
		}
	}
	return 0;
}
int CGameServer::sendRound(CGameTable *pTable) {
	NETOutputPacket resPacket;
	resPacket.Begin(SERVER_COMMAND_UPDATE_GAME_ROUND);
	resPacket.WriteInt(pTable->club_id);
	resPacket.WriteShort(pTable->m_nLevel);
	resPacket.WriteInt(pTable->m_nTid);
	resPacket.WriteInt(pTable->currRound);
	resPacket.End();
	for (HallServerList::iterator iterHall = m_HallServerList.begin(); iterHall != m_HallServerList.end(); iterHall++)
	{
		map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
		if (playerUser != groupPlayer.end()) {
			for (int k = 0; k < playerUser->second.size(); k++)
			{
				if (iterHall->second->m_pSocketHandler != NULL)
				{
					if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
						if (userGroupType.find(playerUser->second[k])->second == 2) {
							map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
							if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
								SendClientPacket(playerUser->second[k], iterHall->first, &resPacket, iterHall->second->m_pSocketHandler);
							}
						}
					}
				}
			}
		}
	}
}

int CGameServer::closeTableTemp(CGameTable *pTable) {
	NETOutputPacket resPacket;
	resPacket.Begin(TABLE_DATA_CHANGE);
	resPacket.WriteByte(7);
	resPacket.WriteInt(pTable->m_nTid);
	resPacket.WriteInt(pTable->club_id);
	resPacket.WriteInt(pTable->m_nLevel);
	resPacket.WriteByte(pTable->isStart);
	resPacket.WriteInt(pTable->configId);
	resPacket.WriteInt(pTable->gameType);
	resPacket.WriteInt(pTable->currRound);
	resPacket.WriteString("");
	resPacket.WriteString("");
	resPacket.WriteString(pTable->groupName.c_str());
	resPacket.WriteString("");
	resPacket.End();
	for (HallServerList::iterator iterHall = m_HallServerList.begin(); iterHall != m_HallServerList.end(); iterHall++)
	{
		map<int, vector<int> >::iterator playerUser = groupPlayer.find(pTable->club_id);
		if (playerUser != groupPlayer.end()) {
			for (int k = 0; k < playerUser->second.size(); k++)
			{
				if (iterHall->second->m_pSocketHandler != NULL)
				{
					if (userGroupType.find(playerUser->second[k]) != userGroupType.end()) {
						if (userGroupType.find(playerUser->second[k])->second == 2) {
							map<int, bool>::iterator itOnClub = userOnClub.find(playerUser->second[k]);
							if (GET_USER_GAME_STATUS(playerUser->second[k]) <= 0 && itOnClub != userOnClub.end() && itOnClub->second == true) {
								SendClientPacket(playerUser->second[k], iterHall->first, &resPacket, iterHall->second->m_pSocketHandler);
							}
						}
					}
				}
			}
		}
	}
}
int CGameServer::InitConfig(char* strXML) {
	//使用CMarkupSTL 
	CMarkupSTL  markup;
	if (!markup.Load(strXML))
	{
		g_pDebugLog->logMsg("load %s failed.\n", strXML);
		return 0;
	}

	if (!markup.FindElem("SYSTEM"))
	{
		g_pDebugLog->logMsg("Can not FindElem[SYSTEM] CONFIG in xml.\n");
		return 0;
	}

	if (!markup.IntoElem())
	{
		g_pDebugLog->logMsg("[%d]ReadConmmonConf:IntoElem [SYSTEM] failed.", false);
		return 0;
	}

	//RedisList
	if (!markup.FindElem("TEST_LEVEL"))
	{
		g_pDebugLog->logMsg("IntoElem [TEST_LEVEL] failed.\n");
		return 0;
	}

	if (!markup.IntoElem())
	{
		g_pDebugLog->logMsg("IntoElem [TEST_LEVEL] failed.\n");
		return 0;
	}

	while (markup.FindElem("Level"))
	{
		int level = atoi(markup.GetAttrib("value").c_str());
		int gameType = atoi(markup.GetAttrib("gameType").c_str());
		list_false[level] = gameType;
		g_pDebugLog->logMsg("IntoElem [TEST_LEVEL]=%d gameType= %d\n", level, gameType);
	}

	if (!markup.OutOfElem())
	{
		g_pDebugLog->logMsg("OutOfElem [configlis] failed.");
		
	}
	return 0;
}
/*---------------------------- by neo ------------------------------*/