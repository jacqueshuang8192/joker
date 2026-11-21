package com.hbi.mapper;

import com.hbi.model.ImsGoods;
import com.hbi.model.TGoods;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TGoodsMapper extends EntityMapper<TGoods> {
	
	List<TGoods> findGoodsByCategoryType(@Param(value = "type") String type);
	List<ImsGoods> findImsGoodsByCategoryType(@Param(value = "type") String type,
											  @Param(value = "status")String status);

    ImsGoods findImsGoodsById(Long goodsId);
}