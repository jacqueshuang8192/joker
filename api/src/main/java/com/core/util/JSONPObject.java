package com.core.util;

import com.wordnik.swagger.annotations.ApiModelProperty;

public class JSONPObject {
	@ApiModelProperty(value="function",notes="jsonp回调方法",dataType="String")
	private String function;// JSONP回调方法
	@ApiModelProperty(value="json",notes="json对象",dataType="Object")
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
