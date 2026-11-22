package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TFreeGameRound;
import com.j.joker.core.mapper.EntityMapper;

public interface TFreeGameRoundMapper extends EntityMapper<TFreeGameRound> {
	List<TFreeGameRound> queryUrlsByLevel(@Param(value = "level") int level);
}