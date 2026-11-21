package com.hbi.mapper;

import com.hbi.model.TFortuneAddress;
import com.hbi.vo.request.common.TAdvertVo;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;
import java.util.Map;

/**
 * Created by dzesla on 2017/2/18.
 */
public interface TFortuneAddressMapper extends Mapper<TFortuneAddress> {
    public List<TAdvertVo> getAdvertList();
}
