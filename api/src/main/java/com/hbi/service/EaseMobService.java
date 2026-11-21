//package com.hbi.service;
//
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Map;
//import java.util.Timer;
//import java.util.TimerTask;
//
//import javax.annotation.PostConstruct;
//
//import com.hbi.utils.InfServerException;
//import org.apache.http.NameValuePair;
//import org.apache.http.message.BasicNameValuePair;
//import org.springframework.aop.interceptor.ConcurrencyThrottleInterceptor;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.ConfigUtil;
//import com.fasterxml.jackson.databind.JsonNode;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.constants.Constants;
//import com.hbi.model.TGoods;
//import com.hbi.utils.EaseMobUtil;
//
//@Service
//public class EaseMobService {
//
//    private static String company = ConfigUtil.get("easemob.company");
//
//    private static String app = ConfigUtil.get("easemob.app");
//
//    private String token;
//
//    /**
//     * 在环信上注册用户
//     *
//     * @param username
//     * @param password
//     * @param nickname
//     * @return
//     */
//    public String registerOnEaseMob(String username, String password,
//            String nickname) throws Exception {
//        JSONObject node = new JSONObject();
//        node.put("username", username);
//        node.put("password", password);
//        node.put("nickname", nickname);
//        JsonNode json = EaseMobUtil.getResponse(
//                "/" + company + "/" + app + "/users", node, null);
//        if (json.get("entities") != null || json.get("data") != null) {
//            return Constants.RETURN_CODE_SUCCESS;
//        }
//        return json.get("error").asText();
//    }
//
//    public boolean resetPassword(String phone, String password)
//            throws Exception {
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("newpassword", password);
//        List<NameValuePair> headers = new ArrayList<NameValuePair>();
//        headers.add(new BasicNameValuePair("Authorization",
//                "Bearer " + getToken()));
//        JsonNode json = EaseMobUtil.getPutResponse(
//                "/" + company + "/" + app + "/users/" + phone + "/password",
//                objectNode, headers);
//        if (json.get("action") != null) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 发送系统消息
//     *
//     * @param usernames
//     * @param messageText
//     * @return
//     */
//    public String sendSystemMessage(String[] usernames, String messageText,
//            String type, JSONObject ext) {
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("target_type", type);
//        objectNode.put("target", usernames);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        msg.put("msg", messageText);
//        objectNode.put("msg", msg);
//        objectNode.put("ext", ext);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return Constants.RETURN_CODE_SUCCESS;
//            }
//            return json.get("error").asText();
//        } catch (Exception e) {
//            e.printStackTrace();
//            return e.getMessage();
//        }
//    }
//
//    public String createChatRoom(String owner) throws Exception {
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("name", System.currentTimeMillis() + "");
//        objectNode.put("description", "chatRoom");
//        objectNode.put("owner", owner);
//        List<NameValuePair> headers = new ArrayList<NameValuePair>();
//        headers.add(new BasicNameValuePair("Authorization",
//                "Bearer " + getToken()));
//        JsonNode json = EaseMobUtil.getResponse(
//                "/" + company + "/" + app + "/chatrooms", objectNode, headers);
//        if (json.get("data") != null) {
//            return json.get("data").get("id").asText();
//        } else {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, json.get("error").asText());
//        }
//    }
//
//    public boolean deleteChatRoom(String chatroomId) throws Exception {
//        JSONObject objectNode = new JSONObject();
//        List<NameValuePair> headers = new ArrayList<NameValuePair>();
//        headers.add(new BasicNameValuePair("Authorization",
//                "Bearer " + getToken()));
//        JsonNode json = EaseMobUtil.getDeleteResponse(
//                "/" + company + "/" + app + "/chatrooms/" + chatroomId, objectNode, headers);
//        if (json.get("data") != null) {
//            return json.get("data").get("success").asBoolean();
//        } else {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, json.get("error").asText());
//        }
//    }
//
//    @PostConstruct
//    private void init() {
//        new Timer().schedule(new TimerTask() {
//            public void run() {
//                JSONObject object = new JSONObject();
//                object.put("grant_type", "client_credentials");
//                object.put("client_id", ConfigUtil.
//                        get("easemob.clientid"));
//                object.put("client_secret",
//                        ConfigUtil.get("easemob.clientsecret"));
//                try {
//                    JsonNode json = EaseMobUtil.getResponse(
//                            "/" + company + "/" + app + "/token", object, null);
//                    token = json.get("access_token").asText();
//                    System.out.println("token : " + token);
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//            }
//        }, 1000, 6000000);
//    }
//
//    /**
//     * 游戏消息
//     *
//     * @param creatorId
//     * @param creatorName
//     * @param creatorPhoto
//     * @param inviteCode
//     * @param content
//     * @param userNames
//     * @return
//     */
//    public boolean gameMessage(Long creatorId, String creatorName,
//            String creatorPhoto, String inviteCode, String content,
//            String[] userNames) {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "game");
//        obj.put("creatorId", creatorId);
//        obj.put("creatorName", creatorName);
//        obj.put("creatorPhoto", creatorPhoto);
//        obj.put("inviteCode", inviteCode);
//        String result = sendSystemMessage(userNames, content, "users", obj);
//        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 开直播
//     *
//     * @param liveId
//     * @param chatrooms
//     * @return
//     */
//    public boolean openLiveMessage(String liveId, String userId,
//            String nickname, String resolution, String... chatrooms) {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "startLive");
//        obj.put("liveId", liveId);
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        obj.put("resolution", resolution);
//        String result = sendSystemMessage(chatrooms, obj.toJSONString(),
//                "chatrooms", obj);
//        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 关直播
//     *
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean stopLiveMessage(String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "stopLive");
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 开麦
//     *
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean openMicMessage(String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "openMic");
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 收麦
//     *
//     * @param liveId
//     * @return
//     * @throws Exception
//     */
//    public boolean takebackMicMessage(String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "takebackMic");
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 改麦
//     *
//     * @param playerList
//     * @return
//     * @throws Exception
//     */
//    public boolean changeMicMessage(List playerList, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "changeMic");
//        return sendChatroomMsg(JSONObject.toJSONString(playerList), obj,
//                chatrooms);
//    }
//
//    /**
//     * 移麦
//     *
//     * @param userId
//     * @return
//     * @throws Exception
//     */
//    public boolean removeFromMicMessage(Long userId, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "removeFromMic");
//        obj.put("userId", userId);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 开启视频游戏
//     *
//     * @param gameId
//     * @param gameName
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean openGameMessage(Long gameId, String gameCode, String gameName,
//            String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "openGame");
//        obj.put("gameId", gameId);
//        obj.put("gameCode", gameCode);
//        obj.put("gameName", gameName);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 开启电台
//     *
//     * @param topic
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean openFmMessage(String topic, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "openFm");
//        obj.put("topic", topic);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 关闭视频游戏
//     *
//     * @param gameId
//     * @param gameName
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean closeGameMessage(Long gameId, String gameName,
//            String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "closeGame");
//        obj.put("gameId", gameId);
//        obj.put("gameName", gameName);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 关闭电台
//     *
//     * @param gameId
//     * @param gameName
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean closeFmMessage(String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "closeFm");
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 进入房间
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean enterRoomMessage(Long userId, String nickname, String photo, String phone,
//            boolean isRobot, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "enterRoom");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        obj.put("photo", photo);
//        obj.put("phone", phone);
//        obj.put("isRobot", isRobot);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 退出房间
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean exitRoomMessage(Long userId, String nickname,
//            String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "exitRoom");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean sendRedPacketMessage(Integer amount, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "hongbao");
//        obj.put("amount", amount);
////        obj.put("nickname", nickname);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 排麦
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean applyMicMessage(Long userId, String photoUrl,
//            String nickname, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "applyMic");
//        obj.put("userId", userId);
//        obj.put("photo", photoUrl);
//        obj.put("nickname", nickname);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 加入电台
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean joinFmMessage(Long userId, String photoUrl, String nickname,
//            String position, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "joinFm");
//        obj.put("userId", userId);
//        obj.put("photo", photoUrl);
//        obj.put("nickname", nickname);
//        obj.put("position", position);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 放麦
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean releaseMicMessage(Long userId, String nickname,
//            String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "releaseMic");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 退出电台
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean exitFmMessage(Long userId, String nickname, String position,
//            String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "exitFm");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        obj.put("position", position);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 送礼物
//     *
//     * @param userId
//     * @param nickname
//     * @param giftName
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean giftMessage(Long userId, String nickname, String photoUrl, String phone, String categoryType, String giftPhoto,
//            String giftName, Integer count, Integer currentCount, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "gift");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        obj.put("photoUrl", photoUrl);
//        obj.put("categoryType", categoryType);
//        obj.put("giftPhoto", giftPhoto);
//        obj.put("giftName", giftName);
//        obj.put("count", count);
//        obj.put("phone", phone);
//        obj.put("currentCount", currentCount);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 关闭房间
//     *
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean closeRoomMessage(String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "closeRoom");
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 踢人
//     *
//     * @param userId
//     * @param nickname
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean kickMessage(Long userId, String nickname,
//            String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "kick");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean joinSocietyMessage(Long societyId, String society, String phone) {
//    	String[] usernames = new String[1];
//    	usernames[0] = phone;
//
//    	JSONObject obj = new JSONObject();
//        obj.put("type", "joinSocietyConfirm");
//        obj.put("societyId", societyId);
//        obj.put("society", society);
//
//    	String result = sendSystemMessage(usernames, "", "users", obj);
//
//    	if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 采矿刷新
//     *
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean refreshMine(String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "refreshMine");
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 发送退群消息
//     * @param memberPhone
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean exitGroupMessage(String memberPhone, String nickname,String groupId, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("groupControlType", "removeMember");
//        obj.put("memberPhone", memberPhone);
//        obj.put("groupId", groupId);
//        return sendChatroomMsg(nickname + "退出群聊", obj, chatrooms);
//    }
//
//    /**
//     * 约饭邀请状态变更
//     *
//     * @param toUserNames
//     * @return
//     */
//    public boolean datingStatusChanged(String[] toUserNames) {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "datingStatusChanged");
//        String result = sendSystemMessage(toUserNames, "", "users", obj);
//        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 约饭拍卖时间到的时候发消息给发起人
//     *
//     * @return
//     */
//    public boolean sendDatingOwnerNotification(String userName, String userId, String nickname, String photoUrl, String userType, Integer cardNum) throws InfServerException {
//        String hxDatingAccount = ConfigUtil.get("datingAccount", "douyouDating888");
//        String [] userNames = {userName};
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("from", hxDatingAccount);
//        objectNode.put("target_type", "users");
//        objectNode.put("target", userNames);
//
//        JSONObject obj = new JSONObject();
//        obj.put("type", "datingOwnerNotification");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        obj.put("photoUrl", photoUrl);
//        obj.put("userType", userType);
//        obj.put("cardNum", cardNum);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        objectNode.put("msg", msg);
//        objectNode.put("ext", obj);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return true;
//            }
//            return false;
//        } catch (Exception e) {
//            e.printStackTrace();
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
//        }
//    }
//
//    /**
//     * 约饭拍卖时间到的时候发消息给拍卖人
//     *
//     * @return
//     */
//    public boolean sendDatingWinnerNotification(String userName, String userId, String nickname, String photoUrl, String userType, Integer cardNum) throws InfServerException {
//        String hxDatingAccount = ConfigUtil.get("datingAccount", "douyouDating888");
//        String [] userNames = {userName};
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("from", hxDatingAccount);
//        objectNode.put("target_type", "users");
//        objectNode.put("target", userNames);
//
//        JSONObject obj = new JSONObject();
//        obj.put("type", "datingWinnerNotification");
//        obj.put("userId", userId);
//        obj.put("nickname", nickname);
//        obj.put("photoUrl", photoUrl);
//        obj.put("userType", userType);
//        obj.put("cardNum", cardNum);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        objectNode.put("msg", msg);
//        objectNode.put("ext", obj);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return true;
//            }
//            return false;
//        } catch (Exception e) {
//            e.printStackTrace();
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
//        }
////
////        JSONObject obj = new JSONObject();
////        String [] userNames = {userName};
////        obj.put("type", "datingWinnerNotification");
////        obj.put("userId", userId);
////        obj.put("nickname", nickname);
////        obj.put("photoUrl", photoUrl);
////        obj.put("userType", userType);
////        obj.put("cardNum", cardNum);
////        String result = sendSystemMessage(userNames, "", "users", obj);
////        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
////            return true;
////        }
////        return false;
//    }
//
//    public boolean datingAuctionCountChanged(String chatroomId) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "datingAuctionCountChanged");
//        return sendChatroomMsg("", obj, chatroomId);
//    }
//
//    private boolean sendChatroomMsg(String msg, JSONObject obj,
//            String... chatrooms) throws Exception {
//        JSONObject object = new JSONObject();
//        object.put("grant_type", "client_credentials");
//        object.put("client_id", ConfigUtil.get("easemob.clientid"));
//        object.put("client_secret", ConfigUtil.get("easemob.clientsecret"));
////        try {
////            JsonNode json = EaseMobUtil.getResponse(
////                    "/" + company + "/" + app + "/token", object, null);
////            token = json.get("access_token").asText();
////            System.out.println("token : " + token);
////        } catch (Exception e) {
////            throw e;
////        }
//        String result = sendSystemMessage(chatrooms, msg, "chatrooms", obj);
//        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    public boolean qiemai() throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "qiemai");
//        obj.put("userId", 282);
//        obj.put("nickname", "松柠");
//        obj.put("liveId", 559);
//        return sendChatroomMsg("", obj, "183578598882410944");
//    }
//
//    public static void main(String[] s) {
//        try {
//            EaseMobService service = new EaseMobService();
//            service.init();
//            Thread.sleep(5000);
//            boolean b = service.qiemai();
//            System.out.println(b);
////            JSONObject objectNode = new JSONObject();
////
////            List<NameValuePair> headers = new ArrayList<NameValuePair>();
////            headers.add(new BasicNameValuePair("Authorization",
////                    "Bearer " + service.getToken()));
////            JsonNode json = EaseMobUtil.getResponse(
////                    "/" + company + "/" + app + "/chatrooms/158964287686050264/users/13798958003", objectNode,
////                    headers);
////            System.out.println(json.toString());
////             String id = service.createChatRoom("admin");
////             System.out.println(id);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        // System.out.println(new
//        // EaseMobService().generateInvitationCode((long)1));
//    }
//
//    /**
//     * 转发审核消息
//     * @param userNames
//     * @param ext
//     * @return
//     */
//    public boolean transmitVerifyMessage(String[] userNames, JSONObject ext) {
//        String result = sendVerifyMessage(userNames, "users", ext);
//        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 通过审核账户，发送审核
//     * @param usernames
//     * @param type
//     * @param ext
//     * @return
//     */
//    public String sendVerifyMessage(String[] usernames, String type, JSONObject ext) {
//        String hxVerifyAccount = ConfigUtil.get("hxVerifyAccount", "douyou888");
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("from", hxVerifyAccount);
//        objectNode.put("target_type", type);
//        objectNode.put("target", usernames);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        msg.put("msg", "douyou");
//        objectNode.put("msg", msg);
//        objectNode.put("ext", ext);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return Constants.RETURN_CODE_SUCCESS;
//            }
//            return json.get("error").asText();
//        } catch (Exception e) {
//            e.printStackTrace();
//            return e.getMessage();
//        }
//    }
//
//    /**
//     * 发送连线奖池奖励消息
//     * @param userNames
//     * @param ext
//     * @return
//     */
//    public boolean sendLinePoolAwardMessage(String[] userNames, JSONObject ext) {
//        String result = sendLinePoolMessage(userNames, "连线奖池奖励", "users", ext);
//        if (Constants.RETURN_CODE_SUCCESS.equals(result)) {
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 开启你说我猜
//     *
//     * @param topic
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean openYouSayIGuessMessage(String topic, TGoods goods, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "openYouSayIGuess");
//        obj.put("topic", topic);
//        obj.put("goods", JSON.toJSONString(goods));
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 加入电台
//     *
//     * @param userId
//     * @param nickname
//     * @param photo
//     * @param chatrooms
//     * @return
//     * @throws Exception
//     */
//    public boolean joinYouSayIGuessMessage(CacheUserListProfile m, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "joinYouSayIGuess");
//        obj.put("user", JSON.toJSONString(m));
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean startYouSayIGuessMessage(Map<String, CacheUserListProfile> userMap, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "startYouSayIGuess");
//        obj.put("userMap", JSON.toJSONString(userMap));
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean selectWordForYouSayIGuessMessage(String word, String... chatrooms) throws Exception {
//    	JSONObject obj = new JSONObject();
//        obj.put("type", "ysig_question");
//        obj.put("word", word);
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean endYouSayIGuessMessage(Map<String, CacheUserListProfile> userMap, String... chatrooms) throws Exception {
//        JSONObject obj = new JSONObject();
//        obj.put("type", "endYouSayIGuess");
//        obj.put("userMap", JSON.toJSONString(userMap));
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean endYouSayIGuessMatchMessage(CacheUserListProfile user, String... chatrooms) throws Exception {
//    	JSONObject obj = new JSONObject();
//        obj.put("type", "endYouSayIGuessMatch");
//        obj.put("winnerPhoto", user.getPhotoUrl());
//        obj.put("winnerId", user.getUserId());
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    public boolean updatePlayerForYouSayIGuessMessage(CacheUserListProfile player, String... chatrooms) throws Exception {
//    	JSONObject obj = new JSONObject();
//        obj.put("type", "updatePlayerForYouSayIGuess");
//        obj.put("player", JSON.toJSONString(player));
//        return sendChatroomMsg("", obj, chatrooms);
//    }
//
//    /**
//     * 发送连线奖池消息
//     * @param usernames
//     * @param messageText
//     * @param type
//     * @param ext
//     * @return
//     */
//    public String sendLinePoolMessage(String[] usernames, String messageText,
//            String type, JSONObject ext) {
//        String hxLinePoolAccount = ConfigUtil.get("hxLinePoolAccount", "douyouBonus888");
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("from", hxLinePoolAccount);
//        objectNode.put("target_type", type);
//        objectNode.put("target", usernames);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        msg.put("msg", messageText);
//        objectNode.put("msg", msg);
//        objectNode.put("ext", ext);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return Constants.RETURN_CODE_SUCCESS;
//            }
//            return json.get("error").asText();
//        } catch (Exception e) {
//            e.printStackTrace();
//            return e.getMessage();
//        }
//    }
//
//    /**
//     *
//     * @param usernames
//     * @param messageText
//     * @param type
//     * @param ext
//     * @return
//     */
//    public String sendOnlineTreasureMessage(String[] usernames, String type, JSONObject ext) {
//        String treasureAccount = ConfigUtil.get("treasureAccount", "douyouTreasure888");
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("from", treasureAccount);
//        objectNode.put("target_type", type);
//        objectNode.put("target", usernames);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        objectNode.put("msg", msg);
//        objectNode.put("ext", ext);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return Constants.RETURN_CODE_SUCCESS;
//            }
//            return json.get("error").asText();
//        } catch (Exception e) {
//            e.printStackTrace();
//            return e.getMessage();
//        }
//    }
//
//    public String sendTransferJewelMessage(String[] usernames, String type, JSONObject ext) throws Exception{
//        String hxTransferJewelAccount = ConfigUtil.get("hxTransferJewelAccount", "douyou88");
//        JSONObject objectNode = new JSONObject();
//        objectNode.put("from", hxTransferJewelAccount);
//        objectNode.put("target_type", type);
//        objectNode.put("target", usernames);
//        JSONObject msg = new JSONObject();
//        msg.put("type", "txt");
//        msg.put("msg", "douyou");
//        objectNode.put("msg", msg);
//        objectNode.put("ext", ext);
//        try {
//            List<NameValuePair> headers = new ArrayList<NameValuePair>();
//            headers.add(new BasicNameValuePair("Authorization",
//                    "Bearer " + getToken()));
//            JsonNode json = EaseMobUtil.getResponse(
//                    "/" + company + "/" + app + "/messages", objectNode,
//                    headers);
//            if (json.get("entities") != null || json.get("data") != null) {
//                return Constants.RETURN_CODE_SUCCESS;
//            }
//            return json.get("error").asText();
//        } catch (Exception e) {
//            e.printStackTrace();
////            throw e;
//            return e.getMessage();
//        }
//    }
//
//    public void setToken(String token) {
//        this.token = token;
//    }
//
//    public String getToken() {
//        return token;
//    }
//}
