package com.hbi.mapper;

import com.hbi.model.TAgentId;
import com.core.mapper.EntityMapper;

/**
 * Created by dzesla on 2017/2/16.
 */
public interface TAgentIdMapper extends EntityMapper<TAgentId> {
    Long selectUnusedId();
}
