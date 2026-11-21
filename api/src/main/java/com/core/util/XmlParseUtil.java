package com.core.util;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

public class XmlParseUtil {

	private static final Logger log = Logger.getLogger(XmlParseUtil.class);

	public static List<Map<String, String>> getMapping(String xmlPath) {
		try {
			SAXBuilder builder = new SAXBuilder();
			InputStream file = XmlParseUtil.class.getResourceAsStream(xmlPath);
			Document document = builder.build(file);// 获得文档对象
			Element root = document.getRootElement();// 获得根节点
			List<Element> list = root.getChildren();
			List<Map<String, String>> result = new ArrayList<Map<String, String>>();
			for (Element e : list) {
				Map<String, String> element = new HashMap<String, String>();
				element.put(e.getAttributeValue("field"),
						e.getAttributeValue("mapping"));
				result.add(element);
			}
			return result;
		} catch (Exception e) {
			// TODO: handle exception
			log.error(e.getMessage());
			return null;
		}
	}
}
