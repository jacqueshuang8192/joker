package com.hbi.vo.response.user;

import com.wordnik.swagger.annotations.ApiModelProperty;

public class AccountVo {

	@ApiModelProperty(value = "宝贝币余额", required = true)
	private Long coinAmount;
	@ApiModelProperty(value = "房卡余额", required = true)
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
