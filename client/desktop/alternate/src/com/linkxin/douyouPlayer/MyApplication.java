package com.linkxin.douyouPlayer;

import java.util.Date;

import org.cocos2dx.lua.AppActivity;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.support.multidex.MultiDex;
//import android.support.multidex.MultiDexApplication;
import android.content.Intent;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.View;
import android.webkit.WebView;
import android.widget.Button;

import com.alibaba.sdk.android.oss.OSSClient;
import com.linkxin.douyouPlayer.activity.nyq.BuildConfig;
import com.linkxin.douyouPlayer.activity.game.GameActivity;
import com.linkxin.douyouPlayer.activity.web.WebActivity;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.view.MovieRecorderView;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.view.VoiceRecorderView;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.library.SensitiveFilter;
import com.linkxin.library.constant.LibConstant;
import com.linkxin.library.crash.CrashHandler;
import com.linkxin.library.utils.AppUtils;
import com.yunva.im.sdk.lib.YvLoginInit;
import com.zxinsight.Session;

public class MyApplication extends Application {

	public static Context applicationContext;
	public static MyApplication instance;

	public static boolean isForeground = true; 	// 当前应用是否在前台
	public static boolean is_Screen_OFF;		// 屏幕是否关闭
	public static boolean iskicked;				// 当前是否被踢出登录

	public static int power = 100;

	// 视频录像
	public static MovieRecorderView movieRV;
	public static Button start_btn;
	public static View ly_record;

	// 视频播放
	public static View showvideo;

	// 音频录制
	public static VoiceRecorderView voiceRV;
	public static View ly_record_voice;

	// 屏幕信息
	public static int SCREEN_WIDTH;		// 宽
	public static int SCREEN_HEIGHT;	// 高
	
	// 平台
	public static boolean isLogin = false;
	public static String userId;
	public static String userAccount;
	public static int userCoinAmount;
	public static String token;
	public static String level;
	public static String photoUrl;
	public static String nickName;
	public static String union;
	public static String myGrade;
	public static String sex;
	public static String phone;
	public static Date birthday;
	public static String province;
	public static String city;
	public static String cityId = "1";
	public static String town;

	//定位城市
	public static String locatedCityId;
	public static String locatedCityName;

	// 浏览器
	public static WebView webView;
	public static WebActivity webActivity;
	
	// 公会
	public static String societyId;
	public static String society;
	public static boolean isloadSociety;
	public static String othersocietyId;// 正在查看的公会id
	public static String nowActivityId;// 当前的活动id
	public static String nowMineSectionId;// 当前正在挖的矿坑
	
	// 经纬度
	public static String latitude;
	public static String longitude;

	// 绑定关系
	public static String bindCompereId;
	public static long promoterId;
	
	// 环信
	public static String nowcount;

	// OSS
	public static OSSClient ossClient;
	public static String accessKey;
	public static String screctKey;
	public static String bucketName;
	
	// 游戏
	public static AppActivity gameActivity;
	public static int nowEnterGame;
	public static String getGameCode;
	public static int nowReloadGameId;
	public static int GAME_SCREEN_WIDTH;			// 宽
	public static int GAME_SCREEN_HEIGHT;			// 高
	public static boolean isToGame;					// 是否需要打开游戏
	public static boolean isInGame;					// 当前是否在游戏里
	public static boolean isRecharge;				// 是否前往充值
	
	// 直播间
	public static String compereId; 	// 当前所在直播间主播id
	public static String compereSex; 	// 当前所在直播间主播性别
	
	// 组局
	public static int tableId;			// 组局的table id
	public static String activityId;	// 组局的活动 id
	public static String inviteCode;	// 组局邀请码
	public static int groupChip;		// 组局创建者的带入筹码（此值为兑换筹码时的最小兑换数）
	public static int gamelevel = 0;	// 组局游戏等级
	public static int extract;			// 组局服务费

	@Override
	public void onCreate() {
		super.onCreate();
		applicationContext = this;
		instance = this;
		nowcount = "";
		is_Screen_OFF = false;

		// 魔窗
		Session.setAutoSession(this);
		
		getDisplayInfo();

		YvLoginInit.initApplicationOnCreate(this, RequestURL.YAYAAPP_ID);

//        PlayerCrash.getInstance().initCrashHandler(this.getApplicationContext());
//        PlayerCrash.getInstance().setFilePrefix("玩家端日志_");
//        SensitiveFilter.getInstance(this);
        
	}
	
	public static MyApplication getInstance() {
		return instance;
	}

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
	
	private int screenWidth;
	private int screenHeight;
	private int screenDensityDpi;
	private float density;
	
	private void getDisplayInfo(){
        DisplayMetrics dm = getApplicationContext().getResources().getDisplayMetrics();
        
        screenWidth = dm.widthPixels;
        screenHeight = dm.heightPixels;
        screenDensityDpi = dm.densityDpi;
        density = dm.density;
	}

	public int getScreenWidth() {
		return screenWidth;
	}

	public int getScreenHeight() {
		return screenHeight;
	}

	public int getScreenDensityDpi() {
		return screenDensityDpi;
	}

	public float getDensity() {
		return density;
	}

    private static class PlayerCrash extends CrashHandler{

        private volatile static PlayerCrash instance;
        public static PlayerCrash getInstance(){
            if (instance == null) {
                synchronized (PlayerCrash.class) {
                    if (instance == null) {
                        instance = new PlayerCrash();
                    }
                }
            }

            return instance;
        }
        private PlayerCrash(){}


        /**
         * 发生异常
         */
        @Override
        protected void onCrash() {

            if (!BuildConfig.LOG_DEBUG && !TextUtils.isEmpty(crashPath) && !TextUtils.isEmpty(logPath)){
                SPUtil.setString(applicationContext, LibConstant.EXTRA_LOG,crashPath+"/"+logPath);
            }

			// 隐藏悬浮按钮
//			PublicViews.hideSpeaker();


			// 需要用SP储存的值
			SPUtil.setInt(applicationContext,"SCREEN_WIDTH",MyApplication.SCREEN_WIDTH);
			SPUtil.setInt(applicationContext,"SCREEN_HEIGHT",MyApplication.SCREEN_HEIGHT);

			// 登录状态
			SPUtil.setboolean(applicationContext,"isLogin",MyApplication.isLogin);

			// 公会
			SPUtil.setboolean(applicationContext,"isloadSociety",MyApplication.isloadSociety);
			SPUtil.setString(applicationContext,"othersocietyId",MyApplication.othersocietyId);
			SPUtil.setString(applicationContext,"nowActivityId",MyApplication.nowActivityId);
			SPUtil.setString(applicationContext,"nowMineSectionId",MyApplication.nowMineSectionId);

			// 当前的经纬度
			SPUtil.setString(applicationContext,"latitude",MyApplication.latitude);
			SPUtil.setString(applicationContext,"longitude",MyApplication.longitude);

			// 游戏
			SPUtil.setInt(applicationContext,"nowEnterGame",MyApplication.nowEnterGame);
			SPUtil.setString(applicationContext,"getGameCode",MyApplication.getGameCode);
			SPUtil.setInt(applicationContext,"GAME_SCREEN_WIDTH",MyApplication.GAME_SCREEN_WIDTH);
			SPUtil.setInt(applicationContext,"GAME_SCREEN_HEIGHT",MyApplication.GAME_SCREEN_HEIGHT);
			SPUtil.setboolean(applicationContext,"isToGame",MyApplication.isToGame);
			SPUtil.setboolean(applicationContext,"isInGame",MyApplication.isInGame);

			// 程序崩溃了，设置用户不在充值界面里
			MyApplication.isRecharge = false;
			SPUtil.setboolean(applicationContext,"isRecharge",MyApplication.isRecharge);

			// 直播间
			SPUtil.setString(applicationContext,"CompereId",MyApplication.compereId); 	    // 当前所在直播间主播id
			SPUtil.setString(applicationContext,"CompereSex",MyApplication.compereSex); 	    // 当前所在直播间主播性别

			// 组局
			SPUtil.setInt(applicationContext,"compereId",MyApplication.tableId);			    // 组局的table id
			SPUtil.setString(applicationContext,"activityId",MyApplication.activityId);	    // 组局的活动 id
			SPUtil.getString(applicationContext,"inviteCode",MyApplication.inviteCode);	    // 组局邀请码
			SPUtil.setInt(applicationContext,"groupChip",MyApplication.groupChip);		    // 组局创建者的带入筹码（此值为兑换筹码时的最小兑换数）
			SPUtil.setInt(applicationContext,"gamelevel",MyApplication.gamelevel);	        // 组局游戏等级
			SPUtil.setInt(applicationContext,"extract",MyApplication.extract);			    // 组局服务费

			// 定位城市
			SPUtil.getString(applicationContext,"locatedCityId", MyApplication.locatedCityId);
			SPUtil.getString(applicationContext,"locatedCityName", MyApplication.locatedCityName);

			AppUtils.getInstance().restart(GameActivity.class);

        }
    }
}
