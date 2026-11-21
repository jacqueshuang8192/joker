package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TAd;
import com.hbi.model.TGameType;
import com.hbi.model.TYaoQingBangDing;

import com.core.mapper.EntityMapper;

public interface TYaoQingBangDingMapper extends EntityMapper<TYaoQingBangDing> {
	int userBindingPromoter(@Param("userId") Long userId,
            @Param("promoterId") Long promoterId);
	int updateIsGet(@Param("userId") Long userId);
	List<TYaoQingBangDing> queryPromoterList(@Param("userId") Long userId);
	
}