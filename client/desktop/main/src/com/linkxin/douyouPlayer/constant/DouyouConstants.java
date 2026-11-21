package com.linkxin.douyouPlayer.constant;

import com.linkxin.douyouPlayer.activity.nyq.BuildConfig;

/**
 * 静态变量
 * @author lxy
 *
 */
public final class DouyouConstants {

    private DouyouConstants(){}
	public static final boolean IS_DEBUG = BuildConfig.LOG_DEBUG;

	//db
	public static final int DB_VERSION = 4;
	public static final String DB_NAME = "db_douyou.db";
	
	//个性签名
	public static final String KEY_SIGN = "sign";
	//昵称
	public static final String KEY_NICK_NAME = "nickName";
	//生日
	public static final String KEY_BIRTHDAY = "birthday";

    public static final String KEY_USER = "user";
    public static final String KEY_PHONE="friendPhone";
    public static final String KEY_REASON="reason";
    public static final String KEY_KEYWORD="keyword";

    //客服环信用户名
    public static final String KEY_HX_CONTACT_SERVICE_NAME = "douyoucustomerserver";
    public static final String KEY_CONTACT_SERVICE_NICKNAME = "兜兜客服";

    //注册时间
    public static final String KEY_LAST_REGISTER_TIME = "lastRegisterTime";

	/*=============选择相片相关=============*/
	public static final String EXTRA_SELECTED_IMAGES = "EXTRA_SELECTED_IMAGES";
    public static final String EXTRA_IMAGE_LIST = "EXTRA_IMAGE_LIST";
    public static final String EXTRA_BUCKET_NAME = "EXTRA_BUCKET_NAME";
    public static final String EXTRA_CURRENT_IMG_POSITION = "EXTRA_CURRENT_IMG_POSITION";
    public static final String EXTRA_REQUEST_COUNT = "EXTRA_REQUEST_COUNT";
    public static final int MAX_IMAGES = 9;
	
	//app 初始化action
	public static final String ACTION_APP_INIT = "ACTION_APP_INIT";
    public static final String ACTION_FRIENDSHIP_INIT = "ACTION_FRIENDSHIP_INIT";
    public static final String ACTION_QUERY_VIP_LEVELS = "ACTION_QUERY_VIP_LEVELS";
    public static final String KEY_VIP_LEVEL = "KEY_VIP_LEVEL";
    public static final String ACTION_UPDATE_USER = "ACTION_UPDATE_USER";

    //=====================环信BoradCast start=====================
    public static final String EMCHAT_NEW_MESSAGE = "new_message";
    public static final String EMCHAT_OFFLINE_MESSAGE = "offline_message";
    public static final String EMCHAT_NEW_CMD_MESSAGE = "cmd_message";
    public static final String EMCHAT_DELIVERY_ACK = "delivery_ack";
    public static final String EMCHAT_ACK_READ = "ack_read";

    //聊天室

    public static final String EMCHAT_CHATROOM_DESTORY = "chatroom_destory";
    public static final String EMCHAT_CHATROOM_MEMBER_JOIN = "chatroom_member_join";
    public static final String EMCHAT_CHATROOM_MEMBER_EXIT = "chatroom_member_exit";
    public static final String EMCHAT_CHATROOM_MEMBER_KICKED = "member_kicked";

    public static final String EMCHAT_TYPE = "type";
    public static final String EMCHAT_EXT = "ext";
    public static final String EMCHAT_USERID = "userId";
    public static final String EMCHAT_NICKNAME = "nickname";
    public static final String EMCHAT_PHOTO = "photo";
    public static final String EMCHAT_ADMIN = "admin";
    public static final String EMCHAT_ROOMID = "roomId";
    public static final String EMCHAT_DOUYOU888 = "douyou888";
    public static final String EMCHAT_GREEN_MESSAGE = "green_live_message";
    public static final String EMCHAT_PHONE = "phone";

    //送礼物
    public static final String EMCHAT_GIFT = "gift";

    //游戏消息
    public static final String EMCHAT_GAME = "game";
    //开启视频游戏
    public static final String EMCHAT_OPEN_GAME = "openGame";
    //关闭视频游戏
    public static final String EMCHAT_CLOSE_GAME = "closeGame";

    //开直播
    public static final String EMCHAT_START_LIVE = "startLive";
    //关直播
    public static final String EMCHAT_STOP_LIVE="stopLive";

    //开麦 该房间已开启抢麦
    public static final String EMCHAT_OPEN_MIC = "openMic";
    //收麦 主播已收麦
    public static final String EMCHAT_TAKEBACK_MIC="takebackMic";
    //改麦
    public static final String EMCHAT_CHANGE_MIC = "changeMic";
    //移麦
    public static final String EMCHAT_REMOVE_FROM_MIC="removeFromMic";
    //排麦
    public static final String EMCHAT_APPLY_MIC = "applyMic";
    //放麦
    public static final String EMCHAT_RELEASE_MIC="releaseMic";
    //切麦 麦克风交给 xxx
    public static final String EMCHAT_QIE_MIC = "qiemai";

    //进入房间
    public static final String EMCHAT_ENTER_ROOM = "enterRoom";
    //退出房间
    public static final String EMCHAT_EXIT_ROOM = "exitRoom";
    //关闭房间
    public static final String EMCHAT_CLOSE_ROOM="closeRoom";
    //踢人
    public static final String EMCHAT_KICK = "kick";

    //开启你说我猜
    public static final String EMCHAT_OPEN_WORD_GUESS = "openYouSayIGuess";
    //加入你说我猜
    public static final String EMCHAT_JOIN_WORD_GUESS = "joinYouSayIGuess";
    //开始你说我猜
    public static final String EMCHAT_START_WORD_GUESS = "startYouSayIGuess";
    //你说我猜选词
    public static final String EMCHAT_SELECT_GUESS_WORD = "ysig_question";
    //结束你说我猜
    public static final String EMCHAT_END_WORD_GUESS = "endYouSayIGuess";
    //结束你说我猜比赛
    public static final String EMCHAT_END_WORD_GUESS_MATCH= "endYouSayIGuessMatch";
    //更新你说我猜玩家信息
    public static final String EMCHAT_UPDATE_WORD_GUESS_PLAYER = "updatePlayerForYouSayIGuess";
    //开启电台
    public static final String EMCHAT_OPEN_FM = "openFm";
    //加入电台
    public static final String EMCHAT_JOIN_FM = "joinFm";
    //退出电台
    public static final String EMCHAT_EXIT_FM = "exitFm";
    //关闭电台
    public static final String EMCHAT_CLOSE_FM = "closeFm";

    //申请约饭
    public static final String EMCHAT_APPLY_DATING = "applyDating";
    //回复申请约饭
    public static final String EMCHAT_REPLY_DATING_APPLY = "replyDatingApply";

    // 申请添加好友
    public static final String EMCHAT_ADD_FRIEND = "addFriend";

    // 公会相关
    // 加入公会
    public static final String EMCHAT_JOIN_SOCIETY = "joinSociety";

    // 刷新抢矿界面
    public static final String EMCHAT_REFRESHMINE = "refreshMine";

    // 同意加入公会
    public static final String EMCHAT_AGREE_JOIN_SOCIETY = "agreejoinSociety";

    // 组局相关
    // 开始游戏
    public static final String EMCHAT_START_GAME = "reganize";

    // 约饭相关
    // 刷新邀请约饭界面
    public static final String EMCHAT_DATING_AUCTION_COUNT_CHANGED = "datingAuctionCountChanged";

    //机器人消息
    public static final String EMCHAT_ROBOT_MESSAGE = "robotMessage";

    //点赞消息
    public static final String EMCHAT_UP_MESSAGE = "up";

    //聊天室感兴趣action
    public static final String[] EMCHAT_ROOM_CHAT_FILITER = {
    	EMCHAT_CHATROOM_MEMBER_KICKED,EMCHAT_CHATROOM_DESTORY,
        EMCHAT_CHATROOM_MEMBER_EXIT,EMCHAT_CHATROOM_MEMBER_JOIN,
        EMCHAT_ENTER_ROOM, EMCHAT_EXIT_ROOM, EMCHAT_START_LIVE, EMCHAT_STOP_LIVE,
        EMCHAT_CLOSE_ROOM, EMCHAT_GIFT, EMCHAT_KICK,EMCHAT_GIFT,
        EMCHAT_OPEN_MIC,EMCHAT_TAKEBACK_MIC,EMCHAT_CHANGE_MIC,
        EMCHAT_REMOVE_FROM_MIC,EMCHAT_APPLY_MIC,EMCHAT_RELEASE_MIC,
        EMCHAT_QIE_MIC, EMCHAT_OPEN_WORD_GUESS, EMCHAT_JOIN_WORD_GUESS,
        EMCHAT_START_WORD_GUESS, EMCHAT_SELECT_GUESS_WORD, EMCHAT_END_WORD_GUESS,
        EMCHAT_UPDATE_WORD_GUESS_PLAYER, EMCHAT_END_WORD_GUESS_MATCH, EMCHAT_OPEN_FM,
        EMCHAT_JOIN_FM, EMCHAT_EXIT_FM, EMCHAT_CLOSE_FM,EMCHAT_NEW_MESSAGE,EMCHAT_OPEN_GAME,
        EMCHAT_CLOSE_GAME, EMCHAT_UP_MESSAGE
    };
    
    // 组局聊天室感兴趣action
    public static final String[] GROUPBUREAU_ROOM_CHAT_FILITER = {
    	EMCHAT_ENTER_ROOM,
    	EMCHAT_EXIT_ROOM,
    	EMCHAT_CLOSE_ROOM,
    	EMCHAT_KICK,
        EMCHAT_START_GAME
    };

    // HTML聊天室感兴趣action
    public static final String[] HTML_ROOM_CHAT_FILITER = {
        EMCHAT_REFRESHMINE,
        EMCHAT_DATING_AUCTION_COUNT_CHANGED
    };

    //=====================环信BoradCast end=====================

    //动画类型
    public static final int AIRCRAFT = 1;
    public static final int CAR = 2;
    public static final int FEED = 3;
    public static final int HELICOPTER = 4;
    public static final int PLANE = 5;
    public static final int PRADA = 6;
    public static final int PROPOSE = 7;
    public static final int SUPER_FIREWORK = 8;
    public static final int VILLA = 9;
    public static final int WAGES = 10;

    //电台类型
    public static final String RADIO_JOKE = "JOKE";
    public static final String RADIO_EMOTION_POUR_OUT = "EMOTION_POUR_OUT";
    public static final String RADIO_WORD_GUESS = "WORD_GUESS";

    //麦克风状态
    public static final String MICPHONE_FREE = "0";
    public static final String MICPHONE_COMPERE = "1";
    public static final String MICPHONE_QUEUE = "2";
    public static final String MICPHONE_PLAYER = "3";

    //H5
    public static final String KEY_URL = "url";
    public static final String KEY_TITLE = "title";
    public static final String KEY_NOWAT = "nowAT";

    public static final String IS_CAN_SWITCH_ROOM = "isCanSwitchRoom";
    public static final String CAN_SWITCH_ROOM = "1";
    public static final String CAN_NOT_SWITCH_ROOM = "0";

    //第三方登录请求码
    public static final int QQ_LOGIN_REQUEST_CODE = 11101;

    //第三方请求类型
    public static final String QQ = "qq";
    public static final String WEIBO = "weibo";
    public static final String WECHAT = "wechat";

    //设置
    public static final String BARRAGE_SETTING = "barrage_";//弹幕
    public static final String ALERT_SOUND_SETTING = "alert_sound_";//提醒声音
    public static final String GAME_MESSAGE_SETTING = "game_message_";//游戏消息
    public static final String NO_DISTURBING_SETTING = "no_disturbing_";//免打扰
    public static final String LOCATE_SETTING = "locate_";//定位服务

    //直播间进入渠道
    public static final String LIVE_ROOM_ENTRANCE = "LIVE_ROOM_ENTRANCE";

    public static final String LIVE_ROOM_NOTIFICATION_ENTRANCE = "LIVE_ROOM_NOTIFICATION_ENTRANCE";

    public static final String NOTIFICATION_LIVE_ROOM_ID = "NOTIFICATION_LIVE_ROOM_ID";

    public static final String IS_IN_LIVE_ROOM = "IS_IN_LIVE_ROOM_";

    //切换城市入口点
    public static final int ROOM_CITY_ENTRY_POINT = 0;
    public static final int SOCIETY_CITY_ENTRY_POINT = 1;
    public static final int OFFLINE_STORE_CITY_ENTRY_POINT = 2;
    public static final int DATING_CITY_ENTRY_POINT = 3;
    public static final int TREASURE_CITY_ENTRY_POINT = 4;

    //直播
    public static final String GAME_DDZ = "ddz";

    public static final String LIVE_SUCCESS = "0";
    public static final String LIVE_FAILED = "1";

    //直播接口回调方法
    public static final String COMMAND_START_LIVE = "startLive";
    public static final String COMMAND_STOP_LIVE = "stopLive";
    public static final String COMMAND_ZOOM_LIVE = "zoomLive";
    public static final String COMMAND_ZOOM_OUT_LIVE = "zoomOutLive";
    public static final String COMMAND_PLAY_LIVE = "playLive";
    public static final String COMMAND_STOP_PLAY_LIVE = "stopPlayLive";

}
