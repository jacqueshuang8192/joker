package com.j.joker.mapper;

import com.j.joker.model.ImsGoods;
import com.j.joker.model.TGoods;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;

public interface TGoodsMapper extends EntityMapper<TGoods> {
	
	List<TGoods> findGoodsByCategoryType(@Param(value = "type") String type);
	List<ImsGoods> findImsGoodsByCategoryType(@Param(value = "type") String type,
											  @Param(value = "status")String status);

    ImsGoods findImsGoodsById(Long goodsId);
}