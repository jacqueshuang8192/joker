package com.linkxin.douyouPlayer.util;

import android.annotation.SuppressLint;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DateUtil {
	public static String getDate2() {
		SimpleDateFormat sdf = new SimpleDateFormat("MM.dd");
		Date d=new Date();
		d.setDate(d.getDate()+1);
		return sdf.format(d);

	}
	public static String getDate3() {
		SimpleDateFormat sdf = new SimpleDateFormat("MM.dd");
		Date d=new Date();
		d.setDate(d.getDate()+2);
		return sdf.format(d);

	}
	public static String getDate4() {
		SimpleDateFormat sdf = new SimpleDateFormat("MM.dd");
		Date d=new Date();
		d.setDate(d.getDate()+3);
		return sdf.format(d);

	}
	public static String getDate5() {
		SimpleDateFormat sdf = new SimpleDateFormat("MM.dd");
		Date d=new Date();
		d.setDate(d.getDate()+4);
		return sdf.format(d);

	}
	public static String getDate6() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
		Date d=new Date();
		d.setDate(d.getDate()+5);
		return sdf.format(d);

	}
	public static String getNow() {
		Date date = new Date();
		String pattern = "yyyy-MM-dd HH:mm:ss";
		SimpleDateFormat sdf = new SimpleDateFormat(pattern);
		String timeStr = sdf.format(date);
		return timeStr;
	}
	public static String getNow(long t) {
		Date date = new Date(t);
		String pattern = "yyyy-MM-dd HH:mm:ss";
		SimpleDateFormat sdf = new SimpleDateFormat(pattern);
		String timeStr = sdf.format(date);
		return timeStr;
	}
	
	/** 
     * 时间戳转换成日期格式字符串 
     * @param seconds 精确到秒的字符串 
     * @param formatStr 
     * @return 
     */  
    @SuppressLint({ "NewApi", "SimpleDateFormat" })
	public static String timeStamp2Date(String seconds,String format) {  
        if(seconds == null || seconds.isEmpty() || seconds.equals("null")){  
            return "";  
        }  
        if(format == null || format.isEmpty()) format = "yyyy-MM-dd HH:mm:ss";  
        SimpleDateFormat sdf = new SimpleDateFormat(format);  
        return sdf.format(new Date(Long.valueOf(seconds+"000")));  
    }  
    /** 
     * 日期格式字符串转换成时间戳 
     * @param date 字符串日期 
     * @param format 如：yyyy-MM-dd HH:mm:ss 
     * @return 
     */  
    @SuppressLint("SimpleDateFormat")
	public static String date2TimeStamp(String date_str,String format){  
        try {  
            SimpleDateFormat sdf = new SimpleDateFormat(format);  
            return String.valueOf(sdf.parse(date_str).getTime()/1000);  
        } catch (Exception e) {  
            e.printStackTrace();  
        }  
        return "";  
    }  
      
    /** 
     * 取得当前时间戳（精确到秒） 
     * @return 
     */  
    public static String timeStamp(){  
        long time = System.currentTimeMillis();  
        String t = String.valueOf(time/1000);  
        return t;  
    } 
}
