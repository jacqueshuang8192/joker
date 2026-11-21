package com.hbi.vo.response.user;

import java.util.List;

import com.hbi.vo.response.base.BaseResultVo;
import com.wordnik.swagger.annotations.ApiModelProperty;

public class AccountChargeVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@ApiModelProperty(value = "条数", required = true)
	private int count;
	@ApiModelProperty(value = "充值金额", required = true)
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
