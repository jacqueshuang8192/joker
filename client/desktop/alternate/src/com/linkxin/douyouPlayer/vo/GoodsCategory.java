package com.linkxin.douyouPlayer.vo;

public class GoodsCategory {
	private Integer categoryId;
	private String categoryPhotoUrl;
	private String categoryName;

	public GoodsCategory() {
	}

	public GoodsCategory(Integer categoryId, String categoryPhotoUrl,
			String categoryName) {
		super();
		this.categoryId = categoryId;
		this.categoryPhotoUrl = categoryPhotoUrl;
		this.categoryName = categoryName;
	}

	public Integer getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(Integer categoryId) {
		this.categoryId = categoryId;
	}

	public String getCategoryPhotoUrl() {
		return categoryPhotoUrl;
	}

	public void setCategoryPhotoUrl(String categoryPhotoUrl) {
		this.categoryPhotoUrl = categoryPhotoUrl;
	}

	public String getCategoryName() {
		return categoryName;
	}

	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}

}
