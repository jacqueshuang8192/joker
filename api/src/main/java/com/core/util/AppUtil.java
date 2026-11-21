/*
 * @(#) SubSegmentCabinServiceImpl.java
 * @Author:dell123jnn(mail) 2013-5-21
 * @Copyright (c) 2002-2013 Travelsky Limited. All rights reserved.
 */
package com.core.util;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;


/**
 * 
 * @author sum
 * @version 1.0
  * @Function 类功能说明
 * 取得Spring容器的上下文环境变量，必须配置在Spring配置文件中才能使用
 *
 */
public class AppUtil implements ApplicationContextAware{
	public static ApplicationContext  appContext=null;
	
	/**
	 * 
	 */
	public void setApplicationContext(ApplicationContext applicationContext)
			throws BeansException {
		appContext=applicationContext;
	}
	
	/**
	 * 按Id取得容器Bean中的实例
	 * @param beanId
	 * @return
	 */
	public static Object getById(String beanId){
		return appContext.getBean(beanId);
	}
	
	/**
	 * 按Id取得容器Bean中的实例
	 * @param beanId
	 * @return
	 */
	public static Object getById(Class arg0){
		return appContext.getBean(arg0.getClass());
	}
}
