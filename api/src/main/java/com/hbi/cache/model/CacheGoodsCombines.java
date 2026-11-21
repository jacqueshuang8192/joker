package com.hbi.cache.model;

import com.hbi.cache.CacheModel;

public class CacheGoodsCombines extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 组合名称
	 */
	private String combineName;

	/**
	 * 数量
	 */
	private int amount;

	/**
	 * 总价格
	 */
	private int price;

	public String getCombineName() {
		return combineName;
	}

	public void setCombineName(String combineName) {
		this.combineName = combineName;
	}

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

}
