package com.core.util;

import java.util.Random;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.RandomUtils;

import com.core.constants.YTConstants;

public class RadomUtil {

	/**
	 * 随机输出，默认输出数字
	 * @param length
	 * @param outType
	 * @return
	 */
	public static String getCharAndNumr(int length,String outType) {
		String val = "";

		String charOrNum =outType;
		Random random = new Random();
		for (int i = 0; i < length; i++) {
			if(StringUtils.isEmpty(outType)|| outType.equalsIgnoreCase(YTConstants.RADOM_OUT_ALL)){
				charOrNum = random.nextInt(2) % 2 == 0 ? "char" : "num"; // 输出字母还是数字
			}
			if ("char".equalsIgnoreCase(charOrNum)) // 字符串
			{
				int choice = random.nextInt(2) % 2 == 0 ? 65 : 97; // 取得大写字母还是小写字母
				val += (char) (choice + random.nextInt(26));
			} else // 数字
			{
				val += String.valueOf(random.nextInt(10));
			}
		}

		return val;
	}

	public static String getRadomNum(int length) {

		String result = "";
		Random random = new Random();
		for (int i = 0; i < length; i++) {
			int num = random.nextInt(10);
			if (i == 0 && num == 0 ) {
				num = 1;
			}
			result += String.valueOf(num);
		}

		return result;
	}
	
	public static String getRadom(int length) {
		Random random = new Random();
		String radomKey=String.valueOf(random.nextInt(length));
		return radomKey;
	}
	
	/**
	 * 根据概率计算是否发生
	 * @param probability
	 * @return
	 */
	public static boolean calProbability(Double probability) {
	    Double threshold = probability * 1000;
	    Integer randomInt = RandomUtils.nextInt(1000);
	    if (randomInt < threshold) {
            return true;
        }
	    return false;
	}
	
	public static void main(String[] args) {
		System.out.println(RadomUtil.getCharAndNumr(5,"as"));
	}
}
