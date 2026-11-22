package com.j.joker.vo.response.user;

import java.util.List;

import com.j.joker.vo.response.base.BaseResultVo;
import io.swagger.v3.oas.annotations.media.Schema;

public class AccountChargeVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Schema(title = "条数", required = true)
	private int count;
	@Schema(title = "充值金额", required = true)
	private List<AccountChargeHistoryVo> accountChargeHistory;

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<AccountChargeHistoryVo> getAccountChargeHistory() {
		return accountChargeHistory;
	}

	public void setAccountChargeHistory(List<AccountChargeHistoryVo> accountChargeHistory) {
		this.accountChargeHistory = accountChargeHistory;
	}

}
