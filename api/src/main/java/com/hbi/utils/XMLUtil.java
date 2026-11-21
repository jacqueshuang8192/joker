package com.hbi.utils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;

public class XMLUtil {
	public static  Log log = LogFactory.getLog(XMLUtil.class);
	/**
	 * 解析xml,返回第一级元素键值对。如果第一级元素有子节点，则此节点的值是子节点的xml数据。
	 * @param strxml
	 * @return
	 * @throws JDOMException
	 * @throws IOException
	 */
	public static Map doXMLParse(String strxml){
		strxml = strxml.replaceFirst("encoding=\".*\"", "encoding=\"UTF-8\"");

		if(null == strxml || "".equals(strxml)) {
			return null;
		}
		
		InputStream in = null;
		
		Map m = new HashMap();
		try
		{
			in = new ByteArrayInputStream(strxml.getBytes("UTF-8"));
			SAXBuilder builder = new SAXBuilder();
			Document doc = builder.build(in);
			Element root = doc.getRootElement();
			List list = root.getChildren();
			Iterator it = list.iterator();
			while(it.hasNext()) {
				Element e = (Element) it.next();
				String k = e.getName();
				String v = "";
				List children = e.getChildren();
				if(children.isEmpty()) {
					v = e.getTextNormalize();
				} else {
					v = XMLUtil.getChildrenText(children);
				}
				
				m.put(k, v);
			}
			
			//关闭流
			in.close();
		}
		catch (Exception e)
		{
			if (in != null)
			{
				try {
					in.close();
				} catch (IOException e1) {
					e1.printStackTrace();
				}
			}
			e.printStackTrace();
			return null;
		}
		
		
		return m;
	}
	
	/**
	 * 获取子结点的xml
	 * @param children
	 * @return String
	 */
	public static String getChildrenText(List children) {
		StringBuffer sb = new StringBuffer();
		if(!children.isEmpty()) {
			Iterator it = children.iterator();
			while(it.hasNext()) {
				Element e = (Element) it.next();
				String name = e.getName();
				String value = e.getTextNormalize();
				List list = e.getChildren();
				sb.append("<" + name + ">");
				if(!list.isEmpty()) {
					sb.append(XMLUtil.getChildrenText(list));
				}
				sb.append(value);
				sb.append("</" + name + ">");
			}
		}
		
		return sb.toString();
	}
	
	
	public static String printMap(Map<String, String> map) 
	{  
		StringBuilder str = new StringBuilder();
		str.append("<xml>");
	    Iterator<String> keys = map.keySet().iterator();  
	    while (keys.hasNext()) 
	    {  
	      String key = keys.next();  
	      str.append("<").append(key).append(">");
	      str.append(map.get(key));
	      str.append("</").append(key).append(">");
	    }  
		str.append("</xml>");
		 
		return str.toString();
	}  
	
	
	
	public static void main(String[] args) 
	{
		String str = "<xml><return_code><![CDATA[SUCCESS]]></return_code><return_msg><![CDATA[OK]]></return_msg><appid><![CDATA[wx2ccd2eb081f7d70e]]></appid><mch_id><![CDATA[1346483001]]></mch_id><nonce_str><![CDATA[0eUEvr8AJwr0ymzH]]></nonce_str><sign><![CDATA[A4FA8C0450804B3E188A23709E34549F]]></sign><result_code><![CDATA[SUCCESS]]></result_code><prepay_id><![CDATA[wx20160527175826c169989c180522627954]]></prepay_id><trade_type><![CDATA[APP]]></trade_type></xml>";
		
		Map map = doXMLParse(str);
		
		log.info(map.get("result_code") + "==" + map.get("return_code"));
	}
	
}
