package com.linkxin.douyouPlayer.http;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import android.graphics.Bitmap;
import android.os.Looper;
import android.util.Log;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.base.BaseActivity;
import com.linkxin.douyouPlayer.utils.BitmapUtils;
import com.linkxin.douyouPlayer.utils.ConfigUtils;
import com.linkxin.douyouPlayer.vo.ImageItem;

/**
 * 阿里云图片上传
 * @author lxy
 *
 */
public class OssImageUploader {

	private static final String TAG = "OssImageUploader";

    private static int defQuality = 70;//默认图片压缩
    private static OSSClient ossClient = MyApplication.ossClient;
    private static String bucketName= MyApplication.bucketName;

    private static List<String> uploadedObjectKey = new ArrayList<String>();

    //待上传图片大小
    private static int uploadSize = 1;

    /****************************************默认图片压缩*********************************************/
    public static void uploadImages(BaseActivity activity,ImageItem images,UploadListener listener){
        uploadImagesWithQuality(activity,images.sourcePath,defQuality,listener);
    }

    public static void uploadImageItmes(BaseActivity activity,List<ImageItem> images,UploadListener listener){
        uploadImageItmesWithQuality(activity,images,defQuality,listener);
    }

    public static void uploadImages(BaseActivity activity,String images,UploadListener listener){
        uploadImagesWithQuality(activity,images,defQuality,listener);
    }

    public static void uploadImages(BaseActivity activity,List<String> images,UploadListener listener){
        uploadImagesWithQuality(activity,images,defQuality,listener);
    }

    public static void uploadBitmap(BaseActivity activity,Bitmap bitmap,UploadListener listener){
        uploadBitmapWithQuality(activity,bitmap,defQuality,listener);
    }

    public static void uploadBitmap(BaseActivity activity,List<Bitmap> bitmaps,UploadListener listener){
        uploadBitmapWithQuality(activity,bitmaps,defQuality,listener);
    }

    /****************************************可选压缩*********************************************/

    public static void uploadImagesWithQuality(BaseActivity activity,ImageItem images,int quality,UploadListener listener){
        uploadImagesWithQuality(activity,images.sourcePath,quality,listener);
    }

    public static void uploadImageItmesWithQuality(BaseActivity activity,List<ImageItem> images,int quality,UploadListener listener){
        uploadSize = images.size();
        for (ImageItem item : images) {
            asyncUploader(activity,item.sourcePath,quality,listener);
        }
    }

    public static void uploadImagesWithQuality(BaseActivity activity,String images,int quality,UploadListener listener){
        uploadSize = 1;
        asyncUploader(activity,images,quality,listener);
    }

    public static void uploadImagesWithQuality(BaseActivity activity,List<String> images,int quality,UploadListener listener){
        uploadSize = images.size();
        for (String image:images) {
            asyncUploader(activity,image,quality,listener);
        }
    }

    public static void uploadBitmapWithQuality(BaseActivity activity,Bitmap bitmap,int quality,UploadListener listener){
        uploadSize = 1;
        asyncUploader(activity,bitmap,quality,listener);
    }

    public static void uploadBitmapWithQuality(BaseActivity activity,List<Bitmap> bitmaps,int quality,UploadListener listener){
        uploadSize = bitmaps.size();
        for (Bitmap bitmap:bitmaps){
            asyncUploader(activity,bitmap,quality,listener);
        }
    }

    private static void asyncUploader(final BaseActivity activity,final String imagePath,final int quality,final UploadListener listener){
        final String objectKey = getObjectKey();
        PutObjectRequest request = new PutObjectRequest(bucketName, objectKey, imagePath);
        asyncUploader(activity,request,listener);
    }

    private static void asyncUploader(final BaseActivity activity, Bitmap bitmap,int quality, final UploadListener listener){
        byte[] data = BitmapUtils.Bitmap2Bytes(bitmap,quality);
        asyncUploader(activity,data,listener);
    }

    private static void asyncUploader(final BaseActivity activity,final byte[] data,final UploadListener listener){
        final String objectKey = getObjectKey();
        PutObjectRequest request = new PutObjectRequest(bucketName, objectKey,data);
        asyncUploader(activity,request,listener);
    }

    public static void uploadLogInBackground(String filePath,UploadListener listener){
        final String objectKey = getTxtKey();
        PutObjectRequest request = new PutObjectRequest(bucketName, objectKey,filePath);
        asyncUploader(null,request,listener);
    }
    private static void asyncUploader(final BaseActivity activity,final PutObjectRequest request,final UploadListener listener){
        new Thread(){
            @Override
            public void run() {

                ossClient.asyncPutObject(request, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {

                    @Override
                    public void onSuccess(PutObjectRequest request, PutObjectResult result) {
                        // TODO Auto-generated method stub
                        String objectKey = request.getObjectKey();

                        Log.d(TAG, "PutObject UploadSuccess");
                        Log.d(TAG, "ETag "+result.getETag());
                        Log.d(TAG, "RequestId "+result.getRequestId());
                        Log.d(TAG, "objectKey "+objectKey);

                        synchronized (this) {
                            uploadedObjectKey.add(objectKey);
                            if (uploadSize == uploadedObjectKey.size()) {
                                onFinish(listener);
                            }
                        }

                    }

                    @Override
                    public void onFailure(PutObjectRequest request, ClientException clientException,
                                          ServiceException serviceException) {
                        // TODO Auto-generated method stub
                        if (clientException !=null) {
                            clientException.printStackTrace();
                        }
                        if (serviceException !=null) {
                            // 服务异常
                            Log.e(TAG, "ErrorCode "+serviceException.getErrorCode());
                            Log.e(TAG, "RequestId "+serviceException.getRequestId());
                            Log.e(TAG, "HostId "+serviceException.getHostId());
                            Log.e(TAG,"RawMessage "+ serviceException.getRawMessage());
                        }
                        showError(activity);
                        clear();

                    }
                });
            }
        }.start();

    }

	private static void showError(BaseActivity activity){
        if (activity == null){
            return;
        }
		Looper.prepare();
		activity.hideLoading();
		activity.shortToast("上传失败,请稍后重试！");
		clear();
		Looper.loop();
	}

	/**
	 * 上传完成后拼接图片url
	 * @param listener
	 */
	private static void onFinish(final UploadListener listener){
		if (listener !=null) {
			List<String> list = new ArrayList<String>(uploadedObjectKey.size());
			for (String key: uploadedObjectKey) {
				StringBuffer url = new StringBuffer();
				url.append(ConfigUtils.OSS_HOST);
				url.append("/").append(key);
				list.add(url.toString());
			}
			listener.onSuccess(list);
			clear();
		}else {
			clear();
		}
	}

	private static String getObjectKey(){
		StringBuffer objectKey = new StringBuffer();
        objectKey.append(UUID.randomUUID()).append(".jpg");
		return objectKey.toString();
	}

    private static String getTxtKey(){
        StringBuffer txt = new StringBuffer();
        txt.append("Android_douyou_player_crash_log_");
        txt.append(new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format(new Date()));
        return txt.toString();
    }

	/**
	 * 文件上传成功后清除
	 */
	private static void clear(){
		uploadedObjectKey.clear();
	}

	public interface UploadListener{
		void onSuccess(List<String> images);
	}
}
