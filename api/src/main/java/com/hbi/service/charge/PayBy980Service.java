package com.hbi.service.charge;

import com.alibaba.fastjson.JSONObject;
import com.core.rfUtil.Md5;
import com.core.util.ConfigUtil;
import com.core.util.StringUtil;
import com.hbi.constants.Constants;
import com.hbi.controller.charge.URL;
import com.hbi.mapper.ImsTpOrdersMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.ImsGoods;
import com.hbi.model.ImsTpOrders;
import com.hbi.model.TUser;
import com.hbi.service.common.GoodsService;
import com.hbi.utils.InfServerException;
import com.hbi.utils.XMLUtil;
import com.hbi.utils.yeepay.HttpClient4Utils;
import com.hbi.utils.yeepay.HttpClientUtil;
import com.hbi.vo.response.Response;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.*;
import java.math.BigInteger;
import java.net.URLDecoder;
import java.security.MessageDigest;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class PayBy980Service extends BaseChargeService{

    private static Logger logger = Logger.getLogger(PayBy980Service.class);

    @Autowired
    private GoodsService goodsService;
    @Autowired
    private ImsTpOrdersMapper imsTpOrdersMapper;
    @Autowired
    private TUserMapper userMapper;


    public Map payOrder(Long userId, Long goodsId, Integer amount, String payType) {
        Response response = new Response();
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是980");
        //商户号id
        String pay_memberid=ConfigUtil.get("pay.980.id");
        //商户密钥
        String key=ConfigUtil.get("pay.980.key");
        //订单id
        long l = System.currentTimeMillis() / 1000;
        String pay_orderid =  pay_memberid + "-" + l + "-" + userId;
        //订单金额
        Double pay_amount = goods.getPrice() * amount/100D;
        //订单时间
        String pay_applydate = String.valueOf(l);
        String pay_bankcode=payType;
        String pay_notifyurl=ConfigUtil.get("pay.980.callBack");
        String pay_callbackurl=ConfigUtil.get("pay.980.callBack");
        String tongdao=ConfigUtil.get("pay.980.tongdao");

        StringBuilder sb = new StringBuilder();
        sb.append("pay_amount=>").append(pay_amount).append("&pay_applydate=>").append(pay_applydate).append("&pay_bankcode=>").
                append(pay_bankcode).append("&pay_callbackurl=>").append(pay_callbackurl).append("&pay_memberid=>").append(pay_memberid).
                append("&pay_notifyurl=>").append(pay_notifyurl).append("&pay_orderid=>").append(pay_orderid).append("&key=").append(key);
        String pay_md5sign = Md5.getMd5ofStr(sb.toString()).toUpperCase();

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("url",ConfigUtil.get("pay.980.url"));
        Map<String,String> map = new HashMap<String,String>();
        map.put("pay_memberid",pay_memberid);
        map.put("pay_orderid",pay_orderid);
        map.put("pay_amount",String.valueOf(pay_amount));
        map.put("pay_applydate",pay_applydate);
        map.put("pay_bankcode",pay_bankcode);
        map.put("pay_notifyurl",pay_notifyurl);
        map.put("pay_callbackurl",pay_callbackurl);
        map.put("tongdao",tongdao);
        map.put("pay_md5sign",pay_md5sign);
        map.put("url",ConfigUtil.get("pay.980.url"));
        jsonObject.put("param",map);

//        if (StringUtils.isNotBlank(imgCode)){
            ImsTpOrders imsTpOrders = new ImsTpOrders();
            imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
            imsTpOrders.setPrice(goods.getPrice()*amount/100D);
            imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
            Calendar cal = Calendar.getInstance();
            int year = cal.get(Calendar.YEAR);
            int month = cal.get(Calendar.MONTH )+1;

            imsTpOrders.setYear(year);
            imsTpOrders.setMonth(month);
            imsTpOrders.setType(1);
            imsTpOrders.setUserId(0);
            imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

            imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
            imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
            imsTpOrders.setCount(amount);
            imsTpOrders.setOrderNo(pay_orderid);

            TUser tUser = userMapper.findById(userId);
            if (tUser.getAgentId() != null) {
                imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
            }
            imsTpOrdersMapper.insert(imsTpOrders);
            //}

//        } else {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的网络异常!!");
//        }
        response.setData(jsonObject);
        return map;
    }

    public Response payOrderNiu(Long userId, Long goodsId, Integer amount, String type) {

        Response response = new Response();
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("比奇订单支付接口");
        //商户号id
        String serverId=ConfigUtil.get("niu.serverId");
        String key=ConfigUtil.get("niu.key");
        String channelNum=ConfigUtil.get("niu.channelNum");
        String PostUrl=ConfigUtil.get("niu.PostUrl");
        //支付类型
        String payType = "3";
        switch (type.toUpperCase().charAt(0)) {
            case 'W':
                payType = "3";
                break;
            case 'Z':
                payType = "1";
                break;
            default:
                break;
        }
        //订单金额
//        Double value = goods.getPrice() * amount/100D;
        int value = goods.getPrice();
        //订单id
        long l = System.currentTimeMillis();
        String gameOrderId =  channelNum + "1" + l + "1" + userId;

        String gameNotifyUrl=ConfigUtil.get("niu.NotifyUrl");

        //sigin
        StringBuilder sb = new StringBuilder();
        sb.append("channel_num=").append(channelNum)
                .append("&gameNotifyUrl=").append(gameNotifyUrl)
                .append("&gameOrderId=").append(gameOrderId)
                .append("&payType=").append(payType)
                .append("&pay_money=").append(value)
                .append("&recharge_gold=").append("0")
                .append("&serverId=").append(serverId)
                .append("&userId=").append(userId+key);
        String sign = Md5.getMd5ofStr(sb.toString());



        Map<String,String> map = new HashMap<String,String>();
        map.put("gameOrderId",gameOrderId);
        map.put("serverId",serverId);
        map.put("userId",userId+"");
        map.put("pay_money",value+"");
        map.put("recharge_gold","0");
        map.put("channel_num",channelNum);
        map.put("payType",payType);
        map.put("gameNotifyUrl",gameNotifyUrl);
        map.put("sign",sign);

        String s = "";
        try {
            s = HttpClientUtil.httpPost(PostUrl,map);
            System.out.println(s);
        } catch (IOException e) {
            e.printStackTrace();
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试");
        }
        JSONObject orderJson = JSONObject.parseObject(s);
        if (StringUtil.isEmpty(s) || null == orderJson.getString("status") || "1".equals(orderJson.getString("status")) ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常,请稍后再试");
        }
        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
        imsTpOrders.setPrice(goods.getPrice()*amount/100D);
        imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH )+1;

        imsTpOrders.setYear(year);
        imsTpOrders.setMonth(month);
        imsTpOrders.setType(1);
        imsTpOrders.setUserId(0);
        imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

        imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
        imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
        imsTpOrders.setCount(amount);
        imsTpOrders.setOrderNo(gameOrderId);
        imsTpOrders.setWxOrderNum(orderJson.getString("orderId"));
        imsTpOrders.setThirdpartyOrderNum(sign);

        TUser tUser = userMapper.findById(userId);
        if (tUser.getAgentId() != null) {
            imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
        }
        imsTpOrdersMapper.insert(imsTpOrders);

        response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("pay_money",value);
        jsonObject.put("myOrderId",gameOrderId);
        jsonObject.put("biqiOrderId",orderJson.getString("orderId"));
        jsonObject.put("payType",type);
        jsonObject.put("token_id",orderJson.getString("token_id"));
        jsonObject.put("appid",orderJson.getString("appid"));
        response.setData(jsonObject);
        return response;
//        return map;
    }

    private String  map2UrlProm(Map<String, String> map) {
        Set<String> strings = map.keySet();
        String str = "";
        for (String key : strings) {
            str += key;
            str += "=";
            str += (String)map.get(key);
            str += "&";
        }
        if (null != str) {
            str  = str.substring(0, str.length() - 1);
        }
        return str;
    }

    public String payOrderCallback(String memberid, String orderid, String datetime, String returncode, Long amount, String sign) throws Exception {

        try {
            System.out.println("980支付开始");

            StringBuilder sb = new StringBuilder();
            sb.append("amount=>").append(amount.toString()).append("&datetime=>").append(datetime).append("&memberid=>").append(memberid).
                    append("&orderId=>").append(orderid).append("&returncode=>").append(returncode).append("&key=>").append(ConfigUtil.get("pay.980.key"));

            //签名成功
            if ( null != sb && sb.toString().toUpperCase().equals(sign)) {
                if (null != returncode && returncode.equals("00")) {
                    //如果到这里了，就证明处理成功了，则做逻辑处理
                    payOrderCallbackTest2(orderid);
                }

            }else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL,"非法平台签名!!");
            }

            return "ok";
        } catch (Exception e) {
            throw e;
            //logger.info("充值失败：" + orderId + "xx" + e.getMessage());
            //jsonObject.put("success","false");
            //return jsonObject.toString();
        } finally {

        }
    }


    //荣州支付
    public Map rongZhouPayOrder(Long userId, Long goodsId, Integer amount, String payType) {
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是荣州");
        //商户号id
        String parter=ConfigUtil.get("rong.zhou.parterId");
        //支付类型
        String type = "1005";
        switch (payType.toUpperCase().charAt(0)) {
            case 'W':
                type = "1005";
                break;
            case 'Z':
                type = "1006";
                break;
            case 'Y':
                type = "2088";
            default:
                break;
        }
        //订单金额
        Double value = goods.getPrice() * amount/100D;
        System.out.println(goods.getPrice());
        System.out.println(goods.getPrice()*amount*1D);
        System.out.println(amount);
        //订单id
        long l = System.currentTimeMillis() / 1000;
        String orderid =  parter + "-" + l + "-" + userId;

        String callbackurl=ConfigUtil.get("rong.zhou.callBack");
        String refbackurl=ConfigUtil.get("rong.zhou.refbackurl");
        String payerIp=ConfigUtil.get("rong.zhou.payerIp");
        //商户密钥
        String key=ConfigUtil.get("rong.zhou.key");
        String attach = "测试";

        //sigin
        StringBuilder sb = new StringBuilder();
        sb.append("parter=").append(parter).append("&type=").append(type).append("&value=").append(value).append("&orderid=").
                append(orderid).append("&callbackurl=").append(callbackurl);
        String sign = Md5.getMd5ofStr(sb.toString()).toLowerCase();



        Map<String,String> map = new HashMap<String,String>();
        map.put("parter",parter);
        map.put("type",type);
        map.put("value",String.valueOf(value));
        map.put("orderid",orderid);
        map.put("callbackurl",callbackurl);
        map.put("hrefbackurl",refbackurl);
        map.put("payerIp ",payerIp );
        map.put("attach",attach);
        map.put("sign",sign);
        map.put("url",ConfigUtil.get("rong.zhou.url"));

//        if (StringUtils.isNotBlank(imgCode)){
        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
        imsTpOrders.setPrice(goods.getPrice()*amount/100D);
        imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH )+1;

        imsTpOrders.setYear(year);
        imsTpOrders.setMonth(month);
        imsTpOrders.setType(1);
        imsTpOrders.setUserId(0);
        imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

        imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
        imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
        imsTpOrders.setCount(amount);
        imsTpOrders.setOrderNo(orderid);

        TUser tUser = userMapper.findById(userId);
        if (tUser.getAgentId() != null) {
            imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
        }
        imsTpOrdersMapper.insert(imsTpOrders);
        //}

//        } else {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的网络异常!!");
//        }
        return map;
    }

    public Map qilinPayOrder (Long userId, Long goodsId, Integer amount, String payType) {
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付使用麒麟支付");

        String isType = "3";
        switch (payType.toUpperCase().charAt(0)) {
            case 'W':
                isType = "3";
                break;
            case 'Z':
                isType = "1";
                break;
            case 'Q':
                isType = "4";
            default:
                break;
        }
        //订单金额
        int price = goods.getPrice() * amount/100;

        //订单id
        String payUid = ConfigUtil.get("qilin.uid");
        String token = ConfigUtil.get("qilin.Token");
        String goodsName = goods.getName();
        String notifyUrl = ConfigUtil.get("qilin.notify_url");
        String returnUrl = ConfigUtil.get("qilin.return_url");
        String version = "2";

        long l = System.currentTimeMillis() / 1000;
        String orderid =  payUid + "-" + l + "-" + userId;


        Map<String,String> map = new HashMap<String,String>();
        map.put("uid",payUid);
        map.put("price",price+"");
        map.put("istype",isType);
        map.put("notify_url",notifyUrl);
        map.put("return_url",returnUrl);
        map.put("orderid", orderid);
        map.put("version",version);
        map.put("goodsname",goodsName);
        map.put("orderuid",userId+"");

        String keyString = "goodsname=" + goodsName + "&istype=" + isType + "&notify_url=" + notifyUrl + "&orderid=" + orderid + "&orderuid=" + userId + "&price=" + price + "&return_url=" + returnUrl + "&token=" + token + "&uid=" + payUid + "&version=" + version;
        String keyMd5 = Md5.getMd5ofStr(keyString);
        map.put("key",keyMd5.toLowerCase());

        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
        imsTpOrders.setPrice(goods.getPrice()*amount/100D);
        imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH )+1;

        imsTpOrders.setYear(year);
        imsTpOrders.setMonth(month);
        imsTpOrders.setType(1);
        imsTpOrders.setUserId(0);
        imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

        imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
        imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
        imsTpOrders.setCount(amount);
        imsTpOrders.setOrderNo(orderid);

        TUser tUser = userMapper.findById(userId);
        if (tUser.getAgentId() != null) {
            imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
        }
        imsTpOrdersMapper.insert(imsTpOrders);

        return map;

    }


    public Map maZhiFuPayOrder (Long userId, Long goodsId, Integer amount, String payType) throws UnsupportedEncodingException {
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是码支付");
        //商户号id
//        String parter=URL.post_url_jft;
        //支付类型
        String type = "3";
        switch (payType.toUpperCase().charAt(0)) {
            case 'W':
                type = "3";
                break;
            case 'Z':
                type = "1";
                break;
            case 'Q':
                type = "2";
            default:
                break;
        }
        //订单金额
        System.out.println(goods.getPrice() + amount);
        int value = goods.getPrice() * amount/100;

        //订单id
        String codepayId = ConfigUtil.get("mazhifu.codepayId");
        String token = ConfigUtil.get("mazhifu.token");


        long l = System.currentTimeMillis() / 1000;
        String orderid =  codepayId + "-" + l + "-" + userId;


        Map<String,String> map = new HashMap<String,String>();
        map.put("price",value+"");
        map.put("type",type);
        map.put("pay_id",orderid);
        map.put("fenghuang","cheng");
        map.put("notify_url",ConfigUtil.get("mazhifu.notify_url"));
        map.put("return_url",ConfigUtil.get("mazhifu.return_url"));
        map.put("token",token);
        map.put("id",codepayId);
//        map.put("param",orderid);

        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
        imsTpOrders.setPrice(goods.getPrice()*amount/100D);
        imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH )+1;

        imsTpOrders.setYear(year);
        imsTpOrders.setMonth(month);
        imsTpOrders.setType(1);
        imsTpOrders.setUserId(0);
        imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

        imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
        imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
        imsTpOrders.setCount(amount);
        imsTpOrders.setOrderNo(orderid);

        TUser tUser = userMapper.findById(userId);
        if (tUser.getAgentId() != null) {
            imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
        }
        imsTpOrdersMapper.insert(imsTpOrders);

        return map;


    }

    public Map junfutongPayOrder(Long userId, Long goodsId, Integer amount, String payType) throws UnsupportedEncodingException {
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是骏付通");
        //商户号id
//        String parter=URL.post_url_jft;
        //支付类型
        String type = "WX";
        switch (payType.toUpperCase().charAt(0)) {
            case 'W':
                type = "WX";
                break;
            case 'Z':
                type = "ZFB";
                break;
            case 'Y':
                type = "2088";
            default:
                break;
        }
        //订单金额
        System.out.println(goods.getPrice() + amount);
        Double value = goods.getPrice() * amount/100D;
        System.out.println(value);
        DecimalFormat df = new DecimalFormat("#.00");
        String value1 = df.format(value);
        //终端设备
        String p25_terminal = "1";

        //订单id
        String p1_yingyongnum = ConfigUtil.get("jft.pay.yingyongnum");


        long l = System.currentTimeMillis() / 1000;
        String orderid =  p1_yingyongnum + "-" + l + "-" + userId;

        //商户密钥
        String key=ConfigUtil.get("jft.pay.key");
        String p14_customname = userId+"";

        String dtLong = "yyyyMMddHHmmss";

        String p6_ordertime = new SimpleDateFormat(dtLong).format(new Date());

        String before = p1_yingyongnum+"&"+orderid+"&"+value1+"&"+p6_ordertime+"&"+type+"&"+key;
        System.out.println(before + "brfore");

        //sigin
        String p8_sign = Md5.getMd5ofStr(p1_yingyongnum+"&"+orderid+"&"+value1+"&"+p6_ordertime+"&"+type+"&"+key);
//        String p8_sign = encoding(before.getBytes("UTF-8"));

        System.out.println(p8_sign + "sign");


//        String p9_signtype = "1";
        String p16_customip = "127_0_0_1";
        String p26_ext1 = "1.1";

        Map<String,String> map = new HashMap<String,String>();
        map.put("p1_yingyongnum",p1_yingyongnum);
        map.put("p2_ordernumber",orderid);
        map.put("p3_money",value1+"");
        map.put("p6_ordertime",p6_ordertime);
        map.put("p7_productcode",type);
        map.put("p8_sign",p8_sign );
        map.put("p14_customname",p14_customname);
        map.put("p16_customip",p16_customip);
//        map.put("p25_terminal",p25_terminal);
        map.put("p26_ext1",p26_ext1);
        map.put("url",URL.post_url_jft);

        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
        imsTpOrders.setPrice(goods.getPrice()*amount/100D);
        imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH )+1;

        imsTpOrders.setYear(year);
        imsTpOrders.setMonth(month);
        imsTpOrders.setType(1);
        imsTpOrders.setUserId(0);
        imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

        imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
        imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
        imsTpOrders.setCount(amount);
        imsTpOrders.setOrderNo(orderid);
        imsTpOrders.setThirdpartyOrderNum(p8_sign);

        TUser tUser = userMapper.findById(userId);
        if (tUser.getAgentId() != null) {
            imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
        }
        imsTpOrdersMapper.insert(imsTpOrders);
        //}

//        } else {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的网络异常!!");
//        }
        return map;
    }


    public String shanyunPayOrder(Long userId, Long goodsId, Integer amount, String payType) throws UnsupportedEncodingException {
        ImsGoods goods = goodsService.findImsGoodsById(goodsId);
        System.out.println("支付用的是闪云支付");
        String type = "0";
        switch (payType.toUpperCase().charAt(0)) {
            case 'W':
                type = "0";
                break;
            case 'Z':
                type = "1";
                break;
            default:
                break;
        }

        HashMap<String,String> map = new HashMap<String, String>();
        //订单金额
        System.out.println(goods.getPrice() + amount);
        Double value = goods.getPrice() * amount/100D;
        String merchant_id = ConfigUtil.get("shanyun.merchantId");
        String buyer = ConfigUtil.get("shanyun.byuer");

        map.put("merchant_id",merchant_id);
        map.put("buyer",buyer);
        DecimalFormat df = new DecimalFormat("#.00");

        String value1 = df.format(value);
        map.put("amount",value1);

        long l = System.currentTimeMillis() / 1000;
        String orderid =  merchant_id + "-" + l + "-" + userId;
        map.put("orderid",orderid);

        map.put("pay_type",type);

        map.put("title","房卡充值");

        String notify_url = ConfigUtil.get("shanyun.notifyUrl");
        map.put("notify_url",notify_url);

        String return_url = ConfigUtil.get("shanyun.returnUrl");
        map.put("return_url",return_url);

        String secretKey = ConfigUtil.get("shanyun.secretKey");
        map.put("secretKey",secretKey);

        Map<String , String> paramMap = getParamString(map);
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : paramMap.entrySet()) {
            sb.append("<input type='text' name=' " + entry.getKey() +  "' value='" + entry.getValue() + "' /><br />");
        }


        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setPlayerId(Integer.parseInt(userId.toString()));
        imsTpOrders.setPrice(goods.getPrice()*amount/100D);
        imsTpOrders.setCreateAt(Long.toString(System.currentTimeMillis()/1000));
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH )+1;

        imsTpOrders.setYear(year);
        imsTpOrders.setMonth(month);
        imsTpOrders.setType(1);
        imsTpOrders.setUserId(0);
        imsTpOrders.setGoodType(Integer.parseInt(goods.getCategoryType()));

        imsTpOrders.setOrderstatus(Integer.parseInt(Constants.PAY_CANCEL));
        imsTpOrders.setGoodsId(Integer.parseInt(goodsId.toString()));
        imsTpOrders.setCount(amount);
        imsTpOrders.setOrderNo(orderid);
        imsTpOrders.setThirdpartyOrderNum(paramMap.get("sign"));

        TUser tUser = userMapper.findById(userId);
        if (tUser.getAgentId() != null) {
            imsTpOrders.setParentId(Integer.parseInt(tUser.getAgentId().toString()));
        }
        imsTpOrdersMapper.insert(imsTpOrders);
        //}
        return sb.toString();
    }

    private Map<String , String> getParamString(HashMap<String , String> paramMap) {

        //存储符合要求的数据map
        HashMap<String, String> paramsSign = new HashMap<String, String>();
        //存储空的map名称
        ArrayList<String> emptyKey = new ArrayList<String>();

        for (Map.Entry<String, String> entry : paramMap.entrySet()) {
            ////计算签名（sign、title,params,secretKey不参加，空值不参加）
            if(!entry.getKey().equals("sign")
                    && !entry.getKey().equals("title")
                    && !entry.getKey().equals("params")
                    && !entry.getKey().equals("secretKey")
                    && !entry.getValue().equals("")) {
                //放入paramsign
                paramsSign.put(entry.getKey(), entry.getValue());
            }
            //值是空的key 存入（遍历是删除map中的数据会报错）
            if(entry.getValue().equals("")) {
                emptyKey.add(entry.getKey());
            }
        }
        //按照key排序
        Map<String , String> mapKeySort = sortMapByKey(paramsSign);
        //获取处理后的url参数
        String httpParam = mapToHttpParam(mapKeySort) + "&" + paramMap.get("secretKey");
        String sign = "";
        try {
            //url解码->md5加密->转大写
            sign = MD5(URLDecoder.decode(httpParam,"UTF-8")).toUpperCase();
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        //放入paramMap中，然后返回
        paramMap.put("sign", sign);
        //删除值是空的数据
        for(String key : emptyKey) {
            paramMap.remove(key);
        }


        return paramMap;
    }
    public String toHex(byte[] bytes) {

        final char[] HEX_DIGITS = "0123456789ABCDEF".toCharArray();
        StringBuilder ret = new StringBuilder(bytes.length * 2);
        for (int i=0; i<bytes.length; i++) {
            ret.append(HEX_DIGITS[(bytes[i] >> 4) & 0x0f]);
            ret.append(HEX_DIGITS[bytes[i] & 0x0f]);
        }
        return ret.toString();
    }


    public String MD5(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(s.getBytes("utf-8"));
            return toHex(bytes);
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public String mapToHttpParam(Map<String , String> map) {
        StringBuilder httpParam = new StringBuilder();
        for(Map.Entry<String, String> entry : map.entrySet()) {
            httpParam.append(entry.getKey() + "=" + entry.getValue() + "&");
        }
        //删除最后一个字符串
        httpParam.deleteCharAt(httpParam.length() - 1);
        return httpParam.toString();
    }
    public Map<String, String> sortMapByKey(Map<String, String> map) {
        if (map == null || map.isEmpty()) {
            return null;
        }
        Map<String, String> sortMap = new TreeMap<String, String>(new MapKeyComparator());
        sortMap.putAll(map);
        return sortMap;
    }



    class MapKeyComparator implements Comparator<String>{
        @Override
        public int compare(String str1, String str2) {
            return str1.compareTo(str2);
        }
    }

//    public final static String encoding(byte[] bs) {
//
//        String encodingStr = null;
//        try {
//            MessageDigest mdTemp = MessageDigest.getInstance("MD5");
//            mdTemp.update(bs);
//
//            return toHexString(mdTemp.digest());
//
//        } catch (Exception e) {
//        }
//
//        return encodingStr;
//    }
//
//    public static String toHexString(byte[] b) {
//        StringBuilder sb = new StringBuilder(b.length * 2);
//        for (int i = 0; i < b.length; i++) {
//            sb.append(hexChar[(b[i] & 0xf0) >>> 4]);
//            sb.append(hexChar[b[i] & 0x0f]);
//        }
//        return sb.toString();
//    }
//
//    private static final char hexChar[] = { '0', '1', '2', '3', '4', '5', '6',
//            '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

    public String payOrderCallbackRongZhou(String orderid, String ovalue, String completiontime, String opstate, String sign, String attach, String msg) throws Exception {
        try {
            System.out.println("荣舟回调支付开始");

            StringBuilder sb = new StringBuilder();
            sb.append("orderid=").append(orderid).append("&opstate=").append(opstate).append("&ovalue=").append(ovalue).append(ConfigUtil.get("rong.zhou.key"));

            //回调失败，则直接结束
            if ( null == opstate && !opstate.equals("0") ) {
                return "opstate=-1";
            }else {

                String sign1 = Md5.getMd5ofStr(sb.toString()).toLowerCase();
                System.out.println(sign + "------");
                System.out.println(sign1 + "+++++++");
                //如果签名错误，直接GG
                if(!StringUtil.isEmpty(sign) && sign.equals(sign1)){
                        payOrderCallbackTest2(orderid);
                        return "opstate=0";
                }

                return "opstate=-1";

            }
        } catch (Exception e) {
            return "opstate=-1";
        } finally {

        }
    }

    public boolean payOrderCallbacShanyun(Map<String,String[]> map) throws Exception {
        try {
            System.out.println("闪云回调支付开始");

            // 新建一个hashMap
            HashMap<String, String> hmap = new HashMap<String, String>();
            for (Map.Entry<String, String[]> entry : map.entrySet()) {
                // System.out.println("Key = " + entry.getKey() + ", Value = " +
                // entry.getValue()[0]);
                // 把获取的参数从新放入hashmap
                hmap.put(entry.getKey(), entry.getValue()[0]);
            }
            // 密钥放入参数中
            hmap.put("secretKey", ConfigUtil.get("shanyun.secretKey"));
            // 返回计算后的参数
            Map<String, String> paramMap = getParamString(hmap);

            if (paramMap.get("sign").equalsIgnoreCase(hmap.get("sign"))) {
                System.out.println(paramMap);
                payOrderCallbackTest2(hmap.get("order_id"));
                return true;
            }else {
                return false;
            }

        } catch (Exception e) {
            logger.error(e);
            return false;
        } finally {

        }
    }

    public String payOrderCallbackBiQi(HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("比奇支付回调 : -->");
        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html;charset=utf-8");
        response.setCharacterEncoding("utf-8");
        PrintWriter out = response.getWriter();
        // 读取参数
        InputStream inputStream;
        inputStream = request.getInputStream();
        BufferedInputStream bis=new BufferedInputStream(inputStream);
        int b=0;
        StringBuilder sb=new StringBuilder();
        while ((b=bis.read())!=-1) {
            sb.append((char)b);

        }
        bis.close();
        System.out.println("比奇回调获得的数据: " + sb.toString());
        // 解析xml成map
        Map<String, String> m = new HashMap<String, String>();
        m = XMLUtil.doXMLParse(sb.toString());

        if (m.isEmpty()) {
            out.print("false");
            out.flush();
            out.close();
            inputStream.close();
            return "false";
        }
        // 过滤空 设置 TreeMap
        SortedMap<Object, Object> packageParams = new TreeMap<Object, Object>();
        Iterator it = m.keySet().iterator();
        while (it.hasNext())
        {
            String parameter = (String) it.next();
            String parameterValue = m.get(parameter);
            String v = "";
            if (null != parameterValue)
            {
                v = parameterValue.trim();
            }
            packageParams.put(parameter, v);
        }
        System.out.println("packageParams is "+packageParams);
        //以下为XML里的所有数据 根据实际需求使用   以上是获取数据

        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setOrderNo(String.valueOf(packageParams.get("gameOrderId")));
        imsTpOrders = imsTpOrdersMapper.selectOne(imsTpOrders);
        if (null == imsTpOrders && !imsTpOrders.getThirdpartyOrderNum().equals(String.valueOf(packageParams.get("sign"))) && "1".equals(String.valueOf(packageParams.get("status")))  ) {
            out.print("false");
            out.flush();
            out.close();
            inputStream.close();
            return "false";
        }

        payOrderCallbackTest2(String.valueOf(packageParams.get("gameOrderId")));

        //比奇支付单号
//        String OrderId = String.valueOf(packageParams.get("OrderId"));
        //你们自己的订单号
//        String gameOrderId = String.valueOf(packageParams.get("gameOrderId"));
        //支付金额
//        String pay_money = String.valueOf(packageParams.get("pay_money"));
        //签名
        String sign = String.valueOf(packageParams.get("sign"));
        //交易状态 status==0代表支付成功 其余失败
//        String status =String.valueOf(packageParams.get("status"));
//        System.out.println("OrderId(比奇单号):"+OrderId+" gameOrderId（支付单号）:"+gameOrderId+" pay_money（支付金额）:"+pay_money+" sign（签名）:"+sign+" status（交易状态0成功）:"+status);
        //根据实际业务逻辑修改（修改判断条件或者做其他处理，交易成功最终需返回success）
        if(null != sign){
            //向比奇返回success
            out.print("success");
            out.flush();
            out.close();
            inputStream.close();
            return "success";
        }
        System.out.println("比奇支付失败 --> 订单号是 : " + imsTpOrders.getOrderNo() );
        return "false";
    }

    public String payOrderCallbackJFT(String p1_yingyongnum, String p2_ordernumber, String p3_money, String p4_zfstate, String p5_orderid, String p6_productcode, String p10_sign, String p11_pdesc, String p12_remark, String p13_zfmoney) throws Exception {
        System.out.println("骏付通回调状态 : -->" + p4_zfstate);

        if (!"1".equals(p4_zfstate)) {
            logger.info("订单" + p2_ordernumber + "回调成功,但是支付结果为未支付!!");
            return "success";
        }


        ImsTpOrders imsTpOrders = new ImsTpOrders();
        imsTpOrders.setOrderNo(p2_ordernumber);
        imsTpOrders = imsTpOrdersMapper.selectOne(imsTpOrders);
        if (null == imsTpOrders && !imsTpOrders.getThirdpartyOrderNum().equals(p10_sign) && "1".equals(p4_zfstate)  ) {
            return "false";
        }

        payOrderCallbackTest2(p2_ordernumber);


        return "success";

    }

    public String payOrderCallbackQilin(String paysapi_id, String orderid, String price, String realprice, String orderuid, String key) throws Exception {
        System.out.println("麒麟支付回调" + paysapi_id + orderid + price + realprice + orderid + key);
        String token = ConfigUtil.get("qilin.Token");

        String keyString = "orderid=" + orderid + "&orderuid=" + orderuid + "&paysapi_id=" + paysapi_id + "&price=" + price + "&realprice=" + realprice + "&token=" + token;
        String keyMd5 = Md5.getMd5ofStr(keyString);
        if (keyMd5.toLowerCase().equals(key)) {
            payOrderCallbackTest2(orderid);
            return "success";
        }

        return "fail";
    }

    public String payOrderCallbackMZF(HttpServletRequest request) throws Exception {

        System.out.println("码支付回调状态 : -->");

        String key = ConfigUtil.get("mazhifu.tongxunkey"); //记得更改 http://codepay.fateqq.com 后台可设置
        Map<String,String> params = new HashMap<String,String>(); //申明hashMap变量储存接收到的参数名用于排序
        Map requestParams = request.getParameterMap(); //获取请求的全部参数
        String valueStr = ""; //申明字符变量 保存接收到的变量
        for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
            String name = (String) iter.next();
            String[] values = (String[]) requestParams.get(name);
            valueStr = values[0];
            //乱码解决，这段代码在出现乱码时使用。如果sign不相等也可以使用这段代码转化
            //valueStr = new String(valueStr.getBytes("ISO-8859-1"), "gbk");
            params.put(name, valueStr);//增加到params保存
            System.out.println("params --> " + name + ":" +valueStr);
        }
        List<String> keys = new ArrayList<String>(params.keySet()); //转为数组
        Collections.sort(keys); //重新排序
        String prestr = "";
        String sign= params.get("sign"); //获取接收到的sign 参数

        for (int i = 0; i < keys.size(); i++) { //遍历拼接url 拼接成a=1&b=2 进行MD5签名
            String key_name = keys.get(i);
            String value = params.get(key_name);
            if(value== null || value.equals("") ||key_name.equals("sign")){ //跳过这些 不签名
                continue;
            }
            if (prestr.equals("")){
                prestr =  key_name + "=" + value;
            }else{
                prestr =  prestr +"&" + key_name + "=" + value;
            }
        }
        MessageDigest md = MessageDigest.getInstance("MD5");
        md.update((prestr+key).getBytes());
        String  mySign = new BigInteger(1, md.digest()).toString(16).toLowerCase();
        if(mySign.length()!=32)mySign="0"+mySign;
        if(mySign.equals(sign)){
            //编码要匹配 编码不一致中文会导致加密结果不一致
            //参数合法处理业务
            //request.getParameter("pay_no") 流水号
            //request.getParameter("pay_id") 用户唯一标识
            //request.getParameter("money") 付款金额
            //request.getParameter("price") 提交的金额
//            if (request.getParameter("money").equalsIgnoreCase(request.getParameter("price"))) {
                payOrderCallbackTest2(request.getParameter("pay_id"));
//            }

            return "ok";
        }else{
            //参数不合法
            return  "fail";
        }

    }
}
