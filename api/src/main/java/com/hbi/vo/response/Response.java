package com.hbi.vo.response;

import io.swagger.v3.oas.annotations.media.Schema;

public class Response {

	@Schema(title = "结果标识位,0为成功，1为失败", required = true)
	private String returnCode;

	@Schema(title = "错误详情", required = false)
	private String error;

	@Schema(title = "返回详情", required = false)
	private Object data;

	public Object getData() {
		return data;
	}

	public void setData(Object data) {
		this.data = data;
	}

	public Response() {
		this.returnCode = "0";
	}

	public String getReturnCode() {
		return returnCode;
	}

	public void setReturnCode(String returnCode) {
		this.returnCode = returnCode;
	}

	public String getError() {
		return error;
	}

	public void setError(String error) {
		this.error = error;
	}

}
