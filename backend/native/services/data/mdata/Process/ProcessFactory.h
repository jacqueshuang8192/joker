#pragma once

#include "IProcess.h"

class GameManager;

class ProcessFactory  
{
	public:		
		map<int,IProcess*> ProcessMap;
		GameManager * m_pOwner;
	public:
		ProcessFactory():m_pOwner(NULL){};
		virtual ~ProcessFactory(){};
		virtual IProcess* getProcesser(int cmd){
			IProcess * p = NULL;
			map<int,IProcess*>::iterator iter = ProcessMap.find(cmd);
			if(iter == ProcessMap.end())
			{
				p = createProcesser(cmd);
				ProcessMap[cmd] = p;
			}else{
				p = iter->second;
			}
			return p;
		}; 
		virtual IProcess* createProcesser(int cmd)=0;
};



