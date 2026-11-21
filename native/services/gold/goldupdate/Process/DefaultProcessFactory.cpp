#include "DefaultProcessFactory.h"
#include "UpdateMidProcess.h"
#include "UpdateActivityUserProcess.h"

IProcess* DefaultProcessFactory::createProcesser(int cmd){
	IProcess* processer = NULL;
	switch(cmd)
	{
		case SYS_COMMAND_UPDATE_MID:
			processer = new UpdateMidProcess();break;
		case SYS_COMMAND_UPDATE_T_ACTIVITY_USER:
			processer = new ActivityUserProcess(); break;
		default:
			processer = NULL;break;
	}
	if(processer)
	{
		processer->setCmd(cmd);
		processer->m_pOwner = m_pOwner;
	}
	return processer;
}


