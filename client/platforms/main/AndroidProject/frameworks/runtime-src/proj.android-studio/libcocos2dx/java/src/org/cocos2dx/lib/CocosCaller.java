package org.cocos2dx.lib;

import android.content.Context;
import android.provider.Settings;
import android.util.Log;

public class CocosCaller {
    private static final String TAG = "CocosCaller";
    
    // Callback handles
    public static int callBackHandle = -1;
    public static int callBackVideoHandle = -1;
    
    // cached login data
    public static int sUid = 0;
    public static String sToken = "";
    public static String sNickName = "";
    public static String sUserType = "";
    public static String sCity = "";
    public static int sScore = 0;
    public static String sLatitude = "0";
    public static String sLongitude = "0";
    public static int sEnterGame = 0;
    public static int sReloadGameId = 0;
    public static String sInviteCode = "";
    public static int sGroupChip = 0;
    public static int sGroupLevel = 0;
    public static int sGroupCostRate = 0;
    public static int sTableId = 0;
    public static int sActivityId = 0;
    public static String sGameCode = "";
    public static String sCityId = "";
    public static int sSex = 1;
    public static String sPresenterId = "0";
    public static String sPresenterSex = "1";
    public static String sStartLiveData = "";
    public static int sSendCardCount = 0;
    public static int sCardCount = 0;
    public static int sVoiceIsRecording = 0;
    public static int sVoiceIsPlaying = 0;
    
    // ========== 基础方法 ==========
    
    public static int addTwoNumbers(int num1, int num2) {
        Log.d(TAG, "addTwoNumbers(" + num1 + ", " + num2 + ")");
        return num1 + num2;
    }
    
    public static void callbackLua(String tipInfo, int luaFunc) {
        Log.d(TAG, "callbackLua(" + tipInfo + ", " + luaFunc + ")");
        callBackHandle = luaFunc;
    }
    
    public static void callbackVideo(String tipInfo, int luaFunc) {
        Log.d(TAG, "callbackVideo(" + tipInfo + ", " + luaFunc + ")");
        callBackVideoHandle = luaFunc;
    }
    
    public static String autoLogin() {
        Log.d(TAG, "autoLogin() called");
        return "{\"uid\":\"100005\",\"token\":\"test_token\",\"androidId\":\"\"}";
    }
    
    // ========== 用户信息方法 ==========
    
    public static int getUserID() {
        Log.d(TAG, "getUserID() = " + sUid);
        return sUid;
    }
    
    public static void setUserID(int uid) {
        Log.d(TAG, "setUserID(" + uid + ")");
        sUid = uid;
    }
    
    public static String getNickName() {
        Log.d(TAG, "getNickName() = " + sNickName);
        return sNickName;
    }
    
    public static void setNickName(String nickName) {
        Log.d(TAG, "setNickName(" + nickName + ")");
        sNickName = nickName;
    }
    
    public static String getToken() {
        Log.d(TAG, "getToken() = " + sToken);
        return sToken;
    }
    
    public static void setToken(String token) {
        Log.d(TAG, "setToken(" + token + ")");
        sToken = token;
    }
    
    public static String getUserType() {
        Log.d(TAG, "getUserType() = " + sUserType);
        return sUserType;
    }
    
    public static String getCity() {
        Log.d(TAG, "getCity() = " + sCity);
        return sCity;
    }
    
    public static String getAddrStr() {
        Log.d(TAG, "getAddrStr()");
        return "";
    }
    
    public static String getLongitude() {
        Log.d(TAG, "getLongitude() = " + sLongitude);
        return sLongitude;
    }
    
    public static String getLatitude() {
        Log.d(TAG, "getLatitude() = " + sLatitude);
        return sLatitude;
    }
    
    public static String getDeviceId() {
        try {
            Context context = Cocos2dxHelper.getActivity();
            if (context != null) {
                return Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            }
        } catch (Exception e) {
            Log.e(TAG, "getDeviceId error", e);
        }
        return "";
    }
    
    public static int getScore() {
        Log.d(TAG, "getScore() = " + sScore);
        return sScore;
    }
    
    public static String getDeviceSize() {
        Log.d(TAG, "getDeviceSize()");
        return "720,1280";
    }
    
    public static int getReloadGameId() {
        Log.d(TAG, "getReloadGameId() = " + sReloadGameId);
        return sReloadGameId;
    }
    
    public static int getEnterGame() {
        Log.d(TAG, "getEnterGame() = " + sEnterGame);
        return sEnterGame;
    }
    
    public static int getSex() {
        Log.d(TAG, "getSex() = " + sSex);
        return sSex;
    }
    
    public static int getPresenterId() {
        Log.d(TAG, "getPresenterId()");
        return 0;
    }
    
    public static int getPresenterSex() {
        Log.d(TAG, "getPresenterSex()");
        return 1;
    }
    
    public static int douniuComchorId() {
        Log.d(TAG, "douniuComchorId()");
        return 0;
    }
    
    // ========== 组局相关方法 ==========
    
    public static int getGroupTableId() {
        Log.d(TAG, "getGroupTableId() = " + sTableId);
        return sTableId;
    }
    
    public static int getReganizeId() {
        Log.d(TAG, "getReganizeId() = " + sActivityId);
        return sActivityId;
    }
    
    public static String getCurrentInviteCode() {
        Log.d(TAG, "getCurrentInviteCode() = " + sInviteCode);
        return sInviteCode;
    }
    
    public static int getGroupChip() {
        Log.d(TAG, "getGroupChip() = " + sGroupChip);
        return sGroupChip;
    }
    
    public static int getGroupLevel() {
        Log.d(TAG, "getGroupLevel() = " + sGroupLevel);
        return sGroupLevel;
    }
    
    public static int getGroupCostRate() {
        Log.d(TAG, "getGroupCostRate() = " + sGroupCostRate);
        return sGroupCostRate;
    }
    
    // ========== 城市相关方法 ==========
    
    public static int getCityId() {
        Log.d(TAG, "getCityId()");
        return 1;
    }
    
    public static String getCityIdStr() {
        Log.d(TAG, "getCityIdStr() = " + sCityId);
        return sCityId;
    }
    
    public static String getGameCode() {
        Log.d(TAG, "getGameCode() = " + sGameCode);
        return sGameCode;
    }
    
    // ========== 游戏控制方法 ==========
    
    public static void exitGame() {
        Log.d(TAG, "exitGame() called");
    }
    
    public static int exitGroupGame(int id) {
        Log.d(TAG, "exitGroupGame(" + id + ")");
        return 0;
    }
    
    public static void exitZbzd(int id) {
        Log.d(TAG, "exitZbzd(" + id + ")");
    }
    
    public static void LuaRecharge() {
        Log.d(TAG, "LuaRecharge() called");
    }
    
    public static void recharge(int price, String type, int amount) {
        Log.d(TAG, "recharge(" + price + ", " + type + ", " + amount + ")");
    }
    
    public static void LuaMobClick(String back) {
        Log.d(TAG, "LuaMobClick(" + back + ")");
    }
    
    public static String getAppVersion() {
        Log.d(TAG, "getAppVersion()");
        return "1.0.0";
    }
    
    // ========== 登录相关方法 ==========
    
    public static void wxLogin() {
        Log.d(TAG, "wxLogin() called");
    }
    
    public static void applyChangeUser() {
        Log.d(TAG, "applyChangeUser() called");
    }
    
    public static void openAlbum() {
        Log.d(TAG, "openAlbum() called");
    }
    
    public static void loginWithPhone(String phone, String code) {
        Log.d(TAG, "loginWithPhone(" + phone + ", " + code + ")");
    }
    
    // ========== 回调方法 ==========
    
    public static void applyGameAwardPool() {
        Log.d(TAG, "applyGameAwardPool() called");
    }
    
    public static void endGameAwardPool() {
        Log.d(TAG, "endGameAwardPool() called");
    }
    
    public static void goldUpdate() {
        Log.d(TAG, "goldUpdate() called");
    }
    
    public static void showLoading() {
        Log.d(TAG, "showLoading() called");
    }
    
    public static void hideLoading() {
        Log.d(TAG, "hideLoading() called");
    }
    
    public static void loginsuccess() {
        Log.d(TAG, "loginsuccess() called");
    }
    
    public static void loginFail() {
        Log.d(TAG, "loginFail() called");
    }
    
    public static void rechargeSuccess() {
        Log.d(TAG, "rechargeSuccess() called");
    }
    
    public static void rechargeFail() {
        Log.d(TAG, "rechargeFail() called");
    }
    
    // ========== 直播相关方法 ==========
    
    public static void startLive(int startX, int startY, int width, int height) {
        Log.d(TAG, "startLive(" + startX + ", " + startY + ", " + width + ", " + height + ")");
    }
    
    public static String getStartLiveData() {
        Log.d(TAG, "getStartLiveData() = " + sStartLiveData);
        return sStartLiveData;
    }
    
    public static void resetStartLiveData() {
        Log.d(TAG, "resetStartLiveData() called");
        sStartLiveData = "";
    }
    
    public static void stopLive() {
        Log.d(TAG, "stopLive() called");
    }
    
    public static void playLive(int startX, int startY, int width, int height, String playAddress, String decodeType) {
        Log.d(TAG, "playLive(" + playAddress + ")");
    }
    
    public static void stopPlayLive() {
        Log.d(TAG, "stopPlayLive() called");
    }
    
    public static void showAlert() {
        Log.d(TAG, "showAlert() called");
    }
    
    // ========== 分享相关方法 ==========
    
    public static void share(String channel, String title, String url, String shareType, String desc) {
        Log.d(TAG, "share(" + channel + ", " + title + ")");
    }
    
    public static void shareSuccess() {
        Log.d(TAG, "shareSuccess() called");
    }
    
    public static void shareCancel() {
        Log.d(TAG, "shareCancel() called");
    }
    
    public static void shareGroupResult(String result) {
        Log.d(TAG, "shareGroupResult(" + result + ")");
    }
    
    // ========== 截图相关方法 ==========
    
    public static void ScreenShot() {
        Log.d(TAG, "ScreenShot() called");
    }
    
    public static void captureScreen_success(String path) {
        Log.d(TAG, "captureScreen_success(" + path + ")");
    }
    
    // ========== 录音录像相关方法 ==========
    
    public static void showRecordFrame(String x, String y, String width, String height, String activityId) {
        Log.d(TAG, "showRecordFrame() called");
    }
    
    public static void recordDidClose() {
        Log.d(TAG, "recordDidClose() called");
    }
    
    public static void setVideoAddr(String tipInfo, int luaFuction) {
        Log.d(TAG, "setVideoAddr() called");
    }
    
    public static void callBackVideoPath(String path) {
        Log.d(TAG, "callBackVideoPath(" + path + ")");
    }
    
    public static void callbackLuaCap(String tipInfo, int luaFuction) {
        Log.d(TAG, "callbackLuaCap() called");
    }
    
    // ========== 位置相关方法 ==========
    
    public static void setLocation() {
        Log.d(TAG, "setLocation() called");
    }
    
    // ========== 返回键相关方法 ==========
    
    public static void backClick(String tipInfo, int luaFuction) {
        Log.d(TAG, "backClick() called");
    }
    
    public static void callBackBackClick(String click) {
        Log.d(TAG, "callBackBackClick(" + click + ")");
    }
    
    // ========== 房间相关方法 ==========
    
    public static void LoginRoom(String roomId) {
        Log.d(TAG, "LoginRoom(" + roomId + ")");
    }
    
    public static void LogoutRoom(String args) {
        Log.d(TAG, "LogoutRoom() called");
    }
    
    // ========== Yaya语音相关方法 ==========
    
    public static void YaYaLoginRoomSuccess() {
        Log.d(TAG, "YaYaLoginRoomSuccess() called");
    }
    
    public static void YaYaLogoutRoomSuccess() {
        Log.d(TAG, "YaYaLogoutRoomSuccess() called");
    }
    
    public static void micUp() {
        Log.d(TAG, "micUp() called");
    }
    
    public static void micUpSuccess() {
        Log.d(TAG, "micUpSuccess() called");
    }
    
    public static void micDown() {
        Log.d(TAG, "micDown() called");
    }
    
    public static void micDownSuccess() {
        Log.d(TAG, "micDownSuccess() called");
    }
    
    // ========== 支付相关方法 ==========
    
    public static void payWithPing(String data) {
        Log.d(TAG, "payWithPing(" + data + ")");
    }
    
    public static void payRoomCardSuccess() {
        Log.d(TAG, "payRoomCardSuccess() called");
    }
    
    public static void payRoomCardFail() {
        Log.d(TAG, "payRoomCardFail() called");
    }
    
    public static void payRoomCardCancel() {
        Log.d(TAG, "payRoomCardCancel() called");
    }
    
    public static void payRoomCardInvalid() {
        Log.d(TAG, "payRoomCardInvalid() called");
    }
    
    // ========== 大厅相关方法 ==========
    
    public static void nowInHall() {
        Log.d(TAG, "nowInHall() called");
    }
    
    public static void joinGame() {
        Log.d(TAG, "joinGame() called");
    }
    
    // ========== 数据传递方法 ==========
    
    public static void sendDataToLua(String type, String data) {
        Log.d(TAG, "sendDataToLua(" + type + ")");
    }
    
    public static void callbackLuaForDict(String a, int luaFuction) {
        Log.d(TAG, "callbackLuaForDict() called");
    }
    
    // ========== 语音相关方法 ==========
    
    public static int getVoiceIsRecording() {
        Log.d(TAG, "getVoiceIsRecording() = " + sVoiceIsRecording);
        return sVoiceIsRecording;
    }
    
    public static int getVoiceIsPlaying() {
        Log.d(TAG, "getVoiceIsPlaying() = " + sVoiceIsPlaying);
        return sVoiceIsPlaying;
    }
    
    public static void isStartVoice(String fling) {
        Log.d(TAG, "isStartVoice(" + fling + ")");
    }
    
    public static void playVoice(String json) {
        Log.d(TAG, "playVoice(" + json + ")");
    }
    
    public static void playVideo(String json) {
        Log.d(TAG, "playVideo(" + json + ")");
    }
    
    public static void playEffect(String args) {
        Log.d(TAG, "playEffect(" + args + ")");
    }
    
    public static void changeOrientation(String orientation) {
        Log.d(TAG, "changeOrientation(" + orientation + ")");
    }
    
    // ========== 工具方法 ==========
    
    public static String getHttpAddr() {
        Log.d(TAG, "getHttpAddr()");
        Context context = Cocos2dxActivity.getContext();
        if (context == null) return "";
        int id = context.getResources().getIdentifier("joker_api_url", "string", context.getPackageName());
        return id == 0 ? "" : context.getString(id);
    }
    
    public static void copyToClipboard(String text) {
        Log.d(TAG, "copyToClipboard(" + text + ")");
    }
    
    public static String getClipText() {
        Log.d(TAG, "getClipText()");
        return "";
    }
    
    public static int getSendCardCount() {
        Log.d(TAG, "getSendCardCount() = " + sSendCardCount);
        return sSendCardCount;
    }
    
    public static int getCardCount() {
        Log.d(TAG, "getCardCount() = " + sCardCount);
        return sCardCount;
    }
    
    public static String getPhonePower() {
        Log.d(TAG, "getPhonePower()");
        return "100";
    }
    
    public static String getIPAddress() {
        Log.d(TAG, "getIPAddress()");
        return "0.0.0.0";
    }
    
    public static String intIP2StringIP(int ip) {
        Log.d(TAG, "intIP2StringIP(" + ip + ")");
        return ((ip >> 24) & 0xFF) + "." + ((ip >> 16) & 0xFF) + "." + ((ip >> 8) & 0xFF) + "." + (ip & 0xFF);
    }
}
