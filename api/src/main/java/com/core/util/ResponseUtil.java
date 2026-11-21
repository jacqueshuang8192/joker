package com.core.util;

import org.apache.log4j.Logger;

import com.hbi.constants.Constants;
import com.hbi.vo.response.Response;

public class ResponseUtil {

	private static final Logger log = Logger.getLogger(ResponseUtil.class);
	/**
	 * 响应失败
	 * @param error
	 * @return
	 */
	public static Response getErrorResponse(String error) {
		Response requestResponse = new Response();
		requestResponse.setReturnCode(Constants.RETURN_CODE_FAIL);
		requestResponse.setError(error);
		log.error(error);
		return requestResponse;
	}

	/**
	 * 响应成功，data返回空对象
	 * @return
	 */
	public static Response getSuccessResponse() {
		Response requestResponse = new Response();
		requestResponse.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		requestResponse.setError("");
		return requestResponse;
	}
	
	/**
	 * 成功响应，data包含对象数据
	 * @param data
	 * @return
	 */
	public static Response getSuccessWithDataResponse(Object data) {
		Response requestResponse = new Response();
		requestResponse.setReturnCode(Constants.RETURN_CODE_SUCCESS);
		requestResponse.setError("");
		requestResponse.setData(data);
		return requestResponse;
	}
}
