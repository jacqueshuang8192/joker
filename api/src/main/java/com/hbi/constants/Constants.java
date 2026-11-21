package com.hbi.constants;

/**
 * Constants
 *
 * @author Lynch 2014-09-15
 */
public interface Constants {
    // 未知错误
    String SYSTEM_ERROR = "000-未知错误！";
    /**
     * 随机输出字母、数字或者随机 char=字母 num=数字 all=随机
     */
    String RADOM_OUT_CHAR = "char";
    String RADOM_OUT_NUM = "num";
    String RADOM_OUT_ALL = "all";

    //接口类型：接口类型，JSON传J，JSONP传P
    String RETURN_TYPE_JSON = "J";
    String RETURN_TYPE_JSONP = "P";

    //第三方登陆渠道
    String OAUTH_QQ = "qq";
    String OAUTH_WECHAT = "wechat";
    String OAUTH_WEIBO = "weibo";

    // 返回码
    String RETURN_CODE_SUCCESS = "0";
    String RETURN_CODE_FAIL = "1";
    String RETURN_CODE_PARAM_ERROR = "2";
    String RETURN_CODE_OBJECT_NOT_FOUND_ERROR = "3";
    String RETURN_CODE_ACCOUNT_ERROR = "5";
    String RETURN_CODE_CHECKCODE_INVALID = "105";
    String RETURN_CODE_TOKEN_INVALID = "106";
    String RETURN_CODE_PHONE_ALREADY_EXISTED = "201";
    String RETURN_CODE_CHARGE_TYPE_SANDBOX = "601";

    // 用户线上状态
    String ON_LINE = "1";

    // 用户类型
    String USER_TYPE_C = "C";
    String USER_TYPE_P = "P";

    // 用户是否废弃  0：未废弃；1：废弃
    Integer USER_NOT_DEPRECATED = 0;
    Integer USER_DEPRECATED = 1;

    // 物品类型
    String GOODS_TYPE_COIN = "0";
    String GOODS_TYPE_EXCHANGE = "1";

  
    String GOODS_TYPE_GIFT = "1";
    String GOODS_TYPE_PROP = "2";
    String GOODS_TYPE_GAME_PROP = "3";
    String GOODS_TYPE_DATING_PROP = "4";
    String GOODS_TYPE_RANSOM_CARD = "5";
    String GOODS_TYPE_DEFEND = "6";

    //游戏类型
    Integer PLAYER_GAME = 0;
    Integer LIVE_GAME = 1;

    //是否:
    Integer YES = 1;
    Integer NO = 0;

    //配置项
    String WHEEL_OF_FORTUNE = "wheelOfFortune"; //抽奖转盘奖品配置
    String WHEEL_COST_POINT = "wheelCostPoint"; //抽奖转盘消耗的积分
    String COIN_EXCHANGE_RATIO = "coinExchangeRatio"; //宝贝币兑换房卡比例
    String GAME_CATEGORY_LIST = "GAME_CATEGORY_LIST"; //游戏配置

    //充值状态
    String PAY_CANCEL = "0";
    String PAY_TO_BE_CONFIRMED = "1";
    String PAY_SUCCESS = "2";

    //用户性别：0保密，1男，2女
    String USER_GENDER_SECRET = "0";
    String USER_GENDER_MALE = "1";
    String USER_GENDER_FEMALE = "2";

    //状态
    String INVALID = "0";
    String VALID = "1";
    String CE_SHI_HAO = "ce_shi_hao";


    //个推类型：0爆矿；
    Integer BOOM = 0;
    Integer AWARD_POOL_REMIND = 1;
    Integer AWARD_POOL_BOOM = 2;
    Integer LOUD_SPEAKER = 3;
    Integer START_LIVE = 4;

    //登录设备，0:IOS;1：ANDROID;2：PC;3：其他
    Integer DEVICE_IOS = 0;
    Integer DEVICE_ANDROID = 1;
    Integer DEVICE_PC = 2;
    Integer DEVICE_OHTER = 6;

    //版本类型
    String VERSION_TYPE_APPLICATION = "1";
    String VERSION_TYPE_GAME_HALL = "2";
    String VERSION_TYPE_GAME = "3";


    //普通状态
    String NORMAL_STATUS_NULL = "0";
    String NORMAL_STATUS_DRAFT = "1";
    String NORMAL_STATUS_PUBLISH = "2";

    //用户游戏状态
    String USER_ONLINE_GAME_STATUS_FREE = "0";
    String USER_ONLINE_GAME_STATUS_GAMING = "1";

    //游戏类型
    String QUICK_GAME = "Q";
    String GAME_MATCH = "M";
    String COMPERE_GAME = "C";
    String FREE_GAME = "R";

    String COMMONDATASOURCE = "commonDataSource";
    String USERCENTERDATASOURCE = "userCenterDataSource";

    //奖品状态
    Integer NOT_SEND = 0;
    Integer NOT_CONFIRMED = 1;
    Integer CONFIRMED = 2;

    //房卡
    String USER_GAME_STATUS = "USER_GAME_STATUS";

    //联盟的相关参数
    //联盟成员
    String GROUP_PLAYER = "GROUP_PLAYER";
    //联盟
    String PLAYER_GROUP_ = "PLAYER_GROUP_";
    String PLAYER_ = "PLAYER_";
    String PHOTOURL = "photoUrl";
    //联盟信息状态
    Integer HAS_NOT_READ = 0;
    Integer INVITE_PLAYER = 5;
    Integer INVITE_PLAYER_SURE = 6;
    Integer INVITE_PLAYER_NO_SURE = 7;

 //赠送|活动  -->赠送的记录
    int giftTypeEverydAY = 1;
    int giftTypeCard2gold = 2;
    int giftTypeGold2Card = 3;
    int giftTypeFirstLogin = 4;
    int giftPlayerBindAgent = 5;
    int giftPlayerByTask = 6;
    int bindPhone = 7;
    int giftPlayerByTaskEvery = 8;

    //任务ID
    String TASK_EVERY_DAY = "1";
    String TASK_CHENG_JIU = "2";
    String TASK_SHENG_JI = "3";

    //领取的任务的ID
    int GIFT_EVERY_DAY = 6;
    int GIFT_CHENG_JIU = 5;
    int GIFT_SHENG_JI = 4;

    //玩家房卡
    String PLAYER_ROOM_CARD = "PLAYER_ROOM_CARD";


    //房卡三级分销
    String SANJIFENXIAO = "SANJIFENXIAO";
    String COMMISSIONS = "COMMISSIONS";
    String COMMISSIONS1 = "COMMISSIONS1";
    String COMMISSIONS2 = "COMMISSIONS2";
    String COMMISSIONS3 = "COMMISSIONS3";

    //商品类型

    String goodsCATEGORYTYPE = "3";

    //赠送的商品类型  金币|房卡
    int GIFT_GOLD = 1;
    int GIFT_ROOM_CARD = 2;

    //config中的配置
    String curGroupMasterRoomCard = "curGroupMasterRoomCard";

    //玩家绑定代理的公告
    String MY_AGENT_ADVICE = "MY_AGENT_ADVICE";


    //通知协议  联盟使用
    Integer GROUP_INFOA = 0x01;
    Integer GROUP_INFOB = 0x67;

    //房间的类型
    Integer GOLD_ROOM = 0;
    Integer CARD_ROOM = 1;
    Integer CLUD_ROOM = 2; //俱乐部积分场
    Integer POINT_CARD_ROOM = 3; //俱乐部房卡场

    //赠送记录查询
    Integer SHONG = 1;
    Integer SHOU = 2;

    //联盟通知大厅的相关类型
    Byte CLU_CREATE = 0;
    Byte CLU_CLOSE = 1;
    Byte CLU_MEMBER_JOIN = 2;
    Byte CLU_MEMBER_LEVEL = 3;
    Byte CLU_REFLESH = 4;

    //俱乐部玩法更新通知
    Byte Club_GameConfig_Add = 1;
    Byte Club_GameConfig_Update = 2;
    Byte Club_GameConfig_Del = 3;

    //上下分
    Integer handle_Success = 99;
    String Lock_By_Owner = "lock_by_Owner";
    Integer System_Err = 100;
    Integer Limit_Err = 101;
    Integer Encrypt_Err = 102;
    Integer Locking_Err = 103;
    Integer TUSER_Err = 104;
    Integer TUSER_No_Exist = 105;
    Integer TUSER_IS_NO_MYSon = 106;
    Integer Point_Nont_Enough= 107;
    Integer TUSER_IS_INGAME= 108;
    Integer MareThat_maxpoint = 109;
    Integer Forbid_Exchange_Point = 110;

    Integer Coins_add = 1;
    Integer Coins_sub = 0;

    Integer Cost_Pattern_guding = 1;
    Integer Cost_Pattern_Com = 2;

    Integer cost_user_type_dayingjia = 0;
    Integer cost_user_type_yingjia = 1;


    String Min_Join_FreeGame_Coins = "Min_Join_FreeGame_Coins";
    String Player_Coins_In_Group = "Player_Coins_In_Group_";
    String Group_Commission = "Group_Commission_";
    String Cost_user_type = "Cost_user_type";
    String Group_Uid_Shangji_Id = "Group_Uid_Shangji_Id";
    String Group_Hehuoren_Commission = "Group_Hehuoren_Commission";
}
