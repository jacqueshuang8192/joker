package com.j.joker.mapper;

import com.j.joker.model.TAccountCharge;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

public interface TAccountChargeMapper extends EntityMapper<TAccountCharge> {
    Long selectRecCount(@Param("playerId") Long playerId);
}