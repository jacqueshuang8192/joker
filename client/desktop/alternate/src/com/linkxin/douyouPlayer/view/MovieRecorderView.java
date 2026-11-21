package com.linkxin.douyouPlayer.view;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.hardware.Camera;
import android.hardware.Camera.Parameters;
import android.media.MediaRecorder;
import android.media.MediaRecorder.AudioEncoder;
import android.media.MediaRecorder.AudioSource;
import android.media.MediaRecorder.OnErrorListener;
import android.media.MediaRecorder.OutputFormat;
import android.media.MediaRecorder.VideoEncoder;
import android.media.MediaRecorder.VideoSource;
import android.os.Build;
import android.os.Environment;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.util.SPUtil;

import java.io.File;
import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

/**
 * 视频录制控件
 * 
 * @author lip
 * 
 * @date 2015-3-16
 */
public class MovieRecorderView extends LinearLayout implements OnErrorListener {
 
    public SurfaceView mSurfaceView;
    private SurfaceHolder mSurfaceHolder;
    private SeekBar mProgressBar;
    private TextView timer_tv;
 
    private MediaRecorder mMediaRecorder;
    private Camera mCamera;
    private Timer mTimer;// 计时器
    private OnRecordFinishListener mOnRecordFinishListener;// 录制完成回调接口
 
    private int mWidth;// 视频分辨率宽度
    private int mHeight;// 视频分辨率高度
    private boolean isOpenCamera;// 是否一开始就打开摄像头
    private int mRecordMaxTime;// 一次拍摄最长时间
    private int mTimeCount;// 时间计数
    private File mVecordFile = null;// 文件
 
    public MovieRecorderView(Context context) {
        this(context, null);
    }
 
    public MovieRecorderView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }
 
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public MovieRecorderView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        mWidth = 320;
        mHeight = 240;
        isOpenCamera = false;
        mRecordMaxTime = 10;
 
        LayoutInflater.from(context).inflate(R.layout.moive_recorder_view, this);
        mSurfaceView = (SurfaceView) findViewById(R.id.surfaceview);
        mSurfaceView.setZOrderMediaOverlay(true);

        mProgressBar = (SeekBar) findViewById(R.id.progressBar);
        mProgressBar.setMax(mRecordMaxTime);// 设置进度条最大量
        mProgressBar.setEnabled(false);
 
        mSurfaceHolder = mSurfaceView.getHolder();
        mSurfaceHolder.addCallback(new CustomCallBack());
        mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        timer_tv = (TextView) findViewById(R.id.timer_tv);
    }
 
    /**
     * 
     * @author liuyinjun
     * 
     * @date 2015-2-5
     */
    private class CustomCallBack implements Callback {
 
        @Override
        public void surfaceCreated(SurfaceHolder holder) {
            if (!isOpenCamera)
                return;
            try {
                initCamera();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
 
        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
 
        }
 
        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
            if (!isOpenCamera)
                return;
            freeCameraResource();
        }
 
    }
 
    /**
     * 初始化摄像头
     * 
     * @author lip
     * @date 2015-3-16
     * @throws IOException
     */
    private void initCamera() throws IOException {

        if (mCamera != null) {
            freeCameraResource();
        }

        try {
//            mCamera = Camera.open();

            // 得到摄像头的个数
            int cameraCount = 0;
            Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
            cameraCount = Camera.getNumberOfCameras();
            for(int i = 0; i < cameraCount; i++) {
                Camera.getCameraInfo(i, cameraInfo);//得到每一个摄像头的信息
                if(cameraInfo.facing  == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                    // 代表摄像头的方位，CAMERA_FACING_FRONT前置，CAMERA_FACING_BACK后置
                    // 打开当前选中的摄像头
                    mCamera = Camera.open(i);
                    break;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            freeCameraResource();
        }

        if (mCamera == null)
            return;

        mSurfaceHolder.setFormat(PixelFormat.OPAQUE);

        setCameraParams();
        mCamera.setDisplayOrientation(0);
        mCamera.setPreviewDisplay(mSurfaceHolder);
        mCamera.startPreview();
        mCamera.unlock();
    }
 
    /**
     * 设置摄像头为竖屏
     * 
     * @author lip
     * @date 2015-3-16
     */
    private void setCameraParams() {
        if (mCamera != null) {
            Parameters params = mCamera.getParameters();
            params.set("orientation", "portrait");
            mCamera.setParameters(params);
        }
    }
 
    /**
     * 释放摄像头资源
     * 
     * @author liuyinjun
     * @date 2015-2-5
     */
    public void freeCameraResource() {
        if (mCamera != null) {
            mCamera.setPreviewCallback(null);
            mCamera.stopPreview();
            mCamera.lock();
            mCamera.release();
            mCamera = null;
        }
    }
 
    private void createRecordDir() {
       // File sampleDir = new File(Environment.getExternalStorageDirectory() + File.separator + "im/video/");
        File sampleDir = new File(Environment.getExternalStorageDirectory() + File.separator + "168MJ/RecordVideo/");
        //File sampleDir = new File("/video/");
        if (!sampleDir.exists()) {
            sampleDir.mkdirs();
        }
        File vecordDir = sampleDir;
        // 创建文件
        try {
            mVecordFile = File.createTempFile("recording", ".mp4", vecordDir);//mp4格式
            //LogUtils.i(mVecordFile.getAbsolutePath());
            Log.d("Path:",mVecordFile.getAbsolutePath());
            SPUtil.setString(MyApplication.gameActivity, "RecordPath", mVecordFile.getAbsolutePath());
        } catch (IOException e) {

        }
    }
 
    /**
     * 初始化
     * 
     * @author lip
     * @date 2015-3-16
     * @throws IOException
     */
    private void initRecord() throws IOException {
        mMediaRecorder = new MediaRecorder();
        mMediaRecorder.reset();
        if (mCamera != null)
            mMediaRecorder.setCamera(mCamera);
        mMediaRecorder.setOnErrorListener(this);
        mMediaRecorder.setPreviewDisplay(mSurfaceHolder.getSurface());
        mMediaRecorder.setVideoSource(VideoSource.CAMERA);// 视频源
        mMediaRecorder.setAudioSource(AudioSource.MIC);// 音频源

//        mMediaRecorder.setOutputFormat(OutputFormat.MPEG_4);// 视频输出格式
//        mMediaRecorder.setAudioEncoder(AudioEncoder.AMR_NB);// 音频格式

        mMediaRecorder.setOutputFormat(OutputFormat.MPEG_4);// 视频输出格式
        mMediaRecorder.setAudioEncoder(AudioEncoder.AAC);// 音频格式

        mMediaRecorder.setVideoSize(mWidth, mHeight);// 设置分辨率：
        // mMediaRecorder.setVideoFrameRate(16);// 这个我把它去掉了，感觉没什么用
        mMediaRecorder.setVideoEncodingBitRate(1 * 1024 * 512);// 设置帧频率，然后就清晰了
        mMediaRecorder.setOrientationHint(0);// 输出旋转180度，保持竖屏录制
        mMediaRecorder.setVideoEncoder(VideoEncoder.MPEG_4_SP);// 视频录制格式
        // mediaRecorder.setMaxDuration(Constant.MAXVEDIOTIME * 1000);
        mMediaRecorder.setOutputFile(mVecordFile.getAbsolutePath());
        mMediaRecorder.prepare();
        try {
            mMediaRecorder.start();
        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (RuntimeException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
 
    /**
     * 开始录制视频
     * 
     * @author liuyinjun
     * @date 2015-2-5
//     * @param fileName
//     *            视频储存位置
     * @param onRecordFinishListener
     *            达到指定时间之后回调接口
     */
    public void record(final OnRecordFinishListener onRecordFinishListener) {

        // 设置录制完成回调事件
        this.mOnRecordFinishListener = onRecordFinishListener;

        // 创建视频文件
        createRecordDir();

        try {
//            if (!isOpenCamera)// 如果未打开摄像头，则打开
//                initCamera();

            // 初始化摄像头
            initCamera();

            initRecord();
            mTimeCount = 0;// 时间计数器重新赋值

            timer_tv.setText("00:00");

            mTimer = new Timer();
            mTimer.schedule(new TimerTask() {
 
                @Override
                public void run() {
                    // TODO Auto-generated method stub

                    mTimeCount++;

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {

                            if (mTimeCount < 10){
                                timer_tv.setText("00:0" + mTimeCount);
                            }else{
                                timer_tv.setText("00:" + mTimeCount);
                            }

                        }
                    });

                    // 设置进度条
                    mProgressBar.setProgress(mTimeCount);

                    // 达到指定时间，停止拍摄
                    if (mTimeCount == mRecordMaxTime) {

                        stop();

                        if (mOnRecordFinishListener != null)
                            mOnRecordFinishListener.onRecordFinish();

                    }
                }

            }, 0, 1000);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 中断录制并上传
     */
    public void cutDownAndUpLoad(){

        // 停止计时任务
        mTimer.cancel();

        // 停止录制
        stop();

        // 调用上传方法
        if (mOnRecordFinishListener != null)
            mOnRecordFinishListener.onRecordFinish();

    }

    /**
     * 外部调用停止录制
     */
    public void closeRecord(){

        // 停止计时任务
        mTimer.cancel();

        // 停止录制
        stop();

    }
 
    /**
     * 停止拍摄
     * 
     * @author liuyinjun
     * @date 2015-2-5
     */
    public void stop() {

        // 设置时间显示为0秒
        MyApplication.gameActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                timer_tv.setText("00:00");
            }
        });

        // 停止录制
        stopRecord();
        // 释放录制
        releaseRecord();
        // 释放摄像头资源
        freeCameraResource();

        // 清空surfaceview的显示痕迹
        mSurfaceHolder.setFormat(PixelFormat.TRANSLUCENT);
        Canvas canvas = mSurfaceHolder.lockCanvas();
        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
        mSurfaceHolder.unlockCanvasAndPost(canvas);

    }
 
    /**
     * 停止录制
     * 
     * @author liuyinjun
     * @date 2015-2-5
     */
    public void stopRecord() {
        mProgressBar.setProgress(0);
        if (mTimer != null)
            mTimer.cancel();
        if (mMediaRecorder != null) {
            // 设置后不会崩
            mMediaRecorder.setOnErrorListener(null);
            mMediaRecorder.setPreviewDisplay(null);
            try {
                mMediaRecorder.stop();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            } catch (RuntimeException e) {
                e.printStackTrace();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
 
    /**
     * 释放资源
     * 
     * @author liuyinjun
     * @date 2015-2-5
     */
    private void releaseRecord() {
        if (mMediaRecorder != null) {
            mMediaRecorder.setOnErrorListener(null);
            try {
                mMediaRecorder.release();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        mMediaRecorder = null;
    }
 
    public int getTimeCount() {
        return mTimeCount;
    }
 
    /**
     * @return the mVecordFile
     */
    public File getmVecordFile() {
        return mVecordFile;
    }
 
    /**
     * 录制完成回调接口
     *
     * @author lip
     * 
     * @date 2015-3-16
     */
    public interface OnRecordFinishListener {
        public void onRecordFinish();
    }
 
    @Override
    public void onError(MediaRecorder mr, int what, int extra) {
        try {
            if (mr != null)
                mr.reset();
        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}