package com.linkxin.douyouPlayer.view;

import android.annotation.TargetApi;
import android.content.Context;
import android.media.MediaRecorder;
import android.media.MediaRecorder.AudioEncoder;
import android.media.MediaRecorder.AudioSource;
import android.media.MediaRecorder.OnErrorListener;
import android.media.MediaRecorder.OutputFormat;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.util.SPUtil;

import java.io.File;
import java.io.IOException;

/**
 * 音频录制控件
 * 
 * @author lip
 * 
 * @date 2015-3-16
 */
public class VoiceRecorderView_old extends LinearLayout implements OnErrorListener {

    private ImageView volume_iv;

    private MediaRecorder mMediaRecorder;
    private OnRecordFinishListener mOnRecordFinishListener;// 录制完成回调接口

    private File mVecordFile = null;// 文件

    private int BASE = 1;
    private int SPACE = 100;// 间隔取样时间

    public VoiceRecorderView_old(Context context) {
        this(context, null);
    }

    public VoiceRecorderView_old(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public VoiceRecorderView_old(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
 
        LayoutInflater.from(context).inflate(R.layout.voice_recorder_view, this);

        volume_iv = (ImageView) findViewById(R.id.volume_iv);

    }

    private final Handler mHandler = new Handler();
    private Runnable mUpdateMicStatusTimer = new Runnable() {
        public void run() {
            updateMicStatus();
        }
    };

    private void updateMicStatus() {
        if (mMediaRecorder != null) {
            double ratio = (double)mMediaRecorder.getMaxAmplitude() / BASE;
            double db = 0;// 分贝
            if (ratio > 1)
                db = 20 * Math.log10(ratio);
            mHandler.postDelayed(mUpdateMicStatusTimer, SPACE);

            final double finalDb = db;
            MyApplication.gameActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (finalDb >= 0 && finalDb < 20){
                        volume_iv.setBackgroundResource(R.drawable.sound1);
                    }else if (finalDb >= 20 && finalDb < 40){
                        volume_iv.setBackgroundResource(R.drawable.sound2);
                    }else if (finalDb >= 40 && finalDb < 60){
                        volume_iv.setBackgroundResource(R.drawable.sound3);
                    }else if (finalDb >= 60 && finalDb < 80){
                        volume_iv.setBackgroundResource(R.drawable.sound4);
                    }else if (finalDb >= 80 && finalDb <= 100){
                        volume_iv.setBackgroundResource(R.drawable.sound5);
                    }
                }
            });

        }
    }

    /**
     * 创建文件保存路径
     */
    private void createRecordDir() {

        // 创建或获取目录路径
        File sampleDir = new File(Environment.getExternalStorageDirectory() + File.separator + "168MJ/RecordVoice/");
        if (!sampleDir.exists()) {
            sampleDir.mkdirs();
        }

        // 创建文件
        File vecordDir = sampleDir;
        try {
            mVecordFile = File.createTempFile("recordVoiceing", ".aac", vecordDir);//mp3格式
            Log.d("Path:",mVecordFile.getAbsolutePath());
            SPUtil.setString(MyApplication.gameActivity, "RecordVoicePath", mVecordFile.getAbsolutePath());
        } catch (IOException e) {

        }
    }
 
    /**
     * 初始化音频录制并开始录制
     * 
     * @author lip
     * @date 2015-3-16
     * @throws IOException
     */
    private void initRecord() throws IOException {

        mMediaRecorder = new MediaRecorder();
        mMediaRecorder.reset();
        mMediaRecorder.setOnErrorListener(this);
        mMediaRecorder.setAudioSource(AudioSource.MIC);// 音频源
        mMediaRecorder.setOutputFormat(OutputFormat.AAC_ADTS);
        mMediaRecorder.setAudioEncoder(AudioEncoder.AAC);// 音频格式
        mMediaRecorder.setOutputFile(mVecordFile.getAbsolutePath());
        mMediaRecorder.prepare();

        try {

            mMediaRecorder.start();

            mHandler.postDelayed(mUpdateMicStatusTimer, 0);

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
     * @param onRecordFinishListener 达到指定时间之后回调接口
     */
    public void record(final OnRecordFinishListener onRecordFinishListener) {

        // 设置录制完成回调事件
        this.mOnRecordFinishListener = onRecordFinishListener;

        // 创建视频文件
        createRecordDir();

        try {
            initRecord();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 中断录制并上传
     */
    public void cutDownAndUpLoad(){

        // 停止录制
        stop();

        // 调用上传方法
        if (mOnRecordFinishListener != null)
            mOnRecordFinishListener.onRecordFinish();

    }
 
    /**
     * 停止拍摄
     * 
     * @author liuyinjun
     * @date 2015-2-5
     */
    public void stop() {

        // 停止录制
        stopRecord();

        // 释放录制
        releaseRecord();

        // 重置界面
        MyApplication.gameActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                volume_iv.setBackgroundResource(R.drawable.sound0);
            }
        });

    }
 
    /**
     * 停止录制
     * 
     * @author liuyinjun
     * @date 2015-2-5
     */
    public void stopRecord() {
        if (mMediaRecorder != null) {
            // 设置后不会崩
            mMediaRecorder.setOnErrorListener(null);
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