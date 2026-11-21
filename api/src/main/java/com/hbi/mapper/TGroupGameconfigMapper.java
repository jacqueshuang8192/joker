package com.hbi.mapper;

import com.hbi.model.TGroupGameconfig;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

public interface TGroupGameconfigMapper extends EntityMapper<TGroupGameconfig> {

    Integer selectConfigCountByGameType(@Param("gameType") String gameType, @Param("groupId") Integer groupId);

}