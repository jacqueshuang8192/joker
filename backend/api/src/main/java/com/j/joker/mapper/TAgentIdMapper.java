package com.j.joker.mapper;

import com.j.joker.model.TAgentId;
import com.j.joker.core.mapper.EntityMapper;

/**
 * Created by dzesla on 2017/2/16.
 */
public interface TAgentIdMapper extends EntityMapper<TAgentId> {
    Long selectUnusedId();
}
