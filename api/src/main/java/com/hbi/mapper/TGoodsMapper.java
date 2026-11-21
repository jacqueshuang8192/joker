package com.hbi.mapper;

import com.hbi.model.ImsGoods;
import com.hbi.model.TGoods;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;

public interface TGoodsMapper extends Mapper<TGoods> {
	
	List<TGoods> findGoodsByCategoryType(@Param(value = "type") String type);
	List<ImsGoods> findImsGoodsByCategoryType(@Param(value = "type") String type,
											  @Param(value = "status")String status);

    ImsGoods findImsGoodsById(Long goodsId);
}