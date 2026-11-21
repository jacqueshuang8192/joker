package com.hbi.vo.response.user;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "历史记录")
public class HistoryVo {

	@Schema(title = "兑换时间", required = true)
	private String buyDate;
	@Schema(title = "购买的房卡", required = true)
	private String goodsName;
	@Schema(title = "房卡数量", required = true)
	private int amount;
	@Schema(title = "游戏币数", required = true)
	private int totalPrice;

	public String getBuyDate() {
		return buyDate;
	}

	public void setBuyDate(String buyDate) {
		this.buyDate = buyDate;
	}

	public String getGoodsName() {
		return goodsName;
	}

	public void setGoodsName(String goodsName) {
		this.goodsName = goodsName;
	}

	public int getAmount() {
		return amount;
	}

	public void setAmount(int amount) {
		this.amount = amount;
	}

	public int getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(int totalPrice) {
		this.totalPrice = totalPrice;
	}

}
