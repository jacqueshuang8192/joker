#pragma once
#include "Singleton.h"
#include "GameManager.h"
#include "global.h"

class ManagerFactory{
	public:
		map<int,GameConfig> m_GameConfigMap;
	public:
		ManagerFactory(){};
		~ManagerFactory(){};
		GameManager * getGameManager(int gameid); 
		static ManagerFactory * Instance()
		{
			return CSingleton<ManagerFactory>::Instance();
		}
	public:
		int getServerTypeByID(int gameid);
		bool isExistServerConfig(int gameid);
		void AddGameConfig(const GameConfig& gc);
	private:
		GameManager* createGameManager(int gameid);
		
};

