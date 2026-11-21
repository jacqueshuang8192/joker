package com.hbi.mapper;

import com.hbi.model.TChargePool;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

/**
 * Created by dzesla on 2017/6/14.
 */
public interface TChargePoolMapper extends Mapper<TChargePool> {
    void increasePool(@Param(value = "amount") Double amount);
}
