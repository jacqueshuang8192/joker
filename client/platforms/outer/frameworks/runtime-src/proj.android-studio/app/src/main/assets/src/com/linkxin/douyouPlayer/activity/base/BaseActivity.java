
package com.linkxin.douyouPlayer.activity.base;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.http.TaskCallBackInf;
import com.linkxin.douyouPlayer.http.ThreadManager;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.TaskUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.douyouPlayer.vo.UserOnlineGameStatus;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.library.utils.AppUtils;

import net.tsz.afinal.FinalBitmap;
import net.tsz.afinal.http.AjaxParams;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import org.cocos2dx.lua.AppActivity;

public class BaseActivity extends Activity implements TaskCallBackInf {

    protected String mPageName;

	public TaskUtil task=null;
	public AjaxParams params=new AjaxParams();
	public Dialog dialog;
	Handler hand = null;
	FinalBitmap fb;
	View loadlayout;
	TextView loadtitle;
	public Button loadleft_bt,loadright_bt;
	public Context mcontext;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);

        AppUtils.getInstance().addActivity(this);

	}
	
	public void taskCallBack(String data,int type,int tag) 
	{
		
	}
	
	public void showLoading(){
		if (!dialog.isShowing()) {
            ThreadManager.getMainHandler().post(new Runnable() {

                @Override
                public void run() {
                    dialog.show();
                }
            });
		}
	}
	
	public void hideLoading(){
        if (isFinishing()){
            return;
        }
        if (dialog.isShowing()) {
            ThreadManager.getMainHandler().post(new Runnable() {

                @Override
                public void run() {
                    if (isFinishing()){
                        return;
                    }
                    dialog.dismiss();
                }
            });
        }

	}
	 /**
     * @param viewId
     * @author lxy
     */
    public <V extends View> V getViewById(int viewId){
        return (V)findViewById(viewId);
    }

    /**
     * @param contentView
     * @param viewId
     * @author lxy
     */
    public <V extends View> V getViewById(View contentView,int viewId){
        return (V)contentView.findViewById(viewId);
    }
	
	/**
    * @param clazz
    * @param extras
    * @param requestCode
    * @author lxy
    */
   public void gotoActivityForResult(Class<?> clazz, Bundle extras, int requestCode) {
       Intent mIntent = new Intent(this, clazz);
       if (extras != null) {
           mIntent.putExtras(extras);
       }
       startActivityForResult(mIntent, requestCode);
   }
   /**
    *
    * @param clazz
    * @param requestCode
    * @author lxy
    */
   public void gotoActivityForResult(Class<?> clazz, int requestCode) {
       gotoActivityForResult(clazz,null,requestCode);
   }

   /**
    * @param clazz
    * @param extras
    * @author lxy
    */
   public void gotoActivity(Class<?> clazz, Bundle extras) {
       Intent mIntent = new Intent(this, clazz);
       if (extras != null) {
           mIntent.putExtras(extras);
       }
       startActivity(mIntent);
   }

   /**
    * @param clazz
    * @author lxy
    */
   public void gotoActivity(Class<?> clazz) {
       gotoActivity(clazz, null);
   }

   /**
    * @param action
    * @author lxy
    */
   public void gotoActivity(String action) {
       gotoActivity(action, null);
   }

   /**
    * @param intent
    * @author lxy
    */
   public void gotoActivity(Intent intent) {
       if (intent == null) {
           return;
       }
       startActivity(intent);
   }

   /**
    * @param action
    * @param extras
    * @author lxy
    */
   public void gotoActivity(String action, Bundle extras) {
       Intent mIntent = new Intent(action);
       if (extras != null) {
           mIntent.putExtras(extras);
       }
       startActivity(mIntent);
   }

	public void defaultFinish() {
		super.finish();
	}

	public void longToast(int resid) {
		Toast.makeText(this, resid, Toast.LENGTH_LONG).show();
	}

	public void longToast(String text) {
		Toast.makeText(this, text, Toast.LENGTH_LONG).show();
	}

	public void shortToast(String text) {
		Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
	}

	public void shortToast(int resid) {
		Toast.makeText(this, resid, Toast.LENGTH_SHORT).show();
	}
	
	public boolean isEmpty(List<?> list){
		return list == null || list.isEmpty();
	}
	
	public void hideKeybord() {
		InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(this.getWindow().getDecorView()
				.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub

        if (MyApplication.isForeground) {
            Log.d("isAppOnForeground","应用在前台，界面启动或恢复");
        }else{
            Log.d("isAppOnForeground","应用从后台到前台");

            // 设置应用在前台
            MyApplication.isForeground = true;

            DouyouUser user = SPUtil.getCurrentUser(getApplicationContext());
            if(user != null){

                // 平台
                MyApplication.userId = user.getUserId();
//                MyApplication.userAccount;
                MyApplication.userCoinAmount = user.getCoinAmount();
                MyApplication.token = user.getToken();
                MyApplication.level = user.getLevel() + "";
                MyApplication.photoUrl = user.getPhotoUrl();
                MyApplication.nickName = user.getNickName();
//                MyApplication.union;
                MyApplication.myGrade = user.getGrade() + "";
                MyApplication.sex = user.getSex();
                MyApplication.phone = user.getPhone();
//                public static Date birthday;
                MyApplication.province = user.getProvince();
//                MyApplication.city = user.getCity();
//                MyApplication.cityId = user.getCityId();
                MyApplication.town = user.getTown();

                // 公会
                MyApplication.societyId = user.getSocietyId();
                MyApplication.society = user.getSociety();

                // 绑定关系
                MyApplication.bindCompereId = user.getBindCompereId();
                MyApplication.promoterId = user.getPromoterId();
            }

            // 需要用SP获取的值
            // 屏幕信息
            MyApplication.SCREEN_WIDTH = SPUtil.getInt(this,"SCREEN_WIDTH");		// 屏幕宽
            MyApplication.SCREEN_HEIGHT = SPUtil.getInt(this,"SCREEN_HEIGHT");	    // 屏幕高

            // 登录状态
            MyApplication.isLogin = SPUtil.getBoolean(this,"isLogin");

            // 公会
            MyApplication.isloadSociety = SPUtil.getBoolean(this,"isloadSociety");
            MyApplication.othersocietyId = SPUtil.getString(this,"othersocietyId");
            MyApplication.nowActivityId = SPUtil.getString(this,"nowActivityId");
            MyApplication.nowMineSectionId = SPUtil.getString(this,"nowMineSectionId");

            // 当前的经纬度
            MyApplication.latitude = SPUtil.getString(this,"latitude");
            MyApplication.longitude = SPUtil.getString(this,"longitude");

            // 游戏
            MyApplication.nowEnterGame = SPUtil.getInt(this,"nowEnterGame");
            MyApplication.getGameCode = SPUtil.getString(this,"getGameCode");
            MyApplication.GAME_SCREEN_WIDTH = SPUtil.getInt(this,"GAME_SCREEN_WIDTH");			    // 游戏宽
            MyApplication.GAME_SCREEN_HEIGHT = SPUtil.getInt(this,"GAME_SCREEN_HEIGHT");			// 游戏高
            MyApplication.isToGame = SPUtil.getBoolean(this,"isToGame");
            MyApplication.isInGame = SPUtil.getBoolean(this,"isInGame");
            MyApplication.isRecharge = SPUtil.getBoolean(this,"isRecharge");

            // 直播间
            MyApplication.compereId = SPUtil.getString(this,"CompereId"); 	    // 当前所在直播间主播id
            MyApplication.compereSex = SPUtil.getString(this,"CompereSex"); 	// 当前所在直播间主播性别

            // 组局
            MyApplication.tableId = SPUtil.getInt(this,"compereId");			// 组局的table id
            MyApplication.activityId = SPUtil.getString(this,"activityId");	    // 组局的活动 id
            MyApplication.inviteCode = SPUtil.getString(this,"inviteCode");	    // 组局邀请码
            MyApplication.groupChip = SPUtil.getInt(this,"groupChip");		// 组局创建者的带入筹码（此值为兑换筹码时的最小兑换数）
            MyApplication.gamelevel = SPUtil.getInt(this,"gamelevel");	    // 组局游戏等级
            MyApplication.extract = SPUtil.getInt(this,"extract");			// 组局服务费

            // 定位城市
            MyApplication.locatedCityId = SPUtil.getString(this,"locatedCityId");
            MyApplication.locatedCityName = SPUtil.getString(this,"locatedCityName");
        }

        super.onResume();

        if(MyApplication.cityId == null || "".equals(MyApplication.cityId)){
            MyApplication.cityId = "1";
            MyApplication.city = "广州";
        }

//        DouyouUser user = SPUtil.getCurrentUser(getApplicationContext());
//        if(user != null){
//            // 若本地检查玩家在游戏里，则检查用户在服务器上的游戏状态
//            if(MyApplication.isInGame){
//                // 用户在游戏里
//                if(MyApplication.isRecharge){
//                    // 当前是在充值界面
//                    Log.d("douyou","在充值界面");
//                }else{
//                    // 当前不是在充值界面
//                    // 判断屏幕是否为亮着
//                    PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
//                    if(pm.isScreenOn()){
//                        queryUserOnlineGameStatus();
//                    }
//                }
//            }
//        }

	}

    @Override
    protected void onStop() {

        if (isAppOnForeground()) {
            Log.d("isAppOnForeground","应用在前台，当前界面停止");
        }else{
            Log.d("isAppOnForeground","应用从前台进入后台");

            // 设置应用不在前台
            MyApplication.isForeground = false;

            // 需要用SP储存的值
            SPUtil.setInt(this,"SCREEN_WIDTH",MyApplication.SCREEN_WIDTH);
            SPUtil.setInt(this,"SCREEN_HEIGHT",MyApplication.SCREEN_HEIGHT);

            // 登录状态
            SPUtil.setboolean(this,"isLogin",MyApplication.isLogin);

            // 公会
            SPUtil.setboolean(this,"isloadSociety",MyApplication.isloadSociety);
            SPUtil.setString(this,"othersocietyId",MyApplication.othersocietyId);
            SPUtil.setString(this,"nowActivityId",MyApplication.nowActivityId);
            SPUtil.setString(this,"nowMineSectionId",MyApplication.nowMineSectionId);

            // 当前的经纬度
            SPUtil.setString(this,"latitude",MyApplication.latitude);
            SPUtil.setString(this,"longitude",MyApplication.longitude);

            // 游戏
            SPUtil.setInt(this,"nowEnterGame",MyApplication.nowEnterGame);
            SPUtil.setString(this,"getGameCode",MyApplication.getGameCode);
            SPUtil.setInt(this,"GAME_SCREEN_WIDTH",MyApplication.GAME_SCREEN_WIDTH);
            SPUtil.setInt(this,"GAME_SCREEN_HEIGHT",MyApplication.GAME_SCREEN_HEIGHT);
            SPUtil.setboolean(this,"isToGame",MyApplication.isToGame);
            SPUtil.setboolean(this,"isInGame",MyApplication.isInGame);
            SPUtil.setboolean(this,"isRecharge",MyApplication.isRecharge);

            // 直播间
            SPUtil.setString(this,"CompereId",MyApplication.compereId); 	    // 当前所在直播间主播id
            SPUtil.setString(this,"CompereSex",MyApplication.compereSex); 	    // 当前所在直播间主播性别

            // 组局
            SPUtil.setInt(this,"compereId",MyApplication.tableId);			    // 组局的table id
            SPUtil.setString(this,"activityId",MyApplication.activityId);	    // 组局的活动 id
            SPUtil.getString(this,"inviteCode",MyApplication.inviteCode);	    // 组局邀请码
            SPUtil.setInt(this,"groupChip",MyApplication.groupChip);		    // 组局创建者的带入筹码（此值为兑换筹码时的最小兑换数）
            SPUtil.setInt(this,"gamelevel",MyApplication.gamelevel);	        // 组局游戏等级
            SPUtil.setInt(this,"extract",MyApplication.extract);			    // 组局服务费

            // 定位城市
            SPUtil.setString(this,"locatedCityId", MyApplication.locatedCityId);
            SPUtil.setString(this,"locatedCityName", MyApplication.locatedCityName);
        }

        super.onStop();
    }

    @Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
	}

    public void onBackward(View view) {
		// TODO Auto-generated method stub
		defaultFinish();
	}
	public void onForward(View view){
		
	}

    /**
     * 注册广播
     */
    public void registerLocalReceiver(BroadcastReceiver receiver, String[] filters) {
        IntentFilter intentFilter = new IntentFilter();
        for (String filter : filters) {
            intentFilter.addAction(filter);
        }
    }

    /**
     * 反注册广播
     *
     * @param receiver receiver
     */
    public void unregisterLocalReceiver(BroadcastReceiver receiver) {

    }


    /**
     * 发送广播（不有内容）
     * @param action
     */
    public void sendLocalBoradCast(String action){
        sendLocalBoradCast(action,null);
    }

    /**
     * 发送广播（含有内容）
     * @param action
     * @param bundle 内容
     */
    public void sendLocalBoradCast(String action, Bundle bundle){
        if (TextUtils.isEmpty(action)){
            return;
        }
        Intent intent = new Intent(action);
        if (bundle !=null){
            intent.putExtras(bundle);
        }
    }

    @Override
    protected void onDestroy() {
        AppUtils.getInstance().removeActivity(this);
        super.onDestroy();
    }

    /**
     * 程序是否在前台运行
     *
     * @return
     */
    public boolean isAppOnForeground() {
        // Returns a list of application processes that are running on the
        // device

        ActivityManager activityManager = (ActivityManager) getApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);
        String packageName = getApplicationContext().getPackageName();

        List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager
                .getRunningAppProcesses();
        if (appProcesses == null)
            return false;

        for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            // The name of the process that this object is associated with.
            if (appProcess.processName.equals(packageName)
                    && appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                return true;
            }
        }

        return false;
    }

    /**
     * 查询用户游戏在线情况
     */
    private void queryUserOnlineGameStatus(){

        Map<String, String> params = new HashMap<String, String>();
        params.put("userId", MyApplication.userId);

        FinalHttpClient.getInstance().post(RequestURL.QUERY_USER_ONLINE_GMAE_STATUS, params, new FinalHttpClient.OnRequestListener() {

            @Override
            public void onFinish(JsonResponse response) {

                if (response.isSuccess()) {
                    UserOnlineGameStatus status =  response.readObject(UserOnlineGameStatus.class);
                    if(status != null){
                        if("0".equals(status.getGameStatus())){
                            if(MyApplication.isToGame){
                                // 用户没有进入游戏，但是进入了游戏大厅，需要重新进入游戏大厅
                                startActivity(new Intent(getApplicationContext(),AppActivity.class));
                            }else{
                                // 设置不需要进入游戏
                                MyApplication.isToGame = false;

                                // 设置用户不在游戏里
                                MyApplication.isInGame = false;
                            }
                        }else{
                            // 用户在游戏里，进行重连
                            MyApplication.nowEnterGame = 0;
                            if("R".equals(status.getType())){
                                // 组局重连
                                if(status.getGameId() == null){
                                    ToastUtil.showBaseToast(getApplicationContext(),"用户组局状态异常，请稍后再试！");
                                    return;
                                }else{
                                    MyApplication.nowEnterGame = Integer.parseInt(status.getGameId());
                                }
                            }else{
                                // 非组局重连
                                if(status.getGameId() == null){
                                    MyApplication.nowEnterGame = 0;
                                }else{
                                    MyApplication.nowEnterGame = Integer.parseInt(status.getGameId());
                                }
                            }
                            startActivity(new Intent(getApplicationContext(),AppActivity.class));
                        }
                    }else{
                        ToastUtil.showBaseToast(getApplicationContext(),"用户游戏状态异常，请稍后再试！");
                    }
                }else{
                    ToastUtil.showBaseToast(getApplicationContext(),response.getError());
                }
            }
        });
    }

}
