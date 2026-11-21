package com.linkxin.douyouPlayer.dialog;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.login.Login;
import com.linkxin.douyouPlayer.utils.StringUtils;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.Md5Util;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.view.PublicViews;

import java.util.HashMap;
import java.util.Map;

public class ThirdPartyRegistDialog extends Dialog implements
        OnClickListener {

    private Context context;
    private BaseActivity activity;
    private Map<String, String> params;

    private LinearLayout input_phone_ll, input_verification_ll, input_password_ll;
    private TextView title_tv, send_verification_tv, input_verification_front_step_tv,
            input_verification_next_step_tv, input_password_front_step_tv, regist_tv;
    private ImageButton close_ib;
    private EditText phone_et, verification_et, password_et;

    public ThirdPartyRegistDialog(BaseActivity context) {
        super(context);
        this.context = context;
        this.activity = context;
    }

    public ThirdPartyRegistDialog(BaseActivity context, int theme, Map<String, String> params) {
        super(context, theme);
        this.context = context;
        this.activity = context;
        this.params = params;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dialog_third_party_regist);
        initView();
    }

    private void initView() {
        title_tv = (TextView) findViewById(R.id.title_tv);
        close_ib = (ImageButton) findViewById(R.id.close_ib);
        close_ib.setOnClickListener(this);

        input_phone_ll = (LinearLayout) findViewById(R.id.input_phone_ll);
        phone_et = (EditText) findViewById(R.id.phone_et);
        send_verification_tv = (TextView) findViewById(R.id.send_verification_tv);
        send_verification_tv.setOnClickListener(this);

        input_verification_ll = (LinearLayout) findViewById(R.id.input_verification_ll);
        verification_et = (EditText) findViewById(R.id.verification_et);
        input_verification_front_step_tv = (TextView) findViewById(R.id.input_verification_front_step_tv);
        input_verification_front_step_tv.setOnClickListener(this);
        input_verification_next_step_tv = (TextView) findViewById(R.id.input_verification_next_step_tv);
        input_verification_next_step_tv.setOnClickListener(this);

        input_password_ll = (LinearLayout) findViewById(R.id.input_password_ll);
        password_et = (EditText) findViewById(R.id.password_et);
        input_password_front_step_tv = (TextView) findViewById(R.id.input_password_front_step_tv);
        input_password_front_step_tv.setOnClickListener(this);
        regist_tv = (TextView) findViewById(R.id.regist_tv);
        regist_tv.setOnClickListener(this);

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.close_ib:
                this.dismiss();

                if(params.get("wechat") != null){
                    activity.finish();
                }

                break;
            case R.id.send_verification_tv:
                String phone = phone_et.getText().toString();
                if (TextUtils.isEmpty(phone) || phone.length() != 11) {
                    PublicViews.ShowErrorDialog(context, "请输入正确的手机号码");
                } else {
                    verifyPhoneAndSendVerification(phone);
                }
                break;
            case R.id.input_verification_front_step_tv:
                showInputPhone();
                break;
            case R.id.input_verification_next_step_tv:
                String verification = verification_et.getText().toString();
                if (TextUtils.isEmpty(verification) || verification.length() != 6) {
                    PublicViews.ShowErrorDialog(context, "请输入正确的验证码");
                } else {
                    showInputPassword();
                }
                break;
            case R.id.input_password_front_step_tv:
                showInputVerification();
                break;
            case R.id.regist_tv:
                regist();
                break;
            default:
                break;
        }
    }

    /**
     * 显示输入手机号码
     */
    private void showInputPhone() {
        title_tv.setText("手机号");
        input_verification_ll.setVisibility(View.GONE);
        input_password_ll.setVisibility(View.GONE);
        input_phone_ll.setVisibility(View.VISIBLE);
    }

    /**
     * 显示输入验证码
     */
    private void showInputVerification() {
        title_tv.setText("验证码");
        input_phone_ll.setVisibility(View.GONE);
        input_password_ll.setVisibility(View.GONE);
        input_verification_ll.setVisibility(View.VISIBLE);
    }

    /**
     * 显示输入密码
     */
    private void showInputPassword() {
        title_tv.setText("设置密码");
        input_phone_ll.setVisibility(View.GONE);
        input_verification_ll.setVisibility(View.GONE);
        input_password_ll.setVisibility(View.VISIBLE);
    }

    /**
     * 验证手机号码并获取验证码
     *
     * @param phoneNum
     */
    private void verifyPhoneAndSendVerification(final String phoneNum) {
        activity.showLoading();
        Map<String, String> sources = new HashMap<String, String>();
        sources.put("phone", phoneNum);
        FinalHttpClient.getInstance().post(RequestURL.IS_PHONE_EXIST_URL, sources, new FinalHttpClient.OnRequestListener() {
            @Override
            public void onFinish(JsonResponse response) {
                if (response.isSuccess()) {
                    if (TextUtils.equals("true", response.getData())) {
                        activity.hideLoading();
                        PublicViews.ShowErrorDialog(context, "手机号码已被注册");
                    } else {
                        sendVerification(phoneNum);
                    }
                }
            }
        });
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
                activity.hideLoading();
                if (response.isSuccess()) {
                    showInputVerification();
                    PublicViews.ShowDialog(context, "提示", "验证码已发送！", "知道啦", null);

                } else {
                    PublicViews.ShowErrorDialog(context, "获取验证码失败，请稍候再试！");
                }
            }
        });
    }

    /**
     * 调用注册接口
     */
    private void regist() {
        final String phone = phone_et.getText().toString();
        if (!StringUtils.isMobile(phone)) {
            PublicViews.ShowErrorDialog(context, "请输入合法手机号码");
            return;
        }

        String verificationCode = verification_et.getText().toString();
        final String password = password_et.getText().toString();
        if (TextUtils.isEmpty(password)) {
            PublicViews.ShowErrorDialog(context, "请输入密码");
            return;
        }

        params.put("phone", phone);
        // 密码MD5加密
        params.put("password", Md5Util.MD5(password));
        params.put("code", verificationCode);
        params.put("roomPhoto", params.get("photo"));
        params.put("livePhoto", params.get("photo"));
        activity.showLoading();
        FinalHttpClient.getInstance().post(RequestURL.REGIST_URL, params, new FinalHttpClient.OnRequestListener() {
            @Override
            public void onFinish(JsonResponse response) {

                if (response.isSuccess()) {
                    SPUtil.onRegisterSuccess(activity, phone, password);
                    MyApplication.userAccount = phone;

                    View.OnClickListener onClickListener = new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            ThirdPartyRegistDialog.this.dismiss();
//                            new Login(activity).loginDouyou(phone, password);
                        }
                    };
                    activity.hideLoading();
                    PublicViews.ShowDialog(context, "提示", "注册成功", "知道啦", onClickListener);
                } else {
                    activity.hideLoading();
                    if (TextUtils.equals("201", response.getData())) {
                        PublicViews.ShowErrorDialog(context, "手机已被注册");
                    } else if (TextUtils.equals("105", response.getData())) {
                        PublicViews.ShowErrorDialog(context, "验证码错误，请重新输入");
                    } else {
                        PublicViews.ShowErrorDialog(context, response.getError());
                    }
                }
            }
        });
    }

}
