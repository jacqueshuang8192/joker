/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package com.cocos2dx.sample.LuaJavaBridgeTest;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.game.GameActivity;
import com.linkxin.douyouPlayer.activity.login.Login;
import com.linkxin.douyouPlayer.activity.login.Register;
import com.linkxin.douyouPlayer.activity.web.WebActivity;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.http.PublicMethod;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.http.WXPublicMethod;
import com.linkxin.douyouPlayer.util.AppUpdateUtil;
import com.linkxin.douyouPlayer.util.BitmapUtil;
import com.linkxin.douyouPlayer.util.OSSUtil;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.utils.JSONUtils;
import com.linkxin.douyouPlayer.utils.PayUtils;
import com.linkxin.douyouPlayer.utils.YaYaVoiceUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.view.VoiceRecorderView;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.douyouPlayer.vo.LiveResponse;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.library.utils.AppUtils;
import com.linkxin.library.utils.StrUtils;
import com.pingplusplus.android.PaymentActivity;
import com.yunva.extension.YayaLiteIM;
import com.yunva.extension.audio.play.PlayListener;

import net.tsz.afinal.FinalDb;
import net.tsz.afinal.FinalHttp;
import net.tsz.afinal.http.AjaxCallBack;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LuaJavaBridgeTest
{
	public static int callBackHandle=-1;

	public static int callBackVideoHandle = -1;

	public static String startLiveReturnData;

	public static native void callLuaback(String s);

	// lua调用原生
	public static int addTwoNumbers(final int num1,final int num2){
		return num1 + num2;
	}

	// 原生调lua
	public static void callbackLua(final String tipInfo,final int luaFunc){
		callBackHandle=luaFunc;
	}

	public static void callbackVideo(final String tipInfo,final int luaFunc){
		callBackVideoHandle=luaFunc;
	}

	
	// lua调用原生
	
	/**
	 * 获取接口地址头（如http://120.25.165.221/hbiInterface）
	 * @return
	 */
	public static String getHttpAddr(){
		return RequestURL.PLATFORM_HOST;
	}

	// 游戏大厅

	/**
	 * 获取重连的gameid
	 * @return
     */
	public static int getReloadGameId(){
		return MyApplication.nowReloadGameId;
	}

	/**
	 * 退出游戏
	 * @return
	 */
	@SuppressLint("NewApi")
	public static void exitGame(){
		if(MyApplication.gameActivity != null){

			// 设置不需要再进入游戏
			MyApplication.isToGame = false;
			SPUtil.setboolean(MyApplication.gameActivity,"isToGame",MyApplication.isToGame);

			// 设置当前不在游戏里
			MyApplication.isInGame = false;
			SPUtil.setboolean(MyApplication.gameActivity,"isInGame",MyApplication.isInGame);

			MyApplication.gameActivity.finish();
			Cocos2dxHelper.sInited = false;
			MyApplication.gameActivity = null;

		}
	}
	
	/**
	 * 跳转充值
	 * @returnf
	 */
	public static void LuaRecharge(){

		MyApplication.isRecharge = true;
		SPUtil.setboolean(MyApplication.gameActivity,"isRecharge",MyApplication.isRecharge);

		Intent i = new Intent(MyApplication.gameActivity, WebActivity.class);
		i.putExtra("title", "充值中心");
		i.putExtra("nowAT", 5);
		String url = PublicMethod.getRechargeCenterUrl(MyApplication.gameActivity,SPUtil.getCurrentUserId(MyApplication.gameActivity));
		i.putExtra("url", url);
		MyApplication.gameActivity.startActivity(i);
	}

	/**
	 * 充值（新）
	 */
	private static final int REQUEST_CODE_PAYMENT = 100;

	public static void recharge(final int price,final String type,final int amount){

		MyApplication.gameActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {

				Map<String, String> source = new HashMap<String, String>();
				source.put("userId", MyApplication.userId);
				//支付宝以分为单位
				int p = price * 100;
				source.put("payAmount", p + "");
				source.put("payType", type);
				source.put("channel", "1");
				source.put("coinAmount", amount + "");
				FinalHttpClient.getInstance().post(RequestURL.PLAYER_CHARGE_URL, source, new FinalHttpClient.OnRequestListener() {

					@Override
					public void onFinish(JsonResponse response) {
						// TODO Auto-generated method stub
						if (response.isSuccess()) {

							// 记录充值金额
							SPUtil.setString(MyApplication.gameActivity,"rechargeamount",amount + "");

							Activity activity = AppUtils.getInstance().getTopActivity();
							Intent intent = new Intent(activity, PaymentActivity.class);
							intent.putExtra(PaymentActivity.EXTRA_CHARGE, response.getData());
							activity.startActivityForResult(intent, REQUEST_CODE_PAYMENT);

						} else {

							LuaJavaBridgeTest.rechargeFail();
							ToastUtil.showBaseToast(MyApplication.gameActivity,"充值失败，请稍候再试！");

						}
					}
				});

			}
		});

	}

	// 通用数据
	/**
	 * 获取屏幕宽高
	 * @return
	 */
	public static String getDeviceSize(){
		String sc_size = MyApplication.GAME_SCREEN_HEIGHT + "," + MyApplication.GAME_SCREEN_WIDTH;
		if(sc_size == null){
			return "";
		}
		return sc_size;
	}

	/**
	 * 获取用户id
	 * @return
	 */
	public static int getUserID(){
		return Integer.parseInt(SPUtil.getCurrentUserId(MyApplication.gameActivity));

//		return 1257;
	}
	
	/**
	 * 获取用户游戏币
	 * @return
	 */
	public static int getScore(){
		return MyApplication.userCoinAmount;
	}

	/**
	 * 获取用户昵称
	 * @return
	 */
	public static String getNickName(){
		return SPUtil.getCurrentUser(MyApplication.gameActivity).getNickName();

//		return "";
	}

	/**
	 * 获取经度
	 * @return
	 */
	public static String getLongitude(){
		String longitude = SPUtil.getString(MyApplication.gameActivity, "Longitude");
		Log.d(longitude, "-----Longitude-----");
		return SPUtil.getString(MyApplication.gameActivity, "Longitude");
	}

	/**
	 * 获取纬度
	 * @return
	 */
	public static String getLatitude(){
		String latitude = SPUtil.getString(MyApplication.gameActivity, "Latitude");
		Log.d(latitude, "-----latitude-----");
		return SPUtil.getString(MyApplication.gameActivity, "Latitude");
	}

	/**
	 * 自动登录
	 */
	public static void autoLogin(){
        // 检查当前是否已经登录
        if(SPUtil.isLogined(MyApplication.gameActivity)){
			LuaJavaBridgeTest.loginsuccess();
        }else{
			LuaJavaBridgeTest.loginFail();
        }
	}

	/**
	 * 微信登陆（新）
	 */
	public static void wxLogin(){
		WXPublicMethod.SendAuth(MyApplication.gameActivity);
	}

	/**
	 * 切换账号
	 */
	public static void applyChangeUser(){
		LuaJavaBridgeTest.loginFail();
	}
	
	/**
	 * 获取当前Token
	 * @return
	 */
	public static String getToken(){
		return "huangyuhaohahahahahahah1231";
	}
	
	/**
	 * 进入当前游戏：0 大厅  1 是组局   7是视屏间斗牛   100是主播战斗
	 * @return
	 */
	public static int getEnterGame(){
//		return MyApplication.nowEnterGame;
		return 0;
	}
	
	/**
	 * 获取玩家类型（P or C）
	 * @return
	 */
	public static String getUserType(){
		return "P";
	}
	
	/**
	 * 获取当前直播间主播id
	 * @return
	 */
	public static int douniuComchorId(){
		return 0;
	}
	
	// 抢主播相关
	/**
	 * 获取用户性别
	 * @return
	 */
	public static int getSex(){
		return Integer.parseInt(MyApplication.sex);
	}
	
	/**
	 * 获取当前直播间主播id
	 * @return
	 */
	public static int getPresenterId(){
		return Integer.parseInt(MyApplication.compereId);
	}
	
	/**
	 * 获取当前直播间主播性别
	 * @return
	 */
	public static int getPresenterSex(){
		return Integer.parseInt(MyApplication.compereSex);
	}
	
	// 组局相关
	/**
	 * 组局的table id
	 * @return
	 */
	public static int getGroupTableId(){
		return MyApplication.tableId;
	}
	
	/**
	 * 组局的活动id
	 * @return
	 */
	public static int getReganizeId(){
		return Integer.parseInt(MyApplication.activityId);
	}
	
	/**
	 * 组局邀请码
	 * @return
	 */
	public static String getCurrentInviteCode(){
		if(MyApplication.inviteCode == null){
			return "";
		}
		return MyApplication.inviteCode;
	}
	
	/**
	 * 组局创建者的带入筹码（此值为兑换筹码时的最小兑换数）
	 * @return
	 */
	public static int getGroupChip(){
		return MyApplication.groupChip;
	}

	/**
	 * 组局等级
	 * @return
	 */
	public static int getGroupLevel(){
		return MyApplication.gamelevel;
	}

	/**
	 * 组局服务费
	 * @return
	 */
	public static int getGroupCostRate(){
		return MyApplication.extract;
	}

	/**
	 * 退出组局
	 * @return
	 */
	@SuppressLint("NewApi")
	public static int exitGroupGame(final int id){
		if(MyApplication.gameActivity != null){

			// 设置当前不在游戏里
			MyApplication.isInGame = false;
			SPUtil.setboolean(MyApplication.gameActivity,"isInGame",MyApplication.isInGame);

			MyApplication.gameActivity.finish();
			Cocos2dxHelper.sInited = false;
			MyApplication.gameActivity = null;
		}
		return 0;
	}

	// 抢主播
	/**
	 * 退出主播战斗
	 * @return
	 */
	@SuppressLint("NewApi")
	public static void exitZbzd(final int id){
		if(MyApplication.gameActivity != null){

			// 设置当前不在游戏里
			MyApplication.isInGame = false;
			SPUtil.setboolean(MyApplication.gameActivity,"isInGame",MyApplication.isInGame);

			MyApplication.gameActivity.finish();
			Cocos2dxHelper.sInited = false;
			MyApplication.gameActivity = null;
		}
	}

	// 一元夺宝
	/**
	 * 获取城市id
	 * @return
     */
	public static int getCityId(){
		return Integer.parseInt(MyApplication.cityId);
	}

	/**
	 * 获取城市ID
	 * @return
	 */
	public static String getCityIdStr(){
		return SPUtil.getString(MyApplication.gameActivity, "locatedCityId", "");
	}

	/**
	 * 获取城市
	 * @return
     */
	public static String getCity(){
		return SPUtil.getString(MyApplication.gameActivity, "locatedCityName", "");
	}

	// 百人牛牛
	/**
	 * 百人牛牛需要传的code参数
	 * @return
     */
	public static String getGameCode(){
		if(MyApplication.getGameCode == null){
			return "";
		}
		return MyApplication.getGameCode;
	}


	/**
	 * 游戏跟踪
	 * @param back
     */
	public static void LuaMobClick(String back){

	}

	/**
	 * 获取原生版本号
	 * @return
     */
	public static String getAppVersion(){
		return AppUpdateUtil.getVersionName(MyApplication.gameActivity);
	}
	
	// 原生调lua

	/**
	 * 通知报名比赛
	 */
	public static void applyGameAwardPool(){
		//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("callbackLua", "applyGameAwardPool");
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"applyGameAwardPool");
	}
	
	/**
	 * 通知报名比赛结束
	 */
	public static void endGameAwardPool(){
		//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("callbackLua", "endGameAwardPool");
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"endGameAwardPool");
	}
	
	/**
	 * 更新金币（在游戏充值时，跳转到充值页面，充值成功后调此方法）
	 */
	public static void goldUpdate(){
		//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("callbackLua", "goldUpdate");
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"goldUpdate");
	}

	/**
	 * 显示loading
	 */
	public static void showLoading(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"showLoading");
	}

	/**
	 * 隐藏loading
	 */
	public static void hideLoading(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"hideLoading");
	}

	/**
	 * 通知登录完成
	 */
	public static void loginsuccess(){

//		SPUtil.setInt(MyApplication.gameActivity,"canHide",1);
//
//		MyApplication.gameActivity.runOnUiThread(new Runnable() {
//			@Override
//			public void run() {
//				PublicViews.HideLoading();
//				PublicViews.HideChangeAccountDialog();
//			}
//		});

		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"loginSuccess");
	}

	/**
	 * 通知登录失败
	 */
	public static void loginFail(){

		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"loginFail");

//		MyApplication.gameActivity.runOnUiThread(new Runnable() {
//			@Override
//			public void run() {
//				PublicViews.HideLoading();
//
//				PublicViews.ShowChangeAccountDialog();
//
//				ToastUtil.showBaseToast(MyApplication.gameActivity,"登录失败");
//			}
//		});

	}

	/**
	 * 通知充值成功
	 */
	public static void rechargeSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"rechargeSuccess");
	}

	/**
	 * 通知充值失败
	 */
	public static void rechargeFail(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle,"rechargeFail");
	}

	/**
	 * 开启直播
	 */
	public static void startLive(final int startX, final int startY, final int width, final int height) {
//		mainActivity.startLive();
		final Activity activity = AppUtils.getInstance().getTopActivity();
		if (activity instanceof GameActivity) {
			((GameActivity) activity).startLive(startX, startY, width, height, new GameActivity.LiveCallBack() {
				@Override
				public void onSuccess(final String response) {
					startLiveReturnData = response;
					Log.i("abc", startLiveReturnData);
				}

				@Override
				public void onError(String response) {
//					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, response);
				}
			});
		} else {
			//没有进入游戏，不能开启直播
			LiveResponse liveResponse = new LiveResponse();
			liveResponse.setReturnCode(DouyouConstants.LIVE_FAILED);
			liveResponse.setCommand(DouyouConstants.COMMAND_START_LIVE);
			liveResponse.setErrorMessage("进入游戏才能开启直播");
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, "[[" + JSONUtils.obj2Json(liveResponse) + "]]");
		}
	}

	public static String getStartLiveData() {
		return startLiveReturnData;
	}

	public static void resetStartLiveData() {
		startLiveReturnData = null;
	}

	/**
	 * 关闭直播
	 */
	public static void stopLive() {
		Activity activity = AppUtils.getInstance().getTopActivity();
		if (activity instanceof GameActivity) {
			((GameActivity) activity).stopLive();

		} else {
			//没有进入游戏，不能停止直播
			LiveResponse liveResponse = new LiveResponse();
			liveResponse.setReturnCode(DouyouConstants.LIVE_FAILED);
			liveResponse.setCommand(DouyouConstants.COMMAND_STOP_LIVE);
			liveResponse.setErrorMessage("进入游戏才能关闭直播");
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, "[[" + JSONUtils.obj2Json(liveResponse) + "]]");
		}
	}

	/**
	 * 观看直播
	 */
	public static void playLive(final int startX, final int startY, final int width, final int height, final String playAddress, final String decodeType) {
		Activity activity = AppUtils.getInstance().getTopActivity();
		if (activity instanceof GameActivity) {
			((GameActivity) activity).playLive(startX, startY, width, height, playAddress, decodeType, new GameActivity.LiveCallBack() {
				@Override
				public void onSuccess(String response) {
//					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, response);
				}

				@Override
				public void onError(String response) {
//					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, response);
				}
			});
		} else {
			//没有进入游戏，不能观看直播
//			LiveResponse liveResponse = new LiveResponse();
//			liveResponse.setReturnCode(DouyouConstants.LIVE_FAILED);
//			liveResponse.setCommand(DouyouConstants.COMMAND_PLAY_LIVE);
//			liveResponse.setErrorMessage("进入游戏才能观看直播");
//			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, "[[" + JSONUtils.obj2Json(liveResponse) + "]]");
		}
	}

	/**
	 * 停止观看直播
	 */
	public static void stopPlayLive() {
		Activity activity = AppUtils.getInstance().getTopActivity();
		if (activity instanceof GameActivity) {
			((GameActivity) activity).stopPlayLive();
		} else {
			//没有进入游戏，不能停止观看直播
//			LiveResponse liveResponse = new LiveResponse();
//			liveResponse.setReturnCode(DouyouConstants.LIVE_FAILED);
//			liveResponse.setCommand(DouyouConstants.COMMAND_STOP_PLAY_LIVE);
//			liveResponse.setErrorMessage("进入游戏才能停止观看直播");
//			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackVideoHandle, "[[" + JSONUtils.obj2Json(liveResponse) + "]]");
		}
	}

	public static void showAlert(){

	}

	/**
	 * 微信分享
     */
	public static void share(final String channel, final String title, final String url, final String shareType, final String desc){

		MyApplication.gameActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {

				int scene = WXPublicMethod.WXSceneSession;
				if (channel.equals("pyq")){
					scene = WXPublicMethod.WXSceneTimeline;
				}
				SPUtil.setInt(MyApplication.gameActivity, "WXSceneSession", scene);

				if (shareType.equals("url")){
					WXPublicMethod.SendUrl(MyApplication.gameActivity, title, desc, url, scene);
				}else if (shareType.equals("pic")){
					captureScreen_success(url);
				}else if (shareType.equals("screen")){
					ScreenShot();
				}

			}
		});

	}

	/**
	 * 通知分享成功
	 */
	public static void shareSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "shareSuccess");
	}

	/**
	 * 通知分享取消
	 */
	public static void shareCancel(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "shareCancel");
	}

	public static int getSendCardCount(){
		int sendCardCount = SPUtil.getCurrentUser(MyApplication.gameActivity).getSendCardCount();
//		SPUtil.getCurrentUser(MyApplication.gameActivity).setSendCardCount(0);
		DouyouUser douyouUser = SPUtil.getCurrentUser(MyApplication.gameActivity);
		douyouUser.setSendCardCount(0);
		FinalDb finalDb = FinalDb.create(MyApplication.gameActivity);
		finalDb.update(douyouUser, String.format("userId=%s", SPUtil.getCurrentUserId(MyApplication.gameActivity)));
		return sendCardCount;
	}

	public static int getCardCount(){
		int cardCount = SPUtil.getCurrentUser(MyApplication.gameActivity).getCardCount();
		return cardCount;
	}

	/**
	 * 注册lua截屏事件
	 * @param tipInfo
	 * @param luaFuction
	 */
	public static void callbackLuaCap(final String tipInfo, final int luaFuction){
		SPUtil.setInt(MyApplication.gameActivity, "luaScreenShot", luaFuction);
	}

	/**
	 * lua截屏
	 */
	public static void ScreenShot(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(SPUtil.getInt(MyApplication.gameActivity, "luaScreenShot"), "");
	}

	/**
	 * lua截屏成功返回图片路径
	 * @param path
	 */
	public static void captureScreen_success(final String path){
		String newPath = "";
		try {
			newPath = BitmapUtil.CopyGameScreenPic(path);
			WXPublicMethod.SendlocalImage(MyApplication.gameActivity, newPath, SPUtil.getInt(MyApplication.gameActivity, "WXSceneSession"));
		} catch (IOException e) {
			e.printStackTrace();

			ToastUtil.showBaseToast(MyApplication.gameActivity, "分享出错");
		}
	}

	/**
	 * 显示视频录像区域
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * @param activityId
	 */
	public static void showRecordFrame(final String x, final String y, final String width, final String height, final String activityId){

		Log.d("x",x);
		Log.d("y",y);
		Log.d("width",width);
		Log.d("height",height);
		Log.d("activityId",activityId);

		// 设置当前使用什么模式去发送语音和视频，1是呀呀，2是lua
		SPUtil.setString(MyApplication.gameActivity, "sendMode", x);

		if ("-1".equals(activityId)){
			// 录音

			MyApplication.gameActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					YaYaVoiceUtil.startRecord();
				}
			});

		}else if ("-2".equals(activityId)){
			// 结束录音

			MyApplication.gameActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					YaYaVoiceUtil.stopReord();
				}
			});

		}else if ("-3".equals(activityId)){
			// 取消录音

			MyApplication.gameActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					YaYaVoiceUtil.cancelReord();
				}
			});

		}else{

			// 录制视频
			MyApplication.gameActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					MyApplication.ly_record.setVisibility(View.VISIBLE);
				}
			});

		}

	}

	/**
	 * 注册从原生获取数据事件
	 * @param a
	 * @param luaFuction
	 */
	public static void callbackLuaForDict(final String a, final int luaFuction){
		SPUtil.setInt(MyApplication.gameActivity, "callbackLuaForDict", luaFuction);
	}

	/**
	 * 返回本地经纬度
	 */
	public static void setLocation(){

		JSONObject object = new JSONObject();
		try {
			object.put("type","setLocation");
			object.put("Longitude", SPUtil.getString(MyApplication.gameActivity, "Longitude"));
			object.put("Latitude", SPUtil.getString(MyApplication.gameActivity, "Latitude"));
		} catch (JSONException e) {
			e.printStackTrace();
		}
		JSONArray backdata_arr = new JSONArray();
		backdata_arr.put(object);

		JSONArray json = new JSONArray();
		json.put(backdata_arr);

//		Toast.makeText(MyApplication.gameActivity, backdata_arr.toString(), Toast.LENGTH_SHORT).show();

		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(SPUtil.getInt(MyApplication.gameActivity, "callbackLuaForDict"), json.toString());

	}

	/**
	 * 通知录制完毕
	 */
	public static void recordDidClose(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(SPUtil.getInt(MyApplication.gameActivity, "callbackLuaForDict"),"recordDidClose");
	}

	/**
	 * 注册回调视频链接
	 * @param tipInfo
	 * @param luaFuction
	 */
	public static void setVideoAddr(final String tipInfo, final int luaFuction){
		SPUtil.setInt(MyApplication.gameActivity, "setVideoAddr", luaFuction);
	}

	/**
	 * 返回视频链接到lua
	 * @param path
	 */
	public static void callBackVideoPath(final String path){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(SPUtil.getInt(MyApplication.gameActivity, "setVideoAddr"), path);
	}

	/**
	 * 注册回调返回按钮点击事件
	 * @param tipInfo
	 * @param luaFuction
	 */
	public static void backClick(final String tipInfo, final int luaFuction){
		SPUtil.setInt(MyApplication.gameActivity, "backClick", luaFuction);
	}

	/**
	 * 返回视频链接到lua
	 * @param click
	 */
	public static void callBackBackClick(final String click){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(SPUtil.getInt(MyApplication.gameActivity, "backClick"), click);
	}

	/**
	 * 通知本地进入游戏房间
	 * @param roomId
     */
	public static void LoginRoom(final String roomId){

		if (roomId != null && !"".equals(roomId)){

			Log.d("-----进入房间-----", "房间号:" + roomId);

			// 记录当前游戏不在大厅
			SPUtil.setInt(MyApplication.gameActivity, "nowInHall", 0);

			// 记录进入的房间号
			SPUtil.setString(MyApplication.gameActivity, "roomId", roomId);

			// 清空魔窗链接记录
			SPUtil.setString(MyApplication.gameActivity, "mLinkhost", "");
			SPUtil.setString(MyApplication.gameActivity, "mLinkInvitationCode", "");
			SPUtil.setString(MyApplication.gameActivity, "mLinkActivityId", "");
			SPUtil.setString(MyApplication.gameActivity, "mLinkLevel", "");

			// 呀呀语音进入房间
			YaYaVoiceUtil.LoginRoom(roomId);

		}

	}

	/**
	 * 通知呀呀进入房间成功
	 */
	public static void YaYaLoginRoomSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "YaYaLoginRoomSuccess");
	}

	/**
	 * 通知本地退出游戏房间
	 */
	public static void LogoutRoom(){

		// 置空房间号
		SPUtil.setString(MyApplication.gameActivity, "roomId", "");

		// 呀呀语音退出房间
		YaYaVoiceUtil.LogoutRoom();

	}

	/**
	 * 通知呀呀退出房间成功
	 */
	public static void YaYaLogoutRoomSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "YaYaLogoutRoomSuccess");
	}

	/**
	 * 上麦
	 */
	public static void micUp(){
		YaYaVoiceUtil.micUp();
	}

	/**
	 * 通知上麦成功
	 */
	public static void micUpSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "micUpSuccess");
	}

	/**
	 * 下麦
	 */
	public static void micDown(){
		YaYaVoiceUtil.micDown();
	}

	/**
	 * 通知下麦成功
	 */
	public static void micDownSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "micDownSuccess");
	}

	/**
	 * 调用ping++支付
	 */
	public static void payWithPing(final String data){
		PayUtils.PayWithPing(MyApplication.gameActivity, data);
	}

	/**
	 * 支付成功
	 */
	public static void payRoomCardSuccess(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "payRoomCardSuccess");
	}

	/**
	 * 支付失败
	 */
	public static void payRoomCardFail(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "payRoomCardFail");
	}

	/**
	 * 支付取消
	 */
	public static void payRoomCardCancel(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "payRoomCardCancel");
	}

	/**
	 * 支付控件无效
	 */
	public static void payRoomCardInvalid(){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "payInvalid");
	}

	/**
	 * lua通知本地进入了大厅
	 */
	public static synchronized void nowInHall(){

		SPUtil.setInt(MyApplication.gameActivity, "nowInHall", 1);

		// 置空本地记录的房间号
		SPUtil.setString(MyApplication.gameActivity, "roomId", "");

		joinGame();

	}

	/**
	 * 通知lua进入组局
	 */
	public static synchronized void joinGame(){

		// 判断当前是否有需要进入的组局
		String host = SPUtil.getString(MyApplication.gameActivity, "mLinkhost");
		if (host != null && "groupgame".equals(host)){
			String mLinkInvitationCode = SPUtil.getString(MyApplication.gameActivity, "mLinkInvitationCode");
			if (mLinkInvitationCode != null && !mLinkInvitationCode.equals("")){
				JSONObject object = new JSONObject();
				try {

					object.put("type", "game");

					JSONObject gameInfo = new JSONObject();
					gameInfo.put("invitationCode", SPUtil.getString(MyApplication.gameActivity, "mLinkInvitationCode"));
					gameInfo.put("activityId", SPUtil.getString(MyApplication.gameActivity, "mLinkActivityId"));
					gameInfo.put("level", SPUtil.getString(MyApplication.gameActivity, "mLinkLevel"));

					object.putOpt("gameInfo", gameInfo);

					String gameInfo_str = object.toString();
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, gameInfo_str);

					// 清空魔窗链接记录
					SPUtil.setString(MyApplication.gameActivity, "mLinkhost", "");
					SPUtil.setString(MyApplication.gameActivity, "mLinkInvitationCode", "");
					SPUtil.setString(MyApplication.gameActivity, "mLinkActivityId", "");
					SPUtil.setString(MyApplication.gameActivity, "mLinkLevel", "");

				} catch (JSONException e) {
					e.printStackTrace();
				}

			}
		}
	}

	// 返回数据到lua
	public static void sendDataToLua(String type, JSONObject data){

		JSONObject object = new JSONObject();
		try {

			object.put("type", type);
			object.putOpt("data", data);

			String gameInfo_str = object.toString();
			try{
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, gameInfo_str);
			}catch (Exception e){

			}

		} catch (JSONException e) {
			e.printStackTrace();
		}

	}
	//是否在录音
	public static int getVoiceIsRecording(){
		if(YayaLiteIM.getInstance().isRecording()){
			return 1;
		}else{
			return 0;
		}

	}
	//是否在播放
	public static int getVoiceIsPlaying(){
		if(YayaLiteIM.getInstance().isPlaying()){
			return 1;
		}else{
			return 0;
		}

	}

	public static void isStartVoice(String fling){
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, fling);
	}

	// 播放录音
	public static void playVoice(String json){

		String url = "";
		try {
			JSONObject obj = new JSONObject(json);
			url = obj.getString("url");
		} catch (JSONException e) {
			e.printStackTrace();
		}

		if ("".equals(url)){
			Toast.makeText(MyApplication.gameActivity, "录音地址有误哦！", Toast.LENGTH_SHORT).show();
			return;
		}

		Log.d("-----playVoice-----",url);
		YayaLiteIM.getInstance().startPlayVoiceByUrl(url, null, new PlayListener() {
			@Override
			public void onPlayStart() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "playing");
				//Toast.makeText(MyApplication.gameActivity, "开始播放", Toast.LENGTH_SHORT).show();
			}

			@Override
			public void onPlayComplete() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackHandle, "playfinish");
				//Toast.makeText(MyApplication.gameActivity, "播放结束", Toast.LENGTH_SHORT).show();
			}

			@Override
			public void onPlayException(int i, String s) {
				Toast.makeText(MyApplication.gameActivity, s, Toast.LENGTH_SHORT).show();
			}
		});
		/*String voicePath = YaYaVoiceUtil.getVoiceFolder() + "/" + new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()) + "_voice.amr";
		final File f = new File(voicePath);
		if (f.exists()) {
			f.delete();
		}
		FinalHttp fh = new FinalHttp();
		fh.download(url, voicePath, new AjaxCallBack<File>(){

			@Override
			public void onStart() {
				super.onStart();
			}

			@Override
			public void onLoading(long count, long current) {
				super.onLoading(count, current);
			}

			@Override
			public void onSuccess(final File t) {
				super.onSuccess(t);
				if (t != null){
					try {

						// 停止正在播的录音
						YayaLiteIM.getInstance().stopPlayVoice();

						// 播放新录音
						YayaLiteIM.getInstance().startPlayVoice(t.getAbsoluteFile().toString(), new PlayListener() {
							@Override
							public void onPlayStart() {
								Log.d("-----YayaLiteIM-----", "onPlayStart: ");
							}

							@Override
							public void onPlayComplete() {
								Log.d("-----YayaLiteIM-----", "onPlayComplete: ");
							}

							@Override
							public void onPlayException(int i) {
								Log.d("-----YayaLiteIM-----", "onPlayException: ");
							}
						});

					} catch (FileNotFoundException e) {
						e.printStackTrace();
					}
				}else {
					Toast.makeText(MyApplication.gameActivity, "录音文件有误", Toast.LENGTH_SHORT).show();
				}
			}

			@Override
			public void onFailure(Throwable t, int errorNo,String strMsg) {
				super.onFailure(t, errorNo, strMsg);
				Toast.makeText(MyApplication.gameActivity, "下载录音失败", Toast.LENGTH_SHORT).show();
			}

		});*/

	}

	// 播放视频
	public static void playVideo(String json){

		String url = "";
		try {
			JSONObject obj = new JSONObject(json);
			url = obj.getString("url");
		} catch (JSONException e) {
			e.printStackTrace();
		}

		if ("".equals(url)){
			return;
		}

		Log.d("-----playVideo-----",url);

		String videoPath = YaYaVoiceUtil.getVoiceFolder() + "/" + new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()) + "_video.mp4";
		final File f = new File(videoPath);
		if (f.exists()) {
			f.delete();
		}
		FinalHttp fh = new FinalHttp();
		fh.download(url, videoPath, new AjaxCallBack<File>(){

			@Override
			public void onStart() {
				super.onStart();
			}

			@Override
			public void onLoading(long count, long current) {
				super.onLoading(count, current);
			}

			@Override
			public void onSuccess(final File t) {
				super.onSuccess(t);
				if (t != null){
					if (MyApplication.isInGame){
						if (MyApplication.gameActivity.videoList == null) {
							MyApplication.gameActivity.videoList = new ArrayList<String>();
						}
						MyApplication.gameActivity.videoList.add(t.getAbsoluteFile().toString());
						if (!MyApplication.gameActivity.player.isPlaying()){
							// 假如当前没有视频在播放，那播放视频
							MyApplication.gameActivity.play();
						}
					}else {
						Toast.makeText(MyApplication.gameActivity, "视频文件有误", Toast.LENGTH_SHORT).show();
					}
				}
			}

			@Override
			public void onFailure(Throwable t, int errorNo,String strMsg) {
				super.onFailure(t, errorNo, strMsg);
				Toast.makeText(MyApplication.gameActivity, "下载视频失败", Toast.LENGTH_SHORT).show();
			}

		});

	}

	// 获取系统电量
	public static String getPhonePower(){
		return MyApplication.power + "";
	}

	// 获取手机当前ip地址
	public static String getIPAddress(){

		NetworkInfo info = ((ConnectivityManager) MyApplication.gameActivity.getSystemService(Context.CONNECTIVITY_SERVICE)).getActiveNetworkInfo();
		if (info != null && info.isConnected()) {
			if (info.getType() == ConnectivityManager.TYPE_MOBILE) {//当前使用2G/3G/4G网络

				try {

					//Enumeration<NetworkInterface> en=NetworkInterface.getNetworkInterfaces();
					for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
						NetworkInterface intf = en.nextElement();
						for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
							InetAddress inetAddress = enumIpAddr.nextElement();
							if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
								JSONObject object = new JSONObject();
								object.put("network", "mobile");
								object.put("ip", inetAddress.getHostAddress());
								return object.toString();
							}
						}
					}

				} catch (SocketException e) {
					e.printStackTrace();
					return "";
				} catch (JSONException e) {
					e.printStackTrace();
					return "";
				}

			} else if (info.getType() == ConnectivityManager.TYPE_WIFI) {

				//当前使用无线网络
				WifiManager wifiManager = (WifiManager) MyApplication.gameActivity.getSystemService(Context.WIFI_SERVICE);
				WifiInfo wifiInfo = wifiManager.getConnectionInfo();
				String ipAddress = intIP2StringIP(wifiInfo.getIpAddress());//得到IPV4地址
				JSONObject object = new JSONObject();
				try {
					object.put("network", "wifi");
					object.put("ssid", wifiInfo.getSSID());
					object.put("ip", ipAddress);
				} catch (JSONException e) {
					e.printStackTrace();
					return "";
				}
				return object.toString();

			}

		} else {

			//当前无网络连接,请在设置中打开网络
			return "";

		}

		return "";
	}

	/**
	 * 将得到的int类型的IP转换为String类型
	 * @param ip
	 * @return
	 */
	public static String intIP2StringIP(int ip) {
		return (ip & 0xFF) + "." + ((ip >> 8) & 0xFF) + "." + ((ip >> 16) & 0xFF) + "." + (ip >> 24 & 0xFF);
	}

}
