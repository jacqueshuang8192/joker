package com.linkxin.douyouPlayer.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.pingplusplus.android.Pingpp;
import com.pingplusplus.android.PingppLog;
import com.pingplusplus.libone.PaymentHandler;
import com.pingplusplus.libone.PingppOne;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by Administrator on 2017-02-14.
 */
public class PayUtils {

    // 银联支付渠道
    private static final String CHANNEL_UPACP = "upacp";

    // 微信支付渠道
    private static final String CHANNEL_WECHAT = "wx";

    // 微信支付渠道
    private static final String CHANNEL_QPAY = "qpay";

    // 支付支付渠道
    private static final String CHANNEL_ALIPAY = "alipay";

    // 百度支付渠道
    private static final String CHANNEL_BFB = "bfb";

    // 京东支付渠道
    private static final String CHANNEL_JDPAY_WAP = "jdpay_wap";

    /**
     * 发起ping++支付
     */
    public static void PayWithPing(Activity context , String data){
        Pingpp.createPayment(context, data, "qwalletapp_0CmDuTGif9GOa9Ki");
    }

    /**
     * 发起ping++ One支付
     */
//    public static void PayWithPingOne(FragmentActivity activity){
//
//        Pingpp.enableDebugLog(true);
//
//        // 设置需要使用的支付方式
//        PingppOne.enableChannels(new String[]{CHANNEL_WECHAT, CHANNEL_ALIPAY, CHANNEL_UPACP});
//
//        // 提交数据的格式，默认格式为json
//        PingppOne.CONTENT_TYPE = "application/json";
//
//        PingppLog.DEBUG = true;
//
//        // 产生个订单号
//        String orderNo = new SimpleDateFormat("yyyyMMddhhmmss").format(new Date());
//
//        // 计算总金额（以分为单位）
//        int amount = 0;
//        JSONArray billList = new JSONArray();
//        Good good = new Good();
//        good.setName("橡胶花盆");
//        good.setCount(1);
//        good.setImgRes(R.drawable.ic_launcher);
//        good.setPrice(0.02f);
//
//        amount += good.getPrice() * good.getCount() * 100;
//        billList.put(good.getName() + " x " + good.getCount());
//
//        // 构建账单json对象
//        JSONObject bill = new JSONObject();
//
//        // 自定义的额外信息 选填
//        JSONObject extras = new JSONObject();
//        try {
//            extras.put("extra1", "extra1");
//            extras.put("extra2", "extra2");
//        } catch (JSONException e) {
//            e.printStackTrace();
//        }
//
//        try {
//            bill.put("order_no", orderNo);
//            bill.put("amount", amount);
//            bill.put("extras", extras);
//        } catch (JSONException e) {
//            e.printStackTrace();
//        }
//
//        //壹收款: 创建支付通道的对话框
//        PaymentHandler handler = new PaymentHandler() {
//            @Override
//            public void handlePaymentResult(Intent data) {
//
//                if (data != null) {
//                    /**
//                     * code：支付结果码  -2:服务端错误、 -1：失败、 0：取消、1：成功
//                     * error_msg：支付结果信息
//                     */
//                    int code = data.getExtras().getInt("code");
//                    String errorMsg = data.getExtras().getString("error_msg");
//                }
//
//            }
//        };
//        PingppOne.showPaymentChannels(activity.getSupportFragmentManager(), bill.toString(), RequestURL.Ping_Charge_URL, handler);
//
//    }
//
//    public static class Good {
//        private String name;
//        private int imgRes;
//        private int count;
//        private float price;
//
//        public Good(){
//        }
//        public int getCount() {
//            return count;
//        }
//
//        public float getPrice() {
//            return price;
//        }
//
//        public void setPrice(float price) {
//            this.price = price;
//        }
//
//        public void setCount(int count) {
//            this.count = count;
//        }
//
//        public void setImgRes(int imgRes) {
//
//            this.imgRes = imgRes;
//        }
//
//        public void setName(String name) {
//
//            this.name = name;
//        }
//
//        public int getImgRes() {
//
//            return imgRes;
//        }
//
//        public String getName() {
//            return name;
//        }
//    }

}
