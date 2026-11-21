package com.linkxin.douyouPlayer.activity.base;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.game.GameActivity;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.AppUpdateUtil;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.library.dialog.DialogUpgrade;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.library.model.AppVersion;
import com.zxinsight.MLink;
import com.zxinsight.MWConfiguration;
import com.zxinsight.MagicWindowSDK;
import com.zxinsight.Session;
import com.zxinsight.mlink.MLinkCallback;
import com.zxinsight.mlink.MLinkIntentBuilder;
import com.zxinsight.mlink.annotation.MLinkDefaultRouter;
import com.zxinsight.mlink.annotation.MLinkRouter;

import org.cocos2dx.lua.AppActivity;

import java.util.HashMap;
import java.util.Map;

@MLinkDefaultRouter
public class WelcomeActivity extends Activity {

	private ImageView iv;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_welcome);

		// 魔窗
		MWConfiguration config = new MWConfiguration(this);
		config.setDebugModel(true)//打开魔窗Log 信息
//                .setPageTrackWithFragment(true)//是否统计Fragment 页面
//                .setCustomWebViewTitleBarOn()//代码内定义webview 标题
				.setSharePlatform(MWConfiguration.ORIGINAL);
		MagicWindowSDK.initSDK(config);

		// 记录魔窗传递来的组局信息
		if (getIntent().getData() != null) {
			Uri mLink = getIntent().getData();
			if (mLink != null){
				Log.d("魔窗", mLink.toString());
				String host = mLink.getHost();
				if (host != null){
					SPUtil.setString(this, "mLinkhost", host);
					if ("groupgame".equals(host)){
						// 当前是组局链接，记录组局信息
						String invitationCode = mLink.getQueryParameter("invitationCode");
						String activityId = mLink.getQueryParameter("activityId");
						String level = mLink.getQueryParameter("level");
						SPUtil.setString(this, "mLinkInvitationCode", invitationCode);
						SPUtil.setString(this, "mLinkActivityId", activityId);
						SPUtil.setString(this, "mLinkLevel", level);
					}
				}
			}
		}

		MLink.getInstance(this).deferredRouter();

		SPUtil.setInt(this,"canHide",0);

		iv = (ImageView) findViewById(R.id.iv);
		iv.post(new Runnable() {
			@Override
			public void run() {
				DisplayMetrics dm = new DisplayMetrics();
				getWindowManager().getDefaultDisplay().getMetrics(dm);
				MyApplication.SCREEN_WIDTH = dm.widthPixels;
				MyApplication.SCREEN_HEIGHT = dm.heightPixels;
				MyApplication.GAME_SCREEN_WIDTH = MyApplication.SCREEN_WIDTH;
				MyApplication.GAME_SCREEN_HEIGHT = MyApplication.SCREEN_HEIGHT;
			}
		});

	}

	/**
	 * 获取服务器最新版本号
	 * @param activity
	 */
	public void CheckVersion(final Activity activity){

		Map<String, String> params = new HashMap<String, String>();
		params.put("type", "1");
		params.put("applicationType", "4");
		params.put("interfaceType","J");
		FinalHttpClient.getInstance().post(RequestURL.APP_VERSION, params, new FinalHttpClient.OnRequestListener() {
			@Override
			public void onFinish(JsonResponse response) {
				if (response.isSuccess()){
					final AppVersion version = response.readObject(AppVersion.class);
					if (version == null){

						final DialogUpgrade dialog = new DialogUpgrade(activity, "检查应用更新失败");
						dialog.setOnUpgradeListener(new View.OnClickListener() {
							@Override
							public void onClick(View v) {
								CheckVersion(WelcomeActivity.this);
								dialog.dismiss();
							}
						});
						dialog.show();

						return;
					}

					// 比较本地版本是否低于服务器版本
					boolean hasNew = AppUpdateUtil.compareVersion(activity, version);
					if (hasNew){

					}else{

						// 静待3秒，跳转到游戏中
						new Handler().postDelayed(new Runnable() {
							@Override
							public void run() {
								startActivity(new Intent(WelcomeActivity.this, AppActivity.class));
								finish();
							}
						}, 3000);

					}

				}else{

//					final DialogUpgrade dialog = new DialogUpgrade(activity, "检查应用更新失败");
//					dialog.setOnUpgradeListener(new View.OnClickListener() {
//						@Override
//						public void onClick(View v) {
//							CheckVersion(WelcomeActivity.this);
//							dialog.dismiss();
//						}
//					});
//					dialog.show();

					// 静待3秒，跳转到游戏中
					new Handler().postDelayed(new Runnable() {
						@Override
						public void run() {
							startActivity(new Intent(WelcomeActivity.this, AppActivity.class));
							finish();
						}
					}, 3000);

				}
			}
		});

	}


	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		Session.onResume(this);

		// 检查应用是否需要更新
		CheckVersion(WelcomeActivity.this);
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		Session.onPause(this);
	}

}
