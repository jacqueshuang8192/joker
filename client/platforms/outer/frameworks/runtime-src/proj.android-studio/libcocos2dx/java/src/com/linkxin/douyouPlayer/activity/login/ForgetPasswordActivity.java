package com.linkxin.douyouPlayer.activity.login;

import java.util.HashMap;
import java.util.Map;

import net.tsz.afinal.http.AjaxParams;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.constant.Constants;
import com.linkxin.douyouPlayer.util.Logger;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.Md5Util;
import com.linkxin.douyouPlayer.util.TaskUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.utils.StringUtils;
import com.linkxin.douyouPlayer.view.PublicViews;

public class ForgetPasswordActivity extends BaseActivity implements OnClickListener {

	private static String TAG = "ForgetPasswordActivity";

	private Button left_bt, send_verification_bt, finish_bt;
	private TextView title_tv, count_down_tv;
	private EditText phone_et, verification_code_et, password_et,
			confirm_password_et;
	private ImageView clean_password_iv, hide_password_iv,
			hide_con_password_iv, clean_con_password_iv;

	private MyCountDownTimer mc;

	private boolean isPasswordHidden = true;
	private boolean isConPasswordHidden = true;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_forget_password);

		initData();
		initView();
	}

	/**
	 * 初始化数据
	 */
	private void initData() {
		mcontext = this;
	}

	/**
	 * 初始化界面
	 */
	private void initView() {
		title_tv = (TextView) findViewById(R.id.title_tv);
		title_tv.setText(getResources().getString(R.string.forget_passward));
		title_tv.setFocusable(true);
		title_tv.setFocusableInTouchMode(true);
		title_tv.requestFocus();

		left_bt = (Button) findViewById(R.id.left_bt);
		left_bt.setOnClickListener(this);
		left_bt.setVisibility(View.VISIBLE);

		phone_et = (EditText) findViewById(R.id.phone_et);

		send_verification_bt = (Button) findViewById(R.id.send_verification_bt);
		send_verification_bt.setOnClickListener(this);

		count_down_tv = (TextView) findViewById(R.id.count_down_tv);

		verification_code_et = (EditText) findViewById(R.id.verification_code_et);

		clean_password_iv = (ImageView) findViewById(R.id.clean_password_iv);
		clean_password_iv.setOnClickListener(this);
		hide_password_iv = (ImageView) findViewById(R.id.hide_password_iv);
		hide_password_iv.setOnClickListener(this);

		clean_con_password_iv = (ImageView) findViewById(R.id.clean_con_password_iv);
		clean_con_password_iv.setOnClickListener(this);
		hide_con_password_iv = (ImageView) findViewById(R.id.hide_con_password_iv);
		hide_con_password_iv.setOnClickListener(this);

		password_et = (EditText) findViewById(R.id.password_et);
		password_et.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				if (s.length() > 0) {
					clean_password_iv.setVisibility(View.VISIBLE);
					hide_password_iv.setVisibility(View.VISIBLE);
				} else {
					clean_password_iv.setVisibility(View.GONE);
					hide_password_iv.setVisibility(View.GONE);
				}
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {
			}
		});

		confirm_password_et = (EditText) findViewById(R.id.confirm_password_et);
		confirm_password_et
				.setOnFocusChangeListener(new OnFocusChangeListener() {
					@Override
					public void onFocusChange(View v, boolean hasFocus) {
						if (!hasFocus) {
							String password = password_et.getText().toString();
							String passwordConfirm = confirm_password_et
									.getText().toString();
							if (!TextUtils.isEmpty(passwordConfirm)) {
								if (!password.equals(passwordConfirm)) {
									confirm_password_et.setText("");
									PublicViews.ShowErrorDialog(mcontext, "密码不一致");
								}
							}
						}
					}
				});

		confirm_password_et.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				if (s.length() > 0) {
					clean_con_password_iv.setVisibility(View.VISIBLE);
					hide_con_password_iv.setVisibility(View.VISIBLE);
				} else {
					clean_con_password_iv.setVisibility(View.GONE);
					hide_con_password_iv.setVisibility(View.GONE);
				}
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {
			}
		});
		
		finish_bt = (Button) findViewById(R.id.finish_bt);
		finish_bt.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.left_bt:
			finish();
			break;

		case R.id.send_verification_bt:
			String phone = phone_et.getText().toString();
			if (StringUtils.isNotBlank(phone)) {
				sendVerification(phone);
			} else {
				PublicViews.ShowErrorDialog(mcontext, "请填写手机号");
				return;
			}
			break;
		case R.id.clean_password_iv:
			password_et.setText("");
			break;
		case R.id.hide_password_iv:
			if (isPasswordHidden) {
				// 设置EditText文本为可见的
				password_et
						.setTransformationMethod(HideReturnsTransformationMethod
								.getInstance());
			} else {
				// 设置EditText文本为隐藏的
				password_et
						.setTransformationMethod(PasswordTransformationMethod
								.getInstance());
			}
			isPasswordHidden = !isPasswordHidden;
			password_et.postInvalidate();
			break;

		case R.id.clean_con_password_iv:
			confirm_password_et.setText("");
			break;

		case R.id.hide_con_password_iv:
			if (isConPasswordHidden) {
				// 设置EditText文本为可见的
				confirm_password_et
						.setTransformationMethod(HideReturnsTransformationMethod
								.getInstance());
			} else {
				// 设置EditText文本为隐藏的
				confirm_password_et
						.setTransformationMethod(PasswordTransformationMethod
								.getInstance());
			}
			isConPasswordHidden = !isConPasswordHidden;
			confirm_password_et.postInvalidate();
			break;

		case R.id.finish_bt:
			String phoneNum = phone_et.getText().toString();
			if (!StringUtils.isNotBlank(phoneNum)) {
				PublicViews.ShowErrorDialog(mcontext, "请填写手机号");
				return;
			}

			String verificationCode = verification_code_et.getText().toString();
			if (!StringUtils.isNotBlank(verificationCode)) {
				PublicViews.ShowErrorDialog(mcontext, "请填写验证码");
				return;
			}

			String password = password_et.getText().toString();
			if (!StringUtils.isNotBlank(password)) {
				PublicViews.ShowErrorDialog(mcontext, "请填写登录密码");
				return;
			}

			String passwordConfirm = confirm_password_et.getText().toString();
			if (!StringUtils.isNotBlank(passwordConfirm)) {
				PublicViews.ShowErrorDialog(mcontext, "请填写密码确认");
				return;
			}

			if (!password.equals(passwordConfirm)) {
				PublicViews.ShowErrorDialog(mcontext, "密码不一致");
				return;
			}
//			MyApplication.userAccount = phone_et.getText().toString();
//			Intent intent = new Intent(ForgetPasswordActivity.this, LoginActivity.class);
//			startActivity(intent);
			callForgetPassword(phoneNum, verificationCode, password);

			break;
		default:
			break;
		}
	}

	/**
	 * 发送验证码
	 */
	private void sendVerification(String phoneNum) {
		Map<String, String> source = new HashMap<String, String>();
		source.put("phone", phoneNum);
		source.put("interfaceType", "J");
		FinalHttpClient.getInstance().post(RequestURL.GetVerificationUrl, source, new FinalHttpClient.OnRequestListener() {
			@Override
			public void onFinish(JsonResponse response) {
				hideLoading();
				if (response.isSuccess()) {
					ToastUtil.showBaseToast(mcontext,"验证码已发送！");

					mc = new MyCountDownTimer(60000, 1000);
					mc.start();
					send_verification_bt.setVisibility(View.GONE);
					count_down_tv.setVisibility(View.VISIBLE);
				} else{
					PublicViews.ShowErrorDialog(mcontext,"获取验证码失败，请稍候再试！");
				}
			}
		});

	}

	/**
	 * 调用忘记密码接口
	 *
	 * @param phoneNum
	 * @param verificationCode
	 * @param password
	 */
	private void callForgetPassword(String phoneNum, String verificationCode,
									String password) {
		showLoading();
		Map<String, String> source = new HashMap<String, String>();
		source.put("phone", phoneNum);
		source.put("password", Md5Util.MD5(password));
		source.put("code", verificationCode);
		FinalHttpClient.getInstance().post(RequestURL.ModifyPasswordByCode, source, new FinalHttpClient.OnRequestListener() {
			@Override
			public void onFinish(JsonResponse response) {
				hideLoading();
				if (response.isSuccess()) {
					shortToast("修改密码成功");
				} else{
					PublicViews.ShowErrorDialog(mcontext,response.getError());
					Logger.e(TAG, response.getError());
				}
			}
		});
	}

	class MyCountDownTimer extends CountDownTimer {

		/**
		 * 
		 * @param millisInFuture
		 *            表示以毫秒为单位 倒计时的总数 例如 millisInFuture=1000 表示1秒
		 * @param countDownInterval
		 *            表示 间隔 多少微秒 调用一次 onTick 方法 例如: countDownInterval=1000 ;
		 *            表示每1000毫秒调用一次onTick()
		 */
		public MyCountDownTimer(long millisInFuture, long countDownInterval) {
			super(millisInFuture, countDownInterval);
		}

		@Override
		public void onFinish() {
			count_down_tv.setVisibility(View.GONE);
			send_verification_bt.setVisibility(View.VISIBLE);
		}

		@Override
		public void onTick(long millisUntilFinished) {
			count_down_tv.setText(millisUntilFinished / 1000 + "秒重新发送");
		}
	}
}
