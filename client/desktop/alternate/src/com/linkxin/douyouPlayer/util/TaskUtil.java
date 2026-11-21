package com.linkxin.douyouPlayer.util;

import net.tsz.afinal.FinalHttp;
import net.tsz.afinal.http.AjaxCallBack;
import net.tsz.afinal.http.AjaxParams;

import com.linkxin.douyouPlayer.http.TaskCallBackInf;

public class TaskUtil extends AjaxCallBack<Object> {
	private TaskCallBackInf callBackInf;
	private int type = 0;
	private int tag = 0;
	public FinalHttp fh = null;

	public TaskUtil(TaskCallBackInf callBackInf) {
		this.callBackInf = callBackInf;
		fh = new FinalHttp();

		// 30秒连接超时
		fh.configTimeout(30 * 1000);
	}

	/**
	 * post请求方法
	 * @param params // 请求参数
	 * @param url // 请求链接
	 * @param type // 请求类型，作为返回辨识用，请求值查看RequestUrl
	 * @param tag // 默认传0，若多次请求则传入请求值
	 */
	public void post(AjaxParams params, String url, int type, int tag) {
		fh.post(url, params, this);
		this.type = type;
		this.tag = tag;
		
		StringBuffer sb = new StringBuffer();
		sb.append("post url:").append(url);
		if (params !=null) {
			sb.append("?").append(params.toString());
		}
		Logger.e("TaskUtil", sb.toString());
	}

	/**
	 * get请求方法
	 * 
	 * @param url
	 */
	public void get(String url, int type, int tag) {
		fh.get(url, this);
		this.type = type;
		this.tag = tag;
	}

	/**
	 * 设置请求代号
	 * 
	 * @param type
	 */
	public void setType(int type) {
		this.type = type;
	}

	/**
	 * 设置请求标记
	 * 
	 * @param type
	 */
	public void setTag(int tag) {
		this.tag = tag;
	}

	@Override
	public void onStart() {
		// TODO Auto-generated method stub
	}

	@Override
	public void onFailure(Throwable t, int errorNo, String strMsg) {
		callBackInf.taskCallBack("请求失败，错误原因：" + errorNo, type, tag);
		Logger.d("兜游", "请求失败，错误原因：" + t.getMessage());
	}

	@Override
	public void onSuccess(Object t) {
		// TODO Auto-generated method stub
		String result = t.toString();
		callBackInf.taskCallBack(result, type, tag);
		Logger.i("兜游", "请求成功：" + result);
	}

}
