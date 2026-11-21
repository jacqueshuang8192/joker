package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TFreeGameRound;
import com.core.mapper.EntityMapper;

public interface TFreeGameRoundMapper extends EntityMapper<TFreeGameRound> {
	List<TFreeGameRound> queryUrlsByLevel(@Param(value = "level") int level);
}