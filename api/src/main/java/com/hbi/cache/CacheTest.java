package com.hbi.cache;

import java.beans.IntrospectionException;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.util.Map;

import com.alibaba.druid.support.json.JSONUtils;
import com.alibaba.fastjson.JSON;
import com.core.beanUtil.BeanMapUtils;
import com.hbi.cache.model.CachePlayerProfile;

public class CacheTest implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String name;
	
	private String sign;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public String getSign() {
		return sign;
	}

	public void setSign(String sign) {
		this.sign = sign;
	}

	public static void main (String[] args) {
		
//		ICache cache = CacheManager.getCache();
//		
//		CacheTest c = new CacheTest();
//
//		c.setName("abcd");
//		
//		cache.set("test1", JSON.toJSONString(c));
//		
//		String test1 = cache.get("test1");
//
//		CacheTest m1 = JSON.parseObject(test1, CacheTest.class);
//		
//		System.out.println(m1.getName());
		
		CacheTest c = new CacheTest();
		c.setName("abcd");
		
		try {
			Map<String, String> map = BeanMapUtils.toMapBySelective(c);
			
			for (String key : map.keySet()) {
				System.out.println(key + " : " + map.get(key));
			}
		} catch (IntrospectionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
