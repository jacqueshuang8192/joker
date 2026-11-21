package com.hbi.controller.charge;

import com.core.util.ConfigUtil;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 这个是sf支付的url
 */
public class URL {
    //下单
    public final static String down_order = "http://f.dotcore.cn//remote/make_prepare_pay.remote";
    //查询订单状态
    public final static String query_status = "http://f.dotcore.cn//remote/query_order_status.remote";
    //支付跳转
    public final static String pay = "http://f.dotcore.cn//remote/pay_page_skip.remote";
    //获取二维码
    public final static String get_code = "http://f.dotcore.cn/remotePay/getCode.remote?";
    //代付
    public final static String merchant_withdraw = "http://f.dotcore.cn/remote/merchant_withdraw.remote";
    //余额查询
    public final static String get_balance_balance = "http://f.dotcore.cn//remote/get_balance_balance.remote";//"c2538ca8-da3b-43a6-bd5e-ab286fd09bd1";//"c19fe17a-a3cf-4c82-ab21-8590388f5688";//"8f7e861c-c63f-4143-81d6-4b2f76fd5bc2";//"11d2ad6a-2630-41d6-b934-ff3c12c0241d";
    //代付查询
    public final static String query_order_status = "http://f.dotcore.cn/remote/query_order_status.remote";

    public final static String key = ConfigUtil.get("sf.pay.key");
    public final static String appid = ConfigUtil.get("sf.pay.appid");
    public final static String returnUrl = ConfigUtil.get("sf.pay.callback");
    public final static String myKey = ConfigUtil.get("sf.pay.myKey");
    public final static int version = Integer.parseInt(ConfigUtil.get("sf.pay.version"));


//    骏付通的地址
    public final static String post_url_jft = "http://order.z.jtpay.com/jh-web-order/order/receiveOrder";

}