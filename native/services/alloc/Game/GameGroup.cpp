#include <GameGroup.h>
#include <CommandType.h>
#include "Singleton.h"
#include "GroupCmd.h"
#include <ace/INET_Addr.h>

#include "clib_log.h"
//#include "http.h"
extern clib_log * g_pDebugLog;

static bool Less_Server_UserCount(const SERVERINFO &s1, const SERVERINFO &s2)
{
	return s1.userCount < s2.userCount;
}
int GetTickCount2()
{
	timeval timesnow;
	struct timezone tmpzone;
	gettimeofday(&timesnow, &tmpzone);
	return timesnow.tv_sec * 1000 * 1000 + timesnow.tv_usec;
}
GameGroup* GameGroup::Instance(void)
{
	return CSingleton<GameGroup>::Instance();
}

void GameGroup::Destroy(void)
{
	return CSingleton<GameGroup>::Destroy();
}

int GameGroup::A2MMoney2Chip(CGameServer* pGameServer, int UserID, int activityID, int chip, int addChips, int level)//请求memcache兑换筹码
{
	int memServerId = UserID % (int)pGameServer->m_MemDataServerMap.size();
	CMemDataServer *pMemServer = pGameServer->GetMemDataServer(memServerId);
	if (pMemServer == NULL)
	{
		//printf("pMemServer != NULL\n");
		//fflush(stdout);
		return 0;
	}

	g_pDebugLog->logMsg("------------A2MMoney2Chip uid [%d] activityID[%d] \n", UserID, activityID);

	NETOutputPacket outPkg;
	outPkg.Begin(A2M_CHANGE_MONEY2CHIP);
	outPkg.WriteInt(UserID);
	outPkg.WriteInt(activityID);
	outPkg.WriteInt(chip);
	outPkg.WriteInt(MONEY2CHIPS_EXCHANGE_RATE);
	outPkg.WriteInt(addChips);

	outPkg.End();
	pMemServer->Send(&outPkg);//发送兑换筹码消息到memdataserver zsw

	NETInputPacket resPacket;
	GetMemDataRet(pMemServer, resPacket);//等待回应 zsw

	if (resPacket.GetCmdType() == M2A_CHANGE_MONEY2CHIP)
	{
		int result = resPacket.ReadInt();

		int curChip = 0;
		if (result)
		{
			if (divideMoneyRequest.size() == 0)
			{
				g_pDebugLog->logMsg("[%s] line:%d no divide money", __FUNCTION__, __LINE__);
			}
			else{

				curChip = resPacket.ReadInt();
				char request[255];
				float value = float(MONEY2CHIPS_EXCHANGE_RATE) / 1000 - 1;
				int costChips = int(chip*value);
				sprintf(request, divideMoneyRequest.c_str(), activityID, chip, UserID, costChips);
				g_pDebugLog->logMsg("xxxxxxxxxxdivideMoneyRequest.c_str()----------%s,%d,%d,%d,%d,%f\n", divideMoneyRequest.c_str(), activityID, chip, UserID, costChips, value);
				g_pDebugLog->logMsg("xxxxxxxxxxHttpPost----------%s,%d,%s\n", backServerUrl.c_str(), backServerPort, request);
				HttpPost(backServerUrl.c_str(), backServerPort, request);
			}
		}
		

	//	printf("pUserServer curChip [%d] [%d]\n", result, curChip);
		//fflush(stdout);
		return curChip;
	}

	return 0;
}

int GameGroup::GetMemDataRet(CMemDataServer* pMemServer, NETInputPacket& resPacket)
{
	char pRecvBuffer[ICHAT_TCP_DEFAULT_BUFFER];
	ACE_Time_Value tv(2);
	int nRecv = pMemServer->m_SocketHandler->peer().recv(pRecvBuffer, ICHAT_TCP_DEFAULT_BUFFER, &tv);//memdataserver立即回应 zsw
	if (nRecv <= 0)
	{
		return 1;
	}

	int ret = pMemServer->m_SocketHandler->OnParser(pRecvBuffer, nRecv);
	if (ret == 0)
	{
		resPacket.Copy(pRecvBuffer, nRecv);
	}
	return 1;
}

bool GameGroup::PerfromBeforeCreateGroupCheck(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)//无用
{
	return true;
}
bool GameGroup::PerfromB2ARemoveGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
{

	int	tableID = pPacket->ReadInt();//zsw 组局
	g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup tableID =%d \n", tableID);
	map<int, int>::iterator groupIterTid = pGameServer->m_GroupTableDict_TID.find(tableID);
	if (groupIterTid == pGameServer->m_GroupTableDict_TID.end())
	{
		A2BRemoveGroupTable(pSocket, -1);
		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup groupIterTid == pGameServer->m_GroupTableDict activityID =%d \n", tableID);
		return;
	}
	int activityID = groupIterTid->second;
	map<int, int>::iterator groupIter = pGameServer->m_GroupTableDict.find(activityID);
	if (groupIter == pGameServer->m_GroupTableDict.end())
	{
		A2BRemoveGroupTable(pSocket, -1);
		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup groupIter == pGameServer->m_GroupTableDict activityID =%d \n", activityID);
		return;
	}
	map<int, int>::iterator serverIter = pGameServer->m_GroupServerDict.find(tableID);
	if (serverIter == pGameServer->m_GroupServerDict.end())
	{
		A2BRemoveGroupTable(pSocket, -2);
		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup serverIter == pGameServer->m_GroupServerDict\n");
		return;
	}
	int serverID = serverIter->second;
	CLogicServer *logicServer = pGameServer->GetServer(serverID);
	if (logicServer == NULL || logicServer->m_pSocketHandler == NULL)
	{
		A2BRemoveGroupTable(pSocket, -3);
		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup tableID %d logicServer = Null\n", tableID);
		return;
	}
	A2BRemoveGroupTable(pSocket, 0);
	A2GRemoveGroupTable(logicServer, tableID, activityID);

	g_pDebugLog->logMsg("A2GRemoveGroupTable ServerId = %d tableID = %d\n", logicServer->m_nServerId, tableID);
}
//bool GameGroup::PerfromB2ARemoveGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
//{
//	
//	int	activityID = pPacket->ReadInt();//zsw 组局
//
//	map<int, int>::iterator groupIter = pGameServer->m_GroupTableDict.find(activityID);
//	if (groupIter == pGameServer->m_GroupTableDict.end())
//	{
//		A2BRemoveGroupTable(pSocket,-1);
//		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup groupIter == pGameServer->m_GroupTableDict activityID =%d \n", activityID);
//		return;
//	}
//	int tableID = groupIter->second;
//	map<int, int>::iterator serverIter = pGameServer->m_GroupServerDict.find(tableID);
//	if (serverIter == pGameServer->m_GroupServerDict.end())
//	{
//		A2BRemoveGroupTable(pSocket, -2);
//		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup serverIter == pGameServer->m_GroupServerDict\n");
//		return;
//	}
//
//	int serverID = serverIter->second;
//	CLogicServer *logicServer = pGameServer->GetServer(serverID);
//	if (logicServer == NULL || logicServer->m_pSocketHandler == NULL)
//	{
//		A2BRemoveGroupTable(pSocket, -3);
//		g_pDebugLog->logMsg("GameGroup::PerfromB2ARemoveGroup tableID %d logicServer = Null\n", tableID);
//		return;
//	}
//
//	A2BRemoveGroupTable(pSocket, 0);
//	A2GRemoveGroupTable(logicServer, tableID, activityID);
//
//	g_pDebugLog->logMsg("A2GRemoveGroupTable ServerId = %d tableID = %d\n", logicServer->m_nServerId, tableID);
//}

bool GameGroup::A2BRemoveGroupTable(SocketHandler *pSocket, int removeStyle)
{
	NETOutputPacket resPacket;
	resPacket.Begin(A2B_REMOVE_GROUP_TABLE_RESULT);//返回创建房间结果给后台服务器 zsw
	resPacket.WriteInt(0);
	resPacket.WriteInt(removeStyle);
	resPacket.End();
	pSocket->Send(&resPacket);

	return true;
}

//bool GameGroup::PerfromCreateGroupTable(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
//{
//	int ret = 0;
//	int tid = 0;
//	int serverId = 0;
//	string ip = "";
//	int port = 0;
//	int roomIndex = 0;
//	int createTime = time(NULL);
//	
//	int uid = pPacket->ReadInt();//玩家账号id zsw
//	int svid = pPacket->ReadInt();//服务器id zsw
//	int level = pPacket->ReadInt();//实际对应游戏类型 zsw
//	int roomType = pPacket->ReadInt();//房间类型zsw 
//	int baseChip = pPacket->ReadInt();//开局的底分，暂时无用到，会直接读配置文件 zsw
//	int needChip = pPacket->ReadInt();// zsw 玩家需要携带多少筹码才能开始组局
//	string roomName = pPacket->ReadString();//zsw 组局名
//	string password = pPacket->ReadString();//zsw 预留字段，暂时无用
//	int isLoveGirl = pPacket->ReadInt();//zsw 预留字段，暂时无用
//	string loveGirlStr = pPacket->ReadString();//zsw 预留字段，暂时无用
//	string strInviteCode = pPacket->ReadString();//zsw 组局邀请码，也是唯一的id
//	string cur_activityID = pPacket->ReadString();//zsw 组局的此组局的唯一id
//	int activityID = 0;
//	CGameTable* pTable = NULL;
//
//	if (cur_activityID.length() > 0)
//	{
//		activityID = atoi(cur_activityID.c_str());
//	}
//	
//	int	nLastTime = pPacket->ReadInt();//zsw 预留字段，暂时无用s
//
//	g_pDebugLog->logMsg("------------PerfromCreateGroupTable uid [%d] activityID[%d]\n", uid, activityID);
//
//	//printf("-----------------pUserServer baseChip [%d] size[%d]\n", baseChip, pGameServer->m_nPrivateRoomConf.size());
//	//fflush(stdout);
//	g_pDebugLog->logMsg("------------xxxPerfromCreateGroupTable baseChip[%d]\n", baseChip);
//
//	map<int, int>::iterator tableIter= pGameServer->m_GroupCreatorDict.find(uid);
//
//	int tableID = tableIter->second;
//	if (tableIter != pGameServer->m_GroupCreatorDict.end())
//	{
//		//printf("tableIter != pGameServer->m_GroupCreatorDict.end()\n");
//		//fflush(stdout);
//		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_HAVE_BEEN_EXIST, tableID);
//		return false;
//	}
//	
//	if (level != pGameServer->m_nLevel)
//	{
//		//printf("pUserServer NULL  level[%d] [%d]\n", level, pGameServer->m_nLevel);
//		//fflush(stdout);
//		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_DIFFERENT_LEVEL, tableID);
//		return false;
//	}
//
//	map<int, TPrivateRoomConf>::iterator it = pGameServer->m_nPrivateRoomConf.find(baseChip);
//	if (it == pGameServer->m_nPrivateRoomConf.end())
//	{
//		//printf("it == pGameServer->m_nPrivateRoomConf.end()\n");
//		//fflush(stdout);
//		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_BASE_CHIP_NOT_EXIST, tableID);
//		return false;
//	}
//	
//	/*CGameTable* pTable = pGameServer->FindCreateTable(uid);//判断玩家是否有创建tableid
//	if (pTable != NULL)
//	{
//		//printf("CGameTable* pTable = pGameServer->FindCreateTable(uid)\n");
//		//fflush(stdout);
//		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_HAVE_BEEN_EXIST, pTable);
//		return true;
//	}*/
//
//	int curChip = A2MMoney2Chip(pGameServer, uid, activityID, needChip, needChip, level);
//
//	//printf("------------pUserServer:A2MMoney2Chip uid[%d] curChip[%d] \n", uid, curChip);
//	//fflush(stdout);
//	g_pDebugLog->logMsg("A2MMoney2Chip [%d] [%d]\n", uid, curChip);
//
//	if (curChip == 0)
//	{
//		//printf("pUserServer NULL  curChip[%d]\n", curChip);
//		//fflush(stdout);
//		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_EXCHANGE_CHIP_FAILED, tableID);
//		return false;
//	}
//
//	CountTableList::iterator iterCount = pGameServer->m_CountTableList.find(0);//在所有游戏服里面的桌子列表中找出空闲的桌子 zsw
//	if (iterCount != pGameServer->m_CountTableList.end())
//	{
//		TableList& tableMap = iterCount->second;
//		TableList::iterator iterTable = tableMap.begin();
//		for (; iterTable != tableMap.end();)
//		{
//			pTable = iterTable->second;
//			if (pTable != NULL)
//			{
//				if (pTable->m_nOwnerUid > 0)//桌子是否被占用 zsw
//				{
//					break;
//				}
//
//				CLogicServer *logicServer = pGameServer->GetServer(pTable->m_nServerId);
//				
//				if (logicServer != NULL)
//				{
//					if (logicServer->m_nRetire == 1 || logicServer->m_pSocketHandler == NULL || logicServer->m_nUserCount >= pGameServer->m_nMaxServerUserCount)
//					{
//						iterTable++;
//					}
//					else
//					{
//						
//						tableMap.erase(iterTable);
//						TableList& tableNewMap = pGameServer->m_CountTableList[0];
//						tableNewMap[pTable->m_nTid] = pTable;
//						pTable->m_nRoomIndex = pGameServer->GetPrivateRoomIndex(pTable->m_nTid);
//
//						initTableInfo(pTable, uid, 0, roomType, baseChip, password, roomName, isLoveGirl, loveGirlStr, createTime, nLastTime, \
//							logicServer, activityID, strInviteCode, roomIndex, "");
//						tid = pTable->m_nTid;
//						ip = logicServer->m_strIp;
//						port = logicServer->m_nPort;
//						serverId = pTable->m_nServerId;
//						roomIndex = pTable->m_nRoomIndex;
//
//						map<int, string>::iterator itTable = pGameServer->m_ActivityTableList.find(tid);
//						if (itTable != pGameServer->m_ActivityTableList.end())
//						{
//							itTable->second = strInviteCode;
//						}
//						else
//						{
//							pGameServer->m_ActivityTableList[tid] = strInviteCode;
//						}
//
//						if (isLoveGirl) //估计暂时没用 zsw
//						{
//							logicServer->AddLoveTable(tid);
//						}
//						else {
//							logicServer->RemoveLoveTable(tid);
//						}
//						g_pDebugLog->logMsg("1111PerfromCreateGroupTable pTable->m_nOwnerUid,tid = %d\n", pTable->m_nOwnerUid, tid);
//						//printf("----pTable->m_nServerId---[%d] [%d]\n", pTable->m_nServerId, tid);
//						//fflush(stdout);
//						A2GCreateGroupTable(logicServer, tid, roomType, baseChip, roomName, password, uid, isLoveGirl, pTable, strInviteCode, activityID);
//						break;
//					}
//				}
//				else
//				{
//					iterTable++;
//				}
//			}
//			else
//			{
//				tableMap.erase(iterTable++);
//			}
//		}
//	}
//
//	if (tid == 0)//没有空闲的桌子，创建一个并且加入玩家到桌子里面 zsw
//	{
//		vector<SERVERINFO> vecServer;
//		ServerList::iterator iterServer = pGameServer->m_ServerList.begin();
//		for (; iterServer != pGameServer->m_ServerList.end(); iterServer++)
//		{
//			CLogicServer *pLogicServer = iterServer->second;
//			if (pLogicServer != NULL)
//			{
//				if (pLogicServer->m_nRetire == 0 && pLogicServer->m_pSocketHandler != NULL && pLogicServer->m_nUserCount < pGameServer->m_nMaxServerUserCount)//nRetire 是判断服务器是否处于休息状态 zsw
//				{
//					SERVERINFO serverInfo;
//					serverInfo.serverId = pLogicServer->m_nServerId;
//					serverInfo.userCount = pLogicServer->m_nUserCount;
//					vecServer.push_back(serverInfo);
//				}
//			}
//		}
//
//		if (vecServer.size() > 0)
//		{
//			std::sort(vecServer.begin(), vecServer.end(), Less_Server_UserCount);
//			SERVERINFO &sInfo = vecServer[0];
//			CLogicServer *logicServer = pGameServer->GetServer(sInfo.serverId);//查找对应的服务器id zsw
//			if (logicServer != NULL)
//			{
//				int sid = sInfo.serverId;
//				int tid = (sid << 16) + logicServer->m_nTableCount;//假如serverid为1则将serverid向左偏移16位
//				
//				pTable = new CGameTable(tid, sInfo.serverId, 0,0);
//				
//				g_pDebugLog->logMsg("222PerfromCreateGroupTable pTable->m_nOwnerUid%d,tid = %d\n", pTable->m_nOwnerUid, tid);
//				if (pTable != NULL)
//				{
//					roomIndex = pGameServer->GetPrivateRoomIndex(tid);
//					initTableInfo(pTable, uid, 0, roomType, baseChip, password, roomName, isLoveGirl, loveGirlStr, createTime, nLastTime, \
//						logicServer, activityID, strInviteCode, roomIndex,"");
//					pGameServer->m_ActivityTableList[tid] = strInviteCode;
//					
//					pGameServer->AddPrivateRoomIndex(tid);
//
//					pGameServer->m_nTableIndexList[roomIndex] = tid;
//					pGameServer->m_nTableIdList[tid] = roomIndex;
//					logicServer->m_TableList[tid] = pTable;
//					logicServer->m_nTableCount++;
//
//					if (isLoveGirl)
//					{
//						logicServer->AddLoveTable(tid);
//					}
//					else {
//						logicServer->RemoveLoveTable(tid);
//					}
//
//					CountTableList::iterator iterCount = pGameServer->m_CountTableList.find(pTable->m_nUserCount);
//					if (iterCount != pGameServer->m_CountTableList.end())
//					{
//						TableList& tableMap = iterCount->second;
//						tableMap[tid] = pTable;
//					}
//					else
//					{
//						TableList& tableMap = pGameServer->m_CountTableList[pTable->m_nUserCount];
//						tableMap[tid] = pTable;
//					}
//				}
//
//				A2GCreateGroupTable(logicServer, tid, roomType, baseChip, roomName, password, uid, isLoveGirl, pTable, strInviteCode, activityID);
//			}
//		}
//
//		else 
//		{
//			ret = 1; //创建桌子失败 zsw
//		}
//	}
//
//	if (ret != 0)
//	{
//		//pServer->Chip2Menoy(uid);//当创建失败，筹码兑换回金币 zsw
//		A2MChip2Money(pGameServer, uid, 0, activityID);
//		return false;
//	}
//
//	A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_SUCCESS, pTable->m_nTid);
//	pGameServer->m_GroupTableDict[activityID] = pTable->m_nTid;
//	pGameServer->m_GroupCreatorDict[uid] = pTable->m_nTid;
//	pGameServer->m_GroupServerDict[pTable->m_nTid] = pTable->m_nServerId;
//	pGameServer->m_GroupActivityCreatorDict[activityID] = uid;
//	pTable->m_activityID = activityID;
//
//	//printf("----------------CGameServer::A2BCreateGroupTable:serverId---[%d] [%d]\n", activityID, pTable->m_nTid);
//	//fflush(stdout);
//	
//	
//	A2MChangeGroupState(pGameServer, uid, 1, activityID);
//	g_pDebugLog->logMsg("%s|| end [%d] [%d] [%d]\n", __FUNCTION__, activityID, pTable->m_nTid, pTable->m_nServerId);
//	return true;
//}



bool GameGroup::PerfromCreateCardGroupTable(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
{
	g_pDebugLog->logMsg("readyPoint=================[%d] ", 1);
	int ret = 0;
	int tid = 0;
	int serverId = 0;
	string ip = "";
	int port = 0;
	int roomIndex = 0;
	int createTime = time(NULL);


	int uid = pPacket->ReadInt();//玩家账号id zsw
	int level = pPacket->ReadInt();//实际对应游戏类型 zsw
	int baseChip = pPacket->ReadInt();//开局的底分，暂时无用到，会直接读配置文件 zsw
	int initChip = pPacket->ReadInt();// zsw 玩家需要携带多少筹码才能开始组局
	string strInviteCode = pPacket->ReadString();//zsw 组局邀请码，也是唯一的id
	int activityID = pPacket->ReadInt();//zsw 组局的此组局的唯一id
	int round = pPacket->ReadInt();//zsw 组局的此组局的唯一id
	string configJson = pPacket->ReadString(); //

	int minCoinsGold = pPacket->ReadInt();//zsw 有可能是俱乐部的最小进入金币
	int max_plaeryCount = pPacket->ReadInt();//zsw 最大人数
	//string createNickName = pPacket->ReadString(); //创建人

	string createProtrait = pPacket->ReadString(); //创建人头像
	string discriotion2Server = pPacket->ReadString(); //组局配置
	string password = pPacket->ReadString();//zsw 密码房
	int gruopId = pPacket->ReadInt();//zsw 俱乐部id
	int configId = pPacket->ReadInt();//zsw configId
	int gameType = pPacket->ReadInt();//gameType
	string groupName = pPacket->ReadString();//桌子名字
	CGameTable* pTable = NULL;
	Json::Reader reader;
	Json::FastWriter fastWriter;
	Json::Value root;
	Json::Value uInfJson;
	if (reader.parse(configJson, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素   
	{
		uInfJson["readyPoint"] = root["readyPoint"];
		uInfJson["joinGamePoint"] = root["joinGamePoint"];
	}
	uInfJson["activityId"] = activityID;
	uInfJson["description"] = discriotion2Server;
	uInfJson["inviteCode"] = strInviteCode;
	uInfJson["maxSeatCount"] = max_plaeryCount;
	uInfJson["round"] = round;
	uInfJson["baseChip"] = baseChip;
	string configT = fastWriter.write(uInfJson);
	
	g_pDebugLog->logMsg("readyPoint[%d] ", uInfJson["readyPoint"].asInt());
	g_pDebugLog->logMsg("configId[%d]", configId);
	g_pDebugLog->logMsg("-------xxx-----PerfromCreateCardGroupTable server[%p] uid [%d] level[%d] activityID[%d] strInviteCode[%s] baseChip[%d] initChip[%d] round[%d]  createProtrait[%s]\n", this, uid, level, activityID, strInviteCode.c_str(), baseChip, initChip, round, createProtrait.c_str());
	g_pDebugLog->logMsg("-------xxx-----PerfromCreateCardGroupTable configJson[%s] discriotion2Server [%s] minCoinsGold[%d] max_plaeryCount[%d] password[%s] gruopId[%d] \n", configJson.c_str(), discriotion2Server.c_str(), minCoinsGold, max_plaeryCount, password.c_str(), gruopId);

	/*map<int, int>::iterator tableIter = pGameServer->m_GroupCreatorDict.find(uid);

	int tableID = tableIter->second;*/
	
	//if (tableIter != pGameServer->m_GroupCreatorDict.end())
	//{
	//	//printf("tableIter != pGameServer->m_GroupCreatorDict.end()\n");
	//	//fflush(stdout);
	//	A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_HAVE_BEEN_EXIST, tableID);
	//	return false;
	//}

	if (level != pGameServer->m_nLevel)
	{
		//printf("pUserServer NULL  level[%d] [%d]\n", level, pGameServer->m_nLevel);
		//fflush(stdout);
		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_DIFFERENT_LEVEL, tid);
		return false;
	}

	//map<int, TPrivateRoomConf>::iterator it = pGameServer->m_nPrivateRoomConf.find(baseChip);
	//if (it == pGameServer->m_nPrivateRoomConf.end())
	//{
	//	//printf("it == pGameServer->m_nPrivateRoomConf.end()\n");
	//	//fflush(stdout);
	//	A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_BASE_CHIP_NOT_EXIST, tableID);
	//	return false;
	//}

	CountTableList::iterator iterCount = pGameServer->m_CountTableList.find(0);//在所有游戏服里面的桌子列表中找出空闲的桌子 zsw
	g_pDebugLog->logMsg("-------xxx-2");
	if (iterCount != pGameServer->m_CountTableList.end())
	{
		g_pDebugLog->logMsg("-------xxx-3");
		TableList& tableMap = iterCount->second;
		g_pDebugLog->logMsg("-------xxx-4");
		TableList::iterator iterTable = tableMap.begin();
		g_pDebugLog->logMsg("-------xxx-5");
		for (; iterTable != tableMap.end();)
		{
			g_pDebugLog->logMsg("-------xxx-6");
			pTable = iterTable->second;
			g_pDebugLog->logMsg("-------xxx-7");
			if (pTable != NULL)
			{
				g_pDebugLog->logMsg("-------xxx-8");
				pTable->groupName = groupName;
				g_pDebugLog->logMsg("-------xxx-88");
				if (pTable->m_nOwnerUid > 0 || pTable->m_nTid == 0)//桌子是否被占用 zsw
				{
					g_pDebugLog->logMsg("-------xxx-12");
					g_pDebugLog->logMsg("[%s] line:%d tid[%d] ownerid[%d]", __FUNCTION__, __LINE__, pTable->m_nTid, pTable->m_nOwnerUid);
					break;
				}

				CLogicServer *logicServer = pGameServer->GetServer(pTable->m_nServerId);

				if (logicServer != NULL)
				{
					g_pDebugLog->logMsg("-------xxx-17");
					if (logicServer->m_nRetire == 1 || logicServer->m_pSocketHandler == NULL || logicServer->m_nUserCount >= pGameServer->m_nMaxServerUserCount)
					{
						iterTable++;
					}
					else
					{
						g_pDebugLog->logMsg("-------xxx-15");
						tableMap.erase(iterTable);

						TableList& tableNewMap = pGameServer->m_CountTableList[0];
						tableNewMap[pTable->m_nTid] = pTable;
						pTable->m_nRoomIndex = pGameServer->GetPrivateRoomIndex(pTable->m_nTid);
						pTable->club_id = gruopId;
						pTable->gameType = gameType;
						pTable->groupName = groupName;
						pTable->configId = configId;
						pTable->max_plaery_count = max_plaeryCount;
						initTableInfo(pTable, uid, 0, 0, baseChip, "", "", 0, "", 0, 0, \
							logicServer, activityID, strInviteCode, initChip, configT);
						tid = pTable->m_nTid;
						ip = logicServer->m_strIp;
						port = logicServer->m_nPort;
						serverId = pTable->m_nServerId;
						roomIndex = pTable->m_nRoomIndex;
						g_pDebugLog->logMsg("-------xxx-19  create_time[%d]", pTable->m_nCreateTime);
						map<int, string>::iterator itTable = pGameServer->m_ActivityTableList.find(tid);
						if (itTable != pGameServer->m_ActivityTableList.end())
						{
							itTable->second = strInviteCode;
						}
						else
						{
							pGameServer->m_ActivityTableList[tid] = strInviteCode;
						}

						g_pDebugLog->logMsg("xxxxPerfromCreateCardGroupTable pTable->m_nOwnerUid[%d],tid = %d\n", pTable->m_nOwnerUid, tid);
						//printf("----pTable->m_nServerId---[%d] [%d]\n", pTable->m_nServerId, tid);
						//fflush(stdout);
						
						A2GCreateCardGroupTable(logicServer, tid, baseChip, uid, pTable, minCoinsGold, max_plaeryCount, strInviteCode, activityID, round, configJson);
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
				g_pDebugLog->logMsg("-------xxx-9");
				tableMap.erase(iterTable++);
				g_pDebugLog->logMsg("-------xxx-10");
			}
		}
	}
	
	if (tid == 0)//没有空闲的桌子，创建一个并且加入玩家到桌子里面 zsw
	{
		vector<SERVERINFO> vecServer;
		ServerList::iterator iterServer = pGameServer->m_ServerList.begin();
		g_pDebugLog->logMsg("-----pLogicServer->m_ServerList[%d]", pGameServer->m_ServerList.size());
		/*if (pGameServer->m_ServerList->size() > 0) {
			ServerList::iterator iterServer = pGameServer->m_ServerList.begin();
			std::advance(iterServer, rand() % m_ServerList.size());
		}*/
		for (; iterServer != pGameServer->m_ServerList.end(); iterServer++)
		{
			CLogicServer *pLogicServer = iterServer->second;

			if (pLogicServer != NULL)
			{
				g_pDebugLog->logMsg("-----pLogicServer->m_nUserCount[%d]", pLogicServer->m_nUserCount);
				g_pDebugLog->logMsg("-----pGameServer->m_nMaxServerUserCount[%d]", pGameServer->m_nMaxServerUserCount);
				g_pDebugLog->logMsg("-----pLogicServer->m_nRetire[%d]", pLogicServer->m_nRetire);
				if (pLogicServer->m_pSocketHandler != NULL) {
					g_pDebugLog->logMsg("-----pLogicServer->m_pSocketHandler");
				}
				if (pLogicServer->m_nRetire == 0 && pLogicServer->m_pSocketHandler != NULL && pLogicServer->m_nUserCount < pGameServer->m_nMaxServerUserCount)//nRetire 是判断服务器是否处于休息状态 zsw
				{
					SERVERINFO serverInfo;
					serverInfo.serverId = pLogicServer->m_nServerId;
					serverInfo.userCount = pLogicServer->m_nUserCount;
					vecServer.push_back(serverInfo);
				}
			}
		}

		if (vecServer.size() > 0)
		{
			std::sort(vecServer.begin(), vecServer.end(), Less_Server_UserCount);
			int size = (int)vecServer.size();
			srand((unsigned)time(NULL));
			int value = rand() % size;
			SERVERINFO &sInfo = vecServer[value];
			CLogicServer *logicServer = pGameServer->GetServer(sInfo.serverId);//查找对应的服务器id zsw
			if (logicServer != NULL)
			{
				int sid = sInfo.serverId;
				tid = (sid << 16) + logicServer->m_nTableCount;//假如serverid为1则将serverid向左偏移16位

				map<int, int>::iterator it_tid = pGameServer->m_GroupServerDict.find(tid);
				while (it_tid != pGameServer->m_GroupServerDict.end())
				{
					tid++;
					it_tid = pGameServer->m_GroupServerDict.find(tid);
				}

				pTable = new CGameTable(tid, sInfo.serverId, level, gruopId);
				
				pTable->m_nOwnerUid = uid;
				pTable->max_plaery_count = max_plaeryCount;
				g_pDebugLog->logMsg("yyyyPerfromCreateCardGroupTable pTable->m_nOwnerUid%d,tid = %d gruopId=%d gameType=%d  logicServer->m_nTableCount=%d\n", pTable->m_nOwnerUid, tid, gruopId, gameType, logicServer->m_nTableCount);
				if (pTable != NULL)
				{
					
					pTable->currRound = 0;
					pTable->groupName = groupName;
					pTable->gameType = gameType;
					pTable->configId = configId;
					roomIndex = pGameServer->GetPrivateRoomIndex(tid);
					initTableInfo(pTable, uid, 0, 0, baseChip, "", "", 0, "", 0, 0, \
						logicServer, activityID, strInviteCode, initChip, configT);
					pGameServer->m_ActivityTableList[tid] = strInviteCode;

					pGameServer->AddPrivateRoomIndex(tid);
					g_pDebugLog->logMsg("roomIndex %d,tid = %d pTable->m_nCreateTime[%d]\n", roomIndex, tid, pTable->m_nCreateTime);
					
					pGameServer->m_nTableIndexList[roomIndex] = tid;
					pGameServer->m_nTableIdList[tid] = roomIndex;
					logicServer->m_TableList[tid] = pTable;
					logicServer->m_nTableCount++;

					CountTableList::iterator iterCount = pGameServer->m_CountTableList.find(pTable->m_nUserCount);
					if (iterCount != pGameServer->m_CountTableList.end())
					{
						TableList& tableMap = iterCount->second;
						tableMap[tid] = pTable;
					}
					else
					{
						TableList& tableMap = pGameServer->m_CountTableList[pTable->m_nUserCount];
						tableMap[tid] = pTable;
					}
				}
				
				A2GCreateCardGroupTable(logicServer, tid, baseChip, uid, pTable, minCoinsGold, max_plaeryCount, strInviteCode, activityID, round, configJson);
			}
		}

		else
		{
			ret = 1; //创建桌子失败 zsw
		}
	}
	g_pDebugLog->logMsg("-----tid[%d]", tid);
	g_pDebugLog->logMsg("[%s] line:%d ret[%d]", __FUNCTION__, __LINE__, ret);
	if (ret != 0)
	{
		//pServer->Chip2Menoy(uid);//当创建失败，筹码兑换回金币 zsw
		//A2MChip2Money(pGameServer, uid, 0, activityID);
		A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_DIFFERENT_LEVEL, tid);
		return false;
	}
	g_pDebugLog->logMsg("pGameServer->userHallServiceId size[%d]", pGameServer->userHallServiceId.size());
	
	
	A2BCreateGroupTable(pSocket, CREATE_GROUP_TABLE_SUCCESS, pTable->m_nTid);
	pGameServer->m_GroupTableDict[activityID] = pTable->m_nTid;
	pGameServer->m_GroupTableDict_TID[pTable->m_nTid] = activityID;
	pGameServer->m_GroupTableDict_AcitiveId[pTable->m_nTid] = activityID;
	pGameServer->m_GroupCreatorDict[uid] = pTable->m_nTid;
	pGameServer->m_GroupServerDict[pTable->m_nTid] = pTable->m_nServerId;
	pGameServer->m_GroupActivityCreatorDict[activityID] = uid;
	pTable->m_activityID = activityID;
	pTable->groupType = pGameServer->groupType;
	g_pDebugLog->logMsg("----------------CGameServer::A2BCreateGroupTable:serverId-- - activityID[%d]pTable->m_nTid[%d] pTable->groupType[%d]\n", activityID, pTable->m_nTid, pTable->groupType);
	//printf("----------------CGameServer::A2BCreateGroupTable:serverId---[%d] [%d]\n", activityID, pTable->m_nTid);
	//fflush(stdout);
	/*if (pGameServer->userHallServiceId.find(uid) != pGameServer->userHallServiceId.end()) {
		g_pDebugLog->logMsg("pGameServer->userHallServiceId uid[%d]", pGameServer->userHallServiceId[uid]);*/
	pGameServer->SendAllowCreateTable(pGameServer->userHallServiceId[uid], pTable);
	//}
	A2MChangeGroupState(pGameServer, uid, 1, activityID);
	g_pDebugLog->logMsg("%s|| end [%d] [%d] [%d]\n", __FUNCTION__, activityID, pTable->m_nTid, pTable->m_nServerId);
	return true;
}

int GameGroup::A2MChangeGroupState(CGameServer* pGameServer, int creatorID, int tableState, int activity_id)
{
	int memServerId = creatorID % (int)pGameServer->m_MemDataServerMap.size();
	CMemDataServer *pMemServer = pGameServer->GetMemDataServer(memServerId);
	if (pMemServer == NULL)
	{
		return 0;
	}

	NETOutputPacket outPkg;
	outPkg.Begin(A2M_CHANGE_TABLE_STATE);
	outPkg.WriteInt(creatorID);
	outPkg.WriteInt(tableState);
	outPkg.WriteInt(activity_id);
	outPkg.End();
	pMemServer->Send(&outPkg,0,1);
	return 0;
}

int GameGroup::A2MChip2Money(CGameServer* pGameServer, int uid,int addChips,int activityID)
{
	int memServerId = uid % (int)pGameServer->m_MemDataServerMap.size();
	CMemDataServer *pMemServer = pGameServer->GetMemDataServer(memServerId);
	if (pMemServer == NULL)
	{
		return 0;
	}

	NETOutputPacket outPkg;
	outPkg.Begin(A2M_CHANGE_CHIP2MONEY);
	outPkg.WriteInt(uid);
	outPkg.WriteInt(CHIPS2MONEY_EXCHANGE_RATE);
	outPkg.WriteInt(addChips);
	outPkg.WriteInt(activityID);
	outPkg.End();
	pMemServer->Send(&outPkg);

	NETInputPacket resPacket;
	GetMemDataRet(pMemServer, resPacket);//等待回应 zsw

	if (resPacket.GetCmdType() == M2A_CHANGE_CHIP2MONEY)
	{
		int curChip = resPacket.ReadInt();
		if (curChip == 0)
		{
			return curChip;
		}
	}

	return 0;
}

bool GameGroup::initTableInfo(CGameTable* pTable, int uid, short userCount, int roomType, int baseChip, string password, string roomName, \
	int isLoveGirl, string loveGirlStr, int createTime, int nLastTime, CLogicServer* pServer, int activityID, string strInviteCode, int needchips,string jsonConfig)
{
	pTable->m_nOwnerUid = uid;
	pTable->m_nUserCount = 0;
	pTable->m_nRoomType = roomType;
	pTable->m_nBaseChip = baseChip;
	pTable->m_strPassword = password;
	pTable->m_strRoomName = roomName;
	pTable->m_nIsLoveGirl = isLoveGirl;
	pTable->m_nLoveGirlStr = loveGirlStr;
	pTable->m_nCreateTime = GetTickCount2();
	pTable->m_pServer = pServer;
	pTable->m_strInviteCode = strInviteCode;
	pTable->m_activityID = activityID;
	pTable->m_nLiftTime = nLastTime;
	pTable->m_needChips = needchips;
	pTable->jsonConfig = jsonConfig;
}

bool GameGroup::PerfromStopGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
{
	int activityID = pPacket->ReadInt();
	CancelGroupTable(pGameServer, activityID);
	return true;
}
int GameGroup::PerfromSendTableCreate(int club_id,int level)
{
	char request[256];
	sprintf(request, GameGroup::Instance()->A2IcreateFreeGame.c_str(), club_id, level);

	g_pDebugLog->logMsg("%s|request[%s] ", __FUNCTION__, request);

	HttpPost(GameGroup::Instance()->backServerUrl.c_str(), GameGroup::Instance()->backServerPort, request);//后台ip暂时写死 zsw，post到后台服务器，结束组局
	g_pDebugLog->logMsg("%s|cost card club_id[%d] level[%d] ", __FUNCTION__, club_id, \
		level);
	return 0;
}
bool GameGroup::PerfromCostCard(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
{
	int activityID = pPacket->ReadInt();
	int round = pPacket->ReadInt();
	map<int, int>::iterator creatorIter = pGameServer->m_GroupActivityCreatorDict.find(activityID);
	if (creatorIter == pGameServer->m_GroupActivityCreatorDict.end())
	{
		g_pDebugLog->logMsg("%s|activityID[%d] is not found", __FUNCTION__, activityID);
		return;
	}

	if (GameGroup::Instance()->costCardRequest.size() == 0)
	{
		g_pDebugLog->logMsg("%s | no cost card", __FUNCTION__);
		return;
	}
	
	int userID = creatorIter->second;
	char request[256];
	sprintf(request, GameGroup::Instance()->costCardRequest.c_str(), pGameServer->m_nLevel, activityID, userID, round);

	g_pDebugLog->logMsg("%s|request[%s] ", __FUNCTION__, request);

	HttpPost(GameGroup::Instance()->backServerUrl.c_str(), GameGroup::Instance()->backServerPort, request);//后台ip暂时写死 zsw，post到后台服务器，结束组局
	g_pDebugLog->logMsg("%s|cost card level[%d] activityID[%d] creator_user_id[%d] ", __FUNCTION__, pGameServer->m_nLevel,\
		activityID, userID);

	A2MChangeGroupState(pGameServer, userID, 2, activityID);
	return true;
}
bool GameGroup::PerfromRequestStopGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
{
	int tid = pPacket->ReadInt();
	int activityID = pPacket->ReadInt();
	int activityRounds = pPacket->ReadInt();
	/*NETOutputPacket resPacketTemp;
	resPacketTemp.Begin(SERVER_CREATE_ROBOT_CLEAN);
	resPacketTemp.WriteInt(tid);
	resPacketTemp.WriteInt(activityID);
	resPacketTemp.End();
	if (pGameServer->allocServer) {
		pGameServer->allocServer->Send(&resPacketTemp);
	}*/
	requestCancelGroupTable(GameGroup::Instance()->backServerRequest, pGameServer, tid, activityID, activityRounds);
	return true;
}

bool GameGroup::PerfromRequestStopCardGroup(NETInputPacket *pPacket, SocketHandler *pSocket, CGameServer *pGameServer)
{
	int tid = pPacket->ReadInt();
	int activityID = pPacket->ReadInt();
	int activityRounds = pPacket->ReadInt();
	g_pDebugLog->logMsg("%s|tid=%d activityID=%d activityRounds=%d", __FUNCTION__, tid, activityID, activityRounds);
	requestCancelGroupTable(GameGroup::Instance()->backServerRequest, pGameServer, tid, activityID, activityRounds);
	CancelGroupTable(pGameServer, activityID);
	return true;
}

int GameGroup::HttpPost(const char* strIp, int iPort, char* request)//返回http协议给后台服务器
{
	ACE_SOCK_Stream httpConnect;

	if (ACE_SOCK_Connector().connect(httpConnect, ACE_INET_Addr(iPort, strIp), 2) != -1) {
		char strRequest[65535];
		sprintf(strRequest, "POST /%s HTTP/1.0\r\n\r\n", request);
		httpConnect.send(strRequest, sizeof(strRequest) - 1); // "- 1": don't send '\0'
		//httpConnect.close();

		httpConnect.close_writer();
		/*char* buf = new char[65535];
		ACE_CString str;
		do {
			int bytes = httpConnect.recv(buf, 65535);
			if (bytes == -1 || bytes == 0) {
				break;
			}
			for (int i = 0; i < bytes; i++) {
				str += buf[i];
			}
		} while (true);
		delete[] buf;*/
		httpConnect.close();
		/*char buf[65535]; // maximum size of an IP packet

		while (ssize_t len = httpConnect.recv(buf, sizeof(buf))) { // (len == 0) is EOF
			if (len > 0) {
				//cout.write(buf, len);
				g_pDebugLog->logMsg("HttpPost----------buf, len =%s %d\n", buf, len);

			}

			else if (errno == EINTR) {
				g_pDebugLog->logMsg("HttpPost----------buf, len =%s %d\n", buf, len);
				return;
			}

			else {
				//std::cerr << "fatal error: " << std::strerror(errno) << '\n';
				//break;
				g_pDebugLog->logMsg("HttpPost----------buf, len =%d\n", errno);
			}
		}*/
	
	}

	g_pDebugLog->logMsg("HttpPost---------finish11111111111\n");
	return 0;
}

int GameGroup::requestCancelGroupTable(string requestUrl, CGameServer *pGameServer, int tid, int activityID, int activityRounds)
{
	
	CGameTable* pTable = getTable(pGameServer, tid);
	g_pDebugLog->logMsg("%s||requestCancelGroupTable == %d,%p\n", __FUNCTION__, tid, pTable);
	if (pTable)
	{
		if (pGameServer->m_pRedisManagerClient->WIN_CLOS_GROUP(tid, activityID, activityRounds) == -1) {
			g_pDebugLog->logMsg("WIN_CLOS_GROUP====  %d %d %d\n", __FUNCTION__, tid, activityID, activityRounds);
		}
	}

	return 1;
}

int GameGroup::CancelGroupTable(CGameServer *pGameServer, int activityID)
{
	int userID = 0;
	int tableID = 0;
	map<int, int>::iterator groupIter = pGameServer->m_GroupTableDict.find(activityID);
	if (groupIter == pGameServer->m_GroupTableDict.end())
	{
		g_pDebugLog->logMsg("%s||groupIter == pGameServer->m_GroupTableDict.end()\n", __FUNCTION__);
		return 0;
	}
	else
	{
		
		tableID = groupIter->second;
		
		for (map<int,int>::iterator  itr = pGameServer->m_GroupTidCreatorDict.begin(); itr!= pGameServer->m_GroupTidCreatorDict.end(); itr++)
		{
			
			if (itr->second == tableID) {
				g_pDebugLog->logMsg("CancelGroupTable  itr->second=%d  itr->second=%d\n", itr->second,itr->first);
				/*NETOutputPacket resPacketTT;
				resPacketTT.Begin(SYS_USER_LEAVE_ROOM);
				resPacketTT.WriteInt(itr->first);
				resPacketTT.WriteInt(tableID);
				resPacketTT.WriteInt(pGameServer->m_nLevel);
				resPacketTT.End();
				pGameServer->ProcessTransferPacketTemp(itr->first, resPacketTT);*/
				pGameServer->m_GroupTidCreatorDict.erase(itr);
			}
		}
		pGameServer->m_GroupTableDict.erase(groupIter);
	}
	map<int, int>::iterator groupIterTid = pGameServer->m_GroupTableDict_TID.find(tableID);
	if (groupIterTid == pGameServer->m_GroupTableDict_TID.end())
	{

	}
	else
	{
		pGameServer->m_GroupTableDict_TID.erase(groupIterTid);
	}
	
	map<int, int>::iterator userIter = pGameServer->m_GroupActivityCreatorDict.find(activityID);
	if (userIter == pGameServer->m_GroupActivityCreatorDict.end())
	{
		g_pDebugLog->logMsg("%s||userIter == pGameServer->m_GroupActivityCreatorDict.end()\n", __FUNCTION__);
		return 0;
	}
	else
	{
		userID = userIter->second;
		pGameServer->m_GroupActivityCreatorDict.erase(userIter);
	}

	//pGameServer->PerfromClearTid(tableID, userID);
	

	map<int, int>::iterator creatorIter = pGameServer->m_GroupCreatorDict.find(userID);
	if (creatorIter != pGameServer->m_GroupCreatorDict.end())
	{
		pGameServer->m_GroupCreatorDict.erase(creatorIter);
	}

	map<int, int>::iterator serverIter = pGameServer->m_GroupServerDict.find(tableID);
	if (serverIter != pGameServer->m_GroupServerDict.end())
	{
		pGameServer->m_GroupServerDict.erase(serverIter);
	}
	g_pDebugLog->logMsg("%s||userIter == pGameServer->m_GroupActivityCreatorDict.end()userID=[%d]\n", __FUNCTION__, userID);
	A2MChangeGroupState(pGameServer, userID, 0, activityID);

	CGameTable* pTable = getTable(pGameServer, tableID);
	if (pTable)
	{
		pTable->m_nOwnerUid = -1;
		pTable->m_activityID = 0;
		pTable->m_nTid = 0;
	}
	/*NETOutputPacket resPacket;
	resPacket.Begin(TABLE_INFO_TYPE_CLOSE_GAME);
	resPacket.WriteByte(7);
	resPacket.WriteShort(pGameServer->m_nLevel);
	resPacket.WriteInt(tableID);
	resPacket.WriteInt(0);
	resPacket.End();
	pGameServer->allocServer->Send(&resPacket);*/
	g_pDebugLog->logMsg("%s||success\n", __FUNCTION__);
	return 0;
}
CGameTable* GameGroup::getTable(CGameServer *pGameServer, int tid)
{
	CountTableList::iterator iterCount = pGameServer->m_CountTableList.begin();
	for (; iterCount != pGameServer->m_CountTableList.end(); iterCount++)
	{
		TableList& tableMap = iterCount->second;
		TableList::iterator iterTable = tableMap.find(tid);
		if (iterTable != tableMap.end())
		{
			CGameTable* pTempTable = iterTable->second;
			if (pTempTable != NULL)
			{
				if (pTempTable->m_nTid == tid)
					return pTempTable;
			}
		}
	}
	return NULL;
}


bool GameGroup::A2GCreateCardGroupTable(CLogicServer* pServer, int tid, int baseChip, int uid, CGameTable* pTable, int minCoinsGold, BYTE max_plaeryCount, \
	string strInviteCode, int activityID, int round, string gameConfig)
{
	//printf("pMemServer != NULL\n");
	//fflush(stdout);
	if (pServer->m_pSocketHandler == NULL)
	{
		//printf("pServer->m_pSocketHandler == NULL\n");
		//fflush(stdout);
		g_pDebugLog->logMsg("pServer->m_pSocketHandler == NULL [%d] [%d]", tid, uid);
		return false;
	}
	NETOutputPacket reqPacket;
	reqPacket.Begin(A2G_CREATE_CARD_GROUP);
	reqPacket.WriteInt(tid);
	reqPacket.WriteInt(baseChip);
	reqPacket.WriteInt(uid);
	reqPacket.WriteString(strInviteCode.c_str());
	reqPacket.WriteInt(activityID);
	reqPacket.WriteInt(round);
	reqPacket.WriteInt(pTable->m_needChips);
	reqPacket.WriteString(gameConfig.c_str());
	reqPacket.WriteInt(minCoinsGold);
	reqPacket.WriteByte(max_plaeryCount);
	reqPacket.WriteInt(pTable->club_id);
	reqPacket.End();
	pServer->m_pSocketHandler->Send(&reqPacket);//发送到斗地主服务器 zsw@1
	g_pDebugLog->logMsg("GameGroup::A2GCreateCardGroupTable [%d] [%d] [%s] [%d] [%d] [%d] [%d] send\n",\
			tid, uid, pServer->m_pSocketHandler->GetAddr().c_str(), pServer->m_pSocketHandler->m_nPort, pServer->m_nServerId,\
			pServer->m_nLevel, round);
	return true;
}

bool GameGroup::A2GCreateGroupTable(CLogicServer* pServer, int tid, int roomType, int baseChip, string roomName, string password, int uid,\
									int isLoveGirl, CGameTable* pTable, string strInviteCode,int activityID)
{
	//printf("pMemServer != NULL\n");
	//fflush(stdout);
	if (pServer->m_pSocketHandler == NULL)
	{
		//printf("pServer->m_pSocketHandler == NULL\n");
		//fflush(stdout);
		g_pDebugLog->logMsg("pServer->m_pSocketHandler == NULL [%d] [%d]",tid,uid);
		return false;
	}
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
	reqPacket.WriteString(strInviteCode.c_str());
	reqPacket.WriteInt(activityID);
	reqPacket.WriteInt(pTable->m_nLiftTime);
	reqPacket.End();
	pServer->m_pSocketHandler->Send(&reqPacket);//发送到斗地主服务器 zsw@1
	//printf("GameGroup::A2GCreateGroupTable [%d] [%d] [%s] [%d] [%d] [%d] send\n", tid, uid, pServer->m_pSocketHandler->GetAddr().c_str(), pServer->m_pSocketHandler->m_nPort, pServer->m_nServerId, pServer->m_nLevel);
	//fflush(stdout);
	g_pDebugLog->logMsg("GameGroup::A2GCreateGroupTable [%d] [%d] [%s] [%d] [%d] [%d] send\n", tid, uid, pServer->m_pSocketHandler->GetAddr().c_str(), pServer->m_pSocketHandler->m_nPort, pServer->m_nServerId, pServer->m_nLevel);
	return true;
}

bool GameGroup::A2GRemoveGroupTable(CLogicServer* pServer, int tid,int activityID)
{
	//printf("pMemServer != NULL\n");
	//fflush(stdout);
	if (pServer->m_pSocketHandler == NULL)
	{
		//printf("pServer->m_pSocketHandler == NULL\n");
		//fflush(stdout);
		g_pDebugLog->logMsg("pServer->m_pSocketHandler == NULL [%d]", tid);
		return false;
	}

	NETOutputPacket reqPacket;
	reqPacket.Begin(A2G_REMOVE_GROUP);
	reqPacket.WriteInt(tid);
	reqPacket.WriteInt(activityID);
	reqPacket.End();
	pServer->m_pSocketHandler->Send(&reqPacket);//发送到组局服务器 zsw@1
	g_pDebugLog->logMsg("GameGroup::A2GRemoveGroupTable tid[%d] activityID[%d] send\n", tid, activityID);
	return true;
}

bool GameGroup::A2BCreateGroupTable(SocketHandler *pSocket, int createFlag, int tableID)
{
	if (pSocket == NULL)
	{
		g_pDebugLog->logMsg("%s||GameGroup::A2BCreateGroupTable pSocket == NULL\n", __FUNCTION__);
		return false;
	}

	g_pDebugLog->logMsg("%s||GameGroup::A2BCreateGroupTable pSocket != NULL\n", __FUNCTION__);


	NETOutputPacket resPacket;
	resPacket.Begin(A2B_CREATE_GROUP_TABLE_RESULT);//返回创建房间结果给后台服务器 zsw
	resPacket.WriteInt(0);
	resPacket.WriteInt(createFlag);

	//printf("GameGroup::A2BCreateGroupTable createFlag[%d]\n", createFlag);
	//fflush(stdout);

	g_pDebugLog->logMsg("%s||GameGroup::A2BCreateGroupTable createFlag[%d]\n", __FUNCTION__, createFlag);

	
	resPacket.WriteInt(0);
	resPacket.WriteInt(tableID);
	resPacket.WriteString("");
	resPacket.WriteInt(0);
	resPacket.WriteInt(0);
	resPacket.WriteInt(0);

	g_pDebugLog->logMsg("%s||pTable->m_nTid[%d]\n", __FUNCTION__, tableID);
	//printf("GameGroup::A2BCreateGroupTable m_nServerId[%d] m_nTid[%d] m_strIp[%s] m_nPort[%d] m_nRoomIndex[%d] m_nCreateTime\n", pTable->m_nServerId, pTable->m_nTid, pTable->m_pServer->m_strIp.c_str(), pTable->m_pServer->m_nPort, pTable->m_nRoomIndex, pTable->m_nCreateTime);
	//fflush(stdout);

	g_pDebugLog->logMsg("%s||GameGroup::A2BCreateGroupTable tableID[%d]\n", __FUNCTION__, tableID);
	
	resPacket.End();
	pSocket->Send(&resPacket);

	return true;
}
