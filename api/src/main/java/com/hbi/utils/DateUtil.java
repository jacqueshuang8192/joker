package com.hbi.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Random;

/**
 * 日期类型工具类
 * created by Mars on 2017年4月25日
 */
public class DateUtil {
	
    /**
     * String → Date (yyyy-MM-dd HH:mm:ss)
     * @param strDate 字符串日期
     */
    public static Date valueOf(String strDate) throws ParseException, NullPointerException {
    	return valueOf(strDate, "yyyy-MM-dd HH:mm:ss");
    }
    
    /**
     * String → Date
     * created by Mars on 2017年5月26日
     * @param strDate 字符串日期
     * @param pattern 字符串格式
     */
    public static Date valueOf(String strDate, String pattern) throws ParseException, NullPointerException {
           return new SimpleDateFormat(pattern).parse(strDate);
    }

	/**
	 * Date - pattern -> String
	 * Create by Mars on 16:02 2019/6/5
	 * @param date 日期
	 * @param pattern 日期格式
	 **/
	public static String parse(Date date, String pattern) {
		return new SimpleDateFormat(pattern).format(date);
	}
    
	/**
	 * 对比两个日期相差的天数
	 */
	public static int daysAbs(Date fDate, Date oDate) {
		long times1 = fDate.getTime();
		long times2 = oDate.getTime();
		long abs = Math.abs(times1 - times2) / (1000 * 60 * 60 * 24);
		return (int) abs;
	}

	/**
	 * 改变时间
	 * created by Mars on 2017年6月26日
	 * @param date 时间
	 * @param field 示例 Calendar.YEAR
	 * @param amount 加时间填正数，减时间填负数
	 */
	public static Date changeDate(Date date, int field, int amount){
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(field, amount);
		return c.getTime();
	}

	/**
	 * 打印当前时间.精确到毫秒
	 * created by Mars on 2017年6月24日
	 */
	public static void printDateTime(){
		printDateTime(new Date());
	}
	
	/**
	 * 打印时间.精确到毫秒
	 * created by Mars on 2017年6月24日
	 */
	public static void printDateTime(Date date){
		System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss SSS").format(date));
	}

	/**
	 * 两个时间相差的小时数
	 * 
	 */
	public static int timesOfTwo(Date fDate, Date oDate){
		long times1 = fDate.getTime();
		long times2 = oDate.getTime();
		long abs = Math.abs(times1 - times2) / (1000 * 60 * 60 );
		return (int) abs;
	}

	public static String getTodayString(Date date,String format) {
		return new SimpleDateFormat(format).format(date);
	}

	public static void main(String[] args) {
//		String s = getTodayString(new Date(), "yyyy-MM-dd");
		Random random = new Random();
		int n = random.nextInt(0);
		System.out.println(n);
//		System.out.println(s);
	}

	/**
	 * 根据指定类型计算两个日期相差的时间  (HH:mm)
	 * @param sDate    开始时间
	 * @param eDate    结束时间
	 */
	public static String dateDiff(Date sDate, Date eDate) {
	    Calendar sc = Calendar.getInstance();
	    Calendar se = Calendar.getInstance();
	    sc.setTime(sDate);
	    se.setTime(eDate);
		long diffMill = se.getTime().getTime() - sc.getTime().getTime();
		long hour = (diffMill / (60 * 60 * 1000)) > 0 ? (diffMill / (60 * 60 * 1000)) : 00;
		long min = ((diffMill / (60 * 1000)) - hour * 60) > 0 ? ((diffMill / (60 * 1000))- hour * 60) : 00;
		return hour + ":" + min;
	}
}