/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.location.Poi;
import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.util.OSSUtil;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.utils.YaYaVoiceUtil;
import com.linkxin.douyouPlayer.view.MovieRecorderView;
import com.linkxin.douyouPlayer.view.VoiceRecorderView;
import com.pingplusplus.android.Pingpp;
import com.yaya.sdk.YayaRTV;
import com.yunva.extension.YayaLiteIM;
import com.zxinsight.MWConfiguration;
import com.zxinsight.MagicWindowSDK;
import com.zxinsight.Session;

import net.tsz.afinal.FinalHttp;
import net.tsz.afinal.http.AjaxCallBack;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class AppActivity extends Cocos2dxActivity {

    private MovieRecorderView movieRV;
    private Button startBtn;
    private Button closeBtn;
    private boolean isRecord = false;

    private VoiceRecorderView voiceRV;

    private PowerManager powerManager = null;
    private PowerManager.WakeLock wakeLock = null;

    // 百度定位
    public LocationClient mLocationClient = null;
    public BDLocationListener myListener = null;

    // 视频播放
    public View showvideo;
    private Button playBtn;
    private Button pauseBtn;

    private SurfaceView playView;
    public MediaPlayer player;
    public List<String> videoList;

    private BatteryReceiver receiver = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 保持屏幕常亮
        powerManager = (PowerManager)this.getSystemService(this.POWER_SERVICE);
        wakeLock = this.powerManager.newWakeLock(PowerManager.FULL_WAKE_LOCK, "My Lock");

        // 进入游戏大厅
        MyApplication.gameActivity = this;
        MyApplication.nowEnterGame = 0;

        // 视频录制
        View v = LayoutInflater.from(this).inflate(R.layout.ly_record, null);
        MyApplication.ly_record = v;
        this.mFrameLayout.addView(v);
        v.setVisibility(View.GONE);

        isRecord = false;

        movieRV = (MovieRecorderView) v.findViewById(R.id.moive_rv);
        MyApplication.movieRV = movieRV;

        //录制
        startBtn = (Button) v.findViewById(R.id.start_btn);
        MyApplication.start_btn = startBtn;
        startBtn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {

                if (isRecord){
                    movieRV.cutDownAndUpLoad();
                }else{

                    isRecord = true;

                    startBtn.setBackgroundResource(R.drawable.game_video_play_p);
                    movieRV.record(new MovieRecorderView.OnRecordFinishListener() {
                        @Override
                        public void onRecordFinish() {

                            Log.d("-----视频录制-----","录制完成，视频地址：" + SPUtil.getString(MyApplication.gameActivity, "RecordPath"));

                            // 通知Lua录制结束
                            isRecord = false;
                            LuaJavaBridgeTest.recordDidClose();

                            OSSUtil.UpLoadFile(AppActivity.this, SPUtil.getString(MyApplication.gameActivity, "RecordPath"));

                            MyApplication.gameActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {

                                    startBtn.setBackgroundResource(R.drawable.game_video_play_n);
                                    MyApplication.ly_record.setVisibility(View.GONE);

                                }
                            });

                        }
                    });
                }

            }
        });

        // 关闭按钮
        closeBtn = (Button) v.findViewById(R.id.close_btn);
        closeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        if (isRecord){
                            movieRV.closeRecord();
                        }else{
                            // 停止录制
                            movieRV.stop();
                        }

                        // 通知Lua录制结束
                        isRecord = false;
                        LuaJavaBridgeTest.recordDidClose();

                        startBtn.setBackgroundResource(R.drawable.game_video_play_n);
                        MyApplication.ly_record.setVisibility(View.GONE);

                    }
                });

            }
        });

        // 视频播放
        videoList = new ArrayList<String>();
        showvideo = LayoutInflater.from(this).inflate(R.layout.ly_showvideo, null);
        showvideo.setVisibility(View.GONE);
        this.mFrameLayout.addView(showvideo);
        MyApplication.showvideo = showvideo;

        // 显示位置
        playView = (SurfaceView) showvideo.findViewById(R.id.play_surfaceV);
        playView.setZOrderMediaOverlay(true);
        // 设置SurfaceView自己不管理的缓冲区
        playView.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        playView.getHolder().setFormat(PixelFormat.OPAQUE);
        playView.getHolder().addCallback(new SurfaceHolder.Callback() {

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                Log.d("surfaceDestroyed", "-----playView-----");
            }

            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                Log.d("surfaceCreated", "-----playView-----");

                // 把视频画面输出到SurfaceView
                player.setDisplay(playView.getHolder());

            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
                Log.d("surfaceChanged", "-----playView-----");
            }

        });

        player = new MediaPlayer();
        player.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mp.start();
            }
        });
        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {

                DelOldAndGoOn();

            }
        });

//        playBtn = (Button) showvideo.findViewById(R.id.playBtn);
//        playBtn.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                play();
//            }
//        });
//
//        pauseBtn = (Button) showvideo.findViewById(R.id.pauseBtn);
//        pauseBtn.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                if (player.isPlaying()) {
//                    player.pause();
//                } else {
//                    player.start();
//                }
//            }
//        });

        // 录音音量监听
        View ly_record_voice = LayoutInflater.from(this).inflate(R.layout.ly_record_voice, null);
        MyApplication.ly_record_voice = ly_record_voice;
        MyApplication.ly_record_voice.setVisibility(View.GONE);
        this.mFrameLayout.addView(ly_record_voice);

        voiceRV = (VoiceRecorderView) ly_record_voice.findViewById(R.id.voice_rv);
        MyApplication.voiceRV = voiceRV;

//        View text_ly = LayoutInflater.from(this).inflate(R.layout.text_ly, null);
//        this.mFrameLayout.addView(text_ly);
//
//        Button show_bt = (Button) text_ly.findViewById(R.id.show_bt);
//        show_bt.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//
//                MyApplication.gameActivity.runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        MyApplication.ly_record.setVisibility(View.VISIBLE);
//
//                    }
//                });
//
//            }
//        });
//
//        Button voice_bt = (Button) text_ly.findViewById(R.id.voice_bt);
//        voice_bt.setOnTouchListener(new View.OnTouchListener() {
//            @Override
//            public boolean onTouch(View v, MotionEvent event) {
//
//                switch(event.getAction()){
//
//                    case MotionEvent.ACTION_DOWN:
//                        System.out.println("按下");
//
//                        MyApplication.ly_record_voice.setVisibility(View.VISIBLE);
//
//                        voiceRV.record(new VoiceRecorderView.OnRecordFinishListener() {
//                            @Override
//                            public void onRecordFinish() {
//
//                                Log.d("-----录音-----","录制完毕，音频地址：" + SPUtil.getString(MyApplication.gameActivity, "RecordVoicePath"));
//
//                                File file = new File(SPUtil.getString(MyApplication.gameActivity, "RecordVoicePath"));
//                                if (!file.exists()) {
//
//                                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
//                                        @Override
//                                        public void run() {
//                                            Toast.makeText(MyApplication.gameActivity, "录音失败，请重试", Toast.LENGTH_SHORT).show();
//                                        }
//                                    });
//
//                                }else{
//
//                                    Log.d("文件大小：", String.valueOf(file.length()));
//
//                                    if (file.length() <= 0){
//
//                                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
//                                            @Override
//                                            public void run() {
//                                                Toast.makeText(MyApplication.gameActivity, "录音时间太短，请重试", Toast.LENGTH_SHORT).show();
//                                            }
//                                        });
//
//                                    }else{
//
//                                        OSSUtil.UpLoadVoiceFile(MyApplication.gameActivity, SPUtil.getString(MyApplication.gameActivity, "RecordVoicePath"));
//
//                                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
//                                            @Override
//                                            public void run() {
//                                                MyApplication.ly_record_voice.setVisibility(View.GONE);
//                                            }
//                                        });
//
//                                    }
//
//                                }
//
//                            }
//                        });
//
//                        break;
//
//                    case MotionEvent.ACTION_UP:
//                        System.out.println("抬起");
//
//                        voiceRV.cutDownAndUpLoad();
//
//                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                MyApplication.ly_record_voice.setVisibility(View.GONE);
//                            }
//                        });
//
//                        break;
//
//                    case MotionEvent.ACTION_CANCEL:
//                        System.out.println("取消");
//
//                        voiceRV.stop();
//
//                        break;
//
//                    case MotionEvent.ACTION_OUTSIDE:
//                        System.out.println("外面");
//
//                        voiceRV.stop();
//
//                        break;
//                }
//
//                return false;
//            }
//        });

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                String roomId = SPUtil.getString(AppActivity.this, "roomId");
                int nowInHall = SPUtil.getInt(AppActivity.this, "nowInHall");
                if (nowInHall == 1 && roomId.equals("")){
                    AppActivity.this.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            LuaJavaBridgeTest.joinGame();
                        }
                    });
                }
            }
        }, 3000);

    }

    public void play(){

        try {

            showvideo.setVisibility(View.VISIBLE);

            player.reset();
            player.setAudioStreamType(AudioManager.STREAM_MUSIC);

            try {

                // 设置需要播放的视频
                File file = new File(videoList.get(0));
                if (file.exists()) {
                    FileInputStream fis = new FileInputStream(file);
                    player.setDataSource(fis.getFD());

//                    player.setDataSource(videoList.get(0));

                    // 设置播放器准备
                    try {
                        player.prepare();
                    } catch (IOException e) {
                        e.printStackTrace();
                        Log.d(e.getMessage(), "-----play prepare-----");

                        final String msg = e.getMessage();
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(AppActivity.this, "视频播放失败," + msg, Toast.LENGTH_SHORT).show();
                            }
                        });

                        DelOldAndGoOn();

                    }

                }else{

//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            Toast.makeText(AppActivity.this, "视频播放失败," + "文件不存在", Toast.LENGTH_SHORT).show();
//                        }
//                    });

                    DelOldAndGoOn();

                }

            } catch (final IOException e) {
                e.printStackTrace();
                Log.d(e.getMessage(), "-----play setDataSource-----");

                final String msg = e.getMessage();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(AppActivity.this, "视频播放失败," + msg, Toast.LENGTH_SHORT).show();
                    }
                });

                DelOldAndGoOn();

            }

        } catch (Exception e) {
            // TODO: handle exception
            Log.d(e.getMessage(), "-----play-----");

            final String msg = e.getMessage();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(AppActivity.this, "视频播放失败," + msg, Toast.LENGTH_SHORT).show();
                }
            });

            DelOldAndGoOn();

        }

    }

    public void DelOldAndGoOn(){

        // 删除播完的视频
        File f = new File(videoList.get(0));
        if (f.exists()) {
            f.delete();
        }

        // 移除这条链接
        videoList.remove(0);

        // 判断当前是否有未播链接
        if (videoList.size() > 0){
            play();
        }else{
            // 清空surfaceview的显示痕迹
            if (playView.getHolder() != null){
                playView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
                playView.getHolder().setFormat(PixelFormat.OPAQUE);
                showvideo.setVisibility(View.GONE);
            }
        }

    }

    private void initLocation(){
        LocationClientOption option = new LocationClientOption();
        option.setLocationMode(LocationClientOption.LocationMode.Hight_Accuracy);//可选，默认高精度，设置定位模式，高精度，低功耗，仅设备
        option.setCoorType("bd09ll");//可选，默认gcj02，设置返回的定位结果坐标系
        int span = 10000;
        option.setScanSpan(span);//可选，默认0，即仅定位一次，设置发起定位请求的间隔需要大于等于1000ms才是有效的
        option.setIsNeedAddress(true);//可选，设置是否需要地址信息，默认不需要
        option.setOpenGps(true);//可选，默认false,设置是否使用gps
        option.setLocationNotify(true);//可选，默认false，设置是否当GPS有效时按照1S/1次频率输出GPS结果
        option.setIsNeedLocationDescribe(false);//可选，默认false，设置是否需要位置语义化结果，可以在BDLocation.getLocationDescribe里得到，结果类似于“在北京天安门附近”
        option.setIsNeedLocationPoiList(false);//可选，默认false，设置是否需要POI结果，可以在BDLocation.getPoiList里得到
        option.setIgnoreKillProcess(true);//可选，默认true，定位SDK内部是一个SERVICE，并放到了独立进程，设置是否在stop的时候杀死这个进程，默认不杀死
        option.SetIgnoreCacheException(false);//可选，默认false，设置是否收集CRASH信息，默认收集
        option.setEnableSimulateGps(true);//可选，默认false，设置是否需要过滤GPS仿真结果，默认需要
        mLocationClient.setLocOption(option);
    }

    public class MyLocationListener implements BDLocationListener {

        @Override
        public void onReceiveLocation(BDLocation location) {
            //Receive Location

            if (location.getLocType() == 161){
                // 定位成功
                SPUtil.setString(AppActivity.this, "Longitude", Double.toString(location.getLongitude()));
                SPUtil.setString(AppActivity.this, "Latitude",  Double.toString(location.getLatitude()));

                // 定位城市
                SPUtil.setString(AppActivity.this, "locatedCityId", location.getCityCode());
                SPUtil.setString(AppActivity.this, "locatedCityName", location.getCity());

//                ToastUtil.showBaseToast(AppActivity.this, "城市Code：" + SPUtil.getString(AppActivity.this, "locatedCityId") + "," + "城市：" + SPUtil.getString(AppActivity.this, "locatedCityName"));

                mLocationClient.stop();

            }else{
                SPUtil.setString(AppActivity.this, "Longitude", "0");
                SPUtil.setString(AppActivity.this, "Latitude",  "0");
                SPUtil.setString(AppActivity.this, "locatedCityId", "");
                SPUtil.setString(AppActivity.this, "locatedCityName", "");
            }

//            StringBuffer sb = new StringBuffer(256);
//            sb.append("time : ");
//            sb.append(location.getTime());
//            sb.append("\nerror code : ");
//            sb.append(location.getLocType());
//            sb.append("\nlatitude : ");
//
//            sb.append(location.getLatitude());
//            sb.append("\nlontitude : ");
//            sb.append(location.getLongitude());
//            sb.append("\nradius : ");
//            sb.append(location.getRadius());
//            if (location.getLocType() == BDLocation.TypeGpsLocation) {// GPS定位结果
//                sb.append("\nspeed : ");
//                sb.append(location.getSpeed());// 单位：公里每小时
//                sb.append("\nsatellite : ");
//                sb.append(location.getSatelliteNumber());
//                sb.append("\nheight : ");
//                sb.append(location.getAltitude());// 单位：米
//                sb.append("\ndirection : ");
//                sb.append(location.getDirection());// 单位度
//                sb.append("\naddr : ");
//                sb.append(location.getAddrStr());
//                sb.append("\ndescribe : ");
//                sb.append("gps定位成功");
//
//            } else if (location.getLocType() == BDLocation.TypeNetWorkLocation) {// 网络定位结果
//                sb.append("\naddr : ");
//                sb.append(location.getAddrStr());
//                //运营商信息
//                sb.append("\noperationers : ");
//                sb.append(location.getOperators());
//                sb.append("\ndescribe : ");
//                sb.append("网络定位成功");
//            } else if (location.getLocType() == BDLocation.TypeOffLineLocation) {// 离线定位结果
//                sb.append("\ndescribe : ");
//                sb.append("离线定位成功，离线定位结果也是有效的");
//            } else if (location.getLocType() == BDLocation.TypeServerError) {
//                sb.append("\ndescribe : ");
//                sb.append("服务端网络定位失败，可以反馈IMEI号和大体定位时间到loc-bugs@baidu.com，会有人追查原因");
//            } else if (location.getLocType() == BDLocation.TypeNetWorkException) {
//                sb.append("\ndescribe : ");
//                sb.append("网络不同导致定位失败，请检查网络是否通畅");
//            } else if (location.getLocType() == BDLocation.TypeCriteriaException) {
//                sb.append("\ndescribe : ");
//                sb.append("无法获取有效定位依据导致定位失败，一般是由于手机的原因，处于飞行模式下一般会造成这种结果，可以试着重启手机");
//            }
//            sb.append("\nlocationdescribe : ");
//            sb.append(location.getLocationDescribe());// 位置语义化信息
//            List<Poi> list = location.getPoiList();// POI数据
//            if (list != null) {
//                sb.append("\npoilist size = : ");
//                sb.append(list.size());
//                for (Poi p : list) {
//                    sb.append("\npoi= : ");
//                    sb.append(p.getId() + " " + p.getName() + " " + p.getRank());
//                }
//            }
//            Log.i("BaiduLocationApiDem", sb.toString());

        }
    }

    @Override
    protected void onResume() {
        // TODO Auto-generated method stub

        MyApplication.gameActivity = this;
        MyApplication.nowEnterGame = 0;

        // 设置当前在游戏里
        MyApplication.isInGame = true;
        SPUtil.setboolean(this,"isInGame",MyApplication.isInGame);

        super.onResume();

        Session.onResume(this);

        // 启动呀呀语音服务
        YaYaVoiceUtil.SetUpVoiceServer(this);

        wakeLock.acquire();

//        LocationUtil.getLoactionServe(this);

        // 回来之后继续播放
        YayaRTV.getInstance().resumePlay();

        // 百度定位
        if (mLocationClient == null){
            mLocationClient = new LocationClient(getApplicationContext());     //声明LocationClient类
            initLocation();// 配置定位参数
        }
        if (myListener == null){
            myListener = new MyLocationListener();// 初始化监听器
            mLocationClient.registerLocationListener(myListener);    //注册监听函数
        }
        mLocationClient.start();

        // 系统电量监听
        receiver = new BatteryReceiver();
        IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        registerReceiver(receiver, filter);//注册BroadcastReceiver

        // 通知lua应用进入前台
//        new Handler().postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                AppActivity.this.runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//
//                        JSONObject object = new JSONObject();
//                        try {
//                            object.put("state", "foreground");
//                        } catch (JSONException e) {
//                            e.printStackTrace();
//                        }
//                        LuaJavaBridgeTest.sendDataToLua("app", object);
//
//                    }
//                });
//            }
//        }, 1000);



//        String ip = LuaJavaBridgeTest.getIPAddress();
//        Log.d(ip,"-----ip-----");

    }

    @Override
    protected void onPause() {
        // TODO Auto-generated method stub

        // 判断是否正在播放视频
        if (player.isPlaying()) {
            player.stop();

            // 删除这条视频
            File f = new File(videoList.get(0));
            if (f.exists()) {
                f.delete();
            }

        }

        // 清空surfaceview的显示痕迹
        if (playView != null){
            playView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
            playView.getHolder().setFormat(PixelFormat.OPAQUE);
        }

        MyApplication.isInGame = false;
        YayaLiteIM.getInstance().stopPlayVoice();

        LuaJavaBridgeTest.shareCancel();

        // 注销系统电量监听
        unregisterReceiver(receiver);
        receiver = null;

        if (MyApplication.movieRV == null){

        }else{
            MyApplication.movieRV.freeCameraResource();
        }

        // 需要用SP储存的值
        SPUtil.setInt(this,"SCREEN_WIDTH",MyApplication.SCREEN_WIDTH);
        SPUtil.setInt(this,"SCREEN_HEIGHT",MyApplication.SCREEN_HEIGHT);

        // 登录状态
        SPUtil.setboolean(this,"isLogin",MyApplication.isLogin);

        // 公会
        SPUtil.setboolean(this,"isloadSociety",MyApplication.isloadSociety);
        SPUtil.setString(this,"othersocietyId",MyApplication.othersocietyId);
        SPUtil.setString(this,"nowActivityId",MyApplication.nowActivityId);
        SPUtil.setString(this,"nowMineSectionId",MyApplication.nowMineSectionId);

        // 当前的经纬度
        SPUtil.setString(this,"latitude",MyApplication.latitude);
        SPUtil.setString(this,"longitude",MyApplication.longitude);

        // 游戏
        SPUtil.setInt(this,"nowEnterGame",MyApplication.nowEnterGame);
        SPUtil.setString(this,"getGameCode",MyApplication.getGameCode);
        SPUtil.setInt(this,"GAME_SCREEN_WIDTH",MyApplication.GAME_SCREEN_WIDTH);
        SPUtil.setInt(this,"GAME_SCREEN_HEIGHT",MyApplication.GAME_SCREEN_HEIGHT);
        SPUtil.setboolean(this,"isToGame",MyApplication.isToGame);
        SPUtil.setboolean(this,"isInGame",MyApplication.isInGame);
        SPUtil.setboolean(this,"isRecharge",MyApplication.isRecharge);

        // 直播间
        SPUtil.setString(this,"CompereId",MyApplication.compereId); 	    // 当前所在直播间主播id
        SPUtil.setString(this,"CompereSex",MyApplication.compereSex); 	    // 当前所在直播间主播性别

        // 组局
        SPUtil.setInt(this,"compereId",MyApplication.tableId);			    // 组局的table id
        SPUtil.setString(this,"activityId",MyApplication.activityId);	    // 组局的活动 id
        SPUtil.getString(this,"inviteCode",MyApplication.inviteCode);	    // 组局邀请码
        SPUtil.setInt(this,"groupChip",MyApplication.groupChip);		    // 组局创建者的带入筹码（此值为兑换筹码时的最小兑换数）
        SPUtil.setInt(this,"gamelevel",MyApplication.gamelevel);	        // 组局游戏等级
        SPUtil.setInt(this,"extract",MyApplication.extract);			    // 组局服务费

        // 定位城市
        SPUtil.setString(this,"locatedCityId", MyApplication.locatedCityId);
        SPUtil.setString(this,"locatedCityName", MyApplication.locatedCityName);

        super.onPause();

        Session.onPause(this);

        wakeLock.release();

//        LocationUtil.closeLoactionServe();

        //退到后台之后不播放
        YayaRTV.getInstance().pausePlay();

//        Cocos2dxHelper.sInited = false;
//        MyApplication.gameActivity = null;

//        // 通知lua应用进入后台
//        JSONObject object = new JSONObject();
//        try {
//            object.put("state", "background");
//        } catch (JSONException e) {
//            e.printStackTrace();
//        }
//        LuaJavaBridgeTest.sendDataToLua("app", object);

    }

    /**
     * 监听Back键按下事件,方法2:
     * 注意:
     * 返回值表示:是否能完全处理该事件
     * 在此处返回false,所以会继续传播该事件.
     * 在具体项目中此处的返回值视情况而定.
     */
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK)) {

            Intent backHome = new Intent(Intent.ACTION_MAIN);
            backHome.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            backHome.addCategory(Intent.CATEGORY_HOME);
            startActivity(backHome);

            return false;
        }else {
            return super.onKeyDown(keyCode, event);
        }

    }

    @Override
    protected void onStop() {
        super.onStop();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // 关闭呀呀语音服务
        YaYaVoiceUtil.CloseVoiceServer();

    }

    /**
     * onActivityResult 获得支付结果，如果支付成功，服务器会收到ping++ 服务器发送的异步通知。
     * 最终支付成功根据异步通知为准
     */
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        //支付页面返回处理
        if (requestCode == Pingpp.REQUEST_CODE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                String result = data.getExtras().getString("pay_result");
                /* 处理返回值
                 * "success" - payment succeed
                 * "fail"    - payment failed
                 * "cancel"  - user canceld
                 * "invalid" - payment plugin not installed
                 */
                String errorMsg = data.getExtras().getString("error_msg"); // 错误信息
                String extraMsg = data.getExtras().getString("extra_msg"); // 错误信息

//                Toast.makeText(AppActivity.this, result, Toast.LENGTH_SHORT).show();

                if ("success".equals(result)){
                    LuaJavaBridgeTest.payRoomCardSuccess();
                }else if ("fail".equals(result)){
                    LuaJavaBridgeTest.payRoomCardFail();
                }else if ("cancel".equals(result)){
                    LuaJavaBridgeTest.payRoomCardCancel();
                }else if ("invalid".equals(result)){
                    LuaJavaBridgeTest.payRoomCardInvalid();
                }else{
                    LuaJavaBridgeTest.payRoomCardFail();
                }

            }else{
                LuaJavaBridgeTest.payRoomCardFail();
            }

        }

    }

    private class BatteryReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            int current = intent.getExtras().getInt("level");//获得当前电量
            int total = intent.getExtras().getInt("scale");//获得总电量
            int percent = current * 100 / total;
            MyApplication.power = percent;
        }
    }

}
