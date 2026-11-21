package com.hbi.mapper;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TConfig;
import com.core.mapper.EntityMapper;

public interface TConfigMapper extends EntityMapper<TConfig> {

    int updateConfig(@Param("key") String key, @Param("value") String value);

    public String getVValues(@Param("V") String V);
}