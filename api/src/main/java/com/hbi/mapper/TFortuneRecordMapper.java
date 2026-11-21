package com.hbi.mapper;

import com.hbi.model.TFortuneRecord;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

/**
 * Created by dzesla on 2017/2/17.
 */
public interface TFortuneRecordMapper extends EntityMapper<TFortuneRecord> {
    List<TFortuneRecord> queryRecord(@Param(value = "userId") Long userId);

}
