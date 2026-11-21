package com.hbi.servlet;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import org.apache.log4j.Logger;
import jakarta.servlet.ReadListener;
import com.core.constants.YTConstants;
import com.core.util.AesUtils;
public class AesHttpServletRequestWrapper extends HttpServletRequestWrapper {


	private static Logger logger = Logger.getLogger(AesHttpServletRequestWrapper.class);
	
	private byte[] body; // 报文
	private Map<String, String[]> map;

	public AesHttpServletRequestWrapper(HttpServletRequest request)
			throws IOException {
		super(request);
		body=request.getInputStream().readAllBytes();
		map = new HashMap<String, String[]>();
		String aesStr = new String(body);
		logger.warn(aesStr);
		String req=AesUtils.Decrypt(aesStr, YTConstants.AES_KEY);
		logger.warn(req);
		String[] params = req.split("&");
		if (params != null) {
			for (int i = 0; i < params.length; i++) {
				String str = params[i];
				String[] keyValues = str.split("=");
				String[] value = {keyValues[1]};
				map.put(keyValues[0], value);
			}
		}
	}

	@Override
	public BufferedReader getReader() throws IOException {
		return new BufferedReader(new InputStreamReader(getInputStream()));
	}

	@Override
	public ServletInputStream getInputStream() throws IOException {
		String aesStr = new String(body);
		logger.warn(aesStr);
		String req=AesUtils.Decrypt(aesStr, YTConstants.AES_KEY);
		body=req.getBytes();
		
		final ByteArrayInputStream bais = new ByteArrayInputStream(body);
		return new ServletInputStream() {
			@Override public boolean isFinished() { return bais.available() == 0; }
			@Override public boolean isReady() { return true; }
			@Override public void setReadListener(ReadListener listener) {
				throw new IllegalStateException("Synchronous request body");
			}

			@Override
			public int read() throws IOException {
				return bais.read();
			}
		};
	}

	@Override
	public String[] getParameterValues(String name) {
//		String[] strs = super.getParameterValues(name);
//		for (int i = 0; i < strs.length; i++) {
//			strs[i]=AesUtils.Decrypt(strs[i], YTConstants.AES_KEY);
//		}
		return map.get(name);
//		return super.getParameterValues(name);
	}
}