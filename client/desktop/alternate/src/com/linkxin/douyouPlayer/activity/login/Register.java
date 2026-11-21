package com.linkxin.douyouPlayer.activity.login;


import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.Toast;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.Logger;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;

import org.json.JSONObject;

import java.util.Date;
import java.util.Map;

public class Register {

    private static final String TAG = "Register";
    private Context context;
    private BaseActivity activity;

    public Register(BaseActivity activity) {
        this.activity = activity;
        this.context = activity;
    }

    public Register(Context context) {
        this.context = context;
    }

//    /**
//     * 快速注册(登录失败登录框不能隐藏)
//     */
//    public void quickRegistWithOutLoading() {
//
//        FinalHttpClient.getInstance().post(RequestURL.QUICK_REGISTER_URL, new FinalHttpClient.OnRequestListener() {
//
//            @Override
//            public void onFinish(JsonResponse response) {
//                // TODO Auto-generated method stub
//
//                if (response.isSuccess()) {
//                    //直接登录
//                    try {
//                        JSONObject json = new JSONObject(response.getData());
//                        final String phone = json.getString("phone");
//                        final String password = json.getString("password");
//                        if (TextUtils.isEmpty(phone) || TextUtils.isEmpty(password)) {
//                            LuaJavaBridgeTest.loginFail();
//                        } else {
//                            SPUtil.setLong(context, DouyouConstants.KEY_LAST_REGISTER_TIME, new Date().getTime());
//                            final Login login = new Login(MyApplication.gameActivity);
//                            login.loginDouyou(phone,password,true,new FinalHttpClient.OnRequestListener() {
//                                @Override
//                                public void onFinish(JsonResponse response) {
//
//                                    if (response.isSuccess()) {
//                                        DouyouUser user = response.readObject(DouyouUser.class);
//
//                                        if (user == null) {
//                                            LuaJavaBridgeTest.loginFail();
//                                            return;
//                                        }
//
//                                        login.handleLogin(phone, password, user, false,MyApplication.gameActivity);
//                                        LuaJavaBridgeTest.loginsuccess();
//
//                                    } else {
//                                        LuaJavaBridgeTest.loginFail();
//                                    }
//                                }
//                            });
//                        }
//                    } catch (Exception e) {
//                        Logger.e(TAG, e.getLocalizedMessage());
//                        LuaJavaBridgeTest.loginFail();
//                    }
//                } else {
//                    Logger.e(TAG, response.getError());
//                    LuaJavaBridgeTest.loginFail();
//                }
//            }
//        });
//    }

//    /**
//     * 快速注册(登录框能隐藏)
//     */
//    public void quickRegist() {
//
//        FinalHttpClient.getInstance().post(RequestURL.QUICK_REGISTER_URL, new FinalHttpClient.OnRequestListener() {
//
//            @Override
//            public void onFinish(JsonResponse response) {
//                // TODO Auto-generated method stub
//
//                if (response.isSuccess()) {
//                    //直接登录
//                    try {
//                        JSONObject json = new JSONObject(response.getData());
//                        final String phone = json.getString("phone");
//                        final String password = json.getString("password");
//                        if (TextUtils.isEmpty(phone) || TextUtils.isEmpty(password)) {
//                            LuaJavaBridgeTest.loginFail();
//                        } else {
//                            SPUtil.setLong(context, DouyouConstants.KEY_LAST_REGISTER_TIME, new Date().getTime());
//                            final Login login = new Login(MyApplication.gameActivity);
//                            login.loginDouyou(phone,password,true,new FinalHttpClient.OnRequestListener() {
//                                @Override
//                                public void onFinish(JsonResponse response) {
//
//                                    if (response.isSuccess()) {
//                                        DouyouUser user = response.readObject(DouyouUser.class);
//
//                                        if (user == null) {
//                                            LuaJavaBridgeTest.loginFail();
//                                            return;
//                                        }
//
//                                        login.handleLogin(phone, password, user, false,MyApplication.gameActivity);
//                                        LuaJavaBridgeTest.loginsuccess();
//
//                                    } else {
//                                        LuaJavaBridgeTest.loginFail();
//                                    }
//                                }
//                            });
//                        }
//                    } catch (Exception e) {
//                        Logger.e(TAG, e.getLocalizedMessage());
//                        LuaJavaBridgeTest.loginFail();
//                    }
//                } else {
//                    Logger.e(TAG, response.getError());
//                    LuaJavaBridgeTest.loginFail();
//                }
//            }
//        });
//    }

    /**
     * 第三方账户快速注册
     */
    public void thirdPartyQuickRegist(Map<String, String> source) {
        FinalHttpClient.getInstance().post(RequestURL.QUICK_REGISTER_URL, source, new FinalHttpClient.OnRequestListener() {

            @Override
            public void onFinish(JsonResponse response) {
                // TODO Auto-generated method stub
                if (response.isSuccess()) {

                    // 快速注册成功

                    // 直接登录
                    try {
                        JSONObject json = new JSONObject(response.getData());
                        final String phone = json.getString("phone");
                        final String password = json.getString("password");
                        if (TextUtils.isEmpty(phone) || TextUtils.isEmpty(password)) {
                            // 账号异常，登录失败
                            LuaJavaBridgeTest.loginFail();
                        } else {
                            // 第三方账号登录
                            MyApplication.userAccount = phone;
//                            new Login(MyApplication.gameActivity).loginDouyouInThirdParty(phone, password, true);
                        }
                    } catch (Exception e) {
                        Logger.e(TAG, e.getLocalizedMessage());
                        LuaJavaBridgeTest.loginFail();
                    }
                } else {
                    Logger.e(TAG, response.getError());
                    LuaJavaBridgeTest.loginFail();
                }
            }
        });
    }

    /**
     * 第三方账户快速注册(微信)
     */
    public void thirdPartyQuickRegist_WX(Map<String, String> source, final Activity activity) {
        FinalHttpClient.getInstance().post(RequestURL.QUICK_REGISTER_URL, source, new FinalHttpClient.OnRequestListener() {

            @Override
            public void onFinish(JsonResponse response) {
                // TODO Auto-generated method stub
                if (response.isSuccess()) {

                    // 快速注册成功

                    // 直接登录
                    try {
                        JSONObject json = new JSONObject(response.getData());
                        final String phone = json.getString("phone");
                        final String password = json.getString("password");
                        if (TextUtils.isEmpty(phone) || TextUtils.isEmpty(password)) {
                            // 账号异常，登录失败

                            Toast.makeText(context, "平台账号信息解析异常2" , Toast.LENGTH_SHORT).show();

                            LuaJavaBridgeTest.loginFail();
                            activity.finish();

                        } else {
                            // 第三方账号登录
                            MyApplication.userAccount = phone;
                            new Login(MyApplication.gameActivity).loginDouyouInThirdParty_WX(phone, password, true, activity);
                        }
                    } catch (Exception e) {
                        Logger.e(TAG, e.getLocalizedMessage());
                        LuaJavaBridgeTest.loginFail();
                        activity.finish();
                    }
                } else {
                    Logger.e(TAG, response.getError());
                    LuaJavaBridgeTest.loginFail();
                    activity.finish();
                }
            }
        });
    }

}
