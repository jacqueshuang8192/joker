package com.j.joker.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.alibaba.fastjson.JSON;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.LoginCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.vo.response.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import org.springframework.web.method.HandlerMethod;
import com.j.joker.controller.common.HallReadController;
import com.j.joker.rooms.interfaces.DouniuRoomPasswordController;

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

		// Static files were served directly by the old servlet container.
		if (arg2 instanceof org.springframework.web.servlet.resource.ResourceHttpRequestHandler) {
			return true;
		}
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
            String uid = req.getParameter(XYUid);
            boolean requiresPlayerSession = arg2 instanceof HandlerMethod handler
                    && (HallReadController.class.isAssignableFrom(handler.getBeanType())
                    || DouniuRoomPasswordController.class.isAssignableFrom(handler.getBeanType()));
            if (!requiresPlayerSession && ("1".equals(cache.hget(SYSCONFIG, DEBUG))
                    || (uid != null && Boolean.TRUE.equals(cache.sismember(SYSCONFIGUSERS, uid))))) return true;

            if (loginCacheController.isTokenValid(cache, uid, req.getParameter(XYToken))) return true;
            Response invalid = new Response();
            invalid.setReturnCode(Constants.RETURN_CODE_TOKEN_INVALID);
            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write(JSON.toJSONString(invalid));
            return false;
		}catch (Exception e ) {
			return false;
		}finally {
			CacheManager.releaseCache(cache);
		}
	}
}
