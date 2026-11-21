package com.linkxin.douyouPlayer.http;

import android.content.Context;
import android.os.Bundle;
import android.widget.Toast;
import com.tencent.connect.share.QQShare;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

public class QQPublicMethod {
	
//	public static String QQ_Appid = "1105142303";
	public static String QQ_Appid = RequestURL.QQ_Appid;
	public static String QQ_App_Key = RequestURL.QQ_App_Key;
	
	public static Tencent mTencent;
	
	public static void SendUrlToQQ(final Context context,String title,String summary,String url,String appName){
		
		final Bundle params = new Bundle();
		params.putString(QQShare.SHARE_TO_QQ_TITLE, title);
        params.putString(QQShare.SHARE_TO_QQ_SUMMARY, summary);
        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL, url);
        params.putString(QQShare.SHARE_TO_QQ_APP_NAME, appName);
        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT, 0x00);
        
        // QQ分享要在主线程做
        ThreadManager.getMainHandler().post(new Runnable() {

            @Override
            public void run() {

        		// 初始化QQ模块
//        		mTencent = Tencent.createInstance(QQ_Appid, context);
//        		mTencent.shareToQQ(QQShareActivity.this, params, qqShareListener)
        		
            }
        });
	}
	
	IUiListener qqShareListener = new IUiListener() {
		
        @Override
        public void onCancel() {
        	
        }
        
        @Override
        public void onComplete(Object response) {
            // TODO Auto-generated method stub
           
        }
        
        @Override
        public void onError(UiError e) {
            // TODO Auto-generated method stub
            
        }
    };

}
