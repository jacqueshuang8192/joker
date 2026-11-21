package com.hbi.mapper;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TConfig;
import tk.mybatis.mapper.common.Mapper;

public interface TConfigMapper extends Mapper<TConfig> {

    int updateConfig(@Param("key") String key, @Param("value") String value);

    public String getVValues(@Param("V") String V);
}