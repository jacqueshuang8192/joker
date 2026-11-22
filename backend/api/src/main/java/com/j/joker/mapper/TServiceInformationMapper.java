package com.j.joker.mapper;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TConfig;
import com.j.joker.model.TServiceInformation;

import com.j.joker.core.mapper.EntityMapper;

public interface TServiceInformationMapper extends EntityMapper<TServiceInformation> {

    String queryServiceInformation();
}