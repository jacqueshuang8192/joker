package com.j.joker.mapper;

import com.j.joker.model.TChargePool;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

/**
 * Created by dzesla on 2017/6/14.
 */
public interface TChargePoolMapper extends EntityMapper<TChargePool> {
    void increasePool(@Param(value = "amount") Double amount);
}
