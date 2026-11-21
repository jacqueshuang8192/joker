package com.hbi.mapper;

import com.hbi.model.TFortuneAddress;
import com.hbi.vo.request.common.TAdvertVo;
import com.core.mapper.EntityMapper;

import java.util.List;
import java.util.Map;

/**
 * Created by dzesla on 2017/2/18.
 */
public interface TFortuneAddressMapper extends EntityMapper<TFortuneAddress> {
    public List<TAdvertVo> getAdvertList();
}
