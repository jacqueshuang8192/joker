package com.hbi.vo.response.user;

import com.hbi.vo.response.base.BaseResultVo;
import com.wordnik.swagger.annotations.ApiModelProperty;

public class AccountChargeHistoryVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@ApiModelProperty(value = "充值渠道", required = true)
	private String channel;
	@ApiModelProperty(value = "充值金额", required = true)
	private int rmbAmount;
	@ApiModelProperty(value = "游戏币", required = true)
	private int coinAmount;
	@ApiModelProperty(value = "充值时间", required = true)
	private String chargeDate;

	public String getChannel() {
		return channel;
	}

	public void setChannel(String channel) {
		this.channel = channel;
	}

	public int getRmbAmount() {
		return rmbAmount;
	}

	public void setRmbAmount(int rmbAmount) {
		this.rmbAmount = rmbAmount;
	}

	public int getCoinAmount() {
		return coinAmount;
	}

	public void setCoinAmount(int coinAmount) {
		this.coinAmount = coinAmount;
	}

	public String getChargeDate() {
		return chargeDate;
	}

	public void setChargeDate(String chargeDate) {
		this.chargeDate = chargeDate;
	}

}
