#ifndef _GAME_CMD_H_
#define _GAME_CMD_H_

#define SYS_CTRL_KEY "sys_ctrl_key_alloc"


#define CLIENT_PACKET  		 0x0001//用户发过来的数据包或者server发给用户的包
#define CLIENT_PACKET2		 0x0004

#define CLIENT_CLOSE_PACKET  0x0002//用户断开连接，hall给逻辑server发的包
#define SERVER_CLOSE_PACKET  0x0003//逻辑server主动断开连接的包
#define HALL_REGISTER_PACKET 0x0004//大厅注册包
#define ALLOC_REGISTER_PACKET 0x0005//Alloc注册包
#define SYS_GET_USER_TABLE  0x0020
#define G2U_BEFORE_CREATE_GROUP_CHECK 0x630		//发送到用户服，创建组局前的检测
#define U2G_BEFORE_CREATE_GROUP_CHECK 0x630		//发送到用户服，创建组局前的检测

#define SYS_GET_USER_TABLE_COMMON 0x0021	//获取用户是否有桌子统一接口
#define SYS_UPDATE_TABLE_LIST 0x0022	//获取用户是否有桌子统一接口

#define DATA_REPORT 0x0010

const int TABLE_DATA_CHANGE = 0x173; //更新俱乐部桌子信息

const int CLIENT_CMD_USER_LOGIN = 0x0116;//用户登录
const int SERVER_CMD_LOGIN_SUCCESS = 0x0201;//用户登录成功
const int CLIENT_CMD_LEAVE_ROOM = 0x0107;//用户退出房间给大厅发登出
const int SERVER_CMD_KICK_OUT = 0x0203;  //剔除用户
const int CMD_GET_ROOM_LEVER_NUM = 0x0311;//获取各等级场人数  
const int CLIENT_CMD_JOIN_GAME = 0x0113;//用户请求进入房间
const int SERVER_CMD_JOIN_GAME = 0x0210;//返回用户进入房间
const int SERVER_CMD_JOIN_MATCH = 0x0211;//返回玩家server信息

const int CMD_REQUIRE_IP_PORT = 0x0604;//请求server的ip和端口
const int CLIENT_CMD_ENTER_ROOM = 0x0106;//用户进入房间
const int CMD_SET_SERVER_RETIRED = 0x0903;//内部命令,将系统retire
const int CMD_SET_SERVER_ADDR_MC = 0x0904;//内部命令,让Alloc写server列表的ip和端口
const int CMD_RESET_FILL_FLAG = 0x0905;//内部命令，重置是否填充server的标志

const int CLIENT_CMD_CREATE_PRIVATEROOM = 0x114;//用户请求创建私人房
const int CLIENT_CMD_CREATE_PRIVATEROOM_NEW = 0x124;//用户请求创建私人房
const int SERVER_CMD_CREATE_PRIVATEROOM = 0x206;//返回服务器创建私人房结果

const int CLIENT_CMD_LIST_PRIVATEROOM = 0x10D;//用户请求私人房间列表
const int CLIENT_CMD_LIST_PRIVATEROOM_NEW = 0x11D;//用户请求私人房间列表
const int SERVER_CMD_LIST_PRIVATEROOM = 0x208;//server返回私人房间列表

const int CLIENT_CMD_ENTER_PRIVATEROOM = 0x0115;//用户请求进入私人房
const int CLIENT_CMD_ENTER_PRIVATEROOM_NEW = 0x0125;//用户请求进入私人房
const int SERVER_CMD_ENTER_PRIVATEROOM = 0x0212;//返回用户进入私人房间

//私人房二人场命令字
const int CLIENT_CMD_CREATE_PRIVATEROOM_DOUBLE = 0x134;	//用户请求创建二人私人房
const int CLIENT_CMD_LIST_PRIVATEROOM_DOUBLEE  = 0x135; //用户请求二人私人房列表
const int CLIENT_CMD_ENTER_PRIVATEROOM_DOUBLE  = 0x136; //用户请求二人进入二人私人房
const int CLIENT_CMD_PRIVATEROOM_DOUBLE_LIKE    = 0x137; //用户请求模糊查询二人私人房


const int CLIENT_CMD_FIND_PRIVATEROOM_LIKE= 0x010e;//用户请求模糊查询私人房间
const int CLIENT_CMD_FIND_PRIVATEROOM_LIKE_NEW= 0x011e;//用户请求模糊查询私人房间
const int SERVER_CMD_FIND_PRIVATEROOM_LIKE = 0x213;//返回用户模糊查询私人房间结果

const int CMD_GET_NEW_ROOM = 0x0117;//随机场点击了准备,重新请求房间号

const int CMD_GET_MATCH_QUICK_ROOM = 0x0120;	//请求登陆超快赛
const int CMD_GET_APPLY_SERVER = 0x0121;       //请求报名server
const int CMD_GET_MATCH_HUODONG_ROOM= 0x0122;	//请求进入活动赛

const int CMD_CREATE_PRIVATE_ROOM = 0x0401;
const int SYS_REPORT_SERVER_DATA = 0x0501;
const int SYS_UPDATE_ROOM_USER_COUNT = 0x0502;
const int SYS_REPORT_PRIVATE_ROOM_DATA = 0x0503; 
const int SYS_REPORT_SERVER_PORTIP = 0x0504;
const int SYS_USER_ENTER_ROOM = 0x0505;
const int SYS_USER_LEAVE_ROOM = 0x0506;
const int SYS_HALL_CORE = 0x0507;
const int SYS_LOGIC_CORE = 0x0508;
const int SYS_UPDATE_MATCH_USER_COUNT = 0x0520;

const int SYS_SYN_DATA = 0x050D;//同步数据

const int SYS_ONLOOK_ENTER_ROOM = 0x530;            //围观用户进入房间
const int SYS_ONLOOK_LEAVE_ROOM = 0x531;            //围观用户离开房间
const int SERVER_ONLOOK_RECONNECT_ROOM = 0x532;     //返回围观玩家重连



const int SYS_CTRL_RELOAD_PRVT_ROOM_SID_MAP = 0x5f01;
const int SYS_CTRL_RELOAD_PRVT_ROOM_BASE_CHIP = 0x5f02;
const int SYS_CTRL_RELOAD_PRVT_ROOM_DITY_WORDS = 0x5f03;

const int CMD_CLEAR_SERVERINFO = 0x0905;//清除server信息，启动server出错的时候使用，让UserServer重新从mc中读取server信息
const int SYS_SYN_BROADCAST_SWITCH = 0x0510;
const int SYS_SET_TJ_SWITCH = 0x0511;
const int SYS_SET_STATLOG_LEVEL = 0x0512;
const int SYS_SET_LEVEL_COUNT_RANDOM = 0x0513;

const int SYS_RESET_LEVEL_INFO = 0x0514;		//重置Server等级信息

const int GET_USER_HALLID	= 0x00a1;	//去userserver取用户的大厅ID
const int GET_USER_TABLE_INFO 	= 0x00a2;	//获取用户桌子信息

//Cache用户的在线信息，在玩信息
const int CA_CLIENT_CLOSE_PACKET  =0x40002;
const int CA_CLIENT_CMD_USER_LOGIN = 0x40116;
const int CA_SYS_USER_ENTER_ROOM = 0x40505;
const int CA_SYS_USER_LEAVE_ROOM = 0x40506;



enum
{
	ERROR_ROOM_NOT_EXIST = 1,
	ERROR_MAX_USERCOUNT,
	ERROR_PASSWORD
};


const int SERVER_ATTR_COUNT = 3;
const int ONLINE_ATTR_COUNT = 2;

const int RANDOM_COUNT = 100;
const int TIME_INTEVAL = 301;//时间间隔5分钟
const int FLUSH_CHECK_TIME = (10*60+1);

#define TIME_CHECK 1
#define OFFLINE_CHECK 2
#define	FLUSH_CHECK	3






#endif

