package com.j.joker.core.util;

public class StringPatternUtils {
	/**
	 * 判断一个字符串是否全部数字
	 * 
	 * @param str
	 * @return true全都是数字
	 */
	public static boolean isDigitalStr(String str) {
		boolean flag = true;
		try {
			Long.valueOf(str);
		} catch (Exception e) {
			flag = false;
		}
		return flag;
	}
}
