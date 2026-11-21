#ifndef __COMMAND_TYPE_H
#define __COMMAND_TYPE_H

#define CLIENT_PACKET  		 0x0001//用户发过来的数据包或者server发给用户的包
#define CLIENT_CLOSE_PACKET  0x0002//用户断开连接，hall给逻辑server发的包
#define SERVER_CLOSE_PACKET  0x0003//逻辑server主动断开连接的包
#define HALL_REGISTER_PACKET 0x0004//大厅注册包
#define ALLOC_REGISTER_PACKET 0x0005//Alloc注册包
#define SYS_GET_USER_TABLE  0x0020		//获取用户是否有桌子
#define SYS_GET_USER_TABLE_COMMON 0x0021	//获取用户桌子的公共接口
/*---------------------------- by neo ------------------------------*/
#define SYS_UPDATE_TABLE_LIST 0x0022	//user通知更新桌子列表
/*---------------------------- by neo ------------------------------*/
#define DATA_REPORT 0x0010


//---------------------------zsw------------------------------------------//
const int B2A_HALL_GAME_PLAY_TO_SERVER = 0x587; //接受通知 玩法数据
const int B2A_HALL_MSG_TO_SERVER = 0x117; //接受通知
const int B2A_GAME_MSG_TO_SERVER = 0x112; //接受通知
const int G2A_GAME_MSG_TO_SERVER = 0x111; //接受通知
const int B2A_HALL_SEND_MSG_TO_SERVER = 0x168; //接受通知
const int B2A_HALL_SEND_PLAYER_MSG_TO_SERVER = 0x169; //俱乐部更新功能配置
const int B2A_CREATE_GROUP_TABLE = 0x149; //请求创建组局 zsw
const int B2A_SET_CLUB_INFO = 0x0165; //设置俱乐部id
const int B2A_CREATE_CARD_GROUP_TABLE = 0x160; //请求创建房卡组局 zsw
const int B2A_CREATE_CARD_GROUP_TABLE_SEND_ALLOW = 0x0119; //请求创建房卡组局 发回allow
const int B2A_CLEAR_CLUB_TABLE_SEND_ALLOW = 0x0129; //清理俱乐部创建的桌子
const int B2A_CLEAR_CLUB_TABLE_TID = 0x0138; //根据tid清理桌子
const int G2A_REPORT_END_GROUNP = 0x150;			//landlordserver发到alloc zsw
const int B2A_REMOVE_GROUP_TABLE = 0x155; //请求注销组局 zsw

const int A2B_CREATE_GROUP_TABLE_RESULT = 0x360;			//返回后台服务器 zsw
const int A2B_REMOVE_GROUP_TABLE_RESULT = 0x361;			//返回后台服务器 zsw
const int A2B_GET_GROUP_TABLE_USER = 0x340;	//返回用户状态 zsw

const int A2U_GET_GROUP_TABLE_USER = 0x340;	//向用户服查询用户状态 zsw

const int A2G_CREATE_GROUP_TABLE = 0x380;     //向游戏服务器请求创建table zsw

const int U2A_POST_GROUP_TABLE_USER = 0x340;	//用户服换回账号信息给alloc zsw
//---------------------------zsw------------------------------------------//

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

const int CMD_CHECK_SERVER_STATUS = 0x0906;  //查询各场次人数，方便退休
const int  CMD_SERVER_USER_IN_TABLE = 0x7883;		//发送到ALLOC 告诉自己有人进房间了

/*以前私人房用过的
const int CLIENT_CMD_CREATE_PRIVATEROOM = 0x114;//用户请求创建私人房
const int CLIENT_CMD_CREATE_PRIVATEROOM_NEW = 0x124;//用户请求创建私人房

const int CLIENT_CMD_LIST_PRIVATEROOM = 0x10D;//用户请求私人房间列表
const int CLIENT_CMD_LIST_PRIVATEROOM_NEW = 0x11D;//用户请求私人房间列表
const int SERVER_CMD_LIST_PRIVATEROOM = 0x208;//server返回私人房间列表

const int CLIENT_CMD_ENTER_PRIVATEROOM = 0x0115;//用户请求进入私人房
const int CLIENT_CMD_ENTER_PRIVATEROOM_NEW = 0x0125;//用户请求进入私人房

const int CLIENT_CMD_FIND_PRIVATEROOM_LIKE= 0x010e;//用户请求模糊查询私人房间
const int CLIENT_CMD_FIND_PRIVATEROOM_LIKE_NEW= 0x011e;//用户请求模糊查询私人房间
const int SERVER_CMD_FIND_PRIVATEROOM_LIKE = 0x213;//返回用户模糊查询私人房间结果

const int CMD_CREATE_PRIVATE_ROOM = 0x0401;
const int SYS_REPORT_PRIVATE_ROOM_DATA = 0x0503; 

*/

const int CLIENT_CMD_CREATE_PRIVATE_ROOM = 0x144; //用户创建私人房
const int CLIENT_CMD_ENTRE_PRIVATE_ROOM  = 0x145;   //进入私人房
const int CLIENT_CMD_LIST_PRIVATE_ROOM   = 0x146;  //获取私人房列表
const int CLIENT_CMD_FIND_PRIVATE_ROOM   = 0x147;  // 用户请求精准查询私人房
const int CLIENT_CMD_REFRESH_PRIVATE_ROOM = 0x148; //刷新私人房人数

const int SERVER_CMD_CREATE_PRIVATEROOM   = 0x206;//返回服务器创建私人房结果
const int SERVER_USER_GAME_STATUS = 0x0668;  //返回用户状态
const int SERVER_CMD_ENTER_PRIVATEROOM    = 0x0212;//返回用户进入私人房间
const int SERVER_CMD_LIST_PRIVATE_ROOM    = 0x246; //返回私人房列表
const int SERVER_CMD_FIND_PRIVATE_ROOM    = 0x247; //返回私人房查询结果
const int SERVER_CMD_REFRESH_PRIVATE_ROOM = 0x248; //返回私人房刷新结果
const int CMD_PUSH_CREATE_PRIVATE_ROOM    = 0x0402; //向GameServer发送创建私人房信息

const int CMD_REPORT_PRIVATE_ROOM_DATA    = 0x0509;  //主版本私人房上报
const int SYS_CTRL_READ_PIVATEROOM_CONFIG = 0x0907;  //重读私人房配置

const int CLIENT_CMD_JOIN_TABLE = 0x179;   //快速加入组局
const int CLIENT_COMMAND_USER_ONLINE = 0x1189;  //用户是否在俱乐部界面
const int CLIENT_DISABLE_USER_GAME = 0x177;   //禁用某个玩家玩游戏
const int CLUB_DATA = 0x172;   //获取俱乐部信息
const int CLIENT_USER_GAME_STATUS = 0x0668;  //请求用户状态
const int TABLE_DATA_CHANGE = 0x173; //更新俱乐部桌子信息
const int TABLE_DATA = 0x174;  //返回桌子列表
const int TABLE_DATA_TEST = 0x175;  //返回桌子列表
const int SERVER_CREATE_MATCH = 0x0160;   //创建比赛场通知
const int CLIENT_CMD_CREATE_MATCH = 0x161;  //创建比赛
const int CLIENT_CMD_ENTER_MATCH = 0x162;   //进入比赛
const int CLIENT_CMD_FIND_MATCH = 0x163;   //查找房间
const int CLIENT_CMD_LIST_MATCH = 0x164;   //比赛列表，目前只显示企业比赛，可做一个开关，控制是否显示个人赛或企业赛或都不显示

const int CLIENT_CMD_MATCH_END = 0x170; 






const int CMD_GET_NEW_ROOM = 0x0117;//随机场点击了准备,重新请求房间号

const int CMD_GET_MATCH_QUICK_ROOM = 0x0120;	//请求登陆超快赛
const int CMD_GET_APPLY_SERVER = 0x0121;       //请求报名server
const int CMD_GET_MATCH_HUODONG_ROOM= 0x0122;	//请求进入活动赛

const int ALLOW_PACKET = 0x0888;
const int ALLOW_GAME_SVID_PACKET = 0x0999;
const int SYS_REPORT_SERVER_DATA = 0x0501;
const int SYS_UPDATE_ROOM_USER_COUNT = 0x0502;
const int SYS_REPORT_SERVER_PORTIP = 0x0504;
const int SYS_USER_ENTER_ROOM = 0x0505;
const int SYS_USER_LEAVE_ROOM = 0x0506;
const int SYS_HALL_CORE = 0x0507;
const int SYS_LOGIC_CORE = 0x0508;

const int SYS_UPDATE_MATCH_USER_COUNT = 0x0520;
const int SYS_UPDATE_PRIVATE_MATCH_USER_COUNT = 0x0521;



const int SYS_ONLOOK_ENTER_ROOM = 0x530;//围观用户进入房间
const int SYS_ONLOOK_LEAVE_ROOM = 0x531;//围观用户离开房间
const int SERVER_ONLOOK_RECONNECT_ROOM = 0x532; //返回围观玩家重连
const int SERVER_ONLOOK_ENTER_ROOM     = 0x533; //围观重连，适用于重连失败后，玩家请求房间时。
const int SERVER_CREATE_ROBOT_CLEAN = 0x0318;   //游戏请求结束组局的时候 清理机器人状态

const int SERVER_CREATE_ROBOT = 0x033;   //添加机器人
const int SERVER_UPDATE_ROBOT = 0x034;   //修改机器人信息
const int SERVER_STATUS_ROBOT = 0x035;   //修改机器人状态
const int SERVER_ADD_GROUP_ROBOT = 0x036;   //把机器人加入到俱乐部
const int SERVER_UPDATE_GROUP_ROBOT_SR = 0x037;   //修改机器人胜率
const int SERVER_GROUP_ADD_LEVEL = 0x039;   //放机器人
const int A2G_ROBOT_LOGIN = 0x180;			//后台添加机器人
const int A2G_MODIFY_SYS_CONFIG = 0x132;			//后台修改机器人胜率
const int SERVER_GROUP_USER_STATUS = 0x040;   //解放机器人
const int SERVER_ROBOT_REDIS_STATUS = 0x041;   //修改机器人只进哪个游戏
const int SERVER_GROUP_ROBOT_LOGIN = 0x0404;   //登入出错和登入成功
const int SERVER_COMMAND_UPDATE_GAME_ROUND = 0x0358;//修改桌子
const int SERVER_COMMAND_SET_TABLE_COUNT = 0x0438;//桌子进入的人数，应该说最低进多少人
const int SERVER_COMMAND_CHANGE_LEVEL_TO_LOGIN = 0x2205;//改变等级重新请求陪桌并登陆
enum
{
	HALLSERVER=1
};


enum
{
	ERROR_PRIVARE_ROOM_LEVEL=1,  //等级错误
	ERROR_PRIVATE_ROOM_BASE=2, //底注错误
	ERROR_PRIVATE_ROOM_ON_ENOUGH=3,  //没有足够的房间
};

//创建自办比赛房间错误代码
enum
{
	ERROR_CREATE_FAILED = 1,
	ERROR_CREATE_ROOMTYPE,		//创建的房间类型错误
	ERROR_CREATE_MAX_ROOMCOUNT	//可创建房间数已达到上限
};

//进入自办比赛房间错误代码
enum
{
	ERROR_ROOM_NOT_EXIST = 1,	//房间不存在
	ERROR_MAX_USERCOUNT,		//房间人数已满
	ERROR_PASSWORD,			//房间密码错误
	ERROR_MATCH_BEGIN,		//房间的比赛已经开始
	ERROR_JOIN_CHIPS,		//加入的积分
	ERROR_USER_DISABLE,		//禁止用户加入
	ERROR_USER_JULI =8,     //短距离不允许加入
	ERROR_USER_SISMEMBER = 12,		//用户同桌
};


enum
{
	SD_DEV_TYPE_IPHONE = 1,
	SD_DEV_TYPE_IPAD = 2,
	SD_DEV_TYPE_PC = 3,
	SD_DEV_TYPE_ANDROID = 4,
	SD_DEV_TYPE_WIN7 = 5,

	SD_DEV_TYPE_IPHONE_GB = 100,   //繁体
	SD_DEV_TYPE_IPHONE_GBK = 101,  //简体
	SD_DEV_TYPE_IPHONE_91 = 102,
	SD_DEV_TYPE_IPAD_GB = 103,
	SD_DEV_TYPE_IPAD_GBK = 104,
	SD_DEV_TYPE_IPAD_91 = 105,
	SD_DEV_TYPE_ANDROID_91 = 116
};

const int MAX_TABLE_USER_COUNT = 3;
#endif
