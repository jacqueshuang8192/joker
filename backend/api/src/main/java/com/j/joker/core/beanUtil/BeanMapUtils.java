package com.j.joker.core.beanUtil;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import org.apache.commons.lang.StringUtils;
import com.alibaba.fastjson.JSON;

/**
 * JavaBean and map converter.
 * 
 * 
 */
public final class BeanMapUtils {

	/**
	 * Converts a map to a JavaBean.
	 * 
	 * @param type
	 *            type to convert
	 * @param map
	 *            map to convert
	 * @return JavaBean converted
	 * @throws IntrospectionException
	 *             failed to get class fields
	 * @throws IllegalAccessException
	 *             failed to instant JavaBean
	 * @throws InstantiationException
	 *             failed to instant JavaBean
	 * @throws InvocationTargetException
	 *             failed to call setters
	 */
	public static final Object toBean(Class<?> type, Map<String, ? extends Object> map)
			throws IntrospectionException, IllegalAccessException, InstantiationException, InvocationTargetException {
		BeanInfo beanInfo = Introspector.getBeanInfo(type);
		Object obj = type.newInstance();
		PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();
		for (int i = 0; i < propertyDescriptors.length; i++) {
			PropertyDescriptor descriptor = propertyDescriptors[i];
			String propertyName = descriptor.getName();
			if (map.containsKey(propertyName)) {
				Object value = map.get(propertyName);
				Object[] args = new Object[1];
				args[0] = value;
				descriptor.getWriteMethod().invoke(obj, args);
			}
		}
		return obj;
	}

	/**
	 * Converts a JavaBean to a map.
	 * 
	 * @param bean
	 *            JavaBean to convert
	 * @return map converted
	 * @throws IntrospectionException
	 *             failed to get class fields
	 * @throws IllegalAccessException
	 *             failed to instant JavaBean
	 * @throws InvocationTargetException
	 *             failed to call setters
	 */
	public static final Map<String, String> toMap(Object bean)
			throws IntrospectionException, IllegalAccessException, InvocationTargetException {
		Map<String, String> returnMap = new HashMap<String, String>();
		BeanInfo beanInfo = Introspector.getBeanInfo(bean.getClass());
		PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();
		for (int i = 0; i < propertyDescriptors.length; i++) {
			PropertyDescriptor descriptor = propertyDescriptors[i];
			String propertyName = descriptor.getName();
			if (!propertyName.equals("class")) {
				Method readMethod = descriptor.getReadMethod();
				Object result = readMethod.invoke(bean, new Object[0]);
				if (result != null) {

					returnMap.put(propertyName, String.valueOf(result));
				} else {
					returnMap.put(propertyName, "");
				}
			}
		}
		return returnMap;
	}

	public static final Object toBeanBySelective(Class<?> type, Map<String, String> map)
			throws IntrospectionException, IllegalAccessException, InstantiationException, InvocationTargetException {
		BeanInfo beanInfo = Introspector.getBeanInfo(type);
		Object obj = type.newInstance();
		PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();
		for (int i = 0; i < propertyDescriptors.length; i++) {
			PropertyDescriptor descriptor = propertyDescriptors[i];
			String propertyName = descriptor.getName();
			if (map.containsKey(propertyName)) {
			    
				String value = map.get(propertyName);
				if(StringUtils.isNotBlank(value)) {
				    Object o = null;
	                if (descriptor.getPropertyType() == Integer.class || descriptor.getPropertyType() == int.class) {
	                    o = Integer.parseInt(value);
	                } else if (descriptor.getPropertyType() == String.class) {
	                    o = value;
	                } else {
	                    o = JSON.parseObject(value, descriptor.getPropertyType());
	                }

	                Object[] args = new Object[1];
	                args[0] = o;
	                descriptor.getWriteMethod().invoke(obj, args);
				}				   				
			}
		}
		return obj;
	}

	/**
	 * Converts a JavaBean to a map.
	 * 
	 * @param bean
	 *            JavaBean to convert
	 * @return map converted
	 * @throws IntrospectionException
	 *             failed to get class fields
	 * @throws IllegalAccessException
	 *             failed to instant JavaBean
	 * @throws InvocationTargetException
	 *             failed to call setters
	 */
	public static final Map<String, String> toMapBySelective(Object bean)
			throws IntrospectionException, IllegalAccessException, InvocationTargetException {
		Map<String, String> returnMap = new HashMap<String, String>();
		BeanInfo beanInfo = Introspector.getBeanInfo(bean.getClass());
		PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();
		for (int i = 0; i < propertyDescriptors.length; i++) {
			PropertyDescriptor descriptor = propertyDescriptors[i];
			String propertyName = descriptor.getName();
			if (!propertyName.equals("class")) {
				Method readMethod = descriptor.getReadMethod();
				Object result = readMethod.invoke(bean, new Object[0]);
				if (result != null) {
					if (descriptor.getPropertyType() == String.class) {
						returnMap.put(propertyName, result.toString());
					} else {
						returnMap.put(propertyName, JSON.toJSONString(result));
					}					
				}
			}
		}
		return returnMap;
	}

	/**
	 * 判断是否是json结构
	 */
	private static boolean isJson(String value) {
		try {
			JSON.parseObject(value);
		} catch (Exception e) {
			return false;
		}
		return true;
	}

	public static void main(String[] args) throws Exception {
		/*
		 * Country country=new Country(); country.setId(1);
		 * country.setCountryname("ce"); Map<String, String>
		 * map=MetadataBeanRefUtil.getFieldValueMap(country);
		 * System.out.println(map);
		 * 
		 * UserInfoVo bean=new UserInfoVo();
		 * MetadataBeanRefUtil.setFieldValue(bean, map);
		 * System.out.println(bean.getUsrId());
		 */}
}
