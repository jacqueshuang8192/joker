package com.linkxin.douyouPlayer.http;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import android.content.Context;
import android.util.Log;
import com.linkxin.douyouPlayer.util.Md5Util;

public class RequestURL {
	//润
//	public static final String PLATFORM_HOST = "http://192.168.100.119:8080/hbiInterface";
//	public static final String PLATFORM_HOST = "http://172.20.10.8/hbi_interface";
		
	// 测试服务器
//	public static final String PLATFORM_HOST = "http://120.25.165.221/hbiInterface";

//    public static final String TREASURE_HOST = "http://192.168.0.113:8080/One2/index.html";// 一元夺宝-小磊

    // 49测试服务器
//  	public static final String PLATFORM_HOST = "http://120.76.133.49/hbiInterface";			// 接口
	public static final String HTML_HOST = "http://120.76.133.49/hbiInterface";				// HTML
//    public static final String TREASURE_HOST = "http://120.76.133.49/hbiInterface/society/index.html";// 一元夺宝
//	public static final String SERVER_ADDRESS = "http://120.76.26.34:9080";					// 直播间

//	public static final String SERVER_ADDRESS = "http://live.vgemv.com";					// 直播间（暂停使用）

	// 生产服务器
//	public static final String PLATFORM_HOST = "http://douyou.net.cn/hbiInterface";			// 接口
//	public static final String HTML_HOST = "http://doudougame.cn/hbiInterface";				// HTML
//	public static final String TREASURE_HOST = "http://doudougame.cn/hbiInterface/society/index.html";// 一元夺宝
//	public static final String SERVER_ADDRESS = "http://120.76.26.34:9080";					// 直播间


	// 新接口地址（游戏服务器）
	public static final String PLATFORM_HOST = "http://39.108.121.70:8080/hbiInterface";		// 外网

//	public static final String PLATFORM_HOST = "http://120.24.152.139:8080/hbiInterface";				// 外网测试服

//	public static final String PLATFORM_HOST = "http://192.168.10.40:8081/hbiInterface";				// 内网

	// OSS
	public static final String accessKey = "LOCAL_ACCESSKEY";
	public static final String screctKey = "LOCAL_SCRECTKEY";

	public static final String bucketName = "niuyouquan";
	public static final String endpoint = "http://oss-cn-shenzhen.aliyuncs.com";
	public static final String OSS_HOST = "http://niuyouquan.oss-cn-shenzhen.aliyuncs.com";

	// ping++
	public static final String Ping_Charge_URL = "http://218.244.151.190/demo/charge";					// 只做对接测试用

	//推流地址前缀
	public static final String STREAMING_URL_PREFIX = "rtmp://push.doudougame.com.cn/live/mp4_";
	//播放地址前缀
	public static final String PLAY_URL_PREFIX = "rtmp://rtmp.doudougame.com.cn/live/mp4_";
	//百度播放AK
	public static final String BAIDU_AK = "LOCAL_BAIDU_AK";

	public static final String WXAPP_ID = "wxc4e3c7aea1fbead6";								// 微信ID
	public static final String WXAPP_SECRET = "LOCAL_WXAPP_SECRET";			// 微信SECRET

	public static final String YAYAAPP_ID = "1002336";										// 呀呀语音（实时）

	public static final String SinaWB_APP_KEY = "3710788407";								// 新浪微博

	public static final String QQ_Appid = "222222";											// QQAPP_ID
	public static final String QQ_App_Key = "LOCAL_QQ_APP_KEY";								// QQAPP_KEY

    //*****************H5**************************
	// 目录路径
	public static final String PROJECTPATH = "/society/";
    public static final String INDEX = "index.html";
    public static final String SOCIETY_PREFIX = HTML_HOST + PROJECTPATH + INDEX;
    public static final String PLAT = "2";
    public static final String TYPE_P = "p";
    public static final String TYPE_C = "c";

	
	// 加密key
	public static final String Key = "123456";
	
	// 登录
	public static final String LOGIN_URL = PLATFORM_HOST + "/userLogin";
	public static final int LOGIN = 0;
	
	// 注册
	public static String REGIST_URL = PLATFORM_HOST + "/playerRegister";
	public static final int Regist = 1;

	//手机号是否已被注册
	public static String IS_PHONE_EXIST_URL = PLATFORM_HOST + "/user/isPhoneExist";

	// 获取手机验证码
	public static String GetVerificationUrl = PLATFORM_HOST + "/getRandomCode";
	public static final int GetVerificationCode = 2;
	
	//忘记密码，通过验证码修改密码
	public static String ModifyPasswordByCode = PLATFORM_HOST + "/modifyPasswordByCode";
	public static final int ModifyPasswordCode = 3;
	
	// 获取用户信息
	public static String GetUserInfoUrl = PLATFORM_HOST + "/playerUser/getUserInfo";
	public static final int GetUserInfoMark = 4;
	//修改个人资料
	public static String PLAYER_MODIFY_USER_URL = PLATFORM_HOST + "/playerUser/modifyUserInfo";
	
	
	// 获取房间列表
	public static String GET_ROOM_LIST_URL = PLATFORM_HOST + "/compereLive/getRoomList";
	public static final int GetRoomListMark = 5;
    //获取所有房间列表
    public static String GET_ALL_ROOMS_URL = PLATFORM_HOST + "/compereLive/getAllRoomList";
	
	//获取所有省市区
	public static String GetAllAreaInfoUrl = PLATFORM_HOST + "/getAllAreaInfo";
	public static final int GetAllAreaInfoMark = 6;
	
	// 加入房间
	public static String EnterLiveRoomUrl = PLATFORM_HOST + "/compereLive/enterRoom";
    // 退出房间
    public static final String EXIT_ROOM_URL = PLATFORM_HOST + "/exitRoom";
	public static final int EnterLiveRoomCode = 7;

	// 获取直播房间玩家列表
	public static String ViewRoomPlayersUrl = PLATFORM_HOST + "/compereLive/viewRoomPlayers";
	public static final int ViewRoomPlayersCode = 8;
		
	// 抢麦
	public static String APPLY_MICROPHONE_URL = PLATFORM_HOST + "/compereLive/applyMicrophone";
	public static final int ApplyMicrophoneCode = 9;
			
	// 获取物品
	public static final String QUERY_GOODS_URL = PLATFORM_HOST + "/goods/queryGoods";
	public static final int QUERY_GOODS_CODE = 10;
	
	// 赠送礼物
	public static final String GIVE_PRESENT_URL = PLATFORM_HOST + "/givePresent";
	public static final int GIVE_PRESENT_CODE = 11;
	
	// 修改密码
	public static final String MODIFY_PASSWORD_URL = PLATFORM_HOST + "/modifyPasswordByOldPassword";
	public static final int MODIFY_PASSWORD_CODE = 12;
	
	// 获取背包道具
	public static final String GET_USER_GOODS_URL = PLATFORM_HOST + "/user/getUserGoods";
	public static final int GET_USER_GOODS_CODE = 13;
	
	// 修改密码
	public static final String QUERY_FRIENDS_URL = PLATFORM_HOST + "/user/queryUserFriends";
	public static final int QUERY_FRIENDS_CODE = 14;
	
	// 获取玩家详情
	public static final String GET_PLAYER_DETAIL_URL = PLATFORM_HOST + "/playerUser/getUserInfo";
	public static final int GET_PLAYER_DETAIL_CODE = 15;
	
	// 获取主播详情
	public static final String GET_ANCHOR_DETAIL_URL = PLATFORM_HOST + "/compereUser/getUserInfo";
	public static final int GET_ANCHOR_DETAIL_CODE = 16;
	
	// 加入黑名单
	public static final String ADD_BLACKLIST_URL = PLATFORM_HOST + "/user/addToBlacklist";
	public static final int ADD_BLACKLIST_CODE = 17;
		
	// 移出黑名单
	public static final String REMOVE_FROM_BLACKLIST_URL = PLATFORM_HOST + "/user/removeFromBlacklist";
	public static final int REMOVE_FROM_BLACKLIST_CODE = 18;
	
	// 查询通讯录好友
	public static final String VARIFY_PHONES_URL = PLATFORM_HOST + "/user/varifyPhones";
	public static final int VARIFY_PHONES_CODE = 19;
		
	// 添加好友
	public static final String ADD_FRIEND_URL = PLATFORM_HOST + "/user/addFriend";
	public static final int ADD_FRIEND_CODE = 20;
    //删除好友
    public static final String USER_REMOVE_FRIEND =PLATFORM_HOST + "/user/removeFriend";
	
	// 购买道具
	public static final String BUY_GOODS_URL = PLATFORM_HOST + "/goods/buyGoods";
	public static final int BUY_GOODS_CODE = 21;
	
	// 财富排行榜
	public static final String QUERY_WEALTH_RANK_URL = PLATFORM_HOST + "/playerUser/queryWealthRank";
	public static final int QUERY_WEALTH_RANK_CODE = 22;
	
	// 查看玩家个人段位
	public static final String PLAYER_GAME_LEVELS = PLATFORM_HOST + "/viewPlayerGameLevels";
	
	// 查看守护我的玩家
	public static final String GetMyDefendPlayer_URL = PLATFORM_HOST + "/captureCompere/getMyDefendPlayer";
	
	// 查看主播的被抓状态接口
	public static final String GetCompereCaptureStatus_URL = PLATFORM_HOST + "/captureCompere/getCompereCaptureStatus";
    // 房间玩家列表
    public static final String ROOM_PLAYER_LIST = PLATFORM_HOST + "/compereLive/viewRoomPlayers";
	
	// 获取房间类别列表
	public static final String ROOM_CATEGORY_LIST = PLATFORM_HOST + "/getRoomCatetoryList";
	
	// 用户上传图片视频文字
	public static final String USER_UPLOAD_MOMENTS = PLATFORM_HOST + "/user/uploadMoments";
	
	// 朋友圈列表
	public static final String USER_TURN_MOMENTS = PLATFORM_HOST + "/user/turnMomentPage";
	
	// 添加关注
	public static final String ADD_ATTENTION_URL = PLATFORM_HOST + "/addAttention";
	// 取消关注
	public static final String REMOVE_ATTENTION_URL = PLATFORM_HOST + "/removeAttention";
    public static final String USER_FRIENDS = PLATFORM_HOST +"/user/queryUserFriends";
    //主播的粉丝
    public static final String COMPERE_MY_FANS = PLATFORM_HOST+"/compereUser/myFans";
    
    // 检测第三方账号是否有注册
    public static final String OAuthCheck = PLATFORM_HOST + "/playerUser/OAuthCheck";

    //我关注的主播
    public static final String USER_ATTENTION_ANCHOR = PLATFORM_HOST +"/playerUser/myAttentions";
    //群列表
    public static final String USER_GROUPS = PLATFORM_HOST +"/user/queryGroup";
    //群详情
    public static final String USER_GROUP_DETAIL = PLATFORM_HOST +"/user/queryGroupDetails";
    //退出群组
    public static final String USER_EXIT_GROUP = PLATFORM_HOST+"/user/exitGroup";
    //修改群组
    public static final String USER_MODIFY_GROUP = PLATFORM_HOST+"/user/modifyGroup";
    //邀请加入群聊
    public static final String USER_INVITE_JOIN_GROUP = PLATFORM_HOST +"/user/inviteJoinGroup";
    //查找用户
    public static final String USER_FIND_USER = PLATFORM_HOST +"/user/findUser";
    //创建群
    public static final String USER_GROUP_CREATE= PLATFORM_HOST +"/user/createGroup";

    //获取电台类型
    public static final String QUERY_THEME_URL = PLATFORM_HOST + "/compereLive/queryTheme";

	//转发审核消息
	public static final String TRANSMIT_VERIFY_MESSAGE_URL = PLATFORM_HOST + "/user/transmitVerifyMessage";

	//加入你说我猜
	public static final String JOIN_WORD_GUESS_URL = PLATFORM_HOST + "/compereLive/joinYouSayIGuess";

	public static final String ANSWER_WORD_GUESS_URL = PLATFORM_HOST + "/compereLive/answerYouSayIGuess";

	//加入FM
	public static final String JOIN_FM_URL = PLATFORM_HOST + "/compereLive/joinFm";
	//退出FM
	public static final String EXIT_FM_URL = PLATFORM_HOST + "/compereLive/exitFm";

	// 公会相关
	// 公会详情
	public static final String GET_SOCIETY_DETAIL_URL = PLATFORM_HOST + "/society/getSocietyDetail";

	// 加入公会
	public static final String JOIN_SOCIETY_URL = PLATFORM_HOST + "/society/joinSociety";

	// 公会主播列表
	public static final String GET_SOCIETTY_COMPERE_LIST_URL = PLATFORM_HOST + "/society/getSocietyCompereList";

	// 公会成员列表
	public static final String GET_SOCIETTY_PLAYER_LIST_URL = PLATFORM_HOST + "/society/getSocietyPlayerList";

	// 进入抢矿活动
	public static final String ENTER_MINING_ACTIVITY_URL = PLATFORM_HOST + "/society/enterMiningActivity";

	// 释放矿坑
	public static final String RELEASE_SECTION_URL = PLATFORM_HOST + "/society/releaseSection";

	// 退出矿坑
	public static final String EXIT_Mining_ACTIVITY_URL = PLATFORM_HOST + "/society/exitMiningActivity";

    // 黑名单列表
    public static final String USER_BLACK_LIST = PLATFORM_HOST + "/user/queryUserBlacklist";
    //移出黑名单
    public static final String USER_REMOVE_FROM_BLACK_LIST = PLATFORM_HOST + "/user/removeFromBlacklist";

	// 游戏相关
	public static final String QUERY_USER_ONLINE_GMAE_STATUS = PLATFORM_HOST + "/game/queryUserOnlineGameStatus";

	// 组局相关
	// 获取组局游戏列表
	public static final String FREE_GAME_LIST_URL = PLATFORM_HOST + "/game/freeGameList";

	// 创建组局
	public static final String CREATE_FREE_GAME_URL = PLATFORM_HOST + "/createFreeGame";

	// 加入组局
	public static final String JOIN_FREE_GAME_URL = PLATFORM_HOST + "/joinFreeGame";

	// 邀请玩家组局
	public static final String INVITE_PLAYER_FOR_FREE_GAME_URL = PLATFORM_HOST + "/invitePlayerForFreeGame";

	// 开始组局
	public static final String START_FREE_GAME_URL = PLATFORM_HOST + "/startFreeGame";

	// 关闭组局
	public static final String CLOSE_FREE_GAME_URL = PLATFORM_HOST + "/closeFreeGame";

	// 退出组局
	public static final String EXIT_FREE_GAME_URL = PLATFORM_HOST + "/exitFreeGame";

	// 查看组局玩家
	public static final String VIEW_ACTIVITY_PLAYER_URL = PLATFORM_HOST + "/viewActivityPlayers";

	// 查看组局历史记录
	public static final String VIEW_REGANIZE_HISTORY_URL = PLATFORM_HOST + "/viewReganizeHistory";

	//绑定主播
	public static final String BIND_COMPERE_URL = PLATFORM_HOST + "/playerUser/bindCompere";

	//绑定玩家
	public static final String BIND_PLAYER_URL = PLATFORM_HOST + "/bindPromotePlayer";

	//验证旧支付密码
	public static final String VARIFY_PAY_PASSWORD_URL = PLATFORM_HOST + "/user/varifyPayPassword";

	public static final String SET_PAY_PASSWORD_URL =  PLATFORM_HOST + "/user/setPayPassword";

    //举报
    public static final String INFORM_INFORM_USER=PLATFORM_HOST+"/inform/informUser";

	public static final String PLAYER_CHARGE_URL = PLATFORM_HOST + "/playerUser/playerCharge";

    //商品类别
    public static final String GOODS_CATEGORYS = PLATFORM_HOST + "/onlineStore/queryMerchantGoodsCategories";

    public static final String VIP_LEVELS = PLATFORM_HOST + "/playerUser/queryVipLevels";

    //查询我的道具
    public static final String GOODS_MY_GOODS = PLATFORM_HOST + "/goods/queryMyGoods";

    //使用小喇叭
    public static final String GOODS_SEND_LOUD_SPEAKER = PLATFORM_HOST + "/goods/useLoudspeaker";
    //任务列表
    public static final String USER_TASK_LIST = PLATFORM_HOST + "/user/getTaskList";
    //公告
    public static final String BASE_ANNOUNCEMENTS = PLATFORM_HOST + "/baseData/queryAnnouncements";
    //可抢矿列表
    public static final String SOCIETY_MINING_LIST = PLATFORM_HOST + "/society/getMiningList";
    //热词
    public static final String LIVE_HOT_WORDS = PLATFORM_HOST + "/compereLive/hotWords";
    //app版本更新
    public static final String APP_VERSION = PLATFORM_HOST + "/version/queryVersion";
    //基础数据版本号
    public static final String DATA_VERSION = PLATFORM_HOST + "/version/queryAllBaseDataVersion";
    //玩家守护的主播
    public static final String USER_DEFENDER_COMPERE = PLATFORM_HOST +  "/captureCompere/getMyDefendCompere";
    //主播的守护
    public static final String COMPERE_DEFENDER_PLAYER = PLATFORM_HOST + "/captureCompere/getMyDefendPlayer";
    //玩家赠送钻石给主播
    public static final String USER_SEND_JEWEL = PLATFORM_HOST + "/playerUser/sendJewel";
    //随机广告
    public static final String AD_RANDOM_AD = PLATFORM_HOST + "/getRandomAd";
	//快速注册
	public static final String QUICK_REGISTER_URL = PLATFORM_HOST + "/playerUser/quickRegister";
	//绑定手机
	public static final String BIND_PHONE_URL = PLATFORM_HOST + "/playerUser/bindPhone";

	/**
	 * 生成请求链接
	 * @param json
	 * @return
	 */
	public static String CreatRequestUrl(Context context,String json){
		String requestUrl = "";
		String encodejson = "";
		String md5 = Key + json;
		md5 = Md5Util.MD5(md5).toLowerCase();
		try {
			encodejson = URLEncoder.encode(json, "utf-8");
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		requestUrl = "&requestMessage=" + encodejson;
		requestUrl = requestUrl + "&sign=" + md5;
		Log.d("json:", json);
		Log.d("encodejson:", encodejson);
		Log.d("toMd5", md5);
		Log.d("sign:", Md5Util.MD5(md5));
		return requestUrl;
	}
	
}
