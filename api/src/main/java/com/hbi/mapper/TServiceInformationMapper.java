package com.hbi.mapper;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TConfig;
import com.hbi.model.TServiceInformation;

import com.core.mapper.EntityMapper;

public interface TServiceInformationMapper extends EntityMapper<TServiceInformation> {

    String queryServiceInformation();
}