package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TAd;
import com.j.joker.model.TGameType;
import com.j.joker.model.TYaoQingBangDing;

import com.j.joker.core.mapper.EntityMapper;

public interface TYaoQingBangDingMapper extends EntityMapper<TYaoQingBangDing> {
	int userBindingPromoter(@Param("userId") Long userId,
            @Param("promoterId") Long promoterId);
	int updateIsGet(@Param("userId") Long userId);
	List<TYaoQingBangDing> queryPromoterList(@Param("userId") Long userId);
	
}