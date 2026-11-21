package com.linkxin.douyouPlayer.view;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.hardware.Camera;
import android.hardware.Camera.Parameters;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.media.MediaRecorder.AudioEncoder;
import android.media.MediaRecorder.AudioSource;
import android.media.MediaRecorder.OnErrorListener;
import android.media.MediaRecorder.OutputFormat;
import android.media.MediaRecorder.VideoEncoder;
import android.media.MediaRecorder.VideoSource;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.util.SPUtil;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Timer;
import java.util.TimerTask;

/**
 * 音频录制控件
 * 
 * @author lip
 * 
 * @date 2015-3-16
 */
public class VoiceRecorderView extends LinearLayout {

    private static final String TAG = "-----录音控件-----";

    public ImageView volume_iv;

    private boolean isRecording;
    private int channelConfiguration = AudioFormat.CHANNEL_IN_MONO;
    private int audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
    private int sampleRate = 11025;
    private int bufferSizeInBytes;

    private File mVecordFile = null;// 文件
    private Context context;

    private Thread thread;
    private int isUpload;

    private OnRecordFinishListener mOnRecordFinishListener;// 录制完成回调接口

    public VoiceRecorderView(Context context) {
        this(context, null);
    }

    public VoiceRecorderView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public VoiceRecorderView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        this.context = context;

        LayoutInflater.from(context).inflate(R.layout.voice_recorder_view, this);

        volume_iv = (ImageView) findViewById(R.id.volume_iv);

        bufferSizeInBytes = AudioRecord.getMinBufferSize(sampleRate,
                channelConfiguration, audioEncoding); // need to be larger than size of a frame

        Log.i(TAG, "bufferSizeInBytes=" + bufferSizeInBytes);

        isRecording = false;

    }

    /**
     * 开始录制音频
     * @param onRecordFinishListener 达到指定时间之后回调接口
     */
    public void record(final OnRecordFinishListener onRecordFinishListener) {

        Log.d(TAG, "开始录制");

        isUpload = 0;

        // 设置录制完成回调事件
        this.mOnRecordFinishListener = onRecordFinishListener;

        // 创建录音线程
        thread = new Thread(new Runnable() {
            @Override
            public void run() {

                Log.d(TAG, "创建录制线程");

                // 创建录制文件
                createRecordFile();

                OutputStream out = null;
                ByteArrayOutputStream baos = null;

                try {

                    // 实例化录制
                    AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC,
                            sampleRate, channelConfiguration, audioEncoding,
                            bufferSizeInBytes); //麦克风

                    audioRecord.startRecording();
                    isRecording = true;

                    baos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[bufferSizeInBytes];
                    int bufferReadResult = 0;

                    while (isRecording) {

                        bufferReadResult = audioRecord.read(buffer, 0, bufferSizeInBytes);
                        if(bufferReadResult > 0){
                            Log.d(TAG, "写入录音大小：" + bufferReadResult);
                            baos.write(buffer, 0, bufferReadResult);
                        }

                        // 音量检测
                        long v = 0;

                        // 将 buffer 内容取出，进行平方和运算
                        for (int i = 0; i < buffer.length; i++) {
                            v += buffer[i] * buffer[i];
                        }

                        // 平方和除以数据总长度，得到音量大小。
                        double mean = v / (double) bufferReadResult;
                        final double volume = 10 * Math.log10(mean) - 30;;
                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (volume >= 0 && volume < 2){
                                    volume_iv.setBackgroundResource(R.drawable.sound1);
                                }else if (volume >= 2 && volume < 4){
                                    volume_iv.setBackgroundResource(R.drawable.sound2);
                                }else if (volume >= 4 && volume < 6){
                                    volume_iv.setBackgroundResource(R.drawable.sound3);
                                }else if (volume >= 6 && volume < 8){
                                    volume_iv.setBackgroundResource(R.drawable.sound4);
                                }else if (volume >= 8 && volume <= 10){
                                    volume_iv.setBackgroundResource(R.drawable.sound5);
                                }
                            }
                        });

                    }

                    Log.i(TAG, "stop recording,file=" + mVecordFile.getAbsolutePath());

                    if (audioRecord != null){
                        // 停止录音
                        audioRecord.stop();

                        // 释放录音
                        audioRecord.release();

                        audioRecord = null;
                    }

//                    buffer = baos.toByteArray();
//                    Log.i(TAG, "audio byte len=" + buffer.length);
//                    out = new FileOutputStream(mVecordFile);
//                    out.write(getWavHeader(buffer.length));
//                    out.write(buffer);
//
//                    if (isUpload == 1){
//                        // 调用上传方法
//                        MyApplication.gameActivity.runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                if (mOnRecordFinishListener != null)
//                                    mOnRecordFinishListener.onRecordFinish();
//                            }
//                        });
//                    }

//                } catch (FileNotFoundException e) {
//                    e.printStackTrace();
//                } catch (IOException e) {
//                    e.printStackTrace();
                } finally {

                    if (out != null) {
                        try {
                            out.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }

                    if(baos!=null){
                        try {
                            baos.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }

                    thread.interrupt();

                }

            }
        });

        // 启动录音线程
        thread.start();

    }

    /**
     * 中断录制并上传
     */
    public void cutDownAndUpLoad(){

        // 设置需要上传
        isUpload = 1;

        // 停止录制
        stop();

    }

    /**
     * 停止录制
     * @author liuyinjun
     * @date 2015-2-5
     */
    public void stop() {

        // 停止录制
        try {
            isRecording = false;
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 重置界面
        MyApplication.gameActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                volume_iv.setBackgroundResource(R.drawable.sound0);
            }
        });

    }

    /**
     * 录制完成回调接口
     */
    public interface OnRecordFinishListener {
        public void onRecordFinish();
    }

    /**
     * 创建录音文件路径
     */
    private void createRecordFile() {

        // 创建目录
        File sampleDir = new File(Environment.getExternalStorageDirectory() + File.separator + "168MJ/RecordVoice/");
        if (!sampleDir.exists()) {
            sampleDir.mkdirs();
        }

        // 创建文件
        File vecordDir = sampleDir;
        try {
            mVecordFile = File.createTempFile("recording", ".wav", vecordDir);// wav格式
            Log.d(TAG, mVecordFile.getAbsolutePath());
            SPUtil.setString(MyApplication.gameActivity, "RecordVoicePath", mVecordFile.getAbsolutePath());
        } catch (IOException e) {
            MyApplication.gameActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(context, "创建录音文件失败", Toast.LENGTH_SHORT).show();
                }
            });
            return;
        }
    }

    /**
     * 转换文件格式
     * @param totalAudioLen
     * @return
     */
    public byte[] getWavHeader(long totalAudioLen){
        int mChannels = 1;
        long totalDataLen = totalAudioLen + 36;
        long longSampleRate = sampleRate;
        long byteRate = sampleRate * 2 * mChannels;

        byte[] header = new byte[44];
        header[0] = 'R';  // RIFF/WAVE header
        header[1] = 'I';
        header[2] = 'F';
        header[3] = 'F';
        header[4] = (byte) (totalDataLen & 0xff);
        header[5] = (byte) ((totalDataLen >> 8) & 0xff);
        header[6] = (byte) ((totalDataLen >> 16) & 0xff);
        header[7] = (byte) ((totalDataLen >> 24) & 0xff);
        header[8] = 'W';
        header[9] = 'A';
        header[10] = 'V';
        header[11] = 'E';
        header[12] = 'f';  // 'fmt ' chunk
        header[13] = 'm';
        header[14] = 't';
        header[15] = ' ';
        header[16] = 16;  // 4 bytes: size of 'fmt ' chunk
        header[17] = 0;
        header[18] = 0;
        header[19] = 0;
        header[20] = 1;  // format = 1
        header[21] = 0;
        header[22] = (byte) mChannels;
        header[23] = 0;
        header[24] = (byte) (longSampleRate & 0xff);
        header[25] = (byte) ((longSampleRate >> 8) & 0xff);
        header[26] = (byte) ((longSampleRate >> 16) & 0xff);
        header[27] = (byte) ((longSampleRate >> 24) & 0xff);
        header[28] = (byte) (byteRate & 0xff);
        header[29] = (byte) ((byteRate >> 8) & 0xff);
        header[30] = (byte) ((byteRate >> 16) & 0xff);
        header[31] = (byte) ((byteRate >> 24) & 0xff);
        header[32] = (byte) (2 * mChannels);  // block align
        header[33] = 0;
        header[34] = 16;  // bits per sample
        header[35] = 0;
        header[36] = 'd';
        header[37] = 'a';
        header[38] = 't';
        header[39] = 'a';
        header[40] = (byte) (totalAudioLen & 0xff);
        header[41] = (byte) ((totalAudioLen >> 8) & 0xff);
        header[42] = (byte) ((totalAudioLen >> 16) & 0xff);
        header[43] = (byte) ((totalAudioLen >> 24) & 0xff);

        return header;
    }

}