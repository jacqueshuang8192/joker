#ifndef _DEFS_H_
#define _DEFS_H_

#define HTTP_SVR_NS_BEGIN namespace __http_svr_ns__ {
#define HTTP_SVR_NS_END }
#define USING_HTTP_SVR_NS using namespace __http_svr_ns__;

#define MAX_WEB_RECV_LEN            102400
#define MAX_ACCEPT_COUNT            256
enum CConnState
{
    CONN_IDLE,
    CONN_FATAL_ERROR,
    CONN_DATA_ERROR,
    CONN_CONNECTING,
    CONN_DISCONNECT,
    CONN_CONNECTED,
    CONN_DATA_SENDING,
    CONN_DATA_RECVING,
    CONN_SEND_DONE,
    CONN_RECV_DONE,
    CONN_APPEND_SENDING,
    CONN_APPEND_DONE
};

enum TDecodeStatus
{
    DECODE_FATAL_ERROR,
    DECODE_DATA_ERROR,
    DECODE_WAIT_HEAD,
    DECODE_WAIT_CONTENT,
    DECODE_HEAD_DONE,
    DECODE_CONTENT_DONE,
    DECODE_DONE,
    DECODE_DISCONNECT_BY_USER
};

typedef struct tagRspList
{
    char*   _buffer;
    int     _len;
    int     _sent;
    int     _type;

    struct tagRspList* _next;

}TRspList;

enum
{
	CLIENT_CMD_SYC = 0x0002,
	SERVER_CMD_SYC = 0x0001
};

enum ConnType
{
	CONN_CLINET,
	CONN_OTHER
};

const int SYS_CMD_BEGIN = 0x0300;//?μí3?????üá?×?
const int SYS_CMD_END	= 0x0400;

const int BROADCAST_CMD_BEGIN = 0x401;
const int BROADCAST_CMD_SINGLE = 0x402;
const int BROADCAST_CMD_ALL	= 0x403;
const int BROADCAST_CMD_CHAT = 0x404;
const int BROADCAST_CMD_RESPONSE_CHAT = 0x405 ;  //聊天回执
const int BROADCAST_INFO_PACKET = 0x406;  //系统广播可按类型
const int BROADCAST_CONSORTIA_PACKET = 0x407; //公会消息
const int BROADCAST_CMD_END = 0x502;

const int FRIEND_CMD_BEGIN = 0x600;
const int FRIEND_CMD_END   = 0x700;

const int PENETRATE_CMD_BEGIN = 0x100;		//í?′??üá?×?
const int CLIENT_CMD_HEART_BEAT = 0x110;	//D?ì?°ü
const int CLIENT_DISABLE_USER_GAME = 0x177;	//禁用某个玩家玩游戏
const int CLIENT_COMMAND_USER_ONLINE = 0x1189;  //用户是否在俱乐部界面;
const int CLIENT_CMD_CLUB_DATA = 0x172;	//请求俱乐部信息
const int CLIENT_USER_GAME_STATUS = 0x0668;	//用户状态
const int B2A_REMOVE_GROUP_TABLE = 0x155;	//请求注销桌子
const int CONTROL_CMD_LOG_LEVEL = 0x111;    //控制日志等级
const int CLIENT_CMD_CLIENT_LOGIN = 0x0116;	//ó??§′óìüμ???°ü
const int CLIENT_CMD_ROBOT_JOIN_GAME = 0x114;//?ú?÷è?μ???·???
const int CLIENT_CMD_GET_LEVEL_NUM   = 0x131;
const int SERVER_CMD_LOGIN_SUCCESS = 0x0201;//ó??§μ???′óìü3é1|
const int CLIENT_CMD_JOIN_GAME = 0x0113;	//ó??§???ó??è?·???
const int CLIENT_CMD_JOIN_TABLE = 0x179;	//快速加入
const int CLIENT_CMD_CHANGE_ROOM = 0x115;	//ó??§???ó?ü??·???
const int SERVER_CMD_JOIN_GAME = 0x0210;	//·μ??ó??§??è?·???
const int SERVER_CMD_KICK_OUT = 0x0203;		//ìT3yó??§
const int CLIENT_CMD_GET_ROOMLIST = 0x0117;  // 
const int CLIENT_CMD_CREATE_ROOM = 0x0118;  //
const int CLIENT_CMD_GET_ROOM_BY_ID = 0x0119;  //
const int CLIENT_CMD_JOIN_PRIVATE_GAME = 0x0120; //μ?????è?3?
const int CLIENT_CMD_CREATE_CUSTOM_ROOM = 0x0121; //创建斗牛馆房间
const int CLIENT_CMD_GET_CUSTOM_ROOM_LIST = 0x0122; //获取斗牛馆列表
const int CLIENT_CMD_SEARCH_ROOM_BY_ID = 0x0123;    //根据房间id查
const int CLIENT_CMD_JOIN_CUSTOM_ROOM = 0x0124;     //加入斗牛馆房间

const int PENETRATE_CMD_END	= 0x300;		

const int CMD_SEPARATE = 0x0800;			//?üá?·???

const int CMD_BULL_LOGIN_TID = 0x1001;       //登录 斗牛桌子
const int CMD_ROBOT_LOGIN_TID = 0x1003;     //机器人登录 
const int CMD_PRIROOM_LOGIN_TID = 0x100A;     //私人房登录
const int CMD_SLOT_LOGIN_TID = 0x11001;      //登录老虎机桌子  C->S
const int CMD_HUNDRED_LOGIN_TID  = 0x21001;   //百人牛牛用户登录
const int CMD_CUSTOM_LOGIN_TID = 0x31001;    //竞技场登录

const int CLIENT_PACKET = 0x0001;			//ó??§·￠1yà′μ?êy?Y°ü?ò??server·￠??ó??§μ?°ü
const int CLIENT_CLOSE_PACKET = 0x0002;		//ó??§???aá??ó￡?hall?????-server·￠μ?°ü
const int SERVER_CLOSE_PACKET = 0x0003;		//Alloc server?÷?ˉ???aá??óμ?°ü
const int CLIENT_FRIEND_PACKET = 0x0004;    //ó??§ó?o?ó?·t???÷í¨D?μ?êy?Y°ü
const int CLIENT_BROADCAST_PACKET = 0x0005; //ó??§ó?1?2￥·t???÷í¨D?μ?êy?Y°ü
const int SERVER_COMMAND_LOGOUT_SUCCESS = 0x1008;
const int SLOT_CMD_LOGOUT = 0x11002;  //slot logout 
const int HUNDRED_CMD_LOOUT = 0x21002; //hundred bull logout
const int CUSTOM_CMD_LOOUT = 0x31002; //custom bull  logout
const int SERVER_COMMAND_KICKOUT = 0x4004;
const int SERVER_COMMAND_LOGIN_FAILED = 0x1005;
const int ALLOW_PACKET = 0x0888;



//比赛控制服务器相关业务
const int HALL_MATCH_CMD = 0x6600;
const int HALL_MATCH_REGIST_CMD = 0x6601;
const int HALL_MATCH_LOGIN = 0x021;



#endif

