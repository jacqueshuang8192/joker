package com.hbi.mapper;

import com.hbi.model.TGroupGameconfig;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

public interface TGroupGameconfigMapper extends Mapper<TGroupGameconfig> {

    Integer selectConfigCountByGameType(@Param("gameType") String gameType, @Param("groupId") Integer groupId);

}