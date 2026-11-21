package com.hbi.mapper;

import com.hbi.model.TAccountCharge;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

public interface TAccountChargeMapper extends EntityMapper<TAccountCharge> {
    Long selectRecCount(@Param("playerId") Long playerId);
}