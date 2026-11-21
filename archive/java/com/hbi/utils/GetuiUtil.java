//package com.hbi.utils;
//
//import java.io.IOException;
//import java.util.ArrayList;
//import java.util.List;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.ConfigUtil;
//import com.gexin.rp.sdk.base.IPushResult;
//import com.gexin.rp.sdk.base.impl.AppMessage;
//import com.gexin.rp.sdk.http.IGtPush;
//import com.gexin.rp.sdk.template.TransmissionTemplate;
//import com.hbi.model.GeTuiMessage;
//
//public class GetuiUtil {
//
//    //首先定义一些常量, 修改成开发者平台获得的值
//    private static String appId = ConfigUtil.get("getui.appId");
//    private static String appKey = ConfigUtil.get("getui.appKey");
//    private static String masterSecret = ConfigUtil.get("getui.masterSecret");
////    private static String url = ConfigUtil.get("getui.url");
//    private static String url = "http://sdk.open.api.igexin.com/serviceex";
//
//
//    public static void push(Integer type, JSONObject json) {
//        // 新建一个IGtPush实例，传入调用接口网址，appkey和masterSecret
//        IGtPush push = new IGtPush(url, appKey, masterSecret);
//        try {
//            push.connect();
//        } catch (IOException e) {
//            // TODO Auto-generated catch block
//            e.printStackTrace();
//        }
//        // 新建一个消息类型，根据app推送的话要使用AppMessage
//        AppMessage message = new AppMessage();
//        // 新建一个推送模版, 以链接模板为例子，就是说在通知栏显示一条含图标、标题等的通知，用户点击可打开您指定的网页
//        TransmissionTemplate template = new TransmissionTemplate();
//        template.setAppId(appId);
//        template.setAppkey(appKey);
//
//        GeTuiMessage tui = new GeTuiMessage();
//        tui.setType(type);
//        tui.setData(json);
//        template.setTransmissionContent(JSONObject.toJSONString(tui));
//
//        List<String> appIds = new ArrayList<String>();
//        appIds.add(appId);
//        // 模板设置好后塞进message里并设置，同时设置推送的app id,还可以配置这条message是否支持离线，以及过期时间等
//        message.setData(template);
//        message.setAppIdList(appIds);
//        message.setOffline(true);
//        message.setOfflineExpireTime(1000 * 600);
//        // 调用IGtPush实例的pushMessageToApp接口，参数就是上面我们配置的message
//        IPushResult ret = push.pushMessageToApp(message);
//        System.out.println(ret.getResponse().toString());
//
//    }
//}
