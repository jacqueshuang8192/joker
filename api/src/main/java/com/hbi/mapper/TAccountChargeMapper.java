package com.hbi.mapper;

import com.hbi.model.TAccountCharge;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

public interface TAccountChargeMapper extends Mapper<TAccountCharge> {
    Long selectRecCount(@Param("playerId") Long playerId);
}