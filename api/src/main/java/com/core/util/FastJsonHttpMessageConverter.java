package com.core.util;

import java.io.IOException;
import java.io.OutputStream;

import org.apache.log4j.Logger;
import org.springframework.http.HttpOutputMessage;
import org.springframework.http.converter.HttpMessageNotWritableException;

import com.alibaba.fastjson.JSON;

/**
 * 支持JSONP的Fastjson的消息转换器
 * 
 * 
 */
public class FastJsonHttpMessageConverter extends com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter {

	private static final Logger log = Logger.getLogger(FastJsonHttpMessageConverter.class);
	
	@Override
	protected void writeInternal(Object obj, HttpOutputMessage outputMessage)
			throws IOException, HttpMessageNotWritableException {
		if (obj instanceof JSONPObject) {
			JSONPObject jsonp = (JSONPObject) obj;
			OutputStream out = outputMessage.getBody();
			String text = jsonp.getFunction() + "("
					+ JSON.toJSONString(jsonp.getJson(), getFeatures()) + ")";
			log.warn(text);
			byte[] bytes = text.getBytes(getCharset());
			out.write(bytes);
		} else {
			super.writeInternal(obj, outputMessage);
		}
	}
}