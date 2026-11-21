package com.hbi.vo.response.user;

import com.wordnik.swagger.annotations.ApiModel;
import com.wordnik.swagger.annotations.ApiModelProperty;

@ApiModel(value = "物品详情")
public class GoodsVo {

	@ApiModelProperty(value = "物品ID", required = true)
	private String goodsId;
	@ApiModelProperty(value = "物品名称", required = true)
	private String name;
	@ApiModelProperty(value = "说明", required = true)
	private String desc;
	@ApiModelProperty(value = "类型", required = true)
	private String type;
	@ApiModelProperty(value = "数量", required = true)
	private int amount;
	@ApiModelProperty(value = "总价", required = true)
	private int price;
	@ApiModelProperty(value = "物品图片", required = true)
	private String photo;

	public String getGoodsId() {
		return goodsId;
	}

	public void setGoodsId(String goodsId) {
		this.goodsId = goodsId;
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

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

}
