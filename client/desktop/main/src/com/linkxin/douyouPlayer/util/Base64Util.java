package com.linkxin.douyouPlayer.util;

import android.util.Base64;
import android.util.Log;

public class Base64Util {

	private static final String TAG = "Base64Util";

	/**
	 * 字符串Base64加密
	 *
	 * @param str
	 * @return
	 * @throws Exception
	 */
	public static String generateBase64String(String str) throws Exception {
		String s = null;
		try {
			s = Base64.encodeToString(str.getBytes(), Base64.DEFAULT);
		} catch (Exception e) {
			Log.e(TAG, e.getLocalizedMessage());
		}
		return s;
	}

	/**
	 * BASE64解密
 	 * @param s
	 * @return
     */
	public static String getFromBase64(String s) {
		String result = null;
		if (s != null) {
			try {
				result = new String(Base64.decode(s.getBytes(), Base64.DEFAULT));
			} catch (Exception e) {
				Log.e(TAG, e.getLocalizedMessage());
			}
		}
		return result;
	}
}
