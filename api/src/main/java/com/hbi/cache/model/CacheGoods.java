package com.hbi.cache.model;

import java.util.List;

import com.hbi.cache.CacheModel;

public class CacheGoods extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 商品ID
	 */
	private String goodsId;
	
	/**
	 * 所属用户ID
	 */
	private String userId;
	
	/**
	 * 商品名称
	 */
	private String name;
	
	/**
	 * 商品描述
	 */
	private String desc;
	
	/**
	 * 商品分类
	 */
	private String type;
	
	/**
	 * 数量
	 */
	private int amount;
	
	/**
	 * 总价格
	 */
	private int price;
	
	/**
	 * 商品组合列表
	 */
	private List<CacheGoodsCombines> combines;

	public String getGoodsId() {
		return goodsId;
	}

	public void setGoodsId(String goodsId) {
		this.goodsId = goodsId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
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

	public List<CacheGoodsCombines> getCombines() {
		return combines;
	}

	public void setCombines(List<CacheGoodsCombines> combines) {
		this.combines = combines;
	}
	
}
