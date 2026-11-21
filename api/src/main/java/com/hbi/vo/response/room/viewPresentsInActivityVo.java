package com.hbi.vo.response.room;

import java.util.List;

import com.hbi.vo.response.base.BaseResultVo;

public class viewPresentsInActivityVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private List<Object> presents;

	public List<Object> getPresents() {
		return presents;
	}

	public void setPresents(List<Object> presents) {
		this.presents = presents;
	}
	
}
