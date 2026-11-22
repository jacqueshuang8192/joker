package com.j.joker.core.util;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.log4j.Logger;

import com.j.joker.core.constants.YTConstants;

public class AesUtils {

	private static Logger logger = Logger.getLogger(AesUtils.class);

	/**
	 * aes加密
	 * @param sSrc
	 * @param sKey
	 * @return
	 * @throws Exception
	 */
	public static String Encrypt(String sSrc, String sKey) throws Exception {
		if (sKey == null) {
			logger.debug("Key为空null");
			return null;
		}
		// 判断Key是否为16位
		if (sKey.length() != 16) {
			logger.debug("Key长度不是16位");
			return null;
		}
		byte[] raw = sKey.getBytes("ASCII");
		SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
		Cipher cipher = Cipher.getInstance("AES");
		cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
		byte[] encrypted = cipher.doFinal(sSrc.getBytes("utf-8"));
		return byte2hex(encrypted).toLowerCase();
	}

	/**
	 * aes解密
	 * @param sSrc
	 * @param sKey
	 * @return
	 */
	public static String Decrypt(String sSrc, String sKey){
		try {
			// 判断Key是否正确
			if (sKey == null) {
				logger.debug("Key为空null");
				return null;
			}
			// 判断Key是否为16位
			if (sKey.length() != 16) {
				logger.debug("Key长度不是16位");
				return null;
			}
			byte[] raw = sKey.getBytes("ASCII");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES");
			cipher.init(Cipher.DECRYPT_MODE, skeySpec);
			byte[] encrypted1 = hex2byte(sSrc);
			try {
				byte[] original = cipher.doFinal(encrypted1);
				String originalString = new String(original,"UTF-8");
				return originalString;
			} catch (Exception e) {
				logger.debug(e.toString());
				return null;
			}
		} catch (Exception ex) {
			logger.debug(ex.toString());
			return null;
		}
	}

	public static byte[] hex2byte(String strhex) {
		if (strhex == null) {
			return null;
		}
		int l = strhex.length();
		if (l % 2 == 1) {
			return null;
		}
		byte[] b = new byte[l / 2];
		for (int i = 0; i != l / 2; i++) {
			b[i] = (byte) Integer.parseInt(strhex.substring(i * 2, i * 2 + 2),
					16);
		}
		return b;
	}

	public static String byte2hex(byte[] b) {
		String hs = "";
		String stmp = "";
		for (int n = 0; n < b.length; n++) {
			stmp = (java.lang.Integer.toHexString(b[n] & 0XFF));
			if (stmp.length() == 1) {
				hs = hs + "0" + stmp;
			} else {
				hs = hs + stmp;
			}
		}
		return hs.toUpperCase();
	}

	public static void main(String[] args) {
		try {

			String json = Encrypt("cityId=1", YTConstants.AES_KEY);
			System.out.println(json);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
