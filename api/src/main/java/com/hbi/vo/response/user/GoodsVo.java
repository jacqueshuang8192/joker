package com.hbi.vo.response.user;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "物品详情")
public class GoodsVo {

	@Schema(title = "物品ID", required = true)
	private String goodsId;
	@Schema(title = "物品名称", required = true)
	private String name;
	@Schema(title = "说明", required = true)
	private String desc;
	@Schema(title = "类型", required = true)
	private String type;
	@Schema(title = "数量", required = true)
	private int amount;
	@Schema(title = "总价", required = true)
	private int price;
	@Schema(title = "物品图片", required = true)
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
