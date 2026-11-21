package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TGameConfig;
import tk.mybatis.mapper.common.Mapper;

public interface TGameConfigMapper extends Mapper<TGameConfig> {
	 String qureyCountlByLevel(@Param("level") Long level);
}