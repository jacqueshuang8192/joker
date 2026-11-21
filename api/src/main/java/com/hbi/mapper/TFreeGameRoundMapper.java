package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TFreeGameRound;
import tk.mybatis.mapper.common.Mapper;

public interface TFreeGameRoundMapper extends Mapper<TFreeGameRound> {
	List<TFreeGameRound> queryUrlsByLevel(@Param(value = "level") int level);
}