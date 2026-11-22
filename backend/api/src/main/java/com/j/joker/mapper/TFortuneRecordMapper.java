package com.j.joker.mapper;

import com.j.joker.model.TFortuneRecord;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;

/**
 * Created by dzesla on 2017/2/17.
 */
public interface TFortuneRecordMapper extends EntityMapper<TFortuneRecord> {
    List<TFortuneRecord> queryRecord(@Param(value = "userId") Long userId);

}
