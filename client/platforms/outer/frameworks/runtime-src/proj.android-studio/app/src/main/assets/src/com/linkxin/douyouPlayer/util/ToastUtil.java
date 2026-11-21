package com.linkxin.douyouPlayer.util;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;

public class ToastUtil {
	
	private static boolean isshow = false;
	
	public static void showBaseToast(Context context,String Content){
		Toast.makeText(context, Content, Toast.LENGTH_SHORT).show();
	}
	
	public static void showOnlyToast(Context context,String Content){
		if(!isshow){
			Toast.makeText(context, Content, Toast.LENGTH_SHORT).show();
			isshow = true;
			new Handler() {
				@Override
				public void handleMessage(Message msg) {
					if(isshow){
						isshow = false;
					}
				}
			}.sendEmptyMessageDelayed(0, 2500);
		}
	}
}
