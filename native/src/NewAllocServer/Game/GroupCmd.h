#define A2M_CHANGE_MONEY2CHIP 0x301A		//查询用户兑换筹码结果 zsw
#define A2M_UPDATE_CHIPS 0x301B		//查询用户获取筹码结果 zsw
#define A2M_GET_CHIPS 0x301C			//查询用户更新筹码结果 zsw
#define A2M_CHANGE_CHIP2MONEY 0x301D	//查询用户筹码换金币结果 zsw
#define A2M_CHANGE_TABLE_STATE 0x302D	//修改组局状态 zsw

#define M2A_CHANGE_MONEY2CHIP 0x301A			//memdataserver返回用户兑换筹码结果 zsw
#define M2A_UPDATE_CHIPS 0x301B			//memdataserver返回用户获取筹码结果 zsw
#define M2A_GET_CHIPS 0x301C				//memdataserver返回用户更新筹码结果 zsw
#define M2A_CHANGE_CHIP2MONEY 0x301D		//memdataserver返回用户筹码换金币结果 zsw

#define G2A_REPORT_END_GROUNP 0x150				//上报结束组局 game_server ---> alloc
#define G2A_REQUEST_END_GROUNP 0x156				//游戏服请求结束组局 game_server ---> alloc
#define G2A_REQUEST_END_CARD_GROUNP 0x157			//请求结束房卡组局
#define G2A_BROADCAST_TABLE_INFO  0x159    //桌子信息
#define G2U_BEFORE_CREATE_GROUP_CHECK 0x630		//发送到用户服，创建组局前的检测
#define U2G_BEFORE_CREATE_GROUP_CHECK 0x630		//发送到用户服，创建组局前的检测

#define A2G_REMOVE_GROUP 0x155				//上报结束组局 game_server ---> alloc


#define A2G_CREATE_CARD_GROUP 0x403				 //向GameServer发送创建消耗卡的组局场
#define A2G_USER_IP			0x414				 //向GameServer发送用户ip
#define G2A_FINISH_FIRST_ROUND 0x1111			//完成第一盘扣除房卡协议

enum
{
	TABLE_INFO_TYPE_CREATE_TABLE = 0,
	TABLE_INFO_TYPE_START_GAME,
	TABLE_INFO_TYPE_END_GAME,
	TABLE_INFO_TYPE_JOIN_TABLE,
	TABLE_INFO_TYPE_SIT,
	TABLE_INFO_TYPE_STAND,
	TABLE_INFO_TYPE_QUIT_GAME,
	TABLE_INFO_TYPE_CLOSE_GAME,
	TABLE_INFO_TYPE_BONUS
};



