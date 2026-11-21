package com.linkxin.douyouPlayer.util;

import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.alibaba.sdk.android.oss.ClientConfiguration;
import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.common.OSSLog;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSPlainTextAKSKCredentialProvider;
import com.alibaba.sdk.android.oss.internal.OSSAsyncTask;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.cocos2dx.sample.LuaJavaBridgeTest.LuaJavaBridgeTest;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.http.RequestURL;
import com.linkxin.douyouPlayer.utils.ConfigUtils;
import com.linkxin.douyouPlayer.utils.YaYaVoiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by Administrator on 2016-09-30.
 */
public class OSSUtil {

    public static void SetUpOSS(Context context){

        initOssService(context);

//        try {
//
//            MyApplication.accessKey = context.getPackageManager()
//                    .getApplicationInfo(context.getPackageName(),
//                            PackageManager.GET_META_DATA).metaData
//                    .getString("com.alibaba.app.ossak");
//            MyApplication.screctKey = context.getPackageManager()
//                    .getApplicationInfo(context.getPackageName(),
//                            PackageManager.GET_META_DATA).metaData
//                    .getString("com.alibaba.app.osssk");
//            MyApplication.bucketName = context.getPackageManager()
//                    .getApplicationInfo(context.getPackageName(),
//                            PackageManager.GET_META_DATA).metaData
//                    .getString("com.alibaba.app.ossbucketname");
//
//            initOssService(context);
//
//        } catch (PackageManager.NameNotFoundException e) {
//            Toast.makeText(context, "上传文件失败，请稍候再试", Toast.LENGTH_SHORT).show();
//            e.printStackTrace();
//        }

    }

    public static void initOssService(Context context) {

        ClientConfiguration conf = new ClientConfiguration();
        conf.setConnectionTimeout(30 * 1000); // 连接超时，默认30秒
        conf.setSocketTimeout(30 * 1000); // socket超时，默认30秒
        conf.setMaxConcurrentRequest(5); // 最大并发请求书，默认5个
        conf.setMaxErrorRetry(2); // 失败后最大重试次数，默认2次

        OSSCredentialProvider credentialProvider = new OSSPlainTextAKSKCredentialProvider(RequestURL.accessKey, RequestURL.screctKey);
        OSSClient ossClient = new OSSClient(context.getApplicationContext(), RequestURL.endpoint, credentialProvider, conf);
        MyApplication.ossClient = ossClient;
        OSSLog.enableLog();

    }

    public static synchronized void UpLoadFile(final Context context, String uploadFilePath){

        if (MyApplication.ossClient == null)
            SetUpOSS(context);

        // 设置服务器保存文件名
        String objectKey = getTxtKey(context);
        objectKey = "media/" + objectKey;

        // 构造上传请求
        PutObjectRequest put = new PutObjectRequest(RequestURL.bucketName, objectKey, uploadFilePath);

        OSSAsyncTask task = MyApplication.ossClient.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {

            @Override
            public void onSuccess(PutObjectRequest request, PutObjectResult result) {
                Log.d("PutObject", "UploadSuccess");

                String objectKey = request.getObjectKey();
                final StringBuffer url = new StringBuffer();
                url.append(RequestURL.OSS_HOST);
                url.append("/").append(objectKey);

                Log.d("-----上传视频成功-----", "视频链接：" + url.toString());

                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        final String url_str = url.toString();
                        if (url_str == null || "".equals(url_str)){

                            Toast.makeText(context, "发送视频失败，视频异常", Toast.LENGTH_SHORT).show();

                        }else{

                            String sendMode = SPUtil.getString(MyApplication.gameActivity, "sendMode");
                            if ("2".equals(sendMode)){

                                // lua发送
                                try {
                                    JSONObject object = new JSONObject();
                                    object.put("msgType", "video");
                                    object.put("url", url_str);
                                    LuaJavaBridgeTest.sendDataToLua("msg", object);

                                    Toast.makeText(context, "发送视频", Toast.LENGTH_SHORT).show();

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    Toast.makeText(context, "发送视频失败", Toast.LENGTH_SHORT).show();
                                }

                            }else{

                                if (SPUtil.getInt(MyApplication.gameActivity, "onLogin") == 0){
                                    Toast.makeText(MyApplication.gameActivity, "视频服务正在启动", Toast.LENGTH_SHORT).show();
                                    return;
                                }

                                // 呀呀发送
                                try {
                                    YaYaVoiceUtil.sendTextMessage("video", url_str);
                                    Toast.makeText(context, "发送视频", Toast.LENGTH_SHORT).show();
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    Toast.makeText(context, "发送视频失败", Toast.LENGTH_SHORT).show();
                                }

                            }

//                            // 把连接视频链接返回lua
//                            LuaJavaBridgeTest.callBackVideoPath(url_str);
//                            Toast.makeText(context, "发送视频成功", Toast.LENGTH_SHORT).show();

                        }

                    }
                });


            }

            @Override
            public void onFailure(PutObjectRequest request, ClientException clientExcepion, ServiceException serviceException) {

                // 请求异常
                if (clientExcepion != null) {

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送视频失败，网络异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                    // 本地异常如网络异常等
                    clientExcepion.printStackTrace();
                }else{

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送视频失败，网络异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                }

                if (serviceException != null) {

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送视频失败，服务异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                    // 服务异常
                    Log.e("ErrorCode", serviceException.getErrorCode());
                    Log.e("RequestId", serviceException.getRequestId());
                    Log.e("HostId", serviceException.getHostId());
                    Log.e("RawMessage", serviceException.getRawMessage());
                }else{

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送视频失败，服务异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                }

            }
        });
    }

    public static synchronized void UpLoadVoiceFile(final Context context, String uploadFilePath){

        if (MyApplication.ossClient == null)
            SetUpOSS(context);

        // 设置服务器保存文件名
        String objectKey = getVoiceTxtKey(context);

        // 构造上传请求
        PutObjectRequest put = new PutObjectRequest(MyApplication.bucketName, objectKey, uploadFilePath);

        OSSAsyncTask task = MyApplication.ossClient.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {

            @Override
            public void onSuccess(PutObjectRequest request, PutObjectResult result) {
                Log.d("PutObject", "UploadSuccess");

                String objectKey = request.getObjectKey();
                final StringBuffer url = new StringBuffer();
                url.append(ConfigUtils.OSS_HOST);
                url.append("/").append(objectKey);

                Log.d("-----上传音频成功-----", "音频链接：" + url.toString());

                MyApplication.gameActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        String url_str = url.toString();
                        if (url_str == null || "".equals(url_str)){

                            Toast.makeText(context, "发送音频失败，音频异常", Toast.LENGTH_SHORT).show();

                        }else{

                            // 把音频链接返回lua
                            LuaJavaBridgeTest.callBackVideoPath(url_str);

                            Toast.makeText(context, "发送音频成功", Toast.LENGTH_SHORT).show();

                        }

                    }
                });


            }

            @Override
            public void onFailure(PutObjectRequest request, ClientException clientExcepion, ServiceException serviceException) {

                // 请求异常
                if (clientExcepion != null) {

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送音频失败，网络异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                    // 本地异常如网络异常等
                    clientExcepion.printStackTrace();
                }else{

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送音频失败，网络异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                }

                if (serviceException != null) {

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送音频失败，服务异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                    // 服务异常
                    Log.e("ErrorCode", serviceException.getErrorCode());
                    Log.e("RequestId", serviceException.getRequestId());
                    Log.e("HostId", serviceException.getHostId());
                    Log.e("RawMessage", serviceException.getRawMessage());

                }else{

                    MyApplication.gameActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(context, "发送音频失败，服务异常", Toast.LENGTH_SHORT).show();
                        }
                    });

                }

            }
        });
    }

    private static String getTxtKey(Context context){
        StringBuffer txt = new StringBuffer();
        txt.append(SPUtil.getCurrentUserId(context));
        txt.append("_video_");
        txt.append(new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()));
        txt.append(".mp4");
        return txt.toString();
    }

    private static String getVoiceTxtKey(Context context){
        StringBuffer txt = new StringBuffer();
        txt.append(SPUtil.getCurrentUserId(context));
        txt.append("_voice_");
        txt.append(new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()));
        txt.append(".wav");
        return txt.toString();
    }

}
