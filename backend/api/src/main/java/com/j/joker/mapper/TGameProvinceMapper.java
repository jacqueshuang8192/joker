package com.j.joker.mapper;

import com.j.joker.model.TGameProvince;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;

public interface TGameProvinceMapper extends EntityMapper<TGameProvince> {
    Long selectAgentByProvinceId(@Param("provinceId") Long provinceId);
    Long selectAgentByGongbanId();
    
    TGameProvince selectByProvinceId(@Param("provinceId") Long provinceId);
    
    List<TGameProvince> queryGameProvince();

    List<TGameProvince> getAllProvince();

}