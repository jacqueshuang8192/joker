package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TConfig;
import com.j.joker.model.TGame;
import com.j.joker.model.TGameType;
import com.j.joker.model.TGameTypeGold;
import com.j.joker.model.TServiceInformation;

import com.j.joker.core.mapper.EntityMapper;

public interface TGameTypeGoldMapper extends EntityMapper<TGameTypeGold> {
	List<TGameTypeGold> queryGameType();
    
}