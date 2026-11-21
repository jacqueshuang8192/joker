package com.linkxin.douyouPlayer.util;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;

import com.linkxin.douyouPlayer.MyApplication;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.activity.nyq.R.drawable;
import com.linkxin.douyouPlayer.http.RequestURL;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TimeZone;

public class CommonUtils {

	private static final Date nowDate = new Date();

    private static final int SECONDS_IN_DAY = 60 * 60 * 24;
    private static final long MILLIS_IN_DAY = 1000L * SECONDS_IN_DAY;
	
	/**
	 * URL特殊字符转义
	 * @param str
	 * @return
	 */
	public static String replaceSpecialCharacter(String str) {
		return str.replaceAll(":", "%3A").replaceAll("/", "%2F");
	}
	
	/**
	 * 时间戳年龄转换
	 * @param birthdayTime
	 * @return
	 */
	public static String convertAge(Long birthdayTime) {
		Long ageTime = nowDate.getTime() - birthdayTime;
		long age = ageTime / 1000 / 60 / 60 / 24 / 365;
		return String.valueOf(age);
	}
	
	/**
	 * 格式化直播时间
	 * @param totalSecond
	 * @return
	 */
	public static String parseTimeStr(int totalSecond) {
		int hours = totalSecond / 3600;
		int minutes = totalSecond % 3600 / 60;
		int second = totalSecond - hours * 3600 - minutes * 60;
		String time = getLastTwoChats(("0" + hours)) + ":" + getLastTwoChats(("0" + minutes)) + ":" + getLastTwoChats(("0" + second));
		return time;
	}
	
	private static String getLastTwoChats(String input) {
		return input.substring(input.length() - 2);
	}
	
	/**
	 * 解决ListView 与 ScrollView冲突
	 * @param listView
	 */
	public static void setListViewHeight(ListView listView) {     
        ListAdapter listAdapter = listView.getAdapter();      
        if (listAdapter == null) {     
            return;     
        }     
     
        int totalHeight = 0;     
        for (int i = 0; i < listAdapter.getCount(); i++) {     
            View listItem = listAdapter.getView(i, null, listView);     
            listItem.measure(0, 0);     
            totalHeight += listItem.getMeasuredHeight();     
        }     
     
        ViewGroup.LayoutParams params = listView.getLayoutParams();     
        params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1));     
        listView.setLayoutParams(params);     
    }     
	
	/**
	 * 判断列表是否为空
	 * @param list
	 * @return
	 */
	public static <T> boolean isNotNullList(List<T> list) {
		return list != null && list.size() > 0;
	}
	
	/**  
     * 根据图片名称获取R.java中对应的id  
     *   
     * @param name  
     * @return  
     */  
    public static int getImageIdByName(String name) {
        return 0;
    }

    /**
     * 根据key获取value
     *
     * @param key
     * @return
     */
    public static String readData(Context mContext, String key, int resId) {
        Properties props = new Properties();
        try {
            InputStream in = new BufferedInputStream(mContext.getResources().openRawResource(resId));
            props.load(in);
            in.close();
            String value = props.getProperty(key);
            return value;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    /**
     * 拼接h5链接
     * @param prefix 前缀
     * @param params 参数
     * @param suffix 后缀
     * @return
     */
    public static String toHtmlUrl(String prefix,Map<String,String> params,String suffix){
        StringBuilder url = new StringBuilder();
        url.append(prefix);
        if (params !=null && !params.isEmpty()) {
            Set<String> keys = params.keySet();

            url.append("?");
            boolean hasNext = false;
            for (String key : keys) {

                String value = params.get(key);
                if (TextUtils.isEmpty(value)){
                    continue;
                }
                url.append(hasNext?"&":"");

                url.append(String.format("%s=%s", key,value));
                hasNext = true;
            }
        }

        url.append(suffix);

        Logger.d("toHtmlUrl",url.toString());

        return url.toString();
    }
    public static String toUrl(String url,Map<String, String> params) {
        StringBuffer sb = new StringBuffer();
        sb.append(url);
        if (params !=null && !params.isEmpty()) {
            Set<String> keys = params.keySet();

            sb.append("?");
            boolean hasNext = false;
            for (String key : keys) {

                String value = params.get(key);
                if (TextUtils.isEmpty(value)){
                    continue;
                }
                sb.append(hasNext?"&":"");

                sb.append(String.format("%s=%s", key,value));
                hasNext = true;
            }
        }

        Logger.d("toUrl",sb.toString());
        return sb.toString();

    }

    /**
     * 计算两个经纬度之间的距离(米)
     * @param lat1
     * @param lng1
     * @param lat2
     * @param lng2
     * @return
     */
    public static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
        double radLat1 = (lat1 * Math.PI / 180.0);
        double radLat2 = (lat2 * Math.PI / 180.0);
        double a = radLat1 - radLat2;
        double b = (lng1 - lng2) * Math.PI / 180.0;
        double s = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a / 2), 2)
                + Math.cos(radLat1) * Math.cos(radLat2)
                * Math.pow(Math.sin(b / 2), 2)));
        s = s * 6378137.0;
        s = Math.round(s * 10000) / 10000;
        return s;
    }

    /**
     *
     * @param lat1
     * @param lng1
     * @param lat2
     * @param lng2
     * @return
     */
    public static String calculateAndFormatDistance(double lat1, double lng1, double lat2, double lng2) {
        double distance = calculateDistance(lat1, lng1, lat2, lng2);
        if (distance / 1000 >= 1) {
            return Math.round(distance / 100) / 10 + "KM";
        } else if (distance >= 100) {
            return distance + "M";
        } else {
            return "<100M";
        }
    }

    /**
     *
     * @param lat2
     * @param lng2
     * @return
     */
    public static String calculateDistanceFrom(double lat2, double lng2) {
        try {
            double lat1 = Double.valueOf(MyApplication.latitude);
            double lng1 = Double.valueOf(MyApplication.longitude);
            return calculateAndFormatDistance(lat1,lng1,lat2,lng2);
        }catch (Exception e){
            e.printStackTrace();
            return "";
        }
    }

    /**
     * 判断两个日期是否同一天
     * @param date1
     * @param date2
     * @return
     */
    public static boolean isSameDate(Calendar date1, Calendar date2) {
        return date1.get(Calendar.YEAR) == date2.get(Calendar.YEAR)
                && date1.get(Calendar.MONTH) == date2.get(Calendar.MONTH)
                && date1.get(Calendar.DATE) == date2.get(Calendar.DATE);
    }

    /**
     * 判断两个时间戳是否同一天
     * @param ms1
     * @param ms2
     * @return
     */
    public static boolean isSameDayOfMillis(final long ms1, final long ms2) {
        final long interval = ms1 - ms2;
        return interval < MILLIS_IN_DAY
                && interval > -1L * MILLIS_IN_DAY
                && toDay(ms1) == toDay(ms2);
    }
    private static long toDay(long millis) {
        return (millis + TimeZone.getDefault().getOffset(millis)) / MILLIS_IN_DAY;
    }
}
