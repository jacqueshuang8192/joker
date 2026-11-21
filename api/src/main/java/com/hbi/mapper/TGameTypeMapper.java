package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TConfig;
import com.hbi.model.TGame;
import com.hbi.model.TGameType;
import com.hbi.model.TServiceInformation;

import tk.mybatis.mapper.common.Mapper;

public interface TGameTypeMapper extends Mapper<TGameType> {
	List<TGameType> queryGameType();
    
}