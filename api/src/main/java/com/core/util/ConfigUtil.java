package com.core.util;

import java.io.UnsupportedEncodingException;
import java.util.ResourceBundle;

import org.apache.log4j.Logger;

/**
 * 项目参数工具类
 * 
 * 
 */
public class ConfigUtil {
	private static ResourceBundle loadConfig() {
		String path = System.getenv().getOrDefault("JOKER_CONFIG", "config.properties");
		try (var reader = java.nio.file.Files.newBufferedReader(java.nio.file.Path.of(path))) {
			return new java.util.PropertyResourceBundle(reader);
		} catch (java.io.IOException e) {
			throw new IllegalStateException("Cannot load API configuration: " + path, e);
		}
	}

	private static final ResourceBundle bundle = loadConfig();
	private static ResourceBundle customBundle=null;
	private static final Logger log = Logger
			.getLogger(ConfigUtil.class);

	/**
	 * 获取自定义bundle key
	 * @param bundleName
	 * @param key
	 * @return
	 */
	public static String getCustomBundle(String bundleName,String key){
		customBundle=java.util.ResourceBundle.getBundle(bundleName);
		if(!customBundle.containsKey(key)){
			return "";
		}else{
			try {
				String value=customBundle.getString(key);
				value=new String(value.getBytes("ISO-8859-1"),"UTF-8");  
				return value;
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				log.error(e.getMessage());
				return "";
			}
		}
	}
	/**
	 * 通过键获取值
	 * 
	 * @param key
	 * @return
	 */
	public static final String get(String key) {
		if(!bundle.containsKey(key)){
			return null;
		}else{
			return bundle.getString(key);
		}
	}
	
	/**
	 * 根据key获取值，获取不到则取默认值
	 * @param key
	 * @param defaultStr
	 * @return
	 */
	public static final String get(String key,String defaultStr) {
		if(!bundle.containsKey(key)){
			return defaultStr;
		}else{
			return bundle.getString(key);
		}
	}
}
