package com.linkxin.douyouPlayer.activity.login;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.util.Logger;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.Md5Util;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.vo.DouyouUser;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 登录相关
 * Created by lxy on 2016/5/26.
 */
public class Login {

    private static final String TAG = "Login";
    private static final int DELAY_TIME = 3000;
    private Context context;
    private BaseActivity activity;
    private boolean isAutoLoagin = false;

    public Login(BaseActivity activity) {
        this.activity = activity;
        this.context = activity;
    }

    public Login(Context context) {
        this.context = context;
    }

//    /**
//     * 自动登录
//     */
//    public void autoLogin(){
//
//        isAutoLoagin = true;
//
//        final String username = SPUtil.getString(context, SPUtil.SP_USERNAME);
//        final String password = SPUtil.getString(context, SPUtil.SP_PASSWORD);
//
//        loginDouyou(username, password, true, new FinalHttpClient.OnRequestListener() {
//            @Override
//            public void onFinish(JsonResponse response) {
//                if (response.isSuccess()) {
//                    DouyouUser user = response.readObject(DouyouUser.class);
//                    if (user == null) {
//                        return;
//                    }
//
//                    handleLogin(username,password,user,false,MyApplication.gameActivity);
//                }else {
//
//                }
//            }
//        });
//    }
//
//    /**
//     * 显式登录
//     * @param username
//     * @param password
//     */
//    public void loginDouyou(final String username,final String password){
//        isAutoLoagin = false;
//        if (TextUtils.isEmpty(username)) {
//            activity.shortToast("请输入手机号码");
//            return;
//        }
//
//        if (TextUtils.isEmpty(password)) {
//            activity.shortToast("请输入登录密码");
//            return;
//        }
//        activity.showLoading();
//        loginDouyou(username, password, true, new FinalHttpClient.OnRequestListener() {
//            @Override
//            public void onFinish(JsonResponse response) {
//                if (response.isSuccess()) {
//                    DouyouUser user = response.readObject(DouyouUser.class);
//
//                    if (user == null) {
//                        activity.hideLoading();
//                        handleLoginError("系统异常，请稍后重试!");
//                        return;
//                    }
//                    try{
//                        handleLogin(username,password,user,false,MyApplication.gameActivity);
//                        loginEMChat(username, password, true);
//                    } catch (Exception e) {
//                        Logger.e(TAG, e.getLocalizedMessage());
//                        handleLoginError("用户登录失败");
//                    }
//                }else {
//                    handleLoginError(response.getError());
//                }
//            }
//        });
//    }
//
//    /**
//     * 第三方登录
//     * @param username
//     * @param password
//     */
//    public void loginDouyouInThirdParty(final String username,final String password, final boolean isNeedMD5){
//
//        if (TextUtils.isEmpty(username)) {
//            LuaJavaBridgeTest.loginFail();
//            return;
//        }
//
//        if (TextUtils.isEmpty(password)) {
//            LuaJavaBridgeTest.loginFail();
//            return;
//        }
//
//        loginDouyou(username, password, isNeedMD5, new FinalHttpClient.OnRequestListener() {
//            @Override
//            public void onFinish(JsonResponse response) {
//
//                PublicViews.HideChangeAccountDialog();
//
//                if (response.isSuccess()) {
//                    DouyouUser user = response.readObject(DouyouUser.class);
//
//                    if (user == null) {
//                        LuaJavaBridgeTest.loginFail();
//                        return;
//                    }
//
//                    handleLogin(username,password,user,true,MyApplication.gameActivity);
//                    LuaJavaBridgeTest.loginsuccess();
//
//                }else {
//                    LuaJavaBridgeTest.loginFail();
//                }
//            }
//        });
//    }

    /**
     * 第三方登录(微信)
     * @param username
     * @param password
     * @param isNeedMD5
     * @param activity
     */
    public void loginDouyouInThirdParty_WX(final String username, final String password, final boolean isNeedMD5, final Activity activity){

        if (TextUtils.isEmpty(username)) {

            Toast.makeText(context, "平台用户不存在，登录失败" , Toast.LENGTH_SHORT).show();

            activity.finish();
            LuaJavaBridgeTest.loginFail();
            return;
        }

        if (TextUtils.isEmpty(password)) {

            Toast.makeText(context, "平台用户账号，登录失败" , Toast.LENGTH_SHORT).show();

            activity.finish();
            LuaJavaBridgeTest.loginFail();
            return;
        }

        loginDouyou(username, password, isNeedMD5, activity, new FinalHttpClient.OnRequestListener() {
            @Override
            public void onFinish(JsonResponse response) {

                PublicViews.HideChangeAccountDialog();

                if (response.isSuccess()) {
                    DouyouUser user = response.readObject(DouyouUser.class);

                    if (user == null) {

                        Toast.makeText(context, "平台账号信息异常，登录失败" , Toast.LENGTH_SHORT).show();

                        LuaJavaBridgeTest.loginFail();
                        return;
                    }

                    handleLogin(username,password,user,true,activity);
                    LuaJavaBridgeTest.loginsuccess();

                }else {

                    Toast.makeText(context, "平台账号登录失败" , Toast.LENGTH_SHORT).show();

                    LuaJavaBridgeTest.loginFail();
                }

                activity.finish();
            }
        });
    }


    public void loginDouyou(String username, String password, boolean isNeedMD5, Activity activity, FinalHttpClient.OnRequestListener listener){
        Map<String, String> params = new HashMap<String, String>();
        params.put("phone", username);
        if (isNeedMD5) {
            // 密码MD5加密
            final String md5pw = Md5Util.MD5(password);
            params.put("password", md5pw);

        } else {
            params.put("password", password);
        }
        params.put("photo", SPUtil.getString(activity, "wxphoto", ""));
        params.put("nickname", SPUtil.getString(activity, "wxnickname", ""));
        params.put("gender", SPUtil.getString(activity, "wxsex", "2"));
        params.put("type", "P");
        params.put("device", "1");
        params.put("longitude", "0");
        params.put("latitude", "0");
        FinalHttpClient.getInstance().post(RequestURL.LOGIN_URL, params,listener);
    }

    public void handleLogin(final String username,final String password, DouyouUser user, boolean isThirdParty ,Context context){
        String userid = user.getUserId();
        MyApplication.token = user.getToken();
        MyApplication.userId = userid;
        MyApplication.userAccount = username;
        MyApplication.userCoinAmount = user.getCoinAmount();
        MyApplication.nickName = user.getNickName();
        MyApplication.phone = user.getPhone();
        MyApplication.photoUrl = user.getPhotoUrl();
        MyApplication.province = user.getProvince();
        MyApplication.town = user.getTown();
        MyApplication.sex = user.getSex();
        MyApplication.level = String.valueOf(user.getLevel());
        MyApplication.society = user.getSociety();
        MyApplication.societyId = user.getSocietyId();
        MyApplication.birthday = new Date(Long.parseLong(user.getBirthday()+""));
        MyApplication.bindCompereId = user.getBindCompereId();
        MyApplication.promoterId = user.getPromoterId();

        /**
         * 登录成功，保存用户登录信息
         */
        SPUtil.onLoginSuccess(context, username, password, user.getUserId(), user, isThirdParty);

    }

    /**
     * 登录环信
     * @param username
     * @param password
     */
    private void loginEMChat(final String username, String password, boolean isNeedMD5){
        if (isNeedMD5) {
            password = Md5Util.MD5(password);
        }
    }

    private void handleLoginError(String errorMessage) {
        return;
    }

    // 初始化用户好友信息
    private void initializeContacts() {

    }

    /**
     * 登录成功
     */
    private void onLoginSuccess(){

    }
    /**
     * 自动登录失败
     * @param sleepTimes
     */
    private void onLoginFail(long sleepTimes){
        //等待sleeptime时长
        if (sleepTimes > 0) {
            try {
                Thread.sleep(sleepTimes);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        activity.defaultFinish();
    }

}
