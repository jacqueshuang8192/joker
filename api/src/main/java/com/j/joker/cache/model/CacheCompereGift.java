package com.j.joker.cache.model;

import com.j.joker.cache.CacheModel;

public class CacheCompereGift extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private Long categoryId;
	private String categoryPhoto;
	private String categoryName;
	private Integer totalPrice;
	private Integer amount;

	public Long getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(Long categoryId) {
		this.categoryId = categoryId;
	}

	public String getCategoryPhoto() {
		return categoryPhoto;
	}

	public void setCategoryPhoto(String categoryPhoto) {
		this.categoryPhoto = categoryPhoto;
	}

	public String getCategoryName() {
		return categoryName;
	}

	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}

	public Integer getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(Integer totalPrice) {
		this.totalPrice = totalPrice;
	}

	public Integer getAmount() {
		return amount;
	}

	public void setAmount(Integer amount) {
		this.amount = amount;
	}

}
