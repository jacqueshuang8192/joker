package com.hbi.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.alibaba.fastjson.JSON;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.LoginCacheController;
import com.hbi.constants.Constants;
import com.hbi.vo.response.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import java.io.PrintWriter;

@Service
public class TokenInterceptor implements HandlerInterceptor{

	private static final String SYSCONFIG = "SYSCONFIG";
	private static final String SYSCONFIGUSERS = "SYSCONFIGUSERS";
	private static final String DEBUG = "DEBUG";

	private static final String XYToken = "XYToken";

	private static final String XYUid = "XYUid";

	@Autowired
	private LoginCacheController loginCacheController;

	@Override
	public void afterCompletion(HttpServletRequest arg0,
			HttpServletResponse arg1, Object arg2, Exception arg3)
			throws Exception {

	}

	@Override
	public void postHandle(HttpServletRequest arg0, HttpServletResponse arg1,
			Object arg2, ModelAndView arg3) throws Exception {

	}

	@Override
	public boolean preHandle(HttpServletRequest req, HttpServletResponse res,
			Object arg2) {

		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			String debug = cache.hget(SYSCONFIG, DEBUG);
			//调试模式,全部通过
			if ("1".equals(debug) ) {
				return true;
			} else {

				String token = req.getParameter(XYToken);
				String uid = req.getParameter(XYUid);

				Boolean isSet = cache.sismember(SYSCONFIGUSERS, uid);
				//如果调试用户,直接通过
				if (isSet ) {
					return true;
				}

				//如果不是调试模式,做token校验
				boolean flag = loginCacheController.isTokenValid(cache, uid, token);
				if (flag ) {
					return true;
				}

				PrintWriter writer = res.getWriter();
				Response response = new Response();
				response.setReturnCode(Constants.RETURN_CODE_TOKEN_INVALID);
				writer.write(JSON.toJSONString(response));
				writer.close();
				return false;
			}
		}catch (Exception e ) {
			return false;
		}finally {
			CacheManager.releaseCache(cache);
		}
	}
}
