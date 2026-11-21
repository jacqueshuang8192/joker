package com.linkxin.douyouPlayer.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Md5Util {
//	private static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5',
//			'6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
//
//	public static String toHexString(byte[] b) {
//		// String to byte
//		StringBuilder sb = new StringBuilder(b.length * 2);
//		for (int i = 0; i < b.length; i++) {
//			sb.append(HEX_DIGITS[(b[i] & 0xf0) >>> 4]);
//			sb.append(HEX_DIGITS[b[i] & 0x0f]);
//		}
//		return sb.toString();
//	}
//
//	public static String md5(String s) {
//		try {
//			// Create MD5 Hash
//			MessageDigest digest = java.security.MessageDigest
//					.getInstance("MD5");
//			digest.update(s.getBytes());
//			byte messageDigest[] = digest.digest();
//			String hs=toHexString(messageDigest);
//			if(hs.length()>16){
//				hs=hs.substring(0, 32);
//			}
//			return hs;
//		} catch (NoSuchAlgorithmException e) {
//			e.printStackTrace();
//		}
//
//		return "";
//	}
	
//	public static void main(String[] a){
//		System.out.println(MD5("123456"));
//	}
	
	public final static String MD5(String string) {
        char hexDigits[]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};       
        try {
            byte[] btInput = string.getBytes();
            // 获得MD5摘要算法的 MessageDigest 对象
            MessageDigest mdInst = MessageDigest.getInstance("MD5");
            // 使用指定的字节更新摘要
            mdInst.update(btInput);
            // 获得密文
            byte[] md = mdInst.digest();
            // 把密文转换成十六进制的字符串形式
            int j = md.length;
            char str[] = new char[j * 2];
            int k = 0;
            for (int i = 0; i < j; i++) {
                byte byte0 = md[i];
                str[k++] = hexDigits[byte0 >>> 4 & 0xf];
                str[k++] = hexDigits[byte0 & 0xf];
            }
//            return new String(str).toLowerCase();
            return new String(str);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
	
}
