package com.j.joker.utils;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import com.alibaba.fastjson.JSON;
import com.j.joker.core.util.JSONUtil;
import com.j.joker.constants.Constants;
import com.j.joker.vo.response.Response;

import jakarta.servlet.http.HttpServletRequest;

public class CommonUtil {

	/**
	 * 
	 * isNotNullList(判断数组非空)
	 * 
	 * @param list
	 * @return
	 */
	public static <T> boolean isNotNullList(List<T> list) {
		if (list != null && list.size() > 0) {
			return true;
		} else {
			return false;
		}

	}

	/**
	 * 拼装错误LOG
	 * 
	 * @param e
	 * @return
	 */
	public static String buildErrorLog(Exception e) {
		String logStr = "";
		if (e instanceof InfServerException) {
			InfServerException infse = (InfServerException) e;
			logStr = logStr + infse.getErrorCode() + "," + infse.getErrorMsg();
		} else {
			logStr = logStr + Constants.SYSTEM_ERROR + ","
					+ e.getLocalizedMessage();
		}
		return logStr;
	}

	/**
	 * 拼装错误返回对象
	 * 
	 * @param e
	 * @param response
	 */
	public static void BuildErrorResponse(Exception e, Response response) {
		if (e instanceof InfServerException) {
			InfServerException infse = (InfServerException) e;
			response.setReturnCode(infse.getErrorCode());
			response.setError(infse.getErrorMsg());
		} else {
			response.setReturnCode(Constants.SYSTEM_ERROR);
			response.setError(e.getLocalizedMessage());
		}
	}

	/**
	 * Date转String
	 * 
	 * @param date
	 * @param pattern
	 * @return
	 */
	public static String dateFormat(Date date, String pattern) {
		SimpleDateFormat sdf = new SimpleDateFormat(pattern, Locale.US);
		sdf.setTimeZone(TimeZone.getTimeZone("GMT+8"));
		return sdf.format(date);
	}

	/**
	 * String转Date
	 * 
	 * @param pattern
	 * @return
	 * @throws Exception
	 */
	public static Date dateParse(String dateStr, String pattern)
			throws Exception {
		SimpleDateFormat sdf = new SimpleDateFormat(pattern, Locale.US);
		sdf.setTimeZone(TimeZone.getTimeZone("GMT+8"));
		return sdf.parse(dateStr);
	}

	/**
	 * 拼装JSONP返回
	 * 
	 * @param callbackName
	 * @param obj
	 * @return
	 */
	public static String buildJSONPResponse(String callbackName, Object obj) {
		String result = callbackName + "(" + JSON.toJSONString(obj) + ");";
		return result;
	}

	public static String buildJSONPResponseContainsNull(String callbackName, Object obj) {
		String result = callbackName + "(" + JSONUtil.parseJSONContainsNull(obj) + ");";
		return result;
	}

	public static String filterEmoji(String source) {
		if(source != null)
		{
			Pattern emoji = Pattern.compile ("[\ud83c\udc00-\ud83c\udfff]|[\ud83d\udc00-\ud83d\udfff]|[\u2600-\u27ff]",Pattern.UNICODE_CASE | Pattern . CASE_INSENSITIVE ) ;
			Matcher emojiMatcher = emoji.matcher(source);
			if ( emojiMatcher.find())
			{
				source = emojiMatcher.replaceAll("*");
				return source ;
			}
			return source;
		}
		return source;
	}

	public static String filterAscii(String content){
		if (content != null && content.length() > 0) {
			char[] contentCharArr = content.toCharArray();
			for (int i = 0; i < contentCharArr.length; i++) {
				if (contentCharArr[i] < 0x20 || contentCharArr[i] == 0x7F) {
					contentCharArr[i] = 0x20;
				}
			}
			return new String(contentCharArr);
		}
		return "";
	}

	public static String getIpAddr(HttpServletRequest request) {
		String ip = request.getHeader("x-forwarded-for");
		if(ip == null || ip.length() == 0 ||"unknown".equalsIgnoreCase(ip)) {
			ip = request.getHeader("Proxy-Client-IP");
		}
		if(ip == null || ip.length() == 0 ||"unknown".equalsIgnoreCase(ip)) {
			ip = request.getHeader("WL-Proxy-Client-IP");
		}
		if(ip == null || ip.length() == 0 ||"unknown".equalsIgnoreCase(ip)) {
			ip = request.getRemoteAddr();
		}
		return ip;
	}


	public static String generateOrderId(Long userId) {
		SimpleDateFormat sf = new SimpleDateFormat("yyyyMMddHHmmss");
		String date = sf.format(new Date());
		return "sj" + date + userId;
	}
}
