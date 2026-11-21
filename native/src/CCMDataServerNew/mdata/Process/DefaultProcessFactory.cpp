#include "DefaultProcessFactory.h"
#include "DCreateProcess.h"
#include "DUpdateProcess.h"
#include "DUpdateMoneyProcess.h"
#include "DDeleteProcess.h"
#include "DGetProcess.h"
#include "DMoney2ChipProcess.h"
#include "DChip2MoneyProcess.h"
#include "DGetChipProcess.h"
#include "DChangeGroupStateProcess.h"
#include "DUpdateChipsProcess.h"
#include "DNewTableProcess.h"
#include "global.h"



IProcess* DefaultProcessFactory::createProcesser(int cmd){
	IProcess* processer = NULL;
	switch(cmd)
	{
		case CLIENT_COMMAND_CREATE_RECORD:
			processer = new DCreateProcess();break;
		case CLIENT_COMMAND_UPDATE_RECORD:
			processer = new DUpdateProcess();break;
		case CLIENT_COMMAND_UPDATE_ACTIVITY_CHIPS:
			processer = new DUpdateActivityChipsProcess(); break;
		case CLIENT_COMMAND_UPDATE_MONEY:
			processer = new DUpdateMoneyProcess();break;
		case CLIENT_COMMAND_DELETE_RECORD:
			processer = new DDeleteProcess();break;
		case CLIENT_COMMAND_GET_RECORD:
			processer = new DGetProcess();break;
		case AG2M_CHANGE_MONEY2CHIPS:
			processer = new DMoney2ChipProcess(); break;
		case AG2M_GET_CHIPS:
			processer = new DGetChipProcess(); break;
		case AG2M_CHANGE_CHIP2MONEY:
			processer = new DChip2MoneyProcess(); break;
		case A2M_CHANGE_TABLE_STATE:
			processer = new DChangeGroupStateProcess(); break;
			//创建桌子列表
		case A2M_CREATE_TABLE_REDIS:
			processer = new DNewTableProcess(); break;
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


