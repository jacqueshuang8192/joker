package com.j.joker.vo.request.common;

public class GoodsReqVo {
	private String categoryId;
	private String goodsId;
//	private String goodsName;
	private int amount;
	private int price;
	private int totalPrice;

	public String getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(String categoryId) {
		this.categoryId = categoryId;
	}

	public String getGoodsId() {
		return goodsId;
	}

	public void setGoodsId(String goodsId) {
		this.goodsId = goodsId;
	}

//	public String getGoodsName() {
//		return goodsName;
//	}
//
//	public void setGoodsName(String goodsName) {
//		this.goodsName = goodsName;
//	}

	public int getAmount() {
		return amount;
	}

	public void setAmount(int amount) {
		this.amount = amount;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public int getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(int totalPrice) {
		this.totalPrice = totalPrice;
	}

}
