package com.linkxin.douyouPlayer.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;

import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.yaya.sdk.RTV;
import com.yaya.sdk.VideoTroopsRespondListener;
import com.yaya.sdk.YayaNetStateListener;
import com.yaya.sdk.YayaRTV;
import com.yaya.sdk.tlv.protocol.message.TextMessageNotify;
import com.yunva.extension.LiteIm;
import com.yunva.extension.YayaLiteIM;
import com.yunva.extension.audio.play.PlayListener;
import com.yunva.extension.audio.record.RecordListener;
import com.yunva.extension.model.UploadFileRespInfo;

import net.tsz.afinal.FinalHttp;
import net.tsz.afinal.http.AjaxCallBack;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by Administrator on 2017-01-16.
 */
public class YaYaVoiceUtil {

    public static VideoTroopsRespondListener videoTroopsRespondListener = null;

    public static YayaNetStateListener netStateListener = null;

    public static String currentMicType = RTV.ACTION_TYPE_CLOSE_MIC; //当前麦状态

    public static long myYunvaId = -1;

    public static final String path = Environment.getExternalStorageDirectory().toString() + "/yunva_sdk_lite";

    public static final String voice_path = path + "/voice";

    /**
     * 初始化实时语音服务
     * @param context
     */
    public static void SetUpVoiceServer(final Context context){

        YayaRTV.Env sdkEnv = RTV.Env.Product;
        RTV.Mode rtvMode = RTV.Mode.Free;

        if (videoTroopsRespondListener == null){

            SPUtil.setInt(context, "YaYainitComplete", 0);

            videoTroopsRespondListener = new VideoTroopsRespondListener() {

                @Override
                public void initComplete() {
                    // 初始化完成返回
                    Log.d("-----呀呀语音-----", "initComplete");

                    SPUtil.setInt(context, "YaYainitComplete", 1);

                    SPUtil.setInt(context, "onLogin", 0);

                    // 获取当前需要进入的房间
                    String roomId = SPUtil.getString(context, "roomId");
                    if ("".equals(roomId)){

                    }else{
                        // 初始化完成后进入语音房间
                        LoginRoom(roomId);
                    }

                }

                @Override
                public void onRecordVolumeNotify(float v, float v1) {

                }

                @Override
                public void onMicStateChangeNotify(String s, long l, String s1, int i) {

                }

                @Override
                public void onPlayVolumeNotify(float v, float v1) {

                }

                @Override
                public void onTroopsListChangeNotify(String s, long l, String s1, int i) {

                }

                @Override
                public void onLoginResp(int result, String msg, long yunvaId, byte mode,boolean isLeader,int leaderId) {
                    // 进入房间返回
                    Log.d("-----呀呀语音-----", "onLoginResp result:" + result + ",msg:" + msg);

                    if(result == 0) {
                        // 进入成功
                        // 初始化呀呀语音网络状态监听
                        if (netStateListener == null){
                            netStateListener = new YayaNetStateListener() {
                                @Override
                                public void onNetStateUpdate(long l, long l1) {

                                }
                            };
                            YayaRTV.getInstance().setNetStateListener(netStateListener);
                        }

                        YayaRTV.getInstance().setVoiceVolume(5);

                        SPUtil.setInt(context, "onLogin", 1);

                    }else {
                        // 进入失败

                    }

                }

                @Override
                public void onLogoutResp(long result, String msg) {
                    // 退出房间返回
                    Log.d("-----呀呀语音-----", "onLogoutResp result:" + result + ",msg:" + msg);

                }

                @Override
                public void onMicResp(long result, String msg, String actionType) {
                    // 麦请求返回
                    Log.d("-----呀呀语音-----", "onMicResp result:" + result + ",msg:" + msg + ",actionType:" + actionType);

                }

                @Override
                public void onModeSettingResp(long l, String s, RTV.Mode mode) {

                }

                @Override
                public void onSendRealTimeVoiceMessageResp(long result, String msg) {
                    Log.d("-----呀呀语音-----", "onSendRealTimeVoiceMessageResp result:" + result + ",msg:" + msg);

                }

                @Override
                public void onTextMessageNotify(TextMessageNotify textMessageNotify) {

                    String sendMode = SPUtil.getString(MyApplication.gameActivity, "sendMode");
                    if ("1".equals(sendMode)){
                        if (!SPUtil.getString(MyApplication.gameActivity, "roomId").equals("")){
                            if (SPUtil.getBoolean(MyApplication.gameActivity, "isInGame")){
                                try {
                                    JSONObject obj = new JSONObject(textMessageNotify.getText());
                                    String type = obj.getString("type");
                                    final String url = obj.getString("url");
                                    if ("voice".equals(type)){
                                        if ("".equals(url)){
                                            Toast.makeText(MyApplication.gameActivity, "录音地址有误哦！", Toast.LENGTH_SHORT).show();
                                            return;
                                        }

                                        Log.d("-----playVoice-----",url);
                                        YayaLiteIM.getInstance().startPlayVoiceByUrl(url, null, new PlayListener() {
                                            @Override
                                            public void onPlayStart() {
                                                //Toast.makeText(MyApplication.gameActivity, "开始播放", Toast.LENGTH_SHORT).show();
                                            }

                                            @Override
                                            public void onPlayComplete() {
                                                //Toast.makeText(MyApplication.gameActivity, "播放结束", Toast.LENGTH_SHORT).show();
                                            }

                                            @Override
                                            public void onPlayException(int i, String s) {
                                                Toast.makeText(MyApplication.gameActivity, s, Toast.LENGTH_SHORT).show();
                                            }
                                        });
                                        /*String voicePath = getVoiceFolder() + "/" + new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()) + "_voice.amr";
                                        final File f = new File(voicePath);
                                        if (f.exists()) {
                                            f.delete();
                                        }
                                        FinalHttp fh = new FinalHttp();
                                        fh.download(url, voicePath, new AjaxCallBack<File>(){

                                            @Override
                                            public void onStart() {
                                                super.onStart();
                                            }

                                            @Override
                                            public void onLoading(long count, long current) {
                                                super.onLoading(count, current);
                                            }

                                            @Override
                                            public void onSuccess(final File t) {
                                                super.onSuccess(t);
                                                if (t != null){
                                                    try {
                                                        YayaLiteIM.getInstance().startPlayVoice(t.getAbsoluteFile().toString(), new PlayListener() {
                                                            @Override
                                                            public void onPlayStart() {
                                                                Log.d("-----YayaLiteIM-----", "onPlayStart: ");
                                                            }

                                                            @Override
                                                            public void onPlayComplete() {
                                                                Log.d("-----YayaLiteIM-----", "onPlayComplete: ");
                                                            }

                                                            @Override
                                                            public void onPlayException(int i) {
                                                                Log.d("-----YayaLiteIM-----", "onPlayException: ");
                                                            }
                                                        });
                                                    } catch (FileNotFoundException e) {
                                                        e.printStackTrace();
                                                    }
                                                }else {
                                                    Toast.makeText(MyApplication.gameActivity, "录音文件有误", Toast.LENGTH_SHORT).show();
                                                }
                                            }

                                            @Override
                                            public void onFailure(Throwable t, int errorNo,String strMsg) {
                                                super.onFailure(t, errorNo, strMsg);
                                                Toast.makeText(MyApplication.gameActivity, "下载录音失败", Toast.LENGTH_SHORT).show();
                                            }

                                        });*/

                                    }else if ("video".equals(type)){

                                        String videoPath = getVoiceFolder() + "/" + new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()) + "_video.mp4";
                                        final File f = new File(videoPath);
                                        if (f.exists()) {
                                            f.delete();
                                        }
                                        FinalHttp fh = new FinalHttp();
                                        fh.download(url, videoPath, new AjaxCallBack<File>(){

                                            @Override
                                            public void onStart() {
                                                super.onStart();
                                            }

                                            @Override
                                            public void onLoading(long count, long current) {
                                                super.onLoading(count, current);
                                            }

                                            @Override
                                            public void onSuccess(final File t) {
                                                super.onSuccess(t);
//                                                Toast.makeText(getApplicationContext(), "下载完成", Toast.LENGTH_SHORT).show();
//                                                textView.setText(t==null?"null":t.getAbsoluteFile().toString());
                                                if (t != null){
                                                    if (MyApplication.isInGame){
                                                        if (MyApplication.gameActivity.videoList == null) {
                                                            MyApplication.gameActivity.videoList = new ArrayList<String>();
                                                        }
                                                        MyApplication.gameActivity.videoList.add(t.getAbsoluteFile().toString());
                                                        if (!MyApplication.gameActivity.player.isPlaying()){
                                                            // 假如当前没有视频在播放，那播放视频
                                                            MyApplication.gameActivity.play();
                                                        }
                                                    }else {
                                                        Toast.makeText(MyApplication.gameActivity, "视频文件有误", Toast.LENGTH_SHORT).show();
                                                    }
                                                }
                                            }

                                            @Override
                                            public void onFailure(Throwable t, int errorNo,String strMsg) {
                                                super.onFailure(t, errorNo, strMsg);
                                                Toast.makeText(MyApplication.gameActivity, "下载视频失败", Toast.LENGTH_SHORT).show();
                                            }

                                        });

                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }

                }

                @Override
                public void onSendTextMessageResp(long l, String s, String s1) {

                }

                @Override
                public void onRealTimeVoiceMessageNotify(String troopsId, long yunvaId, String expand) {
                    // 当前有人说话
                    Log.d("-----呀呀语音-----", "onRealTimeVoiceMessageNotify 当前有人说话 troopsId:" + troopsId + ",yunvaId:" + yunvaId + ",expand:" + expand);

                }

                @Override
                public void onTroopsModeChangeNotify(RTV.Mode mode, boolean b) {

                }

                @Override
                public void audioRecordUnavailableNotify(int i, String s) {

                }

                @Override
                public void onAuthResp(long result, String msg) {
                    // 登录房间授权返回
                   // myYunvaId = yunvaId;
                    Log.d("-----呀呀语音-----", "onAuthResp result:" + result + ",msg:" + msg);
                }

                @Override
                public void onGetRoomResp(long result, String msg) {
                    // 获取房间返回
                    Log.d("-----呀呀语音-----", "onGetRoomResp result:" + result + ",msg:" + msg);
                }

                @Override
                public void onReconnectStart() {
                    // 重连开始
                    Log.d("-----呀呀语音-----", "onReconnectStart:" + "");
                    SPUtil.setInt(context, "onLogin", 0);
                }

                @Override
                public void onReconnectFail(int result, String msg) {
                    // 重连失败
                    Log.d("-----呀呀语音-----", "onGetRoomResp result:" + result + ",msg:" + msg);
                }

                @Override
                public void onReconnectSuccess() {
                    // 重连成功
                    Log.d("-----呀呀语音-----", "onReconnectSuccess:" + "");
                    SPUtil.setInt(context, "onLogin", 1);
                    currentMicType = RTV.ACTION_TYPE_CLOSE_MIC;
                }
            };
            YayaRTV.getInstance().init(context, RequestURL.YAYAAPP_ID, videoTroopsRespondListener, sdkEnv, rtvMode);
        }

        // IM模块
        // 创建语音保存路径
        createFolder();
        // 初始化录音模块
        YayaLiteIM.getInstance().init(context, sdkEnv, RequestURL.YAYAAPP_ID);

    }

    /**
     * 进入房间
     * @param roomId
     */
    public static void LoginRoom(String roomId){
        Log.d("-----呀呀语音-----", "LoginRoom");

        int initComplete = SPUtil.getInt(MyApplication.gameActivity , "YaYainitComplete");
        if (initComplete == 1){
            YayaRTV.getInstance().login(roomId);
        }

    }

    /**
     * 退出房间
     */
    public static void LogoutRoom(){
        Log.d("-----呀呀语音-----", "LogoutRoom");

        YayaRTV.getInstance().logout();

        SPUtil.setInt(MyApplication.gameActivity, "onLogin", 0);

    }

    /**
     * 上麦
     */
    public static void micUp(){
        Log.d("-----呀呀语音-----", "micUp");
        YayaRTV.getInstance().micUp();
    }

    /**
     * 下麦
     */
    public static void micDown(){
        Log.d("-----呀呀语音-----", "micDown");
        YayaRTV.getInstance().micDown();
    }

    /**
     * 发送文字信息
     * @param text
     */
    public static void sendTextMessage(String type,String text) throws JSONException {
        JSONObject obj = new JSONObject();
        obj.put("type",type);
        obj.put("url",text);
        String msg = obj.toString();
        YayaRTV.getInstance().sendTextMessage(msg, SPUtil.getString(MyApplication.gameActivity, "roomId"));
    }

    /**
     * 开始录音
     */
    public static int playanim = 0;
    public static int isStopRecord = 0;
    public static final int maxTime = 60;
    public static int countTime;
    public static boolean isMaxDuration;
    public static Handler dealCountTimeHandler;
    public static void startRecord(){

        String sendMode = SPUtil.getString(MyApplication.gameActivity, "sendMode");
        if (!"2".equals(sendMode)){
            if (SPUtil.getInt(MyApplication.gameActivity, "onLogin") == 0){
                Toast.makeText(MyApplication.gameActivity, "语音服务正在启动", Toast.LENGTH_SHORT).show();
                return;
            }
        }

        // 设置录音倒计时
        if (dealCountTimeHandler == null){

            dealCountTimeHandler = new Handler() {
                @Override
                public void handleMessage(Message msg) {

                    countTime--;
                    if (countTime >= 0) {
                        isMaxDuration = false;

                        if (playanim == 0){
                            playanim = 1;
                            MyApplication.voiceRV.volume_iv.setBackgroundResource(R.drawable.sound2);
                        }else{
                            playanim = 0;
                            MyApplication.voiceRV.volume_iv.setBackgroundResource(R.drawable.sound3);
                        }

                        sendEmptyMessageDelayed(0, 1000);
                    }else{
                        countTime = maxTime;
                        YayaLiteIM.getInstance().stopPlayVoice();
                        isMaxDuration = true;
                        isStopRecord = 1;
                    }

                }
            };

        }

        isMaxDuration = false;
        YayaLiteIM.getInstance().stopPlayVoice();

        String voice_path = getVoiceFolder() + File.separator + "voice.amr";
        boolean start = YayaLiteIM.getInstance().startVoiceRecord(voice_path, new RecordListener() {
            @Override
            public void onRecordStart() {
                Log.d("-----YayaLiteIM-----", "onRecordStart");
            }

            @Override
            public void onRecordFinish(String filePath, long l,String url,String text) {
                Log.d("-----YayaLiteIM-----", "onRecordFinish");
                final String len = Long.toString(l / 1000);
                Log.d("-----YayaLiteIM-----", len);
                if (url != null) {//边录边上传成功
                    filePath = url;
                }
                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (MyApplication.ly_record_voice != null) {
                            MyApplication.ly_record_voice.setVisibility(View.GONE);
                        }
                    }
                });


                if(isStopRecord == 1){
                    YayaLiteIM.getInstance().uploadVoiceMessage(filePath, new LiteIm.UploadVoiceMessageCallback() {
                        @Override
                        public void onUploadVoiceMessageFail(int i, String s) {

                            MyApplication.gameActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Toast.makeText(MyApplication.gameActivity, "上传录音失败", Toast.LENGTH_SHORT).show();
                                }
                            });

                        }

                        @Override
                        public void onUploadVoiceMessageSuccess(UploadFileRespInfo info) {
                            if (info.getFile_id() != null) {

                                String sendMode = SPUtil.getString(MyApplication.gameActivity, "sendMode");
                                if ("2".equals(sendMode)){
                                    // lua发送
                                    JSONObject object = new JSONObject();
                                    try {
                                        object.put("msgType", "voice");
                                        object.put("voiceTime", len);
                                        object.put("url", info.getFile_id());
                                        LuaJavaBridgeTest.sendDataToLua("msg", object);

                                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(MyApplication.gameActivity, "发送录音", Toast.LENGTH_SHORT).show();
                                            }
                                        });

                                    } catch (JSONException e) {
                                        e.printStackTrace();

                                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(MyApplication.gameActivity, "发送录音失败", Toast.LENGTH_SHORT).show();
                                            }
                                        });

                                    }

                                }else{
                                    // 呀呀发送
                                    try {

                                        // 通过呀呀发送录音地址
                                        sendTextMessage("voice", info.getFile_id());

                                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(MyApplication.gameActivity, "发送录音", Toast.LENGTH_SHORT).show();
                                            }
                                        });

                                    } catch (JSONException e) {
                                        e.printStackTrace();

                                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(MyApplication.gameActivity, "发送录音失败", Toast.LENGTH_SHORT).show();
                                            }
                                        });

                                    }

                                }

                            }
                        }

                    });
                }

            }

            @Override
            public void onRecordException(int i, String s) {
                Log.d("-----YayaLiteIM-----", "onRecordException");
                Toast.makeText(MyApplication.gameActivity, "录音时间太短", Toast.LENGTH_SHORT).show();
            }

        });
        if(start){
            isStopRecord = 0;
            playanim = 0;
            countTime = maxTime;
            dealCountTimeHandler.removeMessages(0);
            dealCountTimeHandler.sendEmptyMessage(0);
        }else{
            Toast.makeText(MyApplication.gameActivity, "录音失败", Toast.LENGTH_SHORT).show();
        }

        // 显示音量监听
        MyApplication.gameActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (MyApplication.ly_record_voice != null) {
                    MyApplication.ly_record_voice.setVisibility(View.VISIBLE);
                }
            }
        });

    }

    /**
     * 停止录音
     */
    public static void stopReord(){

        if(!isMaxDuration){
            if (dealCountTimeHandler != null){
                dealCountTimeHandler.removeMessages(0);
            }
            countTime = maxTime;
            isMaxDuration = false;
            YayaLiteIM.getInstance().stopVoiceRecord();

            isStopRecord = 1;
            playanim = 0;
        }

        MyApplication.gameActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (MyApplication.ly_record_voice != null) {
                    MyApplication.ly_record_voice.setVisibility(View.GONE);
                }
            }
        });

    }

    /**
     * 取消录音
     */
    public static void cancelReord(){

        if(!isMaxDuration){
            if (dealCountTimeHandler != null){
                dealCountTimeHandler.removeMessages(0);
            }
            countTime = maxTime;
            isMaxDuration = false;
            YayaLiteIM.getInstance().stopVoiceRecord();

            isStopRecord = 0;
            playanim = 0;
        }

        MyApplication.gameActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (MyApplication.ly_record_voice != null) {
                    MyApplication.ly_record_voice.setVisibility(View.GONE);
                }
            }
        });

    }

    /**
     * 注销实时语音服务
     */
    public static void CloseVoiceServer(){

        Log.d("-----呀呀语音-----", "destroy");

        // 置空房间号
        SPUtil.setString(MyApplication.gameActivity, "roomId", "");

        YayaRTV.getInstance().destroy();

    }

    public static boolean createFolder() {
        File file = new File(getVoiceFolder());
        if (!file.exists()) {
            if (file.mkdirs()) {
                return true;
            } else {
                return false;
            }
        }
        return true;
    }

    public static boolean hasSdcard() {
        String status = Environment.getExternalStorageState();
        if (status.equals(Environment.MEDIA_MOUNTED)) {
            return true;
        } else {
            return false;
        }
    }

    public static String getVoiceFolder(){
        if(hasSdcard()){
            return voice_path;
        }else{
            return MyApplication.gameActivity.getFilesDir().getAbsolutePath()
                    + File.separator + "voice"+ File.separator;
        }
    }

}
