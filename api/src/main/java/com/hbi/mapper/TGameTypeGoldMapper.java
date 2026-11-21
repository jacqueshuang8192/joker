package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TConfig;
import com.hbi.model.TGame;
import com.hbi.model.TGameType;
import com.hbi.model.TGameTypeGold;
import com.hbi.model.TServiceInformation;

import com.core.mapper.EntityMapper;

public interface TGameTypeGoldMapper extends EntityMapper<TGameTypeGold> {
	List<TGameTypeGold> queryGameType();
    
}