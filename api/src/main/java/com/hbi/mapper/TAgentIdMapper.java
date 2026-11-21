package com.hbi.mapper;

import com.hbi.model.TAgentId;
import tk.mybatis.mapper.common.Mapper;

/**
 * Created by dzesla on 2017/2/16.
 */
public interface TAgentIdMapper extends Mapper<TAgentId> {
    Long selectUnusedId();
}
