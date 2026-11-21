package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TGameConfig;
import com.core.mapper.EntityMapper;

public interface TGameConfigMapper extends EntityMapper<TGameConfig> {
	 String qureyCountlByLevel(@Param("level") Long level);
}