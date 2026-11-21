#include <memcheck.h>
#include <CHelper_pool.h>
#include "client_unit.h"

HTTP_SVR_NS_BEGIN

CHelperPool::CHelperPool(void)
{	
}

CHelperPool::~CHelperPool(void)
{
}

int CHelperPool::RandomSvid(vector<int>& v)
{
	int size = (int)v.size();
	//srand((unsigned)time(NULL));
	int value = rand()%size;
	return v[value];
}

int CHelperPool::ProcessUserLogoutHall(CClientUnit * cu)
{
	cu->_decoderunit->complete();
	return 0;
}

int CHelperPool::ProcessSetLogLevel(NETInputPacket &input, CClientUnit *cu)
{
	int old_level = TGlobal::_log_level;
	int new_level = input.ReadInt();
	if(new_level >= 0){
		TGlobal::_log_level = new_level;
		TGlobal::g_pErrorLog->set_level(TGlobal::_log_level); 
		TGlobal::g_pDebugLog->set_level(TGlobal::_log_level);
		set_log_level(TGlobal::_log_level);

		log_error("update log level sucess old_level[%d], new_level[%d]",old_level, new_level);
	}else{
		log_error("update log level fail old_level[%d], want_level[%d]",old_level, new_level);
		new_level = old_level;
	}

	NETOutputPacket out;
	out.Begin(CONTROL_CMD_LOG_LEVEL);
	out.WriteInt(old_level);
	out.WriteInt(new_level);
	out.End();
	cu->_decoderunit->SendPacketToClient(out.packet_buf(),out.packet_size());

	return 0;

}

//收到的客户端消息
int CHelperPool::DispatchPacket(CClientUnit * cu,const char *pData, int len)
{
	if (cu == NULL)
	{
		//fatal error
		return -1;
	}
	NETInputPacket input;
	input.Copy(pData,len);
	int cmd = input.GetCmdType();
	//log_boot("cmd[0x%x],cu->_uid[%d]", cmd, cu->_uid);
	//心跳包
	if(cmd == CLIENT_CMD_HEART_BEAT)
	{
		//short version = input.ReadShort();
		cu->_decoderunit->SendPacketToClient(pData, len);
		//log_debug("response data complete, deconderunit[%d]", cu->_decoderunit->get_conn_type());
	
		CEncryptDecrypt decrypt;
		decrypt.DecryptBuffer(&input);
		//short gameid = input.ReadShort();
		//short business = input.ReadShort();//业务id
		//int pingtai1 = input.ReadByte(); //平台id
		////int pingtai2 = input.ReadByte(); //平台id
		int tid = input.ReadInt();
		//log_boot("cu->HEART_BEAT_TID[%d] ", tid);
		if(tid > 0) {
			int svid = tid >> 16;
			map<int, LogicInfo>::iterator it = m_logicmap.find(svid);

			if (it != m_logicmap.end()) {
				LogicInfo &logicinfo = it->second;
				NETOutputPacket nTPacket;
				if (!nTPacket.Copy(input.packet_buf(), input.packet_size()))//_r.data(), pkglen))//tranPacket.packet_buf(),tranPacket.packet_size()))
				{
					return 0;
				}
				CEncryptDecrypt encryptdecrypt;
				encryptdecrypt.EncryptBuffer(&nTPacket);
				cu->OnUserHeartBeat(nTPacket.packet_buf(), nTPacket.packet_size(), tid, logicinfo.ip, logicinfo.port);
			}
		}
		else {
			
		}
		return 0;
	}else if(cmd == CONTROL_CMD_LOG_LEVEL)
	{

		ProcessSetLogLevel(input, cu);
		return 0;
	}


	//?μí3?????üá?×?
	
	//printf("***************cmd[0x%x],cu->_uid[%d]\n",cmd,cu->_uid);//zswx
	//fflush(stdout);
	if (cmd == B2A_REMOVE_GROUP_TABLE) {
		CHelperUnit *pHelperUnit = NULL;
		CEncryptDecrypt decrypt;
		decrypt.DecryptBuffer(&input);
		//short gameid = input.ReadShort();
		//short business = input.ReadShort();//业务id
		//int pingtai1 = input.ReadByte(); //平台id
		////int pingtai2 = input.ReadByte(); //平台id
		int tid = input.ReadInt();
		log_debug("B2A_REMOVE_GROUP_TABLE Request ,tid[%d]", tid);
		if (tid > 0) {
			int serverId = (tid >> 16) / 20;
			if ((int)m_svidlist.size() > 0)
			{
				//int svid = RandomSvid(m_svidlist);
				pHelperUnit = m_helpermap[serverId];
			}
			if (pHelperUnit != NULL)
			{
				HeadInfo hi;
				hi.gameid = m_GameId;
				NETOutputPacket transPacket;
				//transPacket.SetRegion(m_GameId);//?ùóD·￠3?è￥μ?°ü??′?é?òμ??id
				transPacket.SetHeadInfo(hi);
				transPacket.Begin(CLIENT_PACKET);
				transPacket.WriteInt(cu->_uid);
				transPacket.WriteInt(TGlobal::_svid);//±ê??????server·￠μ?
				transPacket.WriteBinary(pData, len);
				transPacket.End();
				return pHelperUnit->SendPacketToLogic(transPacket.packet_buf(), transPacket.packet_size(), cu->_decoderunit->get_helper_timer());
			}
		}
		
		return 0;
	}
	if(cmd == CLIENT_CMD_CLUB_DATA || cmd == CLIENT_DISABLE_USER_GAME || cmd ==CLIENT_USER_GAME_STATUS || cmd == CLIENT_COMMAND_USER_ONLINE) {
		CHelperUnit *pHelperUnit = NULL;
		if ((int)m_svidlist.size() > 0)
		{
			//int svid = RandomSvid(m_svidlist);
			pHelperUnit = m_helpermap[1];
		}
		if (pHelperUnit != NULL)
		{
			HeadInfo hi;
			hi.gameid = m_GameId;
			NETOutputPacket transPacket;
			//transPacket.SetRegion(m_GameId);//?ùóD·￠3?è￥μ?°ü??′?é?òμ??id
			transPacket.SetHeadInfo(hi);
			transPacket.Begin(CLIENT_PACKET);
			transPacket.WriteInt(cu->_uid);
			transPacket.WriteInt(TGlobal::_svid);//±ê??????server·￠μ?
			transPacket.WriteBinary(pData, len);
			transPacket.End();
			return pHelperUnit->SendPacketToLogic(transPacket.packet_buf(), transPacket.packet_size(), cu->_decoderunit->get_helper_timer());
		}
		return 0;
	}
	
	if(cmd > SYS_CMD_BEGIN && cmd < SYS_CMD_END)
	{
		ProcSysCmd(input);
		return 0;
	}
	if (cmd >BROADCAST_CMD_BEGIN && cmd <BROADCAST_CMD_END)
	{
		ProcBroadCastCmd(cu,input);
		return 0;
	}
	if(cmd > FRIEND_CMD_BEGIN && cmd < FRIEND_CMD_END)
	{
		ProcFriendCmd(cu,input);
		return 0;
	}

	if(cmd == HALL_MATCH_CMD)
	{

		ProcClientMatchCmd(cu, input);
		return 0;
	}
	
	if(cmd != CLIENT_CMD_CLIENT_LOGIN && cu->_uid <= 0)
	{
		log_debug("Invalid Request cmd[0x%x],cu->_uid[%d]",cmd,cu->_uid);
		return -1;
	}

	
	
	//ó??·?üá?×??±?ó′???GameServer
	if(cmd > CMD_SEPARATE)
	{
		return cu->HandleInputGameServerBuf(input.packet_buf(),input.packet_size());
	}
	//′|àíí?′??üá?
	if(cmd > PENETRATE_CMD_BEGIN && cmd < PENETRATE_CMD_END)
	{
		return ProcPenetrateCmd(cu,pData,len);
	}
	//?′?a?üá?,2?óè′|àí
	return -1;
}

//收到的所有的后台消息
int CHelperPool::DispatchBackPacket(CHelperUnit * ch,NETInputPacket & tranPacket){
	if (ch == NULL)
	{
		log_error("Fatal Error,ch is NULL");
	}
	int cmd = tranPacket.GetCmdType();
	int uid = tranPacket.ReadInt();
	int svid = tranPacket.ReadInt();	
	log_debug("Receive Packet From Server.GameId:%d ,uid:%d,svid:%d,cmd:0x%x",m_GameId,uid,svid,cmd);
	(void)svid;
	CDecoderUnit* _decoder = NULL;
	std::map<int, CDecoderUnit*>::iterator iter = m_objmap.find(uid);
	if( iter != m_objmap.end()){
		_decoder = iter->second;
		if(_decoder == NULL || _decoder->get_web_unit() == NULL){
			ch->ProcessUserClose(uid);
			return 0;
		}
		else
		{
			if(cmd == CLIENT_PACKET)
			{
				char szTemp[10240];
				int rLen = tranPacket.ReadBinary(szTemp, sizeof(szTemp));
				//log_boot("rLen:[%d]", rLen);
				if(rLen == -1){
					log_error("Helper ReadBinary error");
					return -1;
				}
				NETInputPacket tempPacket;
				tempPacket.Copy(szTemp, rLen);
				int cmd = tempPacket.GetCmdType();
				
				log_debug("Receive Packet From AllocServer CLIENT_PACKET ip =%ld, uid:%d,svid:%d,cmd:0x%x" , _decoder->get_ip(),uid,svid,cmd);
				if(cmd == SERVER_CMD_LOGIN_SUCCESS){
					ch->ProcessUserLoginSuccess(_decoder, &tempPacket);
				}
				else if (cmd == 371) {

				}
				else if (cmd == SERVER_CMD_JOIN_GAME){
					ch->ProcessUserJoinGame(_decoder, &tempPacket);
				}
				else if (cmd == CLIENT_CMD_JOIN_PRIVATE_GAME )
				{
					ch->ProcessJoinPrivateRoom(uid, _decoder, &tempPacket);
				}
				else if(cmd == CLIENT_CMD_JOIN_CUSTOM_ROOM)
				{
					ch->ProcessJoinCustomRoom(uid, _decoder, &tempPacket);
				}

				_decoder->SendPacketToClient(szTemp,rLen);
			}
			else if(cmd == SERVER_CLOSE_PACKET){
				_decoder->set_conn_type(CONN_OTHER);
				_decoder->complete();
			}
			else if(cmd == CLIENT_FRIEND_PACKET)
			{
				char szTemp[10240];
				int rLen = tranPacket.ReadBinary(szTemp, sizeof(szTemp));
				//log_debug("rLen:[%d]", rLen);
				if(rLen == -1){
					log_error("Helper ReadBinary error");
					return -1;
				}
				_decoder->SendPacketToClient(szTemp,rLen);
			}
			else if(cmd == CLIENT_BROADCAST_PACKET)
			{
				char szTemp[10240];
				int rLen = tranPacket.ReadBinary(szTemp, sizeof(szTemp));
				//log_debug("rLen:[%d]", rLen);
				if(rLen == -1){
					log_error("Helper ReadBinary error");
					return -1;
				}
				NETInputPacket tempPacket;
				tempPacket.Copy(szTemp, rLen);

				ProcBroadCastBackCmd(_decoder,tempPacket);
			}
			else if(cmd == HALL_MATCH_CMD)
			{

				ProcMatchCmd(_decoder,tranPacket);
				return 0;
			}
			else if(cmd==ALLOW_PACKET)
			{
				//allow 的协议正常就是发发出去
				int level= tranPacket.ReadInt(); //要发送给的allow
				log_boot("level:[%d]", level);
				char szTemp[10240];
				int rLen = tranPacket.ReadBinary(szTemp, sizeof(szTemp));
				log_boot("rLen:[%d]", rLen);
				if(rLen == -1){
					log_error("Helper ReadBinary error");
					return -1;
				}
				CHelperUnit *pHelperUnit = NULL;
				//这里获取allow 0 是所有的 递归m_helpermap
				if(level!=0)
				{
					pHelperUnit = m_helpermap[level]; //GetHelpUnitByLevel(level);
													  //然后这里发送
					HeadInfo hi;
					hi.gameid = m_GameId;
					NETOutputPacket _transPacket;
					_transPacket.SetHeadInfo(hi);
					_transPacket.Begin(ALLOW_PACKET);
					NETInputPacket tempPacketTemp;
					tempPacketTemp.Copy(szTemp, rLen);
					_transPacket.WriteInt(uid);
					_transPacket.WriteInt(TGlobal::_svid);
					_transPacket.WriteInt(level);
					_transPacket.WriteBinary(tempPacketTemp.packet_buf(), tempPacketTemp.packet_size());
					_transPacket.End();
					pHelperUnit->SendPacketToLogic(_transPacket.packet_buf(), _transPacket.packet_size(), _decoder->get_helper_timer());
					
					
				}
				else {
					for (std::map<int, CHelperUnit*>::iterator iterHelper = m_helpermap.begin(); iterHelper!= m_helpermap.end(); iterHelper++)
					{
						CHelperUnit *pHelperUnit = iterHelper->second;
						if (pHelperUnit != NULL && iterHelper->first > 2) {
							HeadInfo hi;
							hi.gameid = m_GameId;
							NETOutputPacket _transPacket;
							_transPacket.SetHeadInfo(hi);
							_transPacket.Begin(ALLOW_PACKET);
							NETInputPacket tempPacketTemp;
							tempPacketTemp.Copy(szTemp, rLen);
							_transPacket.WriteInt(uid);
							_transPacket.WriteInt(svid);
							_transPacket.WriteInt(level);
							_transPacket.WriteBinary(tempPacketTemp.packet_buf(), tempPacketTemp.packet_size());
							_transPacket.End();
							pHelperUnit->SendPacketToLogic(_transPacket.packet_buf(), _transPacket.packet_size(), _decoder->get_helper_timer());
						}
					}
					
				}
				
			
			}
			else{
				log_error("Helper invalid cmd");
			}
		}
	}
	else if(cmd==CLIENT_BROADCAST_PACKET && uid<=0)
	{
		char szTemp[10240];
		int rLen = tranPacket.ReadBinary(szTemp, sizeof(szTemp));
		//log_debug("rLen:[%d]", rLen);
		if(rLen == -1){
			log_error("Helper ReadBinary error");
			return -1;
		}
		NETInputPacket tempPacket;
		tempPacket.Copy(szTemp, rLen);

		ProcBroadCastBackCmd(_decoder,tempPacket);
	}
	return 0;
}

void CHelperPool::ProcSysCmd(NETInputPacket & input)
{
	int cmd = input.GetCmdType();
	//log_debug("System Cmd:0x%x",cmd);
	return;
}

int CHelperPool::ProcBroadCastSingle(NETInputPacket & input)
{
	string key = input.ReadString();
	int uid = input.ReadInt();
	log_debug("Login request - uid:%d, storeId will be read next", uid);
	short type = input.ReadShort();
	string info = input.ReadString();
	std::map<int, CDecoderUnit*>::iterator iter = m_objmap.find(uid);
	if( iter != m_objmap.end()){
		CDecoderUnit * _decoder = iter->second;
		if (_decoder != NULL)
		{
			NETOutputPacket output;
			output.Begin(BROADCAST_CMD_SINGLE);
			output.WriteShort(type);
			output.WriteString(info);
			output.End();
			CEncryptDecrypt encryptdecrypt;
			encryptdecrypt.EncryptBuffer(&output);
			_decoder->SendPacketToClient(output.packet_buf(),output.packet_size());
		}
		else
		{
			log_debug("Decoder For User[%d] Is Null",uid);
		}
	}
	else
	{
		log_debug("User[%d] Not Exist",uid);
	}
	
	return 0;
}

int CHelperPool::ProcBroadCastAll(NETInputPacket & input)
{
	string info = input.ReadString();
	std::map<int, CDecoderUnit*>::iterator iter = m_objmap.begin();
	if(iter == m_objmap.end())
		log_debug("No User Exist.");
	while( iter != m_objmap.end()){
		CDecoderUnit * _decoder = iter->second;
		if (_decoder != NULL)
		{
			NETOutputPacket output;
			output.Begin(BROADCAST_CMD_ALL);
			output.WriteString(info);
			output.End();
			CEncryptDecrypt encryptdecrypt;
			encryptdecrypt.EncryptBuffer(&output);
			_decoder->SendPacketToClient(output.packet_buf(),output.packet_size());
		}
		else
		{
			log_debug("Decoder For User[%d] Is Null",iter->first);
		}
		iter ++;
	}
	
	return 0;
}

int CHelperPool::ProcBroadCastInfoAll(NETInputPacket & input)
{
	int type = input.ReadInt();
	string info = input.ReadString();
	log_debug("broadcast type[%d] info[%s]",type, info.c_str());
	std::map<int, CDecoderUnit*>::iterator iter = m_objmap.begin();
	if(iter == m_objmap.end())
		log_debug("No User Exist.");
	while( iter != m_objmap.end()){
		CDecoderUnit * _decoder = iter->second;
		if (_decoder != NULL)
		{
			NETOutputPacket output;
			output.Begin(BROADCAST_INFO_PACKET);
			output.WriteInt(type);
			output.WriteString(info);
			output.End();
			CEncryptDecrypt encryptdecrypt;
			encryptdecrypt.EncryptBuffer(&output);
			_decoder->SendPacketToClient(output.packet_buf(),output.packet_size());
		}
		else
		{
			log_debug("Decoder For User[%d] Is Null",iter->first);
		}
		iter ++;
	}
	
	return 0;
}



int CHelperPool::ProcClientChat(CDecoderUnit* _decoder,NETInputPacket& input)
{
	if(_decoder != NULL)
	{
		_decoder->SendPacketToClient(input.packet_buf(),input.packet_size());
	}
	else
	{
		log_debug("Decoder is Null");
	}

	return 0;
}

int CHelperPool::ProcMatchCmd(CDecoderUnit*  _decoder,NETInputPacket& input)
{
	NETOutputPacket nTPacket;
	
    if(!nTPacket.Copy(input.packet_buf(),input.packet_size()))//_r.data(), pkglen))//tranPacket.packet_buf(),tranPacket.packet_size()))
    {
    	return 0;
    } 
	
	CEncryptDecrypt encryptdecrypt;
	encryptdecrypt.EncryptBuffer(&nTPacket);

	int	nRet = _decoder->SendPacketToClient(nTPacket.packet_buf(),nTPacket.packet_size());
	log_debug("send MatchCmd to client nRet:%d", nRet);
			
}

int CHelperPool::ProcBroadCastBackCmd(CDecoderUnit*  _decoder,NETInputPacket& input)
{
	int cmd = input.GetCmdType();
	log_debug("BroadCast Cmd:0x%x",cmd);
	switch(cmd){
		case BROADCAST_CMD_SINGLE:
			log_debug("BroadCastSingle");
			ProcBroadCastSingle(input);
			break;
		case BROADCAST_CMD_ALL:
			log_debug("BroadCastAll");
			ProcBroadCastAll(input);
			break;
		case BROADCAST_INFO_PACKET:
			ProcBroadCastInfoAll(input);
			break;
		case BROADCAST_CMD_CHAT:
		case BROADCAST_CMD_RESPONSE_CHAT:
		case BROADCAST_CONSORTIA_PACKET:
			log_debug("client chat [%d]",cmd);
			ProcClientChat(_decoder,input);
			break;
		default:
			log_debug("undefined cmd:0x%x",cmd);
			break;
	}
	
	return 0;
}

int CHelperPool::ProcBroadCastCmd(CClientUnit *  cu,NETInputPacket & input)
{
	if(m_pBroadcastUnit != NULL)
	{
		HeadInfo hi;
		hi.gameid = m_GameId;
		NETOutputPacket transPacket;
		transPacket.SetHeadInfo(hi);
		transPacket.Begin(CLIENT_BROADCAST_PACKET);
		transPacket.WriteInt(cu->_uid);
		transPacket.WriteInt(TGlobal::_svid);//±ê??????server·￠μ?
		transPacket.WriteBinary(input.packet_buf(),input.packet_size());
		transPacket.End();
		return m_pBroadcastUnit->SendPacketToLogic(transPacket.packet_buf(),transPacket.packet_size(),\
				cu->_decoderunit->get_helper_timer());
	}
}

int CHelperPool::ProcClientMatchCmd(CClientUnit *  cu,NETInputPacket &input)
{
	if(m_pMatchManager != NULL)
	{
		
		CEncryptDecrypt encryptdecrypt;
		int decryptRet = encryptdecrypt.DecryptBuffer(&input);
	if(decryptRet < 0) {
		log_error("DecryptBuffer failed! ret=%d, possible encryption mismatch", decryptRet);
		return -1;
	}

		NETOutputPacket transPacket;

		
		transPacket.Copy(input.packet_buf(),input.packet_size());

		return m_pMatchManager->SendPacketToLogic(transPacket.packet_buf(),transPacket.packet_size(),cu->_decoderunit->get_helper_timer());
		
	}
}


int CHelperPool::ProcFriendCmd(CClientUnit *  cu,NETInputPacket &input)
{
	if(m_pFriendUnit != NULL)
	{
		HeadInfo hi;
		hi.gameid = m_GameId;
		NETOutputPacket transPacket;
		transPacket.SetHeadInfo(hi);
		transPacket.Begin(CLIENT_FRIEND_PACKET);
		transPacket.WriteInt(cu->_uid);
		transPacket.WriteInt(TGlobal::_svid);//±ê??????server·￠μ?
		transPacket.WriteBinary(input.packet_buf(),input.packet_size());
		transPacket.End();
		return m_pFriendUnit->SendPacketToLogic(transPacket.packet_buf(),transPacket.packet_size(),\
				cu->_decoderunit->get_helper_timer());
	}

	return 0;
}
//请求登入和加入房间使用
int CHelperPool::ProcPenetrateCmd(CClientUnit *  cu,const char *pData, int len)
{
	NETInputPacket input;
	input.Copy(pData,len);
	int cmd = input.GetCmdType();
	CHelperUnit *pHelperUnit = NULL;
	//dispatch to alloc server
	
	if(cmd == CLIENT_CMD_JOIN_GAME || cmd == CLIENT_CMD_CHANGE_ROOM || cmd == CLIENT_CMD_JOIN_TABLE)
	{
		ProcClientJoinGame(pHelperUnit,input);
	}
	else if (cmd == CLIENT_CMD_ROBOT_JOIN_GAME)
	{
		ProcClientJoinGame(pHelperUnit,input);
	}
	else if (cmd == CLIENT_CMD_GET_ROOMLIST || cmd == CLIENT_CMD_CREATE_ROOM || \
		cmd == CLIENT_CMD_GET_ROOM_BY_ID || cmd == CLIENT_CMD_JOIN_PRIVATE_GAME)
	{
		ProcClientPrivateRoom(pHelperUnit,input);
	}
	else if(cmd >= CLIENT_CMD_CREATE_CUSTOM_ROOM && cmd <= CLIENT_CMD_JOIN_CUSTOM_ROOM)
	{
		ProcClientCustomRoom(pHelperUnit,input);
	}
	else if (cmd == CLIENT_CMD_CLIENT_LOGIN )
	{
		ProcClientLoginHall(cu,input);
		//将用户登陆的信息通知广播服务器和好友服务器
		ProcFriendCmd(cu,input);
		ProcBroadCastCmd(cu,input);
		if ((int)m_svidlist.size() > 0) {
			int svid = RandomSvid(m_svidlist);
			pHelperUnit = m_helpermap[1];
		}
	
		
		//if((int)m_svidlist.size() > 0)
		//{
		//	int svid = RandomSvid(m_svidlist);
		//	pHelperUnit = m_helpermap[svid];
		//	for (int k = 0; k < m_svidlist.size(); k++)
		//	{
		//		CHelperUnit *pHelperUnitV = NULL;
		//		pHelperUnitV = m_helpermap[m_svidlist[k]];
		//		if (pHelperUnitV != NULL)
		//		{
		//			HeadInfo hi;
		//			hi.gameid = m_GameId;
		//			NETOutputPacket transPacketV;
		//			NETOutputPacket output;
		//			output.Begin(0x0555);
		//			output.WriteInt(cu->_uid);
		//			output.End();
		//			//transPacket.SetRegion(m_GameId);//?ùóD·￠3?è￥μ?°ü??′?é?òμ??id
		//			transPacketV.SetHeadInfo(hi);
		//			transPacketV.Begin(CLIENT_PACKET);
		//			transPacketV.WriteInt(cu->_uid);
		//			transPacketV.WriteInt(TGlobal::_svid);//±ê??????server·￠μ?
		//			transPacketV.WriteBinary(output.packet_buf(), output.packet_size());
		//			transPacketV.End();
		//			pHelperUnitV->SendPacketToLogic(transPacketV.packet_buf(), transPacketV.packet_size(), cu->_decoderunit->get_helper_timer());
		//		}
		//	}
		//	//return 0;
		//}
	}
	else if(cmd == CLIENT_CMD_GET_LEVEL_NUM)
	{
		if((int)m_svidlist.size() > 0)
		{
			int svid = RandomSvid(m_svidlist);
			pHelperUnit = m_helpermap[svid];
		}
	}
	if(pHelperUnit != NULL)
	{
		HeadInfo hi;
		hi.gameid = m_GameId;
		NETOutputPacket transPacket;
		//transPacket.SetRegion(m_GameId);//?ùóD·￠3?è￥μ?°ü??′?é?òμ??id
		transPacket.SetHeadInfo(hi);
		transPacket.Begin(CLIENT_PACKET);
		transPacket.WriteInt(cu->_uid);
		transPacket.WriteInt(TGlobal::_svid);//±ê??????server·￠μ?
		transPacket.WriteBinary(pData,len);
		transPacket.End();
		return pHelperUnit->SendPacketToLogic(transPacket.packet_buf(),transPacket.packet_size(),cu->_decoderunit->get_helper_timer());
	}

	return 0;
}

int CHelperPool::ProcClientJoinGame(CHelperUnit * & pHelperUnit ,NETInputPacket & input)
{
	CEncryptDecrypt encryptdecrypt;
	int decryptRet = encryptdecrypt.DecryptBuffer(&input);
	if(decryptRet < 0) {
		log_error("DecryptBuffer failed! ret=%d, possible encryption mismatch", decryptRet);
		return -1;
	}
	short level = input.ReadShort();
	log_boot("Client Request Jion Game ,Level:%d",level);
	//if(serverId > 0){//pc′í?ó?￠D???á?
	//	int svid = (serverId/1000)%100;
	//	map<int, CHelperUnit*>::iterator iterHelper = m_helpermap.find(svid);
	//	if(iterHelper != m_helpermap.end())	{
	//		pHelperUnit = iterHelper->second;
	//	}
	//	else{
	//		log_error("Can not find helper, serverId>0, svid:[%d]", svid); //?ò2?μ?alloc helper
	//	}
	//}
	//else
    
	map<int, vector<int> >::iterator iter = m_levelmap.find(level);
	if(iter != m_levelmap.end()){
		vector<int>& v = iter->second;
		if((int)v.size() > 0){
			int svid = RandomSvid(v);
			map<int, CHelperUnit*>::iterator iterHelper = m_helpermap.find(svid);
			if(iterHelper != m_helpermap.end()){
				pHelperUnit = iterHelper->second;
			}
			else{
				log_error("Can not find helper, svid:[%d]", svid); //?ò2?μ?alloc helper
			}
		}
	}
	else{
		log_error("Can not find helper, level:[%d]", level);
	}
	
	return 0;
}

int CHelperPool::ProcClientPrivateRoom(CHelperUnit * & pHelperUnit ,NETInputPacket & input)
{
	CEncryptDecrypt encryptdecrypt;
	int decryptRet = encryptdecrypt.DecryptBuffer(&input);
	if(decryptRet < 0) {
		log_error("DecryptBuffer failed! ret=%d, possible encryption mismatch", decryptRet);
		return -1;
	}
	short level = input.ReadShort();
	pHelperUnit = GetHelpUnitByLevel(level);
	return 0;
}

int CHelperPool::ProcClientCustomRoom(CHelperUnit * & pHelperUnit ,NETInputPacket & input)
{
	CEncryptDecrypt encryptdecrypt;
	int decryptRet = encryptdecrypt.DecryptBuffer(&input);
	if(decryptRet < 0) {
		log_error("DecryptBuffer failed! ret=%d, possible encryption mismatch", decryptRet);
		return -1;
	}
	short level = input.ReadShort();
	pHelperUnit = GetHelpUnitByLevel(level);
	return 0;
}



/*
*根据场次随机一个svid 的 HelperUnit
*/
CHelperUnit* CHelperPool::GetHelpUnitByLevel(int level)
{

	log_debug("GetHelpUnitByLevel level[%d]", level);
	CHelperUnit *pHelperUnit = NULL;
	map<int, vector<int> >::iterator iter = m_levelmap.find(level);
	if(iter != m_levelmap.end()){
		vector<int>& v = iter->second;
		if((int)v.size() > 0){
			int svid = RandomSvid(v);
			map<int, CHelperUnit*>::iterator iterHelper = m_helpermap.find(svid);
			if(iterHelper != m_helpermap.end()){
				pHelperUnit = iterHelper->second;
			}
			else{
				log_error("Can not find helper, svid:[%d]", svid); //?ò2?μ?alloc helper

			}
		}
	}
	else{
		log_error("Can not find helper, level:[%d]", level);
	}

	return pHelperUnit;
}

int CHelperPool::ProcClientLoginHall(CClientUnit * cu ,NETInputPacket & input)
{
	if(cu==NULL){
		return -1;
	}
	if(cu->_uid != 0)
	{
		log_debug("Invalid Login Request Already Login , Uid:%d",cu->_uid);
		return -1;
	}
	CEncryptDecrypt encryptdecrypt;
	int decryptRet = encryptdecrypt.DecryptBuffer(&input);
	if(decryptRet < 0) {
		log_error("DecryptBuffer failed! ret=%d, possible encryption mismatch", decryptRet);
		return -1;
	}
	int uid = input.ReadInt();
	log_debug("Login request - uid:%d, storeId will be read next", uid);
	int storeId = input.ReadInt(); 
	(void)storeId;
	BYTE clientType = input.ReadByte();
	(void)clientType;
	string clientInfo = input.ReadString();
	if(uid <= 0){
		//fatal error
		log_debug("Invalid uid:%d",uid);
		return -1;
	}
	map<int, CDecoderUnit*>::iterator iter = m_objmap.find(uid);
	if (iter != m_objmap.end()) {
		CDecoderUnit* pDecoderUnit = iter->second;
		if (pDecoderUnit != NULL && pDecoderUnit != cu->_decoderunit)//???óò?ì?á??ó′|àíá?D?2??μ???°ü
		{
			NETOutputPacket resPacket;
			resPacket.Begin(SERVER_CMD_KICK_OUT);
			resPacket.End();
			CEncryptDecrypt encryptdecrypt;
			encryptdecrypt.EncryptBuffer(&resPacket);
			pDecoderUnit->SendPacketToClient(resPacket.packet_buf(), resPacket.packet_size());
			pDecoderUnit->set_conn_type(CONN_OTHER);
			pDecoderUnit->complete();
			log_error("%s||Kick the same user, uid:[%d]", __FUNCTION__, uid);
		}
	}
	cu->_decoderunit->set_flag(uid);
	cu->_decoderunit->set_conn_type(CONN_CLINET);
	cu->_uid = uid;
	m_objmap[uid] = cu->_decoderunit;
	cu->_gameID = m_GameId;
        // Send login success response to client - SVR_LOGIN_OK (0x201)
        NETOutputPacket resPacket;
        resPacket.Begin(0x201);  // SVR_LOGIN_OK
        // Field 1: Ver = 1 (success)
        resPacket.WriteInt(1);
        // Field 2: Levelcount = 0 (no level data)
        resPacket.WriteInt(0);
        // Field 3: Usercount array (empty because Levelcount=0, write 0 elements)
        // Field 4: Friendcount = 0
        resPacket.WriteInt(0);
        // Field 5: Tid = 0 (first login)
        resPacket.WriteInt(0);
        // Field 6: Ip = "" (because Tid=0)
        resPacket.WriteString("");
        // Field 7: port = 0 (because Tid=0)
        resPacket.WriteInt(0);
        // Field 8: Serverlevel = 0 (because Tid=0)
        resPacket.WriteShort(0);
        // Field 9: on_look_user = 0
        resPacket.WriteInt(0);
        // Field 10: type = 0
        resPacket.WriteInt(0);
        // Field 11: battles_count = 0
        resPacket.WriteByte(0);
        // Field 12: battles_list array (empty because battles_count=0)
        resPacket.End();
        encryptdecrypt.EncryptBuffer(&resPacket);
        cu->_decoderunit->SendPacketToClient(resPacket.packet_buf(), resPacket.packet_size());
        log_error("Login success, sent SVR_LOGIN_OK to uid:%d, packet size:%d", uid, resPacket.packet_size());
	return 0;
	}

HTTP_SVR_NS_END
