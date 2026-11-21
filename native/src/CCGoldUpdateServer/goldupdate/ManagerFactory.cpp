#include "ManagerFactory.h"
#include "global.h"
#include "DefaultGameManager.h"

map<int,GameManager*> ManagerMap;

GameManager * ManagerFactory::getGameManager(int gameid){
	GameManager * p = NULL;
	map<int,GameManager*>::iterator iter = ManagerMap.find(gameid);
	if(iter == ManagerMap.end())
	{
		p = createGameManager(gameid);
		ManagerMap[gameid] = p;
	}else{
		p = iter->second;
	}
	return p;
}

GameManager * ManagerFactory::createGameManager(int gameid)
{
	GameManager * pManager = NULL;
	int ServerType = getServerTypeByID(gameid);
	if(m_GameConfigMap.find(gameid) == m_GameConfigMap.end()){
		return pManager;
	}
	GameConfig & gc = m_GameConfigMap[gameid];
	switch(ServerType)
	{
		case DEFAULT_SERVER_TYPE:
			pManager = new DefaultGameManager();
			pManager->Init(gc);
			break;
		default:
			pManager = NULL;break;
	}
	return pManager;
}

int ManagerFactory::getServerTypeByID(int gameid){
	map<int,GameConfig>::iterator iter = m_GameConfigMap.find(gameid);
	if(iter != m_GameConfigMap.end()){
		GameConfig & gc = iter->second;
		return gc.m_serverType;
	}
	return INVALID_SERVER_TYPE;
}

bool ManagerFactory::isExistServerConfig(int gameid){
	map<int,GameConfig>::iterator iter =  m_GameConfigMap.find(gameid);
	if(iter != m_GameConfigMap.end()){
		return true;
	}
	return false;
}

void ManagerFactory::AddGameConfig(const GameConfig& gc){
	m_GameConfigMap[gc.m_gameID] = gc;
	getGameManager(gc.m_gameID);
}
