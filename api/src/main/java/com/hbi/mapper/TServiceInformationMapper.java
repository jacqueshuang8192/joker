package com.hbi.mapper;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TConfig;
import com.hbi.model.TServiceInformation;

import tk.mybatis.mapper.common.Mapper;

public interface TServiceInformationMapper extends Mapper<TServiceInformation> {

    String queryServiceInformation();
}