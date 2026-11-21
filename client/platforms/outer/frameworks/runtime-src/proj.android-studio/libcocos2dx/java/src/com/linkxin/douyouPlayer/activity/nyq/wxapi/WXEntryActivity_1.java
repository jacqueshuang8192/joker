package com.linkxin.douyouPlayer.activity.nyq.wxapi;

import java.util.HashMap;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import net.tsz.afinal.FinalHttp;
import net.tsz.afinal.http.AjaxCallBack;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.activity.login.Login;
import com.linkxin.douyouPlayer.activity.login.Register;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.http.WXPublicMethod;
import com.linkxin.library.http.FinalHttpClient.OnRequestListener;
import com.linkxin.douyouPlayer.util.Logger;
//import com.tencent.mm.sdk.openapi.BaseReq;
//import com.tencent.mm.sdk.openapi.BaseResp;
//import com.tencent.mm.sdk.openapi.ConstantsAPI;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
//import com.tencent.mm.sdk.openapi.SendAuth;
//import com.tencent.mm.sdk.openapi.SendAuth.Resp;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Toast;

public class WXEntryActivity extends BaseActivity implements IWXAPIEventHandler {

	private static final String TAG = "WXEntryActivity";

	// IWXAPI 是第三方app和微信通信的openapi接口
	private IWXAPI api;

	// 校验AccessToken请求url
	private String CheckAccessTokenUrl;

	// 获取AccessToken请求url
	private String GetAccessTokenUrl;

	// 刷新AccessToken请求url
	private String RefreshTokenUrl;

	// 获取微信用户信息请求url
	private String GetWXUserInfoUrl;

	// 微信请求AccessToken返回的Object
	private JSONObject accesstoken_obj;

	private String accesstoken;

	private String refreshtoken;

	// 微信请求刷新AccessToken返回的Object
	private JSONObject refreshtoken_obj;

	// 请求微信用户信息返回的Object
	private JSONObject userinfo_obj;

	// 用户id
	private String openid;

	private Context mcontext;

	private Login login;

	private String login_msg;

	private TextView state_tv;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

		setContentView(R.layout.activity_logincheck);

		state_tv = (TextView) findViewById(R.id.state_tv);

		// 通过WXAPIFactory工厂，获取IWXAPI的实例
		api = WXAPIFactory.createWXAPI(this, RequestURL.WXAPP_ID, false);
		api.handleIntent(getIntent(), this);

		login = new Login(this);

		mcontext = this;

		login_msg = "";

	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
		api.handleIntent(intent, this);
	}

	// 微信发送请求到第三方应用时，会回调到该方法
	@Override
	public void onReq(BaseReq req) {
		switch (req.getType()) {
			case ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX:
				break;
			case ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX:
				break;
			default:
				break;
		}
	}

	// 第三方应用发送到微信的请求处理后的响应结果，会回调到该方法
	@Override
	public void onResp(BaseResp resp) {

		String handle = SPUtil.getString(MyApplication.gameActivity, "WXHandle");

		int result = 0;

		switch (resp.errCode) {

			case BaseResp.ErrCode.ERR_OK:

				int type = resp.getType();
				switch (type) {

					case 1:
						SendAuth.Resp saresp = (SendAuth.Resp) resp;
						if(saresp.state.equals("SendAuth")){

							state_tv.setText("微信授权成功，获取用户信息");

							login_msg = login_msg + "授权返回" + " ";

//							PublicViews.ShowLoading(this);

							GetAccessTokenUrl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + WXPublicMethod.WXAPP_ID +
									"&secret=" + WXPublicMethod.WXAPP_SECRET +
									"&code=" + saresp.code + "&grant_type=authorization_code";

							//saresp.token
							// 获取Token
							GetToken();
						}
						break;

					case 2:

						JSONObject object = new JSONObject();
						try {

							int scene = SPUtil.getInt(WXEntryActivity.this, "WXSceneSession");
							if (scene == WXPublicMethod.WXSceneSession){
								object.put("shareType", "wx");
							}else if (scene == WXPublicMethod.WXSceneTimeline){
								object.put("shareType", "pyq");
							}

						} catch (JSONException e) {
							e.printStackTrace();

						}

						LuaJavaBridgeTest.sendDataToLua("share", object);

						finish();

						break;

					default:
						Toast.makeText(getApplicationContext(), "操作成功", Toast.LENGTH_SHORT).show();

//						LuaJavaBridgeTest.shareSuccess();

						finish();
						break;
				}
				break;

			case BaseResp.ErrCode.ERR_USER_CANCEL:

				result = R.string.errcode_cancel;
				Toast.makeText(this, result, Toast.LENGTH_LONG).show();
				if ("login".equals(handle)){
					LuaJavaBridgeTest.loginFail();
				}else if ("share".equals(handle)){
//					LuaJavaBridgeTest.shareCancel();
				}
				finish();
				break;

			case BaseResp.ErrCode.ERR_AUTH_DENIED:

				result = R.string.errcode_deny;
				Toast.makeText(this, result, Toast.LENGTH_LONG).show();
				if ("login".equals(handle)){
					LuaJavaBridgeTest.loginFail();
				}else if ("share".equals(handle)){
//					LuaJavaBridgeTest.shareCancel();
				}
				finish();
				break;

			default:

				result = R.string.errcode_unknown;
				Toast.makeText(this, result, Toast.LENGTH_LONG).show();
				if ("login".equals(handle)){
					LuaJavaBridgeTest.loginFail();
				}else if ("share".equals(handle)){
//					LuaJavaBridgeTest.shareCancel();
				}
				finish();
				break;
		}
	}

	/**
	 * 校验Token
	 */
	private void CheckToken(){

		CheckAccessTokenUrl = "https://api.weixin.qq.com/sns/auth?access_token=ACCESS_TOKEN&openid=OPENID";
		FinalHttp fh = new FinalHttp();
		fh.get(CheckAccessTokenUrl, new AjaxCallBack<Object>(){

			@Override
			public void onStart(){

			}

			@Override
			public void onSuccess(Object object){
				String str = (String) object;
			}

			@Override
			public void onFailure(Throwable t, int errorNo, String strMsg){

				login_msg = login_msg + "校验Token失败" + " ";
				Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

				LuaJavaBridgeTest.loginFail();
				finish();

			}

		});
	}

	/**
	 * 获取Token
	 */
	private void GetToken(){

		FinalHttp fh = new FinalHttp();
		fh.get(GetAccessTokenUrl, new AjaxCallBack<Object>(){

			@Override
			public void onStart(){

			}

			@Override
			public void onSuccess(Object object){

				String str = (String) object;
				try {

					accesstoken_obj = new JSONObject(str);
					if (accesstoken_obj == null){

						login_msg = login_msg + "获取Token失败" + " ";
						Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

						LuaJavaBridgeTest.loginFail();
						finish();
						return;

					}else{

						if(accesstoken_obj.getString("access_token") != null){
							accesstoken = accesstoken_obj.getString("access_token");
						}

						if(accesstoken_obj.getString("refresh_token") != null){
							refreshtoken = accesstoken_obj.getString("refresh_token");
						}

						if(accesstoken_obj.getString("openid") != null){

							openid = accesstoken_obj.getString("openid");
							GetUserInfo();

						}else{

							login_msg = login_msg + "获取openid失败" + " ";
							Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

							LuaJavaBridgeTest.loginFail();
							finish();
							return;

						}

					}

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					LuaJavaBridgeTest.loginFail();
					finish();
				}
			}

			@Override
			public void onFailure(Throwable t, int errorNo, String strMsg){

				login_msg = login_msg + "Token解析失败" + " ";
				Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

				LuaJavaBridgeTest.loginFail();
				finish();
			}
		});
	}

	/**
	 * 刷新Token
	 */
	private void RefreshToken(){

		RefreshTokenUrl = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=" + WXPublicMethod.WXAPP_ID +
				"&grant_type=refresh_token" +
				"&refresh_token=" + refreshtoken;

		FinalHttp fh = new FinalHttp();
		fh.get(RefreshTokenUrl, new AjaxCallBack<Object>(){

			@Override
			public void onStart(){

			}

			@Override
			public void onSuccess(Object object){
				String str = (String) object;
				try {
					refreshtoken_obj = new JSONObject(str);
					if(refreshtoken_obj.getString("access_token") != null){
						accesstoken = refreshtoken_obj.getString("access_token");
					}
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					LuaJavaBridgeTest.loginFail();
					finish();
				}
			}

			@Override
			public void onFailure(Throwable t, int errorNo, String strMsg){
				LuaJavaBridgeTest.loginFail();
				finish();
			}
		});
	}

	/**
	 * 获取用户微信资料
	 */
	private void GetUserInfo(){

		GetWXUserInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=" + accesstoken +
				"&openid=" + openid;

		FinalHttp fh = new FinalHttp();
		fh.get(GetWXUserInfoUrl, new AjaxCallBack<Object>(){

			@Override
			public void onStart(){

			}

			@Override
			public void onSuccess(Object object){
				String str = (String) object;
				try {
					userinfo_obj = new JSONObject(str);

					// 记录用户最新的头像链接
					String headimgurl = "";
					if(userinfo_obj.has("headimgurl")){
						headimgurl = userinfo_obj.getString("headimgurl");
					}
					SPUtil.setString(WXEntryActivity.this, "wxphoto" ,headimgurl);

					// 记录用户最新的微信名称
					String nickname = "";
					if(userinfo_obj.has("nickname")){
						nickname = userinfo_obj.getString("nickname");
					}
					SPUtil.setString(WXEntryActivity.this, "wxnickname" ,nickname);

					// 记录用户最新的性别
					String sex = "2";
					if(userinfo_obj.has("sex")){
						if(userinfo_obj.getInt("sex") == 1){
							sex = "1";
						}
					}
					SPUtil.setString(WXEntryActivity.this, "wxsex" ,sex);

					CheckRegist();

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();

					login_msg = login_msg + "解析用户微信资料失败" + " ";
					Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

					LuaJavaBridgeTest.loginFail();
					finish();

				}
			}

			@Override
			public void onFailure(Throwable t, int errorNo, String strMsg){

				login_msg = login_msg + "获取用户微信资料失败" + " ";
				Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

				LuaJavaBridgeTest.loginFail();
				finish();

			}
		});
	}

	/**
	 * 检测当前微信号是否已经注册
	 */
	private void CheckRegist(){

		state_tv.setText("验证用户信息");

		try {

			Map<String, String> source = new HashMap<String, String>();
			source.put("type", DouyouConstants.WECHAT);
			if(userinfo_obj.has("openid")){
				source.put("code", userinfo_obj.getString("openid"));
			}else{

				login_msg = login_msg + "用户微信资料不包含openid" + " ";
				Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

				LuaJavaBridgeTest.loginFail();
				finish();

				return;
			}

			FinalHttpClient.getInstance().post(RequestURL.OAuthCheck, source, new OnRequestListener() {

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
//								PublicViews.ShowErrorDialog(mcontext, "账号信息异常");

								login_msg = login_msg + "平台账号信息异常" + " ";
								Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

								LuaJavaBridgeTest.loginFail();
								finish();

							} else {

								state_tv.setText("正在登录");

								login.loginDouyouInThirdParty_WX(phone, password, false, WXEntryActivity.this);

							}

						} catch (Exception e) {
							Logger.e(TAG, e.getLocalizedMessage());

							login_msg = login_msg + "平台账号信息解析异常1" + " ";
							Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

							LuaJavaBridgeTest.loginFail();
							finish();
						}

					} else {

						state_tv.setText("正在注册");

						// 没有账号，弹出注册
						try {
							Map<String, String> params = new HashMap<String, String>();

							if(userinfo_obj.has("headimgurl")){
								params.put("photo", userinfo_obj.getString("headimgurl"));
							}else{
								params.put("photo", "");
							}

							if(userinfo_obj.has("nickname")){
								params.put("nickname", userinfo_obj.getString("nickname"));
							}else{
								params.put("nickname", "");
							}

							if(userinfo_obj.has("sex")){
								if(userinfo_obj.getInt("sex") == 1){
									params.put("sex", "1");
								}else{
									params.put("sex", "2");
								}
							}else{
								params.put("sex", "2");
							}

							params.put(DouyouConstants.WECHAT, userinfo_obj.getString("openid"));

							new Register(WXEntryActivity.this).thirdPartyQuickRegist_WX(params,WXEntryActivity.this);

						} catch (JSONException e) {
							e.printStackTrace();

							login_msg = login_msg + "平台账号信息注册异常" + " ";
							Toast.makeText(mcontext, login_msg, Toast.LENGTH_SHORT).show();

							LuaJavaBridgeTest.loginFail();
							finish();
						}
					}
				}
			});

		} catch (JSONException e) {
			ToastUtil.showBaseToast(mcontext, "微信登陆失败");
			LuaJavaBridgeTest.loginFail();
			finish();
			e.printStackTrace();
		}
	}
}
