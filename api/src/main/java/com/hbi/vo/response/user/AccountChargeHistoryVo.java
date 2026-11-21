package com.hbi.vo.response.user;

import com.hbi.vo.response.base.BaseResultVo;
import io.swagger.v3.oas.annotations.media.Schema;

public class AccountChargeHistoryVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Schema(title = "充值渠道", required = true)
	private String channel;
	@Schema(title = "充值金额", required = true)
	private int rmbAmount;
	@Schema(title = "游戏币", required = true)
	private int coinAmount;
	@Schema(title = "充值时间", required = true)
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
