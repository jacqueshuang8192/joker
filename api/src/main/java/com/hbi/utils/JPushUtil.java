package com.hbi.utils;

import cn.jpush.api.JPushClient;
import cn.jiguang.common.resp.APIConnectionException;
import cn.jiguang.common.resp.APIRequestException;
import cn.jpush.api.push.model.Message;
import cn.jpush.api.push.model.Options;
import cn.jpush.api.push.model.Platform;
import cn.jpush.api.push.model.PushPayload;
import cn.jpush.api.push.model.audience.Audience;
import cn.jpush.api.push.model.notification.IosNotification;
import cn.jpush.api.push.model.notification.Notification;
import com.alibaba.fastjson.JSONObject;
import com.core.util.ConfigUtil;
import com.hbi.constants.Constants;

/**
 * Created by ceeuoo on 3/30/2016.
 */
public class JPushUtil extends PushUtil{
    private static String playerAppKey = ConfigUtil.get("jpush.player.appKey");
    private static String playerSecret = ConfigUtil.get("jpush.player.masterSecret");

    private static String compereAppKey = ConfigUtil.get("jpush.compere.appKey");
    private static String compereSecret = ConfigUtil.get("jpush.compere.masterSecret");

    private static JPushClient playerClient;
    private static JPushClient compereClient;

    public static void main(String[] args) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("nickname", "滴滴");
            jsonObject.put("photoUrl", "hehe");
            jsonObject.put("userId", "508");
            jsonObject.put("roomId", "3066");
            jsonObject.put("chatRoomId", "206859828667089348");
            jsonObject.put("longitude", "113.267");
            jsonObject.put("latitude", "23");
            String[] users  = {"533"};
            jsonObject.put("users", users);
            push(Constants.START_LIVE, jsonObject);
        } catch (APIConnectionException e) {
            e.printStackTrace();
        } catch (APIRequestException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void push(Integer type, JSONObject json) throws Exception {
        JPushClient playerClient = getPlayerClient();
        JPushClient compereClient = getCompereClient();
        JSONObject newJson = new JSONObject();
        newJson.put("type", type);
        newJson.put("msg", json);
        PushPayload payload;
        if (type.equals(Constants.START_LIVE)) {
            payload = pushStartLivingMessage(newJson);
            playerClient.sendPush(payload);
            payload = pushStartLivingNotification(newJson);
            playerClient.sendPush(payload);
        } else if (type.equals(Constants.BOOM)) {
            payload = pushMessage(newJson);
            playerClient.sendPush(payload);
            compereClient.sendPush(payload);
        } else {
            payload = pushMessage(newJson);
            playerClient.sendPush(payload);
            compereClient.sendPush(payload);
        }

    }

    public static PushPayload pushDatingOwnerSuccessNotification(JSONObject json, String audience) {
        return PushPayload.newBuilder()
                .setPlatform(Platform.all())
                .setAudience(Audience.alias(audience))
                .setAudience(Audience.all())
                .setNotification(Notification.newBuilder()
                        .addPlatformNotification(IosNotification.newBuilder()
                                .setAlert("你的约饭活动已被" + json.getString("winnerName") + "以" + json.getString("cardNum")
                                + "张饭卡拍下")
                                .build())
                        .build())
//                .setNotification(Notification.alert("你的约饭活动已被" + json.getString("winnerName") + "以" + json.getString("cardNum")+ "张饭卡拍下"))
                .build();
    }

    public static PushPayload pushDatingOwnerFailNotification(String audience) {
        return PushPayload.newBuilder()
                .setPlatform(Platform.all())
                .setAudience(Audience.alias(audience))
                .setAudience(Audience.all())
                .setNotification(Notification.newBuilder()
                        .addPlatformNotification(IosNotification.newBuilder()
                                .setAlert("你的约饭活动无人竞价，已流拍")
                                .build())
                        .build())
//                .setNotification(Notification.alert("你的约饭活动无人竞价，已流拍"))
                .build();
    }

    public static PushPayload pushDatingWinnerSuccessNotification(JSONObject json, String audience) {
        return PushPayload.newBuilder()
                .setPlatform(Platform.all())
                .setAudience(Audience.alias(audience))
                .setNotification(Notification.newBuilder()
                        .addPlatformNotification(IosNotification.newBuilder()
                                .setAlert("你已以" + json.getString("cardNum") + "张饭卡的价格成功拍下" + json.getString("ownerName") + "的约饭活动")
                                .build())
                        .build())
//                .setNotification(Notification.alert("你已以" + json.getString("cardNum") + "张饭卡的价格成功拍下" + json.getString("ownerName") + "的约饭活动"))
                .build();
    }

    public static PushPayload pushStartLivingNotification(JSONObject json) {
        return PushPayload.newBuilder()
                .setPlatform(Platform.all())
                .setAudience(Audience.alias((String[])json.getJSONObject("msg").get("users")))
                .setNotification(Notification.newBuilder()
                        .addPlatformNotification(IosNotification.newBuilder()
                                .setAlert("主播" + json.getJSONObject("msg").getString("nickname") + "正在直播")
                                .build())
                        .build())
//                .setNotification(Notification.alert("主播" + json.getJSONObject("msg").getString("nickname") + "正在直播"))
                .setOptions(Options.newBuilder()
                        .setApnsProduction(true)
                        .build())
                .build();
    }

    public static PushPayload pushStartLivingMessage(JSONObject json) {
        return PushPayload.newBuilder()
                .setPlatform(Platform.all())
                .setAudience(Audience.alias((String[])json.getJSONObject("msg").get("users")))
                .setMessage(Message.newBuilder()
                        .setMsgContent("msg")
                        .addExtra("msg", json.toString())
                        .build())
                .setOptions(Options.newBuilder()
                        .setApnsProduction(true)
                        .build())
                .build();
    }

    public static PushPayload pushMessage(JSONObject jsonObject) {
        return PushPayload.newBuilder()
                .setPlatform(Platform.all())
                .setAudience(Audience.all())
                .setMessage(Message.newBuilder()
                        .setMsgContent("")
                        .addExtra("from", "JPush")
                        .addExtra("msg", jsonObject.toString())
                        .build())
                .build();
    }

    private static JPushClient getPlayerClient() {
        if(playerClient == null) {
            playerClient = new JPushClient(playerSecret, playerAppKey, 3);
        }
        return playerClient;
    }

    private static JPushClient getCompereClient() {
        if(compereClient == null) {
            compereClient = new JPushClient(compereSecret, compereAppKey, 3);
        }
        return compereClient;
    }

}
