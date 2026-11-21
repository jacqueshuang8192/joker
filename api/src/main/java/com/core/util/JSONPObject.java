package com.core.util;

import io.swagger.v3.oas.annotations.media.Schema;

public class JSONPObject {
	@Schema(title = "function", description = "jsonp回调方法")
	private String function;// JSONP回调方法
	@Schema(title = "json", description = "json对象")
	private Object json;// 真正的Json对象

	public JSONPObject(String function, Object json) {
		this.function = function;
		this.json = json;
	}

	public String getFunction() {
		return function;
	}

	public void setFunction(String function) {
		this.function = function;
	}

	public Object getJson() {
		return json;
	}

	public void setJson(Object json) {
		this.json = json;
	}

}
