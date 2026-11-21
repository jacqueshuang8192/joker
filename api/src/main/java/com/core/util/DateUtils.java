package com.core.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.TimeZone;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.context.i18n.LocaleContextHolder;

import javax.xml.crypto.Data;

public class DateUtils {

	private static Logger logger = Logger.getLogger(DateUtils.class);

	/**
	 * format date yyy-MM-dd
	 * @return
	 */
    public static String getDatePattern() {
        Locale locale = LocaleContextHolder.getLocale();
        String defaultDatePattern;
        try {
            defaultDatePattern = ResourceBundle.getBundle("ApplicationResources", locale).getString("date.format");
        } catch (MissingResourceException mse) {
            defaultDatePattern = "yyyy-MM-dd";
        }

        return defaultDatePattern;
    }

    /**
     * format date yyy-MM-dd HH:mm:ss
     * @return
     */
    public static String getDateTimePattern() {
        return DateUtils.getDatePattern() + " HH:mm:ss.S";
    }
    

	/**
	 * yyyy-MM-dd HH:mm:ss
	 * @return
	 */
    public static String getFormaterDate(Date date) {
    	SimpleDateFormat fm = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.US);
        fm.setTimeZone(TimeZone.getTimeZone("GMT+8"));
        return fm.format(date);
    }
	/**
	 * yyyy-MM-dd HH:mm:ss
	 * @return
	 */
    public static Date getParseDate(String date) {
    	SimpleDateFormat fm = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.US);
        fm.setTimeZone(TimeZone.getTimeZone("GMT+8"));
        try {
			return fm.parse(date);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
    }
    
    /**
	 * yyyy-MM-dd
	 * @return
     * @throws Exception 
	 */
    public static Date getParseDate(String date,String format) throws Exception {
    	if(StringUtils.isBlank(format)){
    		format=getDatePattern();
    	}
    	SimpleDateFormat fm = new SimpleDateFormat(format, Locale.US);
        fm.setTimeZone(TimeZone.getTimeZone("GMT+8"));
        try {
			return fm.parse(date);
		} catch (Exception e) {
			throw e;
		}
    }
    
	/**
	 * yyyy-MM-dd HH:mm:ss
	 * @return
	 */
    public static String getTodayDate() {
    	SimpleDateFormat fm = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US);
        fm.setTimeZone(TimeZone.getTimeZone("GMT+8"));
        Date date = new Date();
        return fm.format(date);
    }

    
	/**
	 * yyyy-MM-dd HH:mm:ss
	 * @return
	 */
    public static String getParseDate(Date date,String format) {
    	SimpleDateFormat fm = new SimpleDateFormat(format, Locale.US);
        fm.setTimeZone(TimeZone.getTimeZone("GMT+8"));
        return fm.format(date);
    }
    
    /**
     * 获取指定小时后的日期
     * @param hour
     * @return
     */
    public static String getNewHour(int hour,String format){
    	java.util.Calendar Cal=java.util.Calendar.getInstance();    
    	Cal.setTime(new Date());    
    	Cal.add(java.util.Calendar.HOUR_OF_DAY,hour);    
    	System.out.println("date:"+getParseDate(Cal.getTime(),format));  
    	return getParseDate(Cal.getTime(),format);
    }
    
    /**
     * 获取指定天数后的日期
     * @param hour
     * @return
     */
    public static String getNewDay(int day,String format){
    	java.util.Calendar Cal=java.util.Calendar.getInstance();    
    	Cal.setTime(new Date());    
    	Cal.add(java.util.Calendar.DAY_OF_MONTH,day);    
    	System.out.println("date:"+getParseDate(Cal.getTime(),format));  
    	return getParseDate(Cal.getTime(),format);
    }


	/**
	 * 按照日期取得小时
	 * @param date
	 * @return
	 */
	public static int getHour(Date date){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		return cal.get(Calendar.HOUR_OF_DAY);
	}
	
	/**
	 * 根据生日获取年龄
	 * @param birthday
	 * @return
	 */
	public static String getAge(String birthday) {

		if(StringUtils.isBlank(birthday)){
			return "0";
		}
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
		Date beginDate = null;
		try {
			// 出生年月
			beginDate = format.parse(birthday);
		} catch (ParseException e) {
			logger.error(e.getMessage());
			return "0";
		}
		Date endDate = new Date();
		long day = (endDate.getTime() - beginDate.getTime()) / 1000;
		String age = String.valueOf(day / (60 * 60 * 24 * 365));
		logger.warn("你的年龄是：" + age);
		return age;
	}
	
	/**
	 * 得到本月的第一天  
	 * @return  
	 */  
	public static String getMonthFirstDay(Integer month) {   
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	    Calendar calendar = Calendar.getInstance();  
	    if(null!=month){
		    calendar.set(Calendar.MONTH, month-1);
	    }
	    calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMinimum(Calendar.DAY_OF_MONTH));   
	  
	    return sdf.format(calendar.getTime());   
	}   
	  
	/**  
	 * 得到本月的最后一天  
	 *   
	 * @return  
	 */  
	public static String getMonthLastDay(Integer month) {   
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	    Calendar calendar = Calendar.getInstance();   
	    if(null!=month){
		    calendar.set(Calendar.MONTH, month-1);
	    }
	    calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH));   
	    return sdf.format(calendar.getTime());  
	}  
	
	public static boolean isBetweenTime(String start, String end) {
	    Long cur = System.currentTimeMillis();
	    Long s = getParseDate(start).getTime();
	    Long e = getParseDate(end).getTime();
	    if(cur > s && cur < e) {
	        return true;
	    }
	    return false;
	}
	
    /**
     * 判断两个日期是否是同一天
     * 
     * @param date1
     * @param date2
     * @return
     */
    public static boolean isSameDate(Date date1, Date date2) {
        Calendar cal1 = Calendar.getInstance();
        cal1.setTime(date1);

        Calendar cal2 = Calendar.getInstance();
        cal2.setTime(date2);

        boolean isSameYear = cal1.get(Calendar.YEAR) == cal2
                .get(Calendar.YEAR);
        boolean isSameMonth = isSameYear
                && cal1.get(Calendar.MONTH) == cal2.get(Calendar.MONTH);
        boolean isSameDate = isSameMonth
                && cal1.get(Calendar.DAY_OF_MONTH) == cal2
                        .get(Calendar.DAY_OF_MONTH);

        return isSameDate;
    }
    
	public static void main(String[] args) {
		/*getAge("1984-10-11");
		getNewHour(-1,getDateTimePattern());
		System.out.println(getHour(new Date()));
		getNewDay(30,getDatePattern());*/
		System.out.println(getTodayDate());
		RedisUtil3 ru = RedisUtil3.getRu();
		ru.rename("xxxxxxxxxxx","STT_CLUB_PLAYER_GAME_COUNT_YESTERDAY_-------------");
//		int hour=DateUtils.getHour(new Date());
//
//		String date="";
//		if(hour<=19){
//			date =DateUtils.getNewDay(1, DateUtils.getDatePattern())+" 06:00:00";
//		}else{
//			date =DateUtils.getNewDay(0, DateUtils.getDatePattern())+" 06:00:00";
//		}
//		System.out.println(date);
	}
	
}
