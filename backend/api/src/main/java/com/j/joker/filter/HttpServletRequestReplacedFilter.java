package com.j.joker.filter;

import com.alibaba.fastjson.JSON;
import com.j.joker.core.constants.YTConstants;
import com.j.joker.core.util.AesUtils;
import com.j.joker.core.util.ApplicationContextHelper;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.LoginCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.servlet.AesHttpServletRequestWrapper;
import com.j.joker.servlet.AesHttpServletResponseWrapper;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class HttpServletRequestReplacedFilter implements Filter {

	private static final Logger log = Logger
			.getLogger(HttpServletRequestReplacedFilter.class);
	@Override
	public void destroy() {

	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {
		AesHttpServletRequestWrapper requestWrapper = new AesHttpServletRequestWrapper((HttpServletRequest) request);
		AesHttpServletResponseWrapper responseWrapper = new AesHttpServletResponseWrapper((HttpServletResponse) response);
		Response resp = new Response();
		if (((HttpServletRequest) request).getRequestURI().indexOf("userLogin") == -1
				&& ((HttpServletRequest) request).getRequestURI().indexOf("compereRegister") == -1
				&& ((HttpServletRequest) request).getRequestURI().indexOf("playerRegister") == -1
				&& ((HttpServletRequest) request).getRequestURI().indexOf("queryToken") == -1) { //登陆注册不需要验证token
			ICache cache = null;
			LoginCacheController loginCacheController = (LoginCacheController) ApplicationContextHelper.getBean("loginCacheController");
			String oldToken = ((HttpServletRequest)requestWrapper).getHeader("token");
			oldToken = AesUtils.Decrypt(oldToken, YTConstants.AES_KEY);
			String phone = ((HttpServletRequest)requestWrapper).getHeader("phone");
			try {
				cache = CacheManager.getCache();
				String result = loginCacheController.queryToken(phone, oldToken, cache);
				if (StringUtils.isNotBlank(result)) { //不为空表示token已过期，返回的是新token
					((HttpServletResponse) responseWrapper).setHeader("token", result);
				}
//				boolean validation = loginCacheController.isTokenValid(phone, transToken, cache);
//				if (!validation) {
//					throw new InfServerException(Constants.RETURN_CODE_FAIL, "token验证失败");
//				}
			} catch (InfServerException ie) {
				ie.printStackTrace();
				resp.setReturnCode(ie.getErrorCode());
				resp.setError(ie.getErrorMsg());
				ServletOutputStream output=responseWrapper.getOutputStream();
				String result = JSON.toJSONString(resp);
				output.write(result.getBytes());
				return;
			} catch (Exception e) {
				e.printStackTrace();
				resp.setReturnCode(Constants.RETURN_CODE_TOKEN_INVALID);
				resp.setError(e.getLocalizedMessage());
				ServletOutputStream output=responseWrapper.getOutputStream();
				String result = JSON.toJSONString(resp);
				output.write(result.getBytes());
				return;
			} finally {
				if (cache != null) {
					CacheManager.releaseCache(cache);
				}
			}
		}

		chain.doFilter(requestWrapper, responseWrapper);
		byte[] b1=responseWrapper.getResponseData();
//		chain.doFilter(requestWrapper, responseWrapper);
//		byte[] b1=responseWrapper.getResponseData();
		String  result= new String(b1,"UTF-8");
		ServletOutputStream output=response.getOutputStream();
		output.write(result.getBytes());
		//do something with b1 here

//		ServletOutputStream output=null;
//		byte[] b2 = null;
//		try {
//			String remotAddr=requestWrapper.getRemoteAddr();
//			String aes=result;
//			if(StringUtils.isBlank(remotAddr)){
//				aes=AesUtils.Encrypt(result, YTConstants.AES_KEY);
//			}
//
//			b2 = aes.getBytes("UTF-8");
//			//输出处理后的数据
//			response.setContentLength(b2.length);
//			output=response.getOutputStream();
//			output.write(b2);
//		} catch (Exception e) {
//			// TODO Auto-generated catch block
//			log.error("aes加密错误！"+e.getMessage());
//		}finally{
//			if(null!=output){
//				output.flush();
//				output.close();
//			}
//		}
	}

	@Override
	public void init(FilterConfig arg0) throws ServletException {
		
	}

}