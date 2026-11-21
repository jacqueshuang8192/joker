package com.hbi.vo.response.user;

import java.util.List;

import com.hbi.vo.response.base.BaseResultVo;
import com.wordnik.swagger.annotations.ApiModel;
import com.wordnik.swagger.annotations.ApiModelProperty;

@ApiModel(value = "道具物品")
public class PropGoodsVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@ApiModelProperty(value = "返回行数", required = true)
	private int count;
	@ApiModelProperty(value = "物品清单", required = true)
	private List<GoodsVo> goods;

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<GoodsVo> getGoods() {
		return goods;
	}

	public void setGoods(List<GoodsVo> goods) {
		this.goods = goods;
	}

}
