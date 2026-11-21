package com.hbi.vo.response.user;

import com.wordnik.swagger.annotations.ApiModelProperty;
import java.util.List;
import com.hbi.vo.response.base.BaseResultVo;

public class UserGoodsHistoryVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@ApiModelProperty(value = "返回行数", required = true)
	private int count;
	@ApiModelProperty(value = "兑换历史列表", required = true)
	private List<HistoryVo> history;

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<HistoryVo> getHistory() {
		return history;
	}

	public void setHistory(List<HistoryVo> history) {
		this.history = history;
	}

}
