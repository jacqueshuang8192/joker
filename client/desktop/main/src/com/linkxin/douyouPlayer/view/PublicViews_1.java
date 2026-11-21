package com.linkxin.douyouPlayer.view;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.login.Login;
import com.linkxin.douyouPlayer.activity.login.Register;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.http.AccessTokenKeeper;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.http.SinaWBPublicMethod;
import com.linkxin.douyouPlayer.http.WXPublicMethod;
import com.linkxin.douyouPlayer.util.Logger;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.sina.weibo.sdk.auth.AuthInfo;
import com.sina.weibo.sdk.auth.Oauth2AccessToken;
import com.sina.weibo.sdk.auth.WeiboAuthListener;
import com.sina.weibo.sdk.auth.sso.SsoHandler;
import com.sina.weibo.sdk.exception.WeiboException;
import com.tencent.connect.UserInfo;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;
import android.content.Context;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class PublicViews {

    // 窗口管理器
    private static WindowManager wm;
    private static WindowManager.LayoutParams param;

    // 全局loading
    private static View loading;
    private static boolean isloading;
    private static Timer timer;
    private static int i;

    // 新浪微博相关
    public static AuthInfo mAuthInfo;
    public static SsoHandler mSsoHandler;
    public static Oauth2AccessToken mAccessToken;

    // QQ相关
    private static Tencent mTencent;
    private static boolean isServerSideLogin = false;
    private static UserInfo mInfo;
    private Login login;
    private static String tencentOpenId;
    private static final int REGIST_MSG = 1;

    public static synchronized void ShowLoading(Context context) {

        // 判断当前是否已经显示
        if (loading != null) {

            // 重置计时器
            i = 10;
            timer.cancel();

            // 开始加载计时
            timer = new Timer();
            timer.schedule(new TimerTask() {
                // TimerTask 是个抽象类,实现的是Runable类
                @Override
                public void run() {
                    //定义一个消息传过去
                    Message msg = new Message();
                    msg.what = i--;
                    handler.sendMessage(msg);
                }
            }, 1000, 1000);

        } else {
            i = 10;

            // 初始化loading
            loading = LayoutInflater.from(context).inflate(R.layout.publicloading, null);

            // 添加loading
            wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            param = new WindowManager.LayoutParams();
            param.format = PixelFormat.RGBA_8888;

            wm.addView(loading, param);
            isloading = true;

            // 开始加载计时
            timer = new Timer();
            timer.schedule(new TimerTask() {
                // TimerTask 是个抽象类,实现的是Runable类
                @Override
                public void run() {
                    //定义一个消息传过去
                    Message msg = new Message();
                    msg.what = i--;
                    handler.sendMessage(msg);
                }
            }, 1000, 1000);
        }
    }

    public static synchronized void HideLoading() {
        if (loading != null) {
            wm.removeView(loading);
            loading = null;
            timer.cancel();
            isloading = false;
        }
    }

    // 定义Handler
    final static Handler handler = new Handler() {

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            //handler处理消息
            if (msg.what > 0) {

            } else {
                //在handler里可以更改UI组件
                if (loading != null) {
                    wm.removeView(loading);
                    loading = null;
                    timer.cancel();
                    isloading = false;
                }
            }
        }
    };

    // 橙色提示框
    private static View message_dialog;
    private static TextView dialog_title;
    private static TextView dialog_content;
    private static Button dialog_right_bt;
    private static TextView dialog_bt;
    private static boolean isshow;

    /**
     * 显示出错了提示框
     *
     * @param context
     * @param content
     */
    public static synchronized void ShowErrorDialog(Context context, String content) {
        ShowErrorDialog(context, content, null);
    }

    /**
     * 显示出错了提示框
     *
     * @param context
     * @param content
     */
    public static synchronized void ShowErrorDialog(Context context, String content, OnClickListener listener) {
        ShowDialog(context, "出错了", content, "知道了", listener);
    }

    /**
     * 显示提示框
     *
     * @param context
     * @param title
     * @param content
     * @param btshow
     * @param listener
     */
    public static synchronized void ShowDialog(Context context, String title, String content,
                                               String btshow, OnClickListener listener) {

        // 判断当前是否已经显示
        if (message_dialog != null) {

            // 设置显示内容
            dialog_title.setText(title);
            dialog_content.setText(content);

            // 设置按钮
            dialog_bt.setText(btshow);
            if (listener == null) {
                dialog_bt.setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        // TODO Auto-generated method stub
                        wm.removeView(message_dialog);
                        message_dialog = null;
                        isshow = false;
                    }
                });
            } else {
                dialog_bt.setOnClickListener(listener);
            }
            return;
        }

        // 初始化弹出框
        message_dialog = LayoutInflater.from(context).inflate(R.layout.dialog_error, null);
        dialog_title = (TextView) message_dialog.findViewById(R.id.title_tv);
        dialog_content = (TextView) message_dialog.findViewById(R.id.content_tv);
        dialog_bt = (Button) message_dialog.findViewById(R.id.sure_bt);

        // 添加弹出框
        wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        param = new WindowManager.LayoutParams();
        param.format = PixelFormat.RGBA_8888;

        wm.addView(message_dialog, param);
        isshow = true;

        // 设置显示内容
        dialog_title.setText(title);
        dialog_content.setText(content);

        // 设置按钮
        dialog_bt.setText(btshow);
        if (listener == null) {
            dialog_bt.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View v) {
                    // TODO Auto-generated method stub
                    wm.removeView(message_dialog);
                    message_dialog = null;
                    isshow = false;
                }
            });
        } else {
            dialog_bt.setOnClickListener(listener);
        }
    }

    /**
     * 显示确认提示框
     *
     * @param context
     * @param title
     * @param content
     * @param leftBtShow
     * @param rightBtShow
     * @param leftListener
     * @param rightListener
     */
    public static synchronized void ShowConfirmDialog(Context context, String title, String content,
                                                      String leftBtShow, String rightBtShow, OnClickListener leftListener, OnClickListener rightListener) {

        // 判断当前是否已经显示
        if (message_dialog != null) {
            // 设置显示内容
            dialog_title.setText(title);
            dialog_content.setText(content);

            // 设置按钮
            dialog_bt.setText(leftBtShow);
            if (leftListener == null) {
                dialog_bt.setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        // TODO Auto-generated method stub
                        wm.removeView(message_dialog);
                        message_dialog = null;
                        isshow = false;
                    }
                });
            } else {
                dialog_bt.setOnClickListener(leftListener);
            }
            dialog_right_bt.setText(rightBtShow);
            if (rightListener == null) {
                dialog_right_bt.setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        // TODO Auto-generated method stub
                        wm.removeView(message_dialog);
                        message_dialog = null;
                        isshow = false;
                    }
                });
            } else {
                dialog_right_bt.setOnClickListener(rightListener);
            }
            dialog_right_bt.setVisibility(View.VISIBLE);
            return;
        }

        // 初始化弹出框
        message_dialog = LayoutInflater.from(context).inflate(R.layout.dialog_error, null);
        dialog_title = (TextView) message_dialog.findViewById(R.id.title_tv);
        dialog_content = (TextView) message_dialog.findViewById(R.id.content_tv);
        dialog_right_bt = (Button) message_dialog.findViewById(R.id.right_bt);
        dialog_bt = (Button) message_dialog.findViewById(R.id.sure_bt);

        // 添加弹出框
        wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        param = new WindowManager.LayoutParams();
        param.format = PixelFormat.RGBA_8888;

        wm.addView(message_dialog, param);
        isshow = true;

        // 设置显示内容
        dialog_title.setText(title);
        dialog_content.setText(content);

        // 设置按钮
        dialog_bt.setText(leftBtShow);
        if (leftListener == null) {
            dialog_bt.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View v) {
                    // TODO Auto-generated method stub
                    wm.removeView(message_dialog);
                    message_dialog = null;
                    isshow = false;
                }
            });
        } else {
            dialog_bt.setOnClickListener(leftListener);
        }
        dialog_right_bt.setText(rightBtShow);
        if (rightListener == null) {
            dialog_right_bt.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View v) {
                    // TODO Auto-generated method stub
                    wm.removeView(message_dialog);
                    message_dialog = null;
                    isshow = false;
                }
            });
        } else {
            dialog_right_bt.setOnClickListener(rightListener);
        }
        dialog_right_bt.setVisibility(View.VISIBLE);
    }

    public static synchronized void hideDialog() {
        if (message_dialog != null) {
            wm.removeView(message_dialog);
        }
        message_dialog = null;
        isshow = false;
    }

    // 切换账号提示框
    private static View changeaccount_dialog;
    private static LinearLayout bg_ll;
    private static EditText name_et, code_et;
    private static ImageView forgetcode_iv, login_iv, regist_iv, weibo_iv, weixin_iv, qq_iv;

    /**
     * 显示切换账号提示框
     */
    public static synchronized void ShowChangeAccountDialog() {

        // 判断当前是否已经显示
        if (changeaccount_dialog != null) {
            return;
        }

        // 初始化弹出框
        changeaccount_dialog = LayoutInflater.from(MyApplication.gameActivity).inflate(R.layout.layout_changeaccount, null);
        bg_ll = (LinearLayout) changeaccount_dialog.findViewById(R.id.bg_ll);
        name_et = (EditText) changeaccount_dialog.findViewById(R.id.name_et);
        code_et = (EditText) changeaccount_dialog.findViewById(R.id.code_et);
        forgetcode_iv = (ImageView) changeaccount_dialog.findViewById(R.id.forgetcode_iv);
        login_iv = (ImageView) changeaccount_dialog.findViewById(R.id.login_iv);
        regist_iv = (ImageView) changeaccount_dialog.findViewById(R.id.regist_iv);
        weibo_iv = (ImageView) changeaccount_dialog.findViewById(R.id.weibo_iv);
        weixin_iv = (ImageView) changeaccount_dialog.findViewById(R.id.weixin_iv);
        qq_iv = (ImageView) changeaccount_dialog.findViewById(R.id.qq_iv);

        // 添加弹出框
        wm = (WindowManager) MyApplication.gameActivity.getSystemService(Context.WINDOW_SERVICE);
        param = new WindowManager.LayoutParams();
        param.format = PixelFormat.RGBA_8888;

        wm.addView(changeaccount_dialog, param);

        bg_ll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

                if(SPUtil.getInt(MyApplication.gameActivity,"canHide",0) == 1){
                    HideChangeAccountDialog();
                }

            }
        });

        forgetcode_iv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });

        // 登录按钮
        login_iv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

                final String username = name_et.getText().toString();
                if (username == null || "".equals(username)) {
                    ToastUtil.showBaseToast(MyApplication.gameActivity, "账号不能为空！");
                    return;
                }

                final String password = code_et.getText().toString();
                if (password == null || "".equals(password)) {
                    ToastUtil.showBaseToast(MyApplication.gameActivity, "密码不能为空！");
                    return;
                }

                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        HideChangeAccountDialog();

                        PublicViews.ShowLoading(MyApplication.gameActivity);

//                        final Login login = new Login(MyApplication.gameActivity);
//                        login.loginDouyou(username, password, true, new FinalHttpClient.OnRequestListener() {
//                            @Override
//                            public void onFinish(JsonResponse response) {
//
//                                if (response.isSuccess()) {
//
//                                    DouyouUser user = response.readObject(DouyouUser.class);
//
//                                    if (user == null) {
//                                        LuaJavaBridgeTest.loginFail();
//                                        return;
//                                    }
//
//                                    try {
//                                        PublicViews.HideChangeAccountDialog();
//                                        login.handleLogin(username, password, user, false,MyApplication.gameActivity);
//                                        LuaJavaBridgeTest.loginsuccess();
//                                    } catch (Exception e) {
//                                        LuaJavaBridgeTest.loginFail();
//                                    }
//
//                                } else {
//                                    LuaJavaBridgeTest.loginFail();
//                                }
//                            }
//                        });
                    }
                });
            }
        });

        // 快速注册按钮
        regist_iv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {

                                HideChangeAccountDialog();

                                // 快速注册
                                PublicViews.ShowLoading(MyApplication.gameActivity);
                                Register register = new Register(MyApplication.gameActivity);
//                                register.quickRegist();
                            }
                        });
                    }
                });
            }
        });

        // 渣浪
        weibo_iv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

                HideChangeAccountDialog();

                mAuthInfo = new AuthInfo(MyApplication.gameActivity, SinaWBPublicMethod.SinaWB_APP_KEY,
                        SinaWBPublicMethod.SinaWB_REDIRECT_URL, SinaWBPublicMethod.SinaWB_SCOPE);
                mSsoHandler = new SsoHandler(MyApplication.gameActivity, mAuthInfo);
                mSsoHandler.authorize(new WeiboAuthListener() {

                    @Override
                    public void onWeiboException(WeiboException e) {
                        // TODO Auto-generated method stub
                        LuaJavaBridgeTest.loginFail();
                    }

                    @Override
                    public void onComplete(Bundle values) {
                        // TODO Auto-generated method stub

                        // 从 Bundle 中解析 Token
                        mAccessToken = Oauth2AccessToken.parseAccessToken(values);

                        //从这里获取用户输入的电话号码信息
                        String phoneNum =  mAccessToken.getPhoneNum();
                        if (mAccessToken.isSessionValid()) {

                            // 保存 Token 到 SharedPreferences
                            AccessTokenKeeper.writeAccessToken(MyApplication.gameActivity, mAccessToken);

                            SinaWBPublicMethod.GetUserInfo(MyApplication.gameActivity);

                        } else {

                            // 以下几种情况，您会收到 Code：
                            // 1. 当您未在平台上注册的应用程序的包名与签名时；
                            // 2. 当您注册的应用程序包名与签名不正确时；
                            // 3. 当您在平台上注册的包名和签名与您当前测试的应用的包名和签名不匹配时。

                            LuaJavaBridgeTest.loginFail();

//                            String code = values.getString("code");
//                            String message = "授权失败";
//                            if (!TextUtils.isEmpty(code)) {
//                                message = message + "\nObtained the code: " + code;
//                            }
//                            Toast.makeText(MyApplication.gameActivity, message, Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onCancel() {
                        // TODO Auto-generated method stub
//                        Toast.makeText(mcontext, "取消授权", Toast.LENGTH_SHORT).show();

                        LuaJavaBridgeTest.loginFail();

                    }
                });

            }
        });

        // 微信
        weixin_iv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        HideChangeAccountDialog();
                        WXPublicMethod.SendAuth(MyApplication.gameActivity);
                    }
                });
            }
        });

        // 企鹅
        qq_iv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

                HideChangeAccountDialog();

//                if(mTencent != null){
//                    if (!mTencent.isSessionValid()) {
//                        mTencent.login(MyApplication.gameActivity, "all", loginListener);
//                        isServerSideLogin = false;
//                        Log.d("SDKQQAgentPref", "FirstLaunch_SDK:" + SystemClock.elapsedRealtime());
//                    } else {
//                        if (isServerSideLogin) { // Server-Side 模式的登陆, 先退出，再进行SSO登陆
//                            mTencent.logout(MyApplication.gameActivity);
//                            mTencent.login(MyApplication.gameActivity, "all", loginListener);
//                            isServerSideLogin = false;
//                            Log.d("SDKQQAgentPref", "FirstLaunch_SDK:" + SystemClock.elapsedRealtime());
//                            return;
//                        }
//                        mTencent.logout(MyApplication.gameActivity);
//                        updateUserInfo();
//                    }
//                }else{
//                    LuaJavaBridgeTest.loginFail();
//                }

            }
        });

    }

    // QQ相关
    public static IUiListener loginListener = new BaseUiListener() {
        @Override
        protected void doComplete(JSONObject values) {
            Log.d("SDKQQAgentPref", "AuthorSwitch_SDK:" + SystemClock.elapsedRealtime());
            initOpenidAndToken(values);

            try {
                if (!values.has("ret") || values.getInt("ret") != 0 || !values.has("openid")) {
                    LuaJavaBridgeTest.loginFail();
                    return;
                }
                String openId = values.getString("openid");
                checkThirdPartyRegist(DouyouConstants.QQ, openId);

            } catch (JSONException e) {
                LuaJavaBridgeTest.loginFail();
            }
        }
    };

    public static class BaseUiListener implements IUiListener {

        @Override
        public void onComplete(Object response) {
            if (null == response) {
                LuaJavaBridgeTest.loginFail();
                return;
            }
            JSONObject jsonResponse = (JSONObject) response;
            if (null != jsonResponse && jsonResponse.length() == 0) {
                LuaJavaBridgeTest.loginFail();
                return;
            }
            doComplete((JSONObject)response);
        }

        protected void doComplete(JSONObject values) {

        }

        @Override
        public void onError(UiError e) {
            LuaJavaBridgeTest.loginFail();
        }

        @Override
        public void onCancel() {
            LuaJavaBridgeTest.loginFail();
            if (isServerSideLogin) {
                isServerSideLogin = false;
            }
        }
    }

    public static void initOpenidAndToken(JSONObject jsonObject) {
        try {
            String token = jsonObject.getString(com.tencent.connect.common.Constants.PARAM_ACCESS_TOKEN);
            String expires = jsonObject.getString(com.tencent.connect.common.Constants.PARAM_EXPIRES_IN);
            String openId = jsonObject.getString(com.tencent.connect.common.Constants.PARAM_OPEN_ID);
            if (!TextUtils.isEmpty(token) && !TextUtils.isEmpty(expires)
                    && !TextUtils.isEmpty(openId)) {
                mTencent.setAccessToken(token, expires);
                mTencent.setOpenId(openId);
            }
        } catch(Exception e) {

        }
    }

    private static void updateUserInfo() {

        if (mTencent != null && mTencent.isSessionValid()) {

            IUiListener listener = new IUiListener() {

                @Override
                public void onError(UiError e) {

                }

                @Override
                public void onComplete(final Object response) {
                    try {
                        JSONObject json = (JSONObject)response;
                        if (json.getInt("ret") == 0) {
                            if (json.has("figureurl") || json.has("figureurl_qq_1")) {
                                Message msg = new Message();
                                msg.obj = json;
                                msg.what = REGIST_MSG;
                                Bundle bundle = new Bundle();
                                bundle.putString("type", DouyouConstants.QQ);
                                bundle.putString("code", tencentOpenId);
                                msg.setData(bundle);
                                mHandler.sendMessage(msg);
                            } else {
                                LuaJavaBridgeTest.loginFail();
                            }
                        } else {
                            LuaJavaBridgeTest.loginFail();
                        }
                    } catch (Exception e) {
                        LuaJavaBridgeTest.loginFail();
                    }
                }

                @Override
                public void onCancel() {
                    LuaJavaBridgeTest.loginFail();
                }

            };

            mInfo = new UserInfo(MyApplication.gameActivity, mTencent.getQQToken());
            mInfo.getUserInfo(listener);

        } else {
            LuaJavaBridgeTest.loginFail();
        }
    }

    /**
     * 检测当前第三方账户是否已经注册
     */
    private static void checkThirdPartyRegist(String type, final String code){

        Map<String, String> source = new HashMap<String, String>();
        source.put("type", type);
        source.put("code", code);

        FinalHttpClient.getInstance().post(RequestURL.OAuthCheck, source, new FinalHttpClient.OnRequestListener() {

            @Override
            public void onFinish(JsonResponse response) {
                // TODO Auto-generated method stub
                if (response.isSuccess()) {
                    //直接登录
                    try {
                        JSONObject json = new JSONObject(response.getData());
                        String phone = json.getString("phone");
                        String password = json.getString("password");
                        if (TextUtils.isEmpty(phone) || TextUtils.isEmpty(password)) {
                            LuaJavaBridgeTest.loginFail();
                        } else {
                            Login login = new Login(MyApplication.gameActivity);
//                            login.loginDouyouInThirdParty(phone, password, false);
                        }
                    } catch (Exception e) {
                        LuaJavaBridgeTest.loginFail();
                    }
                } else {
                    //注册
                    tencentOpenId = code;
                    updateUserInfo();
                }
            }
        });
    }

    static Handler mHandler = new Handler() {

        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 0) {
                JSONObject response = (JSONObject) msg.obj;
                if (response.has("nickname")) {

                }
            } else if (msg.what == REGIST_MSG) {
                //注册
                try {
                    JSONObject json = (JSONObject) msg.obj;
                    Map<String, String> params = new HashMap<String, String>();
                    if (json.has("figureurl_qq_1")) {
                        params.put("photo", json.getString("figureurl_qq_1"));
                    } else {
                        params.put("photo", json.getString("figureurl"));
                    }
                    params.put("nickname", json.getString("nickname"));
                    if (json.has("gender")) {
                        if (TextUtils.equals("男", json.getString("gender"))) {
                            params.put("sex", "1");
                        } else {
                            params.put("sex", "2");
                        }
                    } else {
                        params.put("sex", "1");
                    }

                    Bundle bundle = msg.getData();
                    if (bundle != null) {
                        params.put(bundle.getString("type"), bundle.getString("code"));
                    }

                    new Register(MyApplication.gameActivity).thirdPartyQuickRegist(params);

                } catch (Exception e) {
                    LuaJavaBridgeTest.loginFail();
                }
            }
        }

    };

    public static synchronized void HideChangeAccountDialog() {
        if (changeaccount_dialog != null) {
            wm.removeView(changeaccount_dialog);
            changeaccount_dialog = null;
            bg_ll = null;
            name_et = null;
            code_et = null;
            forgetcode_iv = null;
            login_iv = null;
            regist_iv = null;
            weibo_iv = null;
            weixin_iv = null;
            qq_iv = null;
        }
    }

}
