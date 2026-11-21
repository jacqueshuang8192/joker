package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TGameType;
import com.hbi.model.TProvince;
import com.hbi.model.TProvinceAgent;

import tk.mybatis.mapper.common.Mapper;

public interface TProvinceAgentMapper extends Mapper<TProvinceAgent> {
	List<TProvinceAgent> selectProvinceIdByAgentId(@Param("agentId") Long agentId);
	TProvinceAgent selectByAgentIdAndProvinceId(@Param("agentId") Long agentId,@Param("provinceId") Long provinceId);
}