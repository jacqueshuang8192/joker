package com.j.joker.mapper;

import com.j.joker.model.TGroupGameconfig;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

public interface TGroupGameconfigMapper extends EntityMapper<TGroupGameconfig> {

    Integer selectConfigCountByGameType(@Param("gameType") String gameType, @Param("groupId") Integer groupId);

}