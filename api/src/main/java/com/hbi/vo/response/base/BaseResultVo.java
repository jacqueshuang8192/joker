/**
 * 
 */
package com.hbi.vo.response.base;

import java.io.Serializable;

import com.wordnik.swagger.annotations.ApiModelProperty;

/**
 * 
 * @description: 前台基础vo对象
 * @version V1.0.0
 * 
 */
public class BaseResultVo implements Serializable {

	/**
	 * {变量说明}
	 */
	private static final long serialVersionUID = -7978635757653362784L;

	// 返回码，0表示成功，其它数字分别表示对应错误码
	@ApiModelProperty(value = "响应标识", required = true, notes = "0表示成功，其它数字分别表示对应错误码")
	private String returnCode;
	
	private Object data;

	// 返回消息，成功为“success”，失败为具体失败信息
	@ApiModelProperty(value = "失败详情", required = false, notes = "returnCode不为0时，为具体错误详情")
	private String resultMessage;

	public BaseResultVo() {
	}

	public BaseResultVo(String returnCode, String resultMessage) {
		this.returnCode = returnCode;
		this.resultMessage = resultMessage;
	}

	public String getReturnCode() {
		return returnCode;
	}

	public void setReturnCode(String returnCode) {
		this.returnCode = returnCode;
	}

	public String getResultMessage() {
		return resultMessage;
	}

	public void setResultMessage(String resultMessage) {
		this.resultMessage = resultMessage;
	}

	@Override
	public String toString() {
		return "BaseResultVo [returnCode=" + returnCode + ", resultMessage=" + resultMessage + "]";
	}

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

}
