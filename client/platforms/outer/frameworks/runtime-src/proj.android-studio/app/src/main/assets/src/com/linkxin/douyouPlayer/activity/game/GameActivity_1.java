package com.linkxin.douyouPlayer.activity.game;

import android.app.Activity;
import android.app.LocalActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.hardware.Camera;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.view.Display;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.baidu.cyberplayer.core.BVideoView;
import com.baidu.recorder.api.LiveSession;
import com.baidu.recorder.api.LiveSessionHW;
import com.baidu.recorder.api.LiveSessionSW;
import com.baidu.recorder.api.SessionStateListener;
import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.login.Login;
import com.linkxin.douyouPlayer.constant.DouyouConstants;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.util.SPUtil;
import com.linkxin.douyouPlayer.util.ToastUtil;
import com.linkxin.douyouPlayer.utils.JSONUtils;
import com.linkxin.douyouPlayer.view.PublicViews;
import com.linkxin.douyouPlayer.vo.DouyouUser;
import com.linkxin.douyouPlayer.vo.LiveResponse;
import com.linkxin.library.http.FinalHttpClient;
import com.linkxin.library.http.JsonResponse;
import com.tencent.tauth.Tencent;
import com.visionin.gpu.GPU;
import com.visionin.gpu.Visionin;

import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lua.AppActivity;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by zhongweihao on 16/8/1.
 */
public class GameActivity extends BaseActivity {

    private static final String TAG = "GameActivity";

    private static final int EVENT_RECORDER_CONNECTING = 0;
    private static final int EVENT_RECORDER_STARTED = 1;
    private static final int EVENT_RECORDER_STOPPED = 2;
    private static final int EVENT_SESSION_PREPARED = 3;
    private static final int EVENT_RESTART_STREAMING = 4;
    private static final int EVENT_RECONNECT_SERVER = 5;
    private static final int EVENT_STOP_STREAMING = 6;
    private static final int EVENT_SHOW_TOAST_MESSAGE = 7;
    private static final int EVENT_RESIZE_CAMERA_PREVIEW = 8;
    private static final int EVENT_START_LIVE = 9;


    protected LocalActivityManager mLocalActivityManager;
    private RelativeLayout base_rl;
    private RelativeLayout game_rl;


    //直播
    private RelativeLayout live_rl, live_container_rl, btn_container_rl;
    private ImageView live_zoom_bt, live_close_bt;
    private SurfaceView live_sfv;
    private LiveSession mLiveSession = null;
    private SessionStateListener mStateListener = null;
    private boolean isLiving;
    private LiveCallBack startLiveCallBack;
    private String streamAddress;
    private String playAddress;
    private String decodeType = null;
    private Timer hideLiveBtnTimer;
    private boolean isLiveBtnShowed;
    private boolean isLiveBtnHideInterrupt;
    private boolean isLiveZoomed;

    //直播状态
    private boolean isSessionReady = false;
    private boolean isSessionStarted = false;
    private boolean isConnecting = false;
    private boolean needRestartAfterStopped = false;
    private int mWeakConnectionHintCount = 0;

    private int mVideoWidth = 640;
    private int mVideoHeight = 480;
    private int mFrameRate = 15;
    private int mBitrate = 409600;

    //基准屏幕大小
    private int baseLiveWidth = 960;
    private int baseLiveHeight = 540;
    //基准直播控件大小
    private int preLiveWidth = 273;
    private int preLiveHeight = 228;
    private int preLiveMarginLeft = 338;

    private double widthRadio;
    private double heightRadio;

    //播放
    private BVideoView mVideoView = null;
    private boolean isPlaying;

//    private Button play_btn;

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case EVENT_RECORDER_CONNECTING:
                    isConnecting = true;
                    break;
                case EVENT_RECORDER_STARTED:
                    Log.i(TAG, "Starting Streaming succeeded!");
                    isSessionStarted = true;
                    needRestartAfterStopped = false;
                    isConnecting = false;
                    break;
                case EVENT_RECORDER_STOPPED:
                    Log.i(TAG, "Stopping Streaming succeeded!");
                    isSessionStarted = false;
                    needRestartAfterStopped = false;
                    isConnecting = false;
                    break;
                case EVENT_SESSION_PREPARED:
                    isSessionReady = true;
                    break;
                case EVENT_RECONNECT_SERVER:
                    Log.i(TAG, "Reconnecting to server...");
                    if (isSessionReady) {
                        boolean a = mLiveSession.startRtmpSession(streamAddress);
                        Log.i(TAG, "startRtmpSession=" + a);
                    }
                    handler.sendEmptyMessage(EVENT_RECORDER_CONNECTING);
                    break;
                case EVENT_STOP_STREAMING:
                    if (!isConnecting) {
                        Log.i(TAG, "Stopping current session...");
                        if (isSessionReady) {
                            mLiveSession.stopRtmpSession();
                        }
                        handler.sendEmptyMessage(EVENT_RECORDER_STOPPED);
                    }
                    break;
                case EVENT_RESTART_STREAMING:
                    if (!isConnecting) {
                        Log.i(TAG, "Restarting session...");
                        isConnecting = true;
                        needRestartAfterStopped = true;
                        if (isSessionReady) {
                            mLiveSession.stopRtmpSession();
                        }
                        handler.sendEmptyMessage(EVENT_RECORDER_CONNECTING);
                    }
                    break;
                case EVENT_RESIZE_CAMERA_PREVIEW:
                    fitPreviewToParentByResolution(live_sfv.getHolder(), mVideoWidth, mVideoHeight);
                    break;
                case EVENT_START_LIVE:
                    if (mLiveSession.startRtmpSession(streamAddress)) {
                        handler.sendEmptyMessage(EVENT_RECORDER_CONNECTING);
                    }
                    break;
                default:
                    break;
            }
            super.handleMessage(msg);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //不锁屏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_game);

        //初始化视诀
//        Visionin.initialize(this, "LOCAL_VISION_1", "LOCAL_VISION_2");

        mLocalActivityManager = new LocalActivityManager(this, true);

        mLocalActivityManager.dispatchCreate(savedInstanceState);
        initView();

    }

    private void initView() {
        base_rl = getViewById(R.id.base_rl);
        game_rl = getViewById(R.id.game_rl);
        View fv = mLocalActivityManager.startActivity("game", new Intent(GameActivity.this, AppActivity.class)).getDecorView();
        game_rl.addView(fv);

        widthRadio = (double) MyApplication.getInstance().getScreenWidth() / baseLiveWidth;
        heightRadio = (double) MyApplication.getInstance().getScreenHeight() / baseLiveHeight;

        live_rl = getViewById(R.id.live_rl);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams((int) (preLiveWidth * widthRadio), (int) (preLiveHeight * heightRadio));
        layoutParams.leftMargin = (int) (preLiveMarginLeft * widthRadio);
        live_rl.setLayoutParams(layoutParams);
        live_rl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showLiveButtonContainer();
            }
        });

//        live_sfv = getViewById(R.id.live_sfv);

        live_container_rl = getViewById(R.id.live_container_rl);
        btn_container_rl = getViewById(R.id.btn_container_rl);
        live_zoom_bt = getViewById(R.id.live_zoom_bt);
        live_zoom_bt.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        isLiveZoomed = true;
                        live_rl.setVisibility(View.GONE);
                        live_sfv.setVisibility(View.GONE);

                        StringBuffer liveBuff = new StringBuffer();
                        liveBuff.append(DouyouConstants.COMMAND_ZOOM_LIVE).append(",");
                        liveBuff.append(DouyouConstants.LIVE_SUCCESS);

                        Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                    }
                });
            }
        });

        live_close_bt = getViewById(R.id.live_close_bt);
        live_close_bt.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isLiving && !isPlaying) {
                    stopLive();
                } else if (!isLiving && isPlaying) {
                    stopPlayLive();
                }
            }
        });

    }

    @Override
    protected void onResume() {
        super.onResume();
        if (isLiving) {
            if (mLiveSession.startRtmpSession(streamAddress)) {
                handler.sendEmptyMessage(EVENT_RECORDER_CONNECTING);
            }
        } else if (isPlaying) {
            mVideoView.start();
        }
    }

    @Override
    protected void onPause() {
        if (isLiving) {
            if (isSessionStarted) {
                mLiveSession.stopRtmpSession();
                isSessionStarted = false;
            }
        } else if (isPlaying) {
            if (mVideoView != null) {
                mVideoView.stopPlayback();
            }
        }

        super.onPause();
    }

    @Override
    protected void onDestroy() {
        if (isSessionStarted) {
            mLiveSession.stopRtmpSession();
            isSessionStarted = false;
        }
        if (isSessionReady) {
            mLiveSession.destroyRtmpSession();
            mLiveSession = null;
            mStateListener = null;
            isSessionReady = false;
        }
        super.onDestroy();
    }

    private Camera mCamera;

    /**
     * 开启直播
     *
     * @param startX
     * @param startY
     * @param width
     * @param height
     * @param startLiveCallBack
     */
    public void startLive(final int startX, final int startY, final int width, final int height, LiveCallBack startLiveCallBack) {
        if (!isLiving || isLiveZoomed) {
            if (mVideoView != null) {
                mVideoView.setVisibility(View.GONE);
            }
            if (isLiveZoomed) { // 最小化
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        live_rl.setVisibility(View.VISIBLE);
                        live_sfv.setVisibility(View.VISIBLE);
                        isLiveZoomed = false;
                        StringBuffer liveBuff = new StringBuffer();
                        liveBuff.append(DouyouConstants.COMMAND_ZOOM_OUT_LIVE).append(",");
                        liveBuff.append(DouyouConstants.LIVE_SUCCESS);

                        Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                    }
                });
            } else {
                this.startLiveCallBack = startLiveCallBack;
                isLiving = true;
                isPlaying = false;
                String temp = DouyouConstants.GAME_DDZ + "_" + SPUtil.getCurrentUserId(this);
                streamAddress = RequestURL.STREAMING_URL_PREFIX + temp;
                playAddress = RequestURL.PLAY_URL_PREFIX + temp;

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        live_sfv = new SurfaceView(GameActivity.this);
                        live_sfv.setZOrderMediaOverlay(true);

                        RelativeLayout.LayoutParams surfaceLayoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                        int margin = (int) (preLiveWidth * widthRadio / 20);
                        surfaceLayoutParams.setMargins(margin, margin, margin, margin);
                        live_sfv.setLayoutParams(surfaceLayoutParams);
                        live_container_rl.addView(live_sfv, 0);

                        initStateListener();
                        initRTMPSession(live_sfv.getHolder());
                        live_rl.setVisibility(View.VISIBLE);
//                    live_sfv.setVisibility(View.VISIBLE);

                        if (hideLiveBtnTimer != null) {
                            hideLiveBtnTimer.cancel();
                            hideLiveBtnTimer = null;
                        }
                        hideLiveBtnTimer = new Timer();
                        hideLiveBtnTimer.schedule(new TimerTask() {
                            @Override
                            public void run() {
                                hideLiveButtonContainer();
                                hideLiveBtnTimer.cancel();
                                hideLiveBtnTimer = null;
                            }
                        }, 2000);
                    }
                });
            }
        }

    }

    /**
     * 关闭直播
     */
    public void stopLive(/*final LiveCallBack liveCallBack*/) {
        try {
            if (isLiving) {
//                if (isSessionStarted) {
//                    mLiveSession.stopRtmpSession();
//                    isSessionStarted = false;
//                }
//                if (isSessionReady) {
//                    mLiveSession.destroyRtmpSession();
//                    mLiveSession = null;
//                    mStateListener = null;
//                    isSessionReady = false;
//                }
                handler.sendEmptyMessage(EVENT_STOP_STREAMING);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (live_sfv != null) {
                            live_container_rl.removeView(live_sfv);
                            live_sfv = null;
                            btn_container_rl.clearAnimation();
                            btn_container_rl.setAlpha(0f);
                            live_rl.setVisibility(View.GONE);

                            StringBuffer liveBuff = new StringBuffer();
                            liveBuff.append(DouyouConstants.COMMAND_STOP_LIVE).append(",");
                            liveBuff.append(DouyouConstants.LIVE_SUCCESS);

                            Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                            isLiving = false;
                        }
                    }
                });
            } else {
                StringBuffer liveBuff = new StringBuffer();
                liveBuff.append(DouyouConstants.COMMAND_STOP_LIVE).append(",");
                liveBuff.append(DouyouConstants.LIVE_SUCCESS);

                Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                isLiving = false;
            }

        } catch (Exception e) {
            Log.e(TAG, e.getLocalizedMessage());
            StringBuffer liveBuff = new StringBuffer();
            liveBuff.append(DouyouConstants.COMMAND_STOP_LIVE).append(",");
            liveBuff.append(DouyouConstants.LIVE_SUCCESS).append(",");
            liveBuff.append("停止直播错误");

            Cocos2dxHelper.setStringForKey("getStartLiveData", liveBuff.toString());
        }
    }

    private void initStateListener() {
        if (mStateListener == null) {
            mStateListener = new SessionStateListener() {
                @Override
                public void onSessionPrepared(int code) {
                    if (code == SessionStateListener.RESULT_CODE_OF_OPERATION_SUCCEEDED) {
                        if (handler != null) {
                            handler.sendEmptyMessage(EVENT_SESSION_PREPARED);

                            int realWidth = mLiveSession.getAdaptedVideoWidth();
                            int realHeight = mLiveSession.getAdaptedVideoHeight();
                            if (realHeight != mVideoHeight || realWidth != mVideoWidth) {
                                mVideoHeight = realHeight;
                                mVideoWidth = realWidth;
                                handler.sendEmptyMessage(EVENT_RESIZE_CAMERA_PREVIEW);
                            }
                            mLiveSession.enableDefaultBeautyEffect(true);
                            mLiveSession.setBeautyEffectLevel(1.0f, 1.0f, 0.0f);
                            if (mLiveSession.startRtmpSession(streamAddress)) {
                                handler.sendEmptyMessage(EVENT_RECORDER_CONNECTING);
                            }
                        }
                    }
                }

                @Override
                public void onSessionStarted(int code) {
                    if (code == SessionStateListener.RESULT_CODE_OF_OPERATION_SUCCEEDED) {
                        handler.sendEmptyMessage(EVENT_RECORDER_STARTED);
//                        mLiveSession.enableDefaultBeautyEffect(true);
                        if (startLiveCallBack != null) {
                            StringBuffer liveBuff = new StringBuffer();
                            liveBuff.append(DouyouConstants.COMMAND_START_LIVE).append(",");
                            liveBuff.append(DouyouConstants.LIVE_SUCCESS).append(",");
                            liveBuff.append(playAddress).append(",");
                            liveBuff.append(decodeType);

                            Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                        }
                    } else {
                        PublicViews.ShowErrorDialog(GameActivity.this, "开启直播失败");
                        Log.e(TAG, "开启直播失败,Starting Streaming failed!");
                    }
                }

                @Override
                public void onSessionStopped(int code) {
                    if (code == SessionStateListener.RESULT_CODE_OF_OPERATION_SUCCEEDED) {
                        if (needRestartAfterStopped && isSessionReady) {
                            mLiveSession.startRtmpSession(streamAddress);
                        } else {
                            handler.sendEmptyMessage(EVENT_RECORDER_STOPPED);
                        }
                        mLiveSession.enableDefaultBeautyEffect(false);
                    } else {
                        Log.e(TAG, "Stopping Streaming failed!");
                    }
                }

                @Override
                public void onSessionError(int code) {
                    String errorMsg = null;

                    switch (code) {
                        case SessionStateListener.ERROR_CODE_OF_OPEN_MIC_FAILED:
                            errorMsg = "摄像头或MIC打开失败！请确认您已开启相关硬件使用权限！";
                            Log.e(TAG, "Error occurred while opening MIC!");
                            break;
                        case SessionStateListener.ERROR_CODE_OF_OPEN_CAMERA_FAILED:
                            errorMsg = "摄像头或MIC打开失败！请确认您已开启相关硬件使用权限！";
                            Log.e(TAG, "Error occurred while opening Camera!");
                            break;
                        case SessionStateListener.ERROR_CODE_OF_PREPARE_SESSION_FAILED:
                            errorMsg = "直播初始化异常";
                            Log.e(TAG, "Error occurred while preparing recorder!");
                            onPrepareFailed();
                            break;
                        case SessionStateListener.ERROR_CODE_OF_CONNECT_TO_SERVER_FAILED:
                            Log.e(TAG, "Error occurred while connecting to server!");
                            if (handler != null) {
                                errorMsg = "连接服务器失败，正在重试！";
                                handler.sendEmptyMessageDelayed(EVENT_RECONNECT_SERVER, 2000);
                            }
                            break;
                        case SessionStateListener.ERROR_CODE_OF_DISCONNECT_FROM_SERVER_FAILED:
                            errorMsg = "断开连接异常";
                            Log.e(TAG, "Error occurred while disconnecting from server!");
                            isConnecting = false;
                            // Although we can not stop session successfully, we still need to take it as stopped
                            if (handler != null) {
                                handler.sendEmptyMessage(EVENT_RECORDER_STOPPED);
                            }
                            break;
                        default:
                            errorMsg = onStreamingError(code);
                            break;
                    }
                    StringBuffer liveBuff = new StringBuffer();
                    liveBuff.append(DouyouConstants.COMMAND_START_LIVE).append(",");
                    liveBuff.append(DouyouConstants.LIVE_FAILED).append(",");
                    liveBuff.append(errorMsg);

                }

//                @Override
//                public void onEncodedAudioData(byte[] data, long length, long pts) {
//                    Log.i(TAG, "aaa");
//                }
//
//                @Override
//                public void onEncodedVideoData(byte[] data, long length, long pts) {
//                    Log.i(TAG, "bbb");
//                }
            };
        }

    }

    private void initRTMPSession(SurfaceHolder sh) {
        Log.d(TAG, "Calling initRTMPSession...");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            mLiveSession = new LiveSessionHW(this, mVideoWidth, mVideoHeight, mFrameRate, mBitrate, Camera.CameraInfo.CAMERA_FACING_FRONT);
            decodeType = BVideoView.DECODE_HW + "";
        } else {
            mLiveSession = new LiveSessionSW(this, mVideoWidth, mVideoHeight, mFrameRate, mBitrate, Camera.CameraInfo.CAMERA_FACING_FRONT);
            decodeType = BVideoView.DECODE_SW + "";
        }
        mLiveSession.setStateListener(mStateListener);
        mLiveSession.setAudioEnabled(true);
        mLiveSession.setVideoEnabled(true);
        mLiveSession.bindPreviewDisplay(sh);
        mLiveSession.prepareSessionAsync();
    }

    private void onPrepareFailed() {
        isSessionReady = false;
    }

    private String onStreamingError(int errno) {
        String errorMsg = null;
        switch (errno) {
            case SessionStateListener.ERROR_CODE_OF_PACKET_REFUSED_BY_SERVER:
            case SessionStateListener.ERROR_CODE_OF_SERVER_INTERNAL_ERROR:
                errorMsg = "因服务器异常，当前直播已经中断！正在尝试重新推流...";
                if (handler != null) {
                    handler.sendEmptyMessage(EVENT_RESTART_STREAMING);
                }
                break;
            case SessionStateListener.ERROR_CODE_OF_WEAK_CONNECTION:
                Log.i(TAG, "Weak connection...");
                errorMsg = "当前网络不稳定，请检查网络信号！";
                mWeakConnectionHintCount++;
                if (handler != null) {
                    if (mWeakConnectionHintCount >= 5) {
                        mWeakConnectionHintCount = 0;
                        handler.sendEmptyMessage(EVENT_RESTART_STREAMING);
                    }
                }
                break;
            case SessionStateListener.ERROR_CODE_OF_CONNECTION_TIMEOUT:
                Log.i(TAG, "Timeout when streaming...");
                errorMsg = "连接超时，请检查当前网络是否畅通！我们正在努力重连...";
                if (handler != null) {
                    handler.sendEmptyMessage(EVENT_RESTART_STREAMING);
                }
                break;
            default:
                Log.i(TAG, "Unknown error when streaming...");
                errorMsg = "未知错误，当前直播已经中断！正在重试！";
                if (handler != null) {
                    handler.sendEmptyMessageDelayed(EVENT_RESTART_STREAMING, 1000);
                }
                break;
        }
        return errorMsg;
    }

    private void fitPreviewToParentByResolution(SurfaceHolder holder, int width, int height) {
        // Adjust the size of SurfaceView dynamically
        int screenHeight = getWindow().getDecorView().getRootView().getHeight();
        int screenWidth = getWindow().getDecorView().getRootView().getWidth();

        if (getResources().getConfiguration().orientation
                == Configuration.ORIENTATION_PORTRAIT) { // If portrait, we should swap width and height
            width = width ^ height;
            height = width ^ height;
            width = width ^ height;
        }

        int adjustedVideoHeight = screenHeight;
        int adjustedVideoWidth = screenWidth;
        if (width * screenHeight > height * screenWidth) { // means width/height > screenWidth/screenHeight
            // Fit width
            adjustedVideoHeight = height * screenWidth / width;
            adjustedVideoWidth = screenWidth;
        } else {
            // Fit height
            adjustedVideoHeight = screenHeight;
            adjustedVideoWidth = width * screenHeight / height;
        }
        holder.setFixedSize(adjustedVideoWidth, adjustedVideoHeight);
    }

    /**
     * 播放直播
     *
     * @param startX
     * @param startY
     * @param width
     * @param height
     * @param playAddress
     */
    public void playLive(final int startX, final int startY, final int width, final int height, final String playAddress, final String decodeType, final LiveCallBack liveCallBack) {

        if (!isPlaying && !isLiving) {
            if (live_sfv != null) {
                live_sfv.setVisibility(View.GONE);
            }
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mVideoView != null) {
                            live_container_rl.removeView(mVideoView);
                            mVideoView = null;
                        }
                        live_zoom_bt.setVisibility(View.GONE);
                        BVideoView.setAK(RequestURL.BAIDU_AK);

                        double widthRadio = (double) MyApplication.getInstance().getScreenWidth() / baseLiveWidth;
                        double heightRadio = (double) MyApplication.getInstance().getScreenHeight() / baseLiveHeight;
                        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams((int) (preLiveWidth * widthRadio), (int) (preLiveHeight * heightRadio));
                        layoutParams.leftMargin = (int) (preLiveMarginLeft * widthRadio);
                        live_rl.setLayoutParams(layoutParams);
                        mVideoView = new BVideoView(GameActivity.this);
                        int margin = (int) (preLiveWidth * widthRadio / 20);
                        RelativeLayout.LayoutParams surfaceLayoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                        surfaceLayoutParams.setMargins(margin, margin, margin, margin);
                        mVideoView.setLayoutParams(surfaceLayoutParams);
                        live_container_rl.addView(mVideoView, 0);

                        live_rl.setVisibility(View.VISIBLE);

                        mVideoView.setOnPreparedListener(new BVideoView.OnPreparedListener() {
                            @Override
                            public void onPrepared() {

                            }
                        });
                        mVideoView.setOnCompletionListener(new BVideoView.OnCompletionListener() {
                            @Override
                            public void onCompletion() {

                            }
                        });
                        mVideoView.setOnErrorListener(new BVideoView.OnErrorListener() {
                            @Override
                            public boolean onError(int i, int i1) {
                                return false;
                            }
                        });
                        mVideoView.setOnInfoListener(new BVideoView.OnInfoListener() {
                            @Override
                            public boolean onInfo(int i, int i1) {
                                return false;
                            }
                        });

                        /**
                         * 设置解码模式
                         */
//                        int decodeMode = BVideoView.DECODE_HW;
//                        if (!TextUtils.isEmpty(decodeType)) {
//                            decodeMode = Integer.parseInt(decodeType);
//                        }
                        mVideoView.setDecodeMode(BVideoView.DECODE_SW);
                        mVideoView.setVideoPath(playAddress);
                        /**
                         * 显示或者隐藏缓冲提示
                         */
                        mVideoView.showCacheInfo(true);

                        /**
                         * 开始播放
                         */
                        mVideoView.start();
                        isPlaying = true;
                        isLiving = false;


                        StringBuffer liveBuff = new StringBuffer();
                        liveBuff.append(DouyouConstants.COMMAND_PLAY_LIVE).append(",");
                        liveBuff.append(DouyouConstants.LIVE_SUCCESS);
                        Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());

                    } catch (Exception e) {
                        Log.e(TAG, e.getLocalizedMessage());
                        StringBuffer liveBuff = new StringBuffer();
                        liveBuff.append(DouyouConstants.COMMAND_PLAY_LIVE).append(",");
                        liveBuff.append(DouyouConstants.LIVE_FAILED).append(",");
                        liveBuff.append("播放视频错误");
                        Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                    }
                }
            });
        }


    }

    /**
     * 停止观看直播
     */
    public void stopPlayLive() {
        try {
            if (isPlaying) {
                mVideoView.stopPlayback();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mVideoView != null) {
                            mVideoView.setVisibility(View.GONE);
                            btn_container_rl.clearAnimation();
                            btn_container_rl.setAlpha(0f);
                            live_rl.setVisibility(View.GONE);
                            StringBuffer liveBuff = new StringBuffer();
                            liveBuff.append(DouyouConstants.COMMAND_STOP_PLAY_LIVE).append(",");
                            liveBuff.append(DouyouConstants.LIVE_SUCCESS);
                            Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                            isPlaying = false;
                        }
                    }
                });
            } else {
                StringBuffer liveBuff = new StringBuffer();
                liveBuff.append(DouyouConstants.COMMAND_STOP_PLAY_LIVE).append(",");
                liveBuff.append(DouyouConstants.LIVE_SUCCESS);
                Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
                isPlaying = false;
            }

        } catch (Exception e) {
            Log.e(TAG, e.getLocalizedMessage());
            StringBuffer liveBuff = new StringBuffer();
            liveBuff.append(DouyouConstants.COMMAND_PLAY_LIVE).append(",");
            liveBuff.append(DouyouConstants.LIVE_FAILED).append(",");
            liveBuff.append("停止播放视频错误");
            Cocos2dxHelper.setStringForKey("getLiveData", liveBuff.toString());
        }
    }

    /**
     * 显示直播按钮
     */
    private void showLiveButtonContainer() {
        if (isLiveBtnShowed) {
            isLiveBtnHideInterrupt = true;
            btn_container_rl.clearAnimation();
            btn_container_rl.setAlpha(1);
            if (hideLiveBtnTimer != null) {
                hideLiveBtnTimer.cancel();
                hideLiveBtnTimer = null;
            }
            hideLiveBtnTimer = new Timer();
            hideLiveBtnTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    hideLiveButtonContainer();
                    hideLiveBtnTimer.cancel();
                    hideLiveBtnTimer = null;
                }
            }, 2000);
        } else {
            AnimationSet animationSet = new AnimationSet(true);
            AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
            alphaAnimation.setDuration(500);
            alphaAnimation.setFillAfter(true);
            animationSet.addAnimation(alphaAnimation);
            btn_container_rl.startAnimation(animationSet);
            btn_container_rl.postDelayed(new Runnable() {
                public void run() {
                    btn_container_rl.setVisibility(View.VISIBLE);
                    if (hideLiveBtnTimer != null) {
                        hideLiveBtnTimer.cancel();
                        hideLiveBtnTimer = null;
                    }
                    hideLiveBtnTimer = new Timer();
                    hideLiveBtnTimer.schedule(new TimerTask() {
                        @Override
                        public void run() {
                            hideLiveButtonContainer();
                            hideLiveBtnTimer.cancel();
                            hideLiveBtnTimer = null;
                        }
                    }, 2000);
                }
            }, 500);
        }
        isLiveBtnShowed = true;

    }

    /**
     * 隐藏直播按钮
     */
    private void hideLiveButtonContainer() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AnimationSet animationSet = new AnimationSet(true);
                AlphaAnimation alphaAnimation = new AlphaAnimation(1, 0);
                alphaAnimation.setDuration(1000);
                alphaAnimation.setFillAfter(true);
                animationSet.addAnimation(alphaAnimation);
                btn_container_rl.startAnimation(animationSet);
                btn_container_rl.postDelayed(new Runnable() {
                    public void run() {
                        if (!isLiveBtnHideInterrupt) {
                            btn_container_rl.setVisibility(View.GONE);
                            isLiveBtnShowed = false;
                        } else {
                            isLiveBtnHideInterrupt = false;
                        }

                    }
                }, 1000);
            }
        });
    }

    private static final int REQUEST_CODE_PAYMENT = 100;

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        // ping++
        //支付页面返回处理
        if (requestCode == REQUEST_CODE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                String result = data.getExtras().getString("pay_result");
                if ("success".equals(result)) {

                    String rechargeamount = SPUtil.getString(this,"rechargeamount");
                    if(rechargeamount != null){

//                        // 更新用户宝贝币数
//                        DouyouUser user = SPUtil.getCurrentUser(this);
//                        user.setCoinAmount(user.getCoinAmount() + Integer.parseInt(SPUtil.getString(this,"rechargeamount")));
//                        SPUtil.updateCurrentUser(this,user);
//
//                        MyApplication.userCoinAmount = SPUtil.getCurrentUser(this).getCoinAmount();
//
//                        // 通知游戏充值成功
//                        LuaJavaBridgeTest.rechargeSuccess();

                        // 充值成功，获取当前用户最新的金币数

//                        GetCoinAmount();

                        LuaJavaBridgeTest.rechargeSuccess();
                    }else{
                        LuaJavaBridgeTest.rechargeFail();
                    }

                } else if ("cancel".equals(result)) {
                    ToastUtil.showBaseToast(GameActivity.this,"充值取消");
                    LuaJavaBridgeTest.rechargeFail();
                } else {
                    ToastUtil.showBaseToast(GameActivity.this,"充值失败");
                    LuaJavaBridgeTest.rechargeFail();
                }

                // 记录充值金额
                SPUtil.setString(GameActivity.this,"rechargeamount","0");

            }
        }

        // 企鹅
        if (requestCode == DouyouConstants.QQ_LOGIN_REQUEST_CODE) {
            Tencent.onActivityResultData(requestCode,resultCode,data,PublicViews.loginListener);
        }

        // 渣浪
        // SSO 授权回调
        // 重要：发起 SSO 登陆的 Activity 必须重写 onActivityResults
        if (PublicViews.mSsoHandler != null) {
            PublicViews.mSsoHandler.authorizeCallBack(requestCode, resultCode, data);
            return;
        }

    }

    // 更新用户金币数量
    private void GetCoinAmount(){

        PublicViews.ShowLoading(GameActivity.this);

        // 本地记录已经登录，则获取本地数据并进行自动登录
        final String username = SPUtil.getString(MyApplication.gameActivity,SPUtil.SP_USERNAME);
        final String password = SPUtil.getString(MyApplication.gameActivity,SPUtil.SP_PASSWORD);

//        MyApplication.gameActivity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//
//                final Login login = new Login(MyApplication.gameActivity);
//                login.loginDouyou(username, password, true, new FinalHttpClient.OnRequestListener() {
//                    @Override
//                    public void onFinish(JsonResponse response) {
//
//                        PublicViews.HideLoading();
//
//                        if (response.isSuccess()) {
//
//                            DouyouUser user = response.readObject(DouyouUser.class);
//                            if (user == null) {
//                                GetCoinAmount();
//                                return;
//                            }
//
//                            try {
//
//                                // 更新用户金币数
//                                login.handleLogin(username, password, user, false,MyApplication.gameActivity);
//
//                                // 通知充值成功
//                                LuaJavaBridgeTest.rechargeSuccess();
//
//                            } catch (Exception e) {
//                                GetCoinAmount();
//                            }
//
//                        } else {
//                            GetCoinAmount();
//                        }
//                    }
//                });
//            }
//        });

    }

    public interface LiveCallBack {
        void onSuccess(String response);

        void onError(String response);
    }
}
