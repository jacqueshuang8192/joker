package com.hbi.vo.response.user;

import io.swagger.v3.oas.annotations.media.Schema;

public class AccountVo {

	@Schema(title = "宝贝币余额", required = true)
	private Long coinAmount;
	@Schema(title = "房卡余额", required = true)
	private Long jewelAmount;

	private String receiverName;

	public Long getCoinAmount() {
		return coinAmount;
	}

	public void setCoinAmount(Long coinAmount) {
		this.coinAmount = coinAmount;
	}

	public Long getJewelAmount() {
		return jewelAmount;
	}

	public void setJewelAmount(Long jewelAmount) {
		this.jewelAmount = jewelAmount;
	}

	public String getReceiverName() {
		return receiverName;
	}

	public void setReceiverName(String receiverName) {
		this.receiverName = receiverName;
	}
}
