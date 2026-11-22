package com.j.joker.vo.response.user;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;
import com.j.joker.vo.response.base.BaseResultVo;

public class UserGoodsHistoryVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@Schema(title = "返回行数", required = true)
	private int count;
	@Schema(title = "兑换历史列表", required = true)
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
