package com.j.joker.vo.response;

import lombok.Setter;
import lombok.Getter;
import io.swagger.v3.oas.annotations.media.Schema;

@Getter
@Setter
public class Response {

	@Schema(title = "结果标识位,0为成功，1为失败", required = true)
	private String returnCode = "0";

	@Schema(title = "错误详情", required = false)
	private String error;

	@Schema(title = "返回详情", required = false)
	private Object data;

}
