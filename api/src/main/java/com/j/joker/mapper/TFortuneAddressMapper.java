package com.j.joker.mapper;

import com.j.joker.model.TFortuneAddress;
import com.j.joker.vo.request.common.TAdvertVo;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;
import java.util.Map;

/**
 * Created by dzesla on 2017/2/18.
 */
public interface TFortuneAddressMapper extends EntityMapper<TFortuneAddress> {
    public List<TAdvertVo> getAdvertList();
}
