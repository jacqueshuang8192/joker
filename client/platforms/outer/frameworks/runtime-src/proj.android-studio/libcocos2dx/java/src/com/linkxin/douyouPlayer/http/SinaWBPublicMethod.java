package com.linkxin.douyouPlayer.http;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.activity.login.Login;
import com.linkxin.douyouPlayer.activity.login.Register;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.dialog.ThirdPartyRegistDialog;
import com.linkxin.douyouPlayer.util.Logger;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.sina.weibo.sdk.api.ImageObject;
import com.sina.weibo.sdk.api.TextObject;
import com.sina.weibo.sdk.api.WebpageObject;
import com.sina.weibo.sdk.api.WeiboMultiMessage;
import com.sina.weibo.sdk.api.share.IWeiboShareAPI;
import com.sina.weibo.sdk.api.share.SendMultiMessageToWeiboRequest;
import com.sina.weibo.sdk.api.share.WeiboShareSDK;
import com.sina.weibo.sdk.auth.AuthInfo;
import com.sina.weibo.sdk.auth.Oauth2AccessToken;
import com.sina.weibo.sdk.auth.WeiboAuthListener;
import com.sina.weibo.sdk.auth.sso.SsoHandler;
import com.sina.weibo.sdk.exception.WeiboException;
import com.sina.weibo.sdk.net.RequestListener;
import com.sina.weibo.sdk.openapi.UsersAPI;
import com.sina.weibo.sdk.openapi.models.ErrorInfo;
import com.sina.weibo.sdk.openapi.models.User;
import com.sina.weibo.sdk.utils.Utility;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

@SuppressLint("NewApi")
public class SinaWBPublicMethod {

    // 应用的APP_KEY
    public static final String SinaWB_APP_KEY = RequestURL.SinaWB_APP_KEY;

    // 应用的回调页
    public static final String SinaWB_REDIRECT_URL = "https://api.weibo.com/oauth2/default.html";

    // 应用申请的高级权限
    public static final String SinaWB_SCOPE =
            "email,direct_messages_read,direct_messages_write,"
                    + "friendships_groups_read,friendships_groups_write,statuses_to_me_read,"
                    + "follow_app_official_microblog," + "invitation_write";

    private static Activity mcontext;

    private static AuthInfo mAuthInfo;

    /**
     * 封装了 "access_token"，"expires_in"，"refresh_token"，并提供了他们的管理功能
     */
    private static Oauth2AccessToken mAccessToken;

    /**
     * 注意：SsoHandler 仅当 SDK 支持 SSO 时有效
     */
    private static SsoHandler mSsoHandler;

    /**
     * 微博分享的接口实例
     */
    private static IWeiboShareAPI mWeiboShareAPI;

    /**
     * 用户信息接口
     */
    private static UsersAPI mUsersAPI;

    /**
     * 新浪微博授权
     */
    public static void SinaWBAuth(Activity activity) {

        mcontext = activity;

        mAuthInfo = new AuthInfo(mcontext, SinaWB_APP_KEY,
                SinaWB_REDIRECT_URL, SinaWB_SCOPE);
        mSsoHandler = new SsoHandler(mcontext, mAuthInfo);
        mSsoHandler.authorize(new WeiboAuthListener() {

            @Override
            public void onWeiboException(WeiboException e) {
                // TODO Auto-generated method stub
                Toast.makeText(mcontext, "Auth exception : " + e.getMessage(), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onComplete(Bundle values) {
                // TODO Auto-generated method stub

                // 从 Bundle 中解析 Token
                mAccessToken = Oauth2AccessToken.parseAccessToken(values);

                //从这里获取用户输入的电话号码信息
                String phoneNum = mAccessToken.getPhoneNum();
                if (mAccessToken.isSessionValid()) {

                    // 保存 Token 到 SharedPreferences
                    AccessTokenKeeper.writeAccessToken(mcontext, mAccessToken);

                } else {
                    // 以下几种情况，您会收到 Code：
                    // 1. 当您未在平台上注册的应用程序的包名与签名时；
                    // 2. 当您注册的应用程序包名与签名不正确时；
                    // 3. 当您在平台上注册的包名和签名与您当前测试的应用的包名和签名不匹配时。
                    String code = values.getString("code");
                    String message = "授权失败";
                    if (!TextUtils.isEmpty(code)) {
                        message = message + "\nObtained the code: " + code;
                    }
                    Toast.makeText(mcontext, message, Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onCancel() {
                // TODO Auto-generated method stub
                Toast.makeText(mcontext, "取消授权", Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * 发送文字
     *
     * @param activity
     * @param text
     */
    public static void SendText(Activity activity, final String text) {

        mcontext = activity;

        mAuthInfo = new AuthInfo(mcontext, SinaWB_APP_KEY,
                SinaWB_REDIRECT_URL, SinaWB_SCOPE);
        mSsoHandler = new SsoHandler(mcontext, mAuthInfo);
        mSsoHandler.authorize(new WeiboAuthListener() {

            @Override
            public void onWeiboException(WeiboException e) {
                // TODO Auto-generated method stub
                Toast.makeText(mcontext, "Auth exception : " + e.getMessage(), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onComplete(Bundle values) {
                // TODO Auto-generated method stub

                // 从 Bundle 中解析 Token
                mAccessToken = Oauth2AccessToken.parseAccessToken(values);

                //从这里获取用户输入的电话号码信息
                String phoneNum = mAccessToken.getPhoneNum();
                if (mAccessToken.isSessionValid()) {

                    // 保存 Token 到 SharedPreferences
                    AccessTokenKeeper.writeAccessToken(mcontext, mAccessToken);

                    // 创建微博 SDK 接口实例
                    mWeiboShareAPI = WeiboShareSDK.createWeiboAPI(mcontext, SinaWB_APP_KEY);

                    // 注册到新浪微博
                    mWeiboShareAPI.registerApp();

                    // 1. 初始化微博的分享消息
                    WeiboMultiMessage weiboMessage = new WeiboMultiMessage();
                    TextObject textObject = new TextObject();
                    textObject.text = text;
                    weiboMessage.textObject = textObject;

                    // 2. 初始化从第三方到微博的消息请求
                    SendMultiMessageToWeiboRequest request = new SendMultiMessageToWeiboRequest();

                    // 用transaction唯一标识一个请求
                    request.transaction = String.valueOf(System.currentTimeMillis());
                    request.multiMessage = weiboMessage;

                    AuthInfo authInfo = new AuthInfo(mcontext, SinaWB_APP_KEY, SinaWB_REDIRECT_URL, SinaWB_SCOPE);
                    Oauth2AccessToken accessToken = AccessTokenKeeper.readAccessToken(mcontext);

                    String token = "";
                    if (accessToken != null) {
                        token = accessToken.getToken();
                    }

                    mWeiboShareAPI.sendRequest(mcontext, request, authInfo, token, new WeiboAuthListener() {

                        @Override
                        public void onWeiboException(WeiboException arg0) {
                        }

                        @Override
                        public void onComplete(Bundle bundle) {
                            // TODO Auto-generated method stub
                            Oauth2AccessToken newToken = Oauth2AccessToken.parseAccessToken(bundle);
                            AccessTokenKeeper.writeAccessToken(mcontext, newToken);
                        }

                        @Override
                        public void onCancel() {

                        }
                    });

                } else {
                    String code = values.getString("code");
                    String message = "授权失败";
                    if (!TextUtils.isEmpty(code)) {
                        message = message + "\nObtained the code: " + code;
                    }
                    Toast.makeText(mcontext, message, Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onCancel() {
                // TODO Auto-generated method stub
                Toast.makeText(mcontext, "取消授权", Toast.LENGTH_SHORT).show();
            }
        });

    }

    /**
     * 发送图片
     *
     * @param activity
     * @param bitmap
     */
    public static void SendImage(Activity activity, Bitmap bitmap) {

        // 授权新浪微博
        SinaWBAuth(activity);

        // 创建微博 SDK 接口实例
        mWeiboShareAPI = WeiboShareSDK.createWeiboAPI(mcontext, SinaWB_APP_KEY);

        // 注册到新浪微博
        mWeiboShareAPI.registerApp();

        // 1. 初始化微博的分享消息
        WeiboMultiMessage weiboMessage = new WeiboMultiMessage();
        ImageObject imageObject = new ImageObject();
        imageObject.setImageObject(bitmap);
        weiboMessage.mediaObject = imageObject;

        // 2. 初始化从第三方到微博的消息请求
        SendMultiMessageToWeiboRequest request = new SendMultiMessageToWeiboRequest();

        // 用transaction唯一标识一个请求
        request.transaction = String.valueOf(System.currentTimeMillis());
        request.multiMessage = weiboMessage;

        AuthInfo authInfo = new AuthInfo(mcontext, SinaWB_APP_KEY, SinaWB_REDIRECT_URL, SinaWB_SCOPE);
        Oauth2AccessToken accessToken = AccessTokenKeeper.readAccessToken(mcontext);

        String token = "";
        if (accessToken != null) {
            token = accessToken.getToken();
        }

        mWeiboShareAPI.sendRequest(mcontext, request, authInfo, token, new WeiboAuthListener() {

            @Override
            public void onWeiboException(WeiboException arg0) {
            }

            @Override
            public void onComplete(Bundle bundle) {
                // TODO Auto-generated method stub
                Oauth2AccessToken newToken = Oauth2AccessToken.parseAccessToken(bundle);
                AccessTokenKeeper.writeAccessToken(mcontext, newToken);
            }

            @Override
            public void onCancel() {

            }
        });
    }

    /**
     * 发送链接
     *
     * @param activity
     */
    public static void SendUrl(Activity activity, String title, String description, Bitmap thumb, String url) {

        // 授权新浪微博
        SinaWBAuth(activity);

        // 创建微博 SDK 接口实例
        mWeiboShareAPI = WeiboShareSDK.createWeiboAPI(mcontext, SinaWB_APP_KEY);

        // 注册到新浪微博
        mWeiboShareAPI.registerApp();

        // 1. 初始化微博的分享消息
        WeiboMultiMessage weiboMessage = new WeiboMultiMessage();
        WebpageObject mediaObject = new WebpageObject();
        mediaObject.identify = Utility.generateGUID();
        mediaObject.title = title;
        mediaObject.description = description;

        // 设置 Bitmap 类型的图片到视频对象里
        // 设置缩略图。 注意：最终压缩过的缩略图大小不得超过 32kb。
        mediaObject.setThumbImage(thumb);
        mediaObject.actionUrl = url;
        mediaObject.defaultText = title;
        weiboMessage.mediaObject = mediaObject;

        // 2. 初始化从第三方到微博的消息请求
        SendMultiMessageToWeiboRequest request = new SendMultiMessageToWeiboRequest();

        // 用transaction唯一标识一个请求
        request.transaction = String.valueOf(System.currentTimeMillis());
        request.multiMessage = weiboMessage;

        AuthInfo authInfo = new AuthInfo(mcontext, SinaWB_APP_KEY, SinaWB_REDIRECT_URL, SinaWB_SCOPE);
        Oauth2AccessToken accessToken = AccessTokenKeeper.readAccessToken(mcontext);

        String token = "";
        if (accessToken != null) {
            token = accessToken.getToken();
        }

        mWeiboShareAPI.sendRequest(mcontext, request, authInfo, token, new WeiboAuthListener() {

            @Override
            public void onWeiboException(WeiboException arg0) {
            }

            @Override
            public void onComplete(Bundle bundle) {
                // TODO Auto-generated method stub
                Oauth2AccessToken newToken = Oauth2AccessToken.parseAccessToken(bundle);
                AccessTokenKeeper.writeAccessToken(mcontext, newToken);
            }

            @Override
            public void onCancel() {

            }
        });
    }

    /**
     * 获取用户信息
     *
     * @param activity
     */
    public static void GetUserInfo(final Activity activity) {

        PublicViews.ShowLoading(MyApplication.gameActivity);

        mcontext = activity;

        // 获取当前已保存过的 Token
        mAccessToken = AccessTokenKeeper.readAccessToken(activity);

        if (mAccessToken != null && mAccessToken.isSessionValid() && mAccessToken.getUid() != null && !mAccessToken.getUid().equals("")) {

            // 获取用户信息接口
            mUsersAPI = new UsersAPI(activity, SinaWB_APP_KEY, mAccessToken);

            long uid = Long.parseLong(mAccessToken.getUid());
            mUsersAPI.show(uid, new RequestListener() {

                @Override
                public void onWeiboException(WeiboException e) {
                    // TODO Auto-generated method stub
//                    ErrorInfo info = ErrorInfo.parse(e.getMessage());
//                    Toast.makeText(mcontext, info.toString(), Toast.LENGTH_SHORT).show();

                    LuaJavaBridgeTest.loginFail();

                }

                @Override
                public void onComplete(String response) {
                    // TODO Auto-generated method stub
                    if (!TextUtils.isEmpty(response)) {
                        // 调用 User#parse 将JSON串解析成User对象
                        User user = User.parse(response);
                        if (user != null) {
                            CheckRegist(user, activity);
                        } else {
//                            Toast.makeText(mcontext, response, Toast.LENGTH_SHORT).show();

                            LuaJavaBridgeTest.loginFail();

                        }
                    }
                }
            });
        } else {

            LuaJavaBridgeTest.loginFail();

        }
    }

    /**
     * 检测当前微博号是否已经注册
     */
    private static void CheckRegist(final User user, final Context activity) {

        Map<String, String> source = new HashMap<String, String>();
        source.put("type", DouyouConstants.WEIBO);
        if (user.idstr != null && !"".equals(user.idstr)) {
            source.put("code", user.idstr);
        } else {
//            ToastUtil.showBaseToast(mcontext, "微博登陆失败");

            LuaJavaBridgeTest.loginFail();

            return;
        }

        FinalHttpClient.getInstance().post(RequestURL.OAuthCheck, source, new FinalHttpClient.OnRequestListener() {

            @Override
            public void onFinish(JsonResponse response) {
                // TODO Auto-generated method stub
                if (response.isSuccess()) {
                    // 账号存在，直接登录
                    try {
                        JSONObject json = new JSONObject(response.getData());
                        String phone = json.getString("phone");
                        String password = json.getString("password");
                        if (TextUtils.isEmpty(phone) || TextUtils.isEmpty(password)) {
                            LuaJavaBridgeTest.loginFail();
                        } else {
                            Login login = new Login(activity);
//                            login.loginDouyouInThirdParty(phone, password, false);
                        }
                    } catch (Exception e) {
                        LuaJavaBridgeTest.loginFail();
                    }
                } else {
                    // 没有账号，弹出注册
                    Map<String, String> params = new HashMap<String, String>();

                    if (user.avatar_large != null && !"".equals(user.avatar_large)) {
                        params.put("photo", user.avatar_large);
                    } else {
                        params.put("photo", "");
                    }

                    if (user.name != null && !"".equals(user.name)) {
                        params.put("nickname", user.name);
                    } else {
                        params.put("nickname", "");
                    }

                    if ("m".equals(user.gender)) {
                        params.put("sex", "1");
                    } else {
                        params.put("sex", "2");
                    }

                    params.put("weibo", user.idstr);

                    new Register(activity).thirdPartyQuickRegist(params);

                }
            }
        });

    }

}
