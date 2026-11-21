package com.linkxin.douyouPlayer.activity.web;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.dialog.SingleChoseDialog;
import com.linkxin.douyouPlayer.http.PublicMethod;
import com.linkxin.douyouPlayer.util.DBUtils;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.view.TitleBar;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.douyouPlayer.web.JavaScriptObject;
import com.pingplusplus.android.PaymentActivity;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.LinearLayout;

import java.util.HashMap;
import java.util.Map;

import de.greenrobot.event.EventBus;

public class WebActivity extends BaseActivity {

    private LinearLayout rootView;
	private WebView webView;
    private TitleBar titleBar;
	private Button right_bt;
	private String title;
	private String url;
	public int nowAT;// 0 普通界面，1 地图，2 店铺列表, 3 抢矿活动, 4 邀请约饭， 5 充值， 6 钻石兑换，7 公会详情, 8 线下商城, 9 我的道具

	// 支付
	private static final int REQUEST_CODE_PAYMENT = 100;
	private static final int SHOW_PAYMENT_CHANNEL = 1;
	private static final int HIDE_PAYMENT_CHANNEL = 2;
	private String price;
	private String amount;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_web);

		initData();
		initView();

	}

	/**
	 * 初始化数据
	 */
	private void initData() {
		mcontext = this;
		title = this.getIntent().getStringExtra("title");
		url = this.getIntent().getStringExtra("url");
		nowAT = this.getIntent().getIntExtra("nowAT", 0);
	}

	/**
	 * 初始化界面
	 */
	private void initView() {

        rootView = getViewById(R.id.ll_web_view);
        titleBar = getViewById(R.id.title_bar);
        titleBar.setTitleText(title);

		loadleft_bt.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				BackAction();
			}
		});

		// 设置左上角退出按钮操作
		titleBar.getLeftBt().setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				BackAction();
			}
		});

		if(nowAT == 5 || nowAT == 6){
			titleBar.showRightBt();
			titleBar.setRightBtBackgroundResource(R.drawable.ic_rechargecenter);
			titleBar.getRightBt().setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					Intent i = new Intent(mcontext,WebActivity.class);
					String tourl = "";
					if(nowAT == 5){
						i.putExtra("title", "充值记录");
						tourl = PublicMethod.getRechargerecordUrl(mcontext,SPUtil.getCurrentUserId(mcontext));
					}else if(nowAT == 6){
						i.putExtra("title", "兑换记录");
						tourl = PublicMethod.getExchangerecordUrl(mcontext,SPUtil.getCurrentUserId(mcontext));
					}
					i.putExtra("url", tourl);
					startActivity(i);
				}
			});
		}

		webView = (WebView) findViewById(R.id.webView);
		webView.getSettings().setJavaScriptEnabled(true);//设置js支持
		webView.getSettings().setDefaultTextEncodingName("utf-8");//设置字符编码
		webView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);//滚动条风格，为0指滚动条不占用空间，直接覆盖在网页上
		webView.addJavascriptInterface(new JavaScriptObject(mcontext,this), "JavaScriptObject");

		webView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				return false;
			}
		});

		webView.setWebChromeClient(new WebChromeClient() {

			@Override
			public void onProgressChanged(WebView view, int newProgress) {
				// TODO Auto-generated method stub
				if (newProgress == 100) {
					if(nowAT == 1){
						// 网页加载完成
						PublicViews.HideLoading();
					}
				}
			}


		});

        PublicViews.ShowLoading(mcontext);
		webView.loadUrl(url);
	}

	/**
	 * 重新加载页面
	 */
	public void ReloadUrl(){
		webView.loadUrl(url);
	}

	@Override
	protected void onResume() {
		super.onResume();

		if(nowAT == 7 || nowAT == 9){
			MyApplication.webActivity = this;
		}

	}

	@Override
	protected void onPause() {
		super.onPause();

		if(nowAT == 7 || nowAT == 9){
			MyApplication.webActivity = null;
		}
	}

	@Override
	protected void onStop() {
		super.onStop();
	}

	@Override
	public void onDestroy(){
		if(dialog.isShowing()){
			dialog.cancel();
		}
        rootView.removeAllViews();
        webView.removeAllViews();
		webView.destroy();
		super.onDestroy();
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		BackAction();
	}

	// 返回事件处理
	private void BackAction(){

		if(nowAT == 5){
			MyApplication.isRecharge = false;
			SPUtil.setboolean(mcontext,"isRecharge",MyApplication.isRecharge);
		}

		if(nowAT == 3){

		}else if(nowAT == 4){

		}else{
			defaultFinish();
		}

	}

	// 支付相关
	public void showChoosePayChannel(String price, String amount) {
		this.price = price;
		this.amount = amount;
	}

    private void alipay(){
        showLoading();
        Map<String, String> source = new HashMap<String, String>();
        source.put("userId", MyApplication.userId);
		//支付宝以分为单位
		int p = Integer.parseInt(price) * 100;
        source.put("payAmount", p + "");
        source.put("channel", "1");
        source.put("payType", "P");
        source.put("coinAmount", amount);
        FinalHttpClient.getInstance().post(RequestURL.PLAYER_CHARGE_URL, source, new FinalHttpClient.OnRequestListener() {

            @Override
            public void onFinish(JsonResponse response) {
                // TODO Auto-generated method stub
                if (response.isSuccess()) {
                    Intent intent = new Intent(WebActivity.this, PaymentActivity.class);
                    intent.putExtra(PaymentActivity.EXTRA_CHARGE, response.getData());
                    startActivityForResult(intent, REQUEST_CODE_PAYMENT);
                } else {
                    hideLoading();
                    PublicViews.ShowErrorDialog(mcontext, response.getError());
                }
            }
        });
    }

	private void wechatPay() {
		showLoading();
		Map<String, String> source = new HashMap<String, String>();
		source.put("userId", SPUtil.getCurrentUserId(this));
		int p = Integer.parseInt(price) * 100;
		source.put("payAmount", p + "");
		source.put("channel", "1");
		source.put("payType", "W");
		source.put("coinAmount", amount);
		FinalHttpClient.getInstance().post(RequestURL.PLAYER_CHARGE_URL, source, new FinalHttpClient.OnRequestListener() {

			@Override
			public void onFinish(JsonResponse response) {
				// TODO Auto-generated method stub
				if (response.isSuccess()) {
					Intent intent = new Intent(WebActivity.this, PaymentActivity.class);
					intent.putExtra(PaymentActivity.EXTRA_CHARGE, response.getData());
					startActivityForResult(intent, REQUEST_CODE_PAYMENT);
				} else {
					hideLoading();
					PublicViews.ShowErrorDialog(mcontext, response.getError());
				}
			}
		});
	}

	private void unionPay() {
		showLoading();
		Map<String, String> source = new HashMap<String, String>();
		source.put("userId", SPUtil.getCurrentUserId(this));
		int p = Integer.parseInt(price) * 100;
		source.put("payAmount", p + "");
		source.put("channel", "1");
		source.put("payType", "U");
		source.put("coinAmount", amount);
		FinalHttpClient.getInstance().post(RequestURL.PLAYER_CHARGE_URL, source, new FinalHttpClient.OnRequestListener() {

			@Override
			public void onFinish(JsonResponse response) {
				// TODO Auto-generated method stub
				if (response.isSuccess()) {
					Intent intent = new Intent(WebActivity.this, PaymentActivity.class);
					intent.putExtra(PaymentActivity.EXTRA_CHARGE, response.getData());
					startActivityForResult(intent, REQUEST_CODE_PAYMENT);
				} else {
					hideLoading();
					PublicViews.ShowErrorDialog(mcontext, response.getError());
				}
			}
		});
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		//支付页面返回处理
		if (requestCode == REQUEST_CODE_PAYMENT) {
			if (resultCode == Activity.RESULT_OK) {
				String result = data.getExtras().getString("pay_result");
				if ("success".equals(result)) {
					if (!TextUtils.isEmpty(amount)) {
                        DouyouUser user = SPUtil.getCurrentUser(this);
                        user.setCoinAmount(user.getCoinAmount() + Integer.parseInt(amount));
                        SPUtil.updateCurrentUser(this,user);
					}

					hideLoading();
					PublicViews.ShowDialog(this, "提示", "付款成功", "我知道了", null);

					if(MyApplication.gameActivity != null){
						MyApplication.isRecharge = true;
					}

				} else if ("cancel".equals(result)) {
					hideLoading();
				} else {
					hideLoading();
					PublicViews.ShowErrorDialog(this, data.getExtras().getString("error_msg"));
				}
			}
		}
	}

}
