#include "GameServer.h"
#include "RedisManagerClient.h"

CRedisManagerClient::~CRedisManagerClient()
{
	for (map<int,RedisConf*>::iterator iter = m_RedisConfMap.begin(); iter != m_RedisConfMap.end(); ++iter)
	{
		RedisConf* pRc = iter->second;
		delete pRc;
		pRc = NULL;
	}
	m_RedisConfMap.clear();


	for (RedisMap::iterator iter = m_RedisClientList.begin(); iter != m_RedisClientList.end(); ++iter)
	{
		RedisClient* pRc = iter->second;
		delete pRc;
		pRc = NULL;
	}
	m_RedisClientList.clear();
}

int CRedisManagerClient::Init(char* strXML)
{
	
	//使用CMarkupSTL 
	CMarkupSTL  markup;
    if(!markup.Load(strXML))
    {      
		g_pDebugLog->logMsg("load %s failed.\n", strXML);
        return -1;
    }

	if(!markup.FindElem("SYSTEM"))
    {
		g_pDebugLog->logMsg("Can not FindElem[SYSTEM] in xml.\n");
        return -1;
    }

	if (!markup.IntoElem())    
	{
		g_pDebugLog->logMsg("[%d]ReadConmmonConf:IntoElem [SYSTEM] failed.",false);
	}

    //RedisList
	if(!markup.FindElem("RedisList"))
	{
		g_pDebugLog->logMsg("IntoElem [RedisList] failed.\n");
		return -1; 
	}

	if (!markup.IntoElem())    
	{
		g_pDebugLog->logMsg("IntoElem [RedisList] failed.\n");
		return -1;    
	}

	while(markup.FindElem("Redis"))
	{
		int redisId = atoi(markup.GetAttrib("redisId").c_str());
		string strip = markup.GetAttrib("ip");
		int port = atoi(markup.GetAttrib("port").c_str());
		string password = markup.GetAttrib("password");
		
		RedisConf* rc = NULL;
		map<int,RedisConf*>::iterator it = m_RedisConfMap.find(redisId);
		if(it != m_RedisConfMap.end())
		{
			rc = it->second;
		}
		else
		{
			rc = new RedisConf;
			rc->m_redisId =  redisId;
			rc->m_strip = strip;
			rc->m_port = port;
			rc->m_password = password;
			m_RedisConfMap[rc->m_redisId] = rc;
			g_pDebugLog->logMsg("Add New Redis,ID:%d,IP:%s,Port:%d\n", rc->m_redisId, rc->m_strip.c_str(), rc->m_port);
		}

		if(NULL == rc)
		{
			g_pDebugLog->logMsg("OutOfElem [RedisList] failed.");
			return -1;
		}
		
	}
		
	if (!markup.OutOfElem())    
	{
		g_pDebugLog->logMsg("OutOfElem [RedisList] failed.");
		return -1;    
	}

    int ret=InitConnect();

	return ret;
}

int CRedisManagerClient::InitConnect()
{
	map<int,RedisConf*>::iterator iter =  m_RedisConfMap.begin();
	for(;iter!=m_RedisConfMap.end();iter++)
	{
		RedisConf* sc = iter->second;
		RedisClient* m_RedisClient = new RedisClient;
		m_RedisClient->Connect(sc->m_strip.c_str(), sc->m_port, sc->m_password);
		m_RedisClientList[iter->first] = m_RedisClient;		
	}
	return 0;
}
int CRedisManagerClient::GetGroupPlayer() {
	RedisMap::iterator it = m_RedisClientList.find(0);
	RedisClient* m_RedisClient = it->second;
	int ret = m_RedisClient->GetGroupPlayer();
	//VLogMsg(LM_DEBUG,"Get User[%d] Game Count[%d]\n",uid,GameCount);
	return ret;

}
int CRedisManagerClient::WIN_CLOS_GROUP(int tid, int activityId, int round)
{
	int RedisId = 1;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;
		return m_RedisClient->WIN_CLOS_GROUP(tid, activityId, round);
	}
	else {
		return -1;
	}
}

int CRedisManagerClient::ROBOT_STATUS(int club_id,int uid, int status,int level,int tempLevel)
{
	if (uid > 0) {
		int RedisId = 1;			//4503
		RedisMap::iterator it = m_RedisClientList.find(RedisId);

		if (it != m_RedisClientList.end())
		{
			RedisClient* m_RedisClient = it->second;
			return m_RedisClient->ROBOT_STATUS(club_id,uid, status, level, tempLevel);
		}
	}
	return 0;
}

int CRedisManagerClient::GetRobotStatus(int uid, string& buff)
{
	int RedisId = 1;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;
		
		if (m_RedisClient->GetRobotStatus(uid, buff) > 0) {
			
			return 1;
		}
		else {
			return -1;
		}
		
	}
	return 0;
}
int CRedisManagerClient::writeUserChips(int uid, int club_id, int chips) {
	int RedisId = 1;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;
		return m_RedisClient->writeUserChips(uid, club_id, chips);
	}
	else {
		return -1;
	}
}
int CRedisManagerClient::HGET_GROUP_USER_CHIPS(int uid, int club_id, string &str)
{
	int RedisId = 1;			//4502
	RedisMap::iterator it = m_RedisClientList.find(RedisId);
	RedisClient* m_RedisClient = it->second;
	int ret = m_RedisClient->HGET_GROUP_USER_CHIPS(uid, club_id, str);
	//VLogMsg(LM_DEBUG,"Get User[%d] PayLevel[%d]\n",uid,paylevel);
	return ret;
}
int CRedisManagerClient::GET_TEMP_ROBOT_STATUS(int uid, string& buff)
{
	int RedisId = 1;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;

		if (m_RedisClient->GET_TEMP_ROBOT_STATUS(uid, buff) > 0) {

			return 1;
		}
		else {
			return -1;
		}

	}
	return 0;
}
int CRedisManagerClient::SET_TEMP_ROBOT_STATUS(int uid, int status, int level)
{
	if (uid > 0) {
		int RedisId = 1;			//4503
		RedisMap::iterator it = m_RedisClientList.find(RedisId);

		if (it != m_RedisClientList.end())
		{
			RedisClient* m_RedisClient = it->second;
			return m_RedisClient->SET_TEMP_ROBOT_STATUS(uid, status, level);
		}
	}
	return 0;
}
int CRedisManagerClient::SET_DISABLE_USER(int uid, int status, int club_id)
{
	if (uid > 0) {
		int RedisId = 1;			//4503
		RedisMap::iterator it = m_RedisClientList.find(RedisId);

		if (it != m_RedisClientList.end())
		{
			RedisClient* m_RedisClient = it->second;
			return m_RedisClient->SET_DISABLE_USER(uid, status, club_id);
		}
	}
	return 0;
}
int CRedisManagerClient::GET_DISABLE_USER(int club_id,int uid, string& buff)
{
	int RedisId = 1;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;

		if (m_RedisClient->GET_DISABLE_USER(club_id, uid, buff) > 0) {

			return 1;
		}
		else {
			return -1;
		}

	}
	return 0;
}
int CRedisManagerClient::GET_SISMEMBER(int club_id, int uid,int fidUid) {
	int RedisId = 2;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;
		char key[255] = { 0 };
		snprintf(key, sizeof(key) - 1, "CLUB_USER_JOIN_TOGETHER_LIMIT_%d_%d", club_id, uid);
		if (m_RedisClient->GET_SISMEMBER(key, fidUid) > 0) {

			return 1;
		}
		else {
			return 0;
		}

	}
	return 0;
}
int CRedisManagerClient::GET_SISMEMBER_USER(int club_id, int uid)
{
	int RedisId = 2;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;

		if (m_RedisClient->GET_SISMEMBER_USER(club_id, uid) > 0) {

			return 1;
		}
		else {
			return 0;
		}

	}
	return 0;
}
int CRedisManagerClient::GET_USER_GAME_STATUS(int uid, string& buff)
{
	int RedisId = 0;			//4501
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;

		if (m_RedisClient->GET_USER_GAME_STATUS(uid, buff) > 0) {

			return 1;
		}
		else {
			return -1;
		}

	}
	return 0;
}
int CRedisManagerClient::HSET_USER_STATUS(int uid, int level, int tid, int activitId)
{
	int RedisId = 0;			//4503
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;

		if (m_RedisClient->HSET_USER_STATUS(uid, level, tid, activitId) > 0) {

			return 1;
		}
		else {
			return -1;
		}

	}
	return 0;
}
int CRedisManagerClient::getAllConfig(int clubId, std::vector<string>& vctReply) {
	int RedisId = 0;			//4501
	RedisMap::iterator it = m_RedisClientList.find(RedisId);

	if (it != m_RedisClientList.end())
	{
		RedisClient* m_RedisClient = it->second;

		if (m_RedisClient->getAllConfig(clubId, vctReply) > 0) {

			return 1;
		}
		else {
			return -1;
		}

	}
	return 0;
}
