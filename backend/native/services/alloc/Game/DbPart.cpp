#include "DbPart.h"
#include "time.h"
#include "global.h"
int CDbPart::m_tableNum = 0;
int CDbPart::m_dbNum = 0;
CDbPart::CDbPart()
{
	m_pMysqlConn = NULL;
	m_pStore = NULL;
}

CDbPart::~CDbPart()
{
	if (m_pMysqlConn)
	{
		delete m_pMysqlConn;
		m_pMysqlConn = NULL;
	}

	if (m_pStore)
	{
		delete m_pStore;
		m_pStore = NULL;
	}
}

int CDbPart::GetDatabaseIndex(int mid)
{
	return (mid/CDbPart::m_tableNum)%CDbPart::m_dbNum;
}

int CDbPart::GetTableIndex(int mid)
{
	return mid%m_tableNum;
}

int CDbPart::Init(char *strXML)
{
	//使用CMarkupSTL 
	CMarkupSTL  markup;
    if(!markup.Load(strXML))
    {
		g_pDebugLog->logMsg("Load %s failed.\n", strXML);
        return -1;
    }

	if(!markup.FindElem("SYSTEM"))
    {
		g_pDebugLog->logMsg("[%d]Can not FindElem [SYSTEM] in xml failed.\n", FALSE);
        return -1;
    }

	if (!markup.IntoElem())    
	{        
		g_pDebugLog->logMsg("[%d]ReadConmmonConf:IntoElem [SYSTEM] failed.", FALSE);
	}

    //BCastServer
	if(markup.FindElem("DB"))
	{
		//CDbPart *pDbPart = new CDbPart();
		//if(pDbPart != NULL)
		//{
			//char cdbName[255] = {0};
			//snprintf(cdbName,sizeof(cdbName),"%s",gc.m_DBConf.m_dbName.c_str());
			dbp.client_flag = 0;
			//dbp.db = cdbName;
			dbp.db = markup.GetAttrib("dbName");
			//dbp.host = gc.m_DBConf.m_ip;
			dbp.host = markup.GetAttrib("ip");
			//dbp.password = gc.m_DBConf.m_pwd;
			dbp.password = markup.GetAttrib("pwd");
			//dbp.port = (unsigned int)gc.m_DBConf.m_port;
			dbp.port = (unsigned int)atoi(markup.GetAttrib("port").c_str());
			//dbp.user = gc.m_DBConf.m_user;
			dbp.user = markup.GetAttrib("user");
			dbp.unix_socket = "";
			if(!ConnectDB(dbp))
			{
				g_pDebugLog->logMsg("Connect to DB[IP:%s,PORT:%d] Failed", dbp.host.c_str(), dbp.port);
				return -1;
			}
		//}
		m_tableNum = atoi(markup.GetAttrib("tableNum").c_str());
		m_dbNum = atoi(markup.GetAttrib("dbNum").c_str());
		//m_strip = markup.GetAttrib("ip");
        //m_port=atoi(markup.GetAttrib("port").c_str());
	}
    //int ret=InitConnect(m_strip.c_str(),m_port);
	return 0;
}

BOOL CDbPart::ConnectDB(DatabaseParam& dbParam)
{
	try
	{
		m_pMysqlConn = new CMysqlConnect();
		if(!m_pMysqlConn->Connect(dbParam.host, dbParam.user, dbParam.password, dbParam.db, dbParam.port, dbParam.unix_socket, "utf8"))
		{
			g_pDebugLog->logMsg("ConnectDB! ERROR:%s", m_pMysqlConn->What().c_str());
			return FALSE;
		}
		m_pStore = new CMysqlStore();
		m_pStore->SetTransAction(m_pMysqlConn);
		g_pDebugLog->logMsg("ConnectDB IP:%s,Port:%d\n", dbParam.host.c_str(), dbParam.port);
		return TRUE;
	}
	catch (...)
	{
		g_pDebugLog->logMsg("ConnectDB exception:%s\n", m_pMysqlConn->What().c_str());
		return FALSE;
	}

	return FALSE;
}

BOOL CDbPart::CallProcedure(const char * strMysql)
{
	if(strMysql == "")
		return TRUE;
	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		return FALSE;
	}
	if(m_pStore->Exec(strMysql))
	{
		return TRUE;
	}
	m_strError = "ExecErr";
	m_strError += m_pStore->What();
	g_pDebugLog->logMsg("CallProcedure error:[%s]\n", m_strError.c_str());
	return FALSE;
}

int CDbPart::GetGroupPlayerList(CGameServer *gamsSever, map<int, vector<int> > &testGroupList, map<int, map<int, CUserBalanceInfo*> > &groupRobotMap, map<int, CUserBalanceInfo*> &m_userRobotMap,map<int,string> &robotConfig) {
	char buf[512] = { 0 };
	std::string s_sql = "";
	snprintf(buf, 511, "select  t_user.RegisterIP, t_group_player.ower_id, \
		t_user.latitude, t_user.longitude, t_player_group.player_id,t_group_player.robots_config,\
		t_group_player.group_id, t_user.nick_name, t_user.is_robot,t_player_group.robot_status,t_user.gender,t_player_group.point_count,\
		t_user.small_icon from t_group_player  join t_player_group, t_user \
		WHERE t_group_player.group_id = t_player_group.group_id and t_user.userid = t_player_group.player_id");
	s_sql = buf;

	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		g_pDebugLog->logMsg("error->m_strError");
		return -1;
	}

	if (m_pStore->Query(s_sql))

	{
		unsigned long count = m_pStore->RowCount();
		if (count <= 0)
		{
			g_pDebugLog->logMsg("error->count");
			return -1;
		}
		
		g_pDebugLog->logMsg("[%s] count[%d] \n", __FUNCTION__, count);
		for (int i = 0; i < count; i++)
		{
			int gender = m_pStore->GetItemLong(i, "gender");
			int point_count = m_pStore->GetItemLong(i, "point_count");
			int player_id = m_pStore->GetItemLong(i, "player_id");
			int group_id = m_pStore->GetItemLong(i, "group_id");
			int ower_id = m_pStore->GetItemLong(i, "ower_id");
			string ip = m_pStore->GetItemString(i, "RegisterIP");
			string latitude = m_pStore->GetItemString(i, "latitude");
			string longitude = m_pStore->GetItemString(i, "longitude");
			string nick_name = m_pStore->GetItemString(i, "nick_name");
			string small_icon = m_pStore->GetItemString(i, "small_icon");
			int is_robot = m_pStore->GetItemLong(i, "is_robot");
			int robot_status = m_pStore->GetItemLong(i, "robot_status");
			string robots_config = m_pStore->GetItemString(i, "robots_config");
			robotConfig[group_id] = robots_config;
		
			//gamsSever->groupOwerMap[group_id] = ower_id;
			if (is_robot == 1) {
				g_pDebugLog->logMsg("player_id_robot==[%d] [%s]", player_id, nick_name.c_str());
				m_userRobotMap[player_id] = new CUserBalanceInfo(gamsSever,player_id, gender, nick_name, small_icon, is_robot, longitude, latitude, ip, robots_config, robot_status, group_id, point_count);
				if (groupRobotMap.find(group_id) != groupRobotMap.end()) {
					groupRobotMap.find(group_id)->second[player_id] = m_userRobotMap[player_id];
				}
				else {
					map<int, CUserBalanceInfo*> test;
					test[player_id] = m_userRobotMap[player_id];
					groupRobotMap[group_id] = test;
				}
			}
			else {
				if (testGroupList.find(group_id) != testGroupList.end()) {
					map<int, vector<int> >::iterator it = testGroupList.find(group_id);
					it->second.push_back(player_id);

				}
				else {
					vector<int> v;
					v.push_back(player_id);
					testGroupList[group_id] = v;
				}
			}
		}

		return 0;
	}
	g_pDebugLog->logMsg("error->m_pStore");
	return -1;
}

int CDbPart::GE_TUSER_INGFO(CGameServer* gamsSever,int uid, map<int, CUserBalanceInfo*>& m_userRobotMap, map<int, map<int, CUserBalanceInfo*> >& groupRobotMap) {
	char buf[512] = { 0 };
	std::string s_sql = "";
	snprintf(buf, 511, "select  t_user.RegisterIP, t_group_player.ower_id, \
		t_user.latitude, t_user.longitude, t_player_group.player_id,t_group_player.robots_config,\
		t_group_player.group_id, t_user.nick_name, t_user.is_robot,t_player_group.robot_status,t_user.gender,t_player_group.point_count,\
		t_user.small_icon from t_group_player  join t_player_group, t_user \
		WHERE t_group_player.group_id = t_player_group.group_id and t_user.userid = t_player_group.player_id and t_user.is_robot =1 and t_user.userid= %d",uid);
	s_sql = buf;

	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		g_pDebugLog->logMsg("error->m_strError");
		return -1;
	}

	if (m_pStore->Query(s_sql))

	{
		unsigned long count = m_pStore->RowCount();
		if (count <= 0)
		{
			g_pDebugLog->logMsg("error->count");
			return -1;
		}

		g_pDebugLog->logMsg("[%s] count[%d] \n", __FUNCTION__, count);
		for (int i = 0; i < count; i++)
		{
			int gender = m_pStore->GetItemLong(i, "gender");
			int point_count = m_pStore->GetItemLong(i, "point_count");
			int player_id = m_pStore->GetItemLong(i, "player_id");
			int group_id = m_pStore->GetItemLong(i, "group_id");
			int ower_id = m_pStore->GetItemLong(i, "ower_id");
			string ip = m_pStore->GetItemString(i, "RegisterIP");
			string latitude = m_pStore->GetItemString(i, "latitude");
			string longitude = m_pStore->GetItemString(i, "longitude");
			string nick_name = m_pStore->GetItemString(i, "nick_name");
			string small_icon = m_pStore->GetItemString(i, "small_icon");
			int is_robot = m_pStore->GetItemLong(i, "is_robot");
			int robot_status = m_pStore->GetItemLong(i, "robot_status");
			string robots_config = m_pStore->GetItemString(i, "robots_config");
			
			//gamsSever->groupOwerMap[group_id] = ower_id;
			g_pDebugLog->logMsg("GE_TUSER_INGFO player_id_robot==[%d] [%s] is_robot %d", player_id, nick_name.c_str(), is_robot);
			if (is_robot == 1) {
				
				m_userRobotMap[player_id] = new CUserBalanceInfo(gamsSever, player_id, gender, nick_name, small_icon, is_robot, longitude, latitude, ip, robots_config, robot_status, group_id, point_count);
				if (groupRobotMap.find(group_id) != groupRobotMap.end()) {
					groupRobotMap.find(group_id)->second[player_id] = m_userRobotMap[player_id];
				}
				else {
					map<int, CUserBalanceInfo*> test;
					test[player_id] = m_userRobotMap[player_id];
					groupRobotMap[group_id] = test;
				}
			}
		}

		return 0;
	}
	g_pDebugLog->logMsg("error->m_pStore");
	 
	return 0;
}
int CDbPart::GetUserClubPoint(int clubId, int uid, int &ret)
{
	char buf[512] = { 0 };
	std::string s_sql = "";

	int point = 0;
	snprintf(buf, 511, "SELECT point_count FROM t_player_group WHERE player_id = %d AND group_id = %d", uid, clubId);
	s_sql = buf;

	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		ret = -1;
		return point;
	}

	if (m_pStore->Query(s_sql))
	{
		unsigned long count = m_pStore->RowCount();
		if (count <= 0)
		{
			ret = -1;
			return point;
		}

		for (int i = 0; i < count; i++)
		{
			point = m_pStore->GetItemLong(i, "point_count");
		}
		g_pDebugLog->logMsg("%s point[%d] clubId[%d] uid[%d]\n", __FUNCTION__, point, clubId, uid);
		ret = 1;
		return point;
	}
	ret = -1;
	return point;
}
vector<groupConfigInfo> CDbPart::GetConfigList(int clubId, int level) {
	char buf[512] = { 0 };
	vector<groupConfigInfo> listConfig;
	std::string s_sql = "";
	snprintf(buf, 511, "SELECT * FROM t_group_gameconfig WHERE group_id = %d and level =%d", clubId, level);
	s_sql = buf;

	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		g_pDebugLog->logMsg("error->m_strError");
		return listConfig;
	}
	
	if (m_pStore->Query(s_sql))
	{
		unsigned long count = m_pStore->RowCount();
		if (count <= 0)
		{
			g_pDebugLog->logMsg("error->count");
			return listConfig;
		}
		
		g_pDebugLog->logMsg("[%s] count[%d] \n", __FUNCTION__, count);
		for (int i = 0; i < count; i++)
		{
			int m_id = m_pStore->GetItemLong(i, "id");
			int m_group_id = m_pStore->GetItemLong(i, "group_id");
			int m_level = m_pStore->GetItemLong(i, "level");
			string m_name = m_pStore->GetItemString(i, "name");
			string m_config = m_pStore->GetItemString(i, "config");
			groupConfigInfo table;
			table.mid = m_id;
			table.Name = m_name;
			table.Config = m_config;
			listConfig.push_back(table);
			
		}
	}
	return listConfig;
}