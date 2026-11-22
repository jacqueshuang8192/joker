package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TGameType;
import com.j.joker.model.TProvince;
import com.j.joker.model.TProvinceAgent;

import com.j.joker.core.mapper.EntityMapper;

public interface TProvinceAgentMapper extends EntityMapper<TProvinceAgent> {
	List<TProvinceAgent> selectProvinceIdByAgentId(@Param("agentId") Long agentId);
	TProvinceAgent selectByAgentIdAndProvinceId(@Param("agentId") Long agentId,@Param("provinceId") Long provinceId);
}