package com.hbi.mapper;

import com.hbi.model.TGameProvince;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TGameProvinceMapper extends EntityMapper<TGameProvince> {
    Long selectAgentByProvinceId(@Param("provinceId") Long provinceId);
    Long selectAgentByGongbanId();
    
    TGameProvince selectByProvinceId(@Param("provinceId") Long provinceId);
    
    List<TGameProvince> queryGameProvince();

    List<TGameProvince> getAllProvince();

}