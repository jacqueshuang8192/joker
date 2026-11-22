package com.j.joker.vo.response.user;

import java.util.List;

import com.j.joker.vo.response.base.BaseResultVo;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "道具物品")
public class PropGoodsVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@Schema(title = "返回行数", required = true)
	private int count;
	@Schema(title = "物品清单", required = true)
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
