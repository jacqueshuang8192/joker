package com.hbi.mapper;

import com.hbi.model.TFortuneRecord;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;

/**
 * Created by dzesla on 2017/2/17.
 */
public interface TFortuneRecordMapper extends Mapper<TFortuneRecord> {
    List<TFortuneRecord> queryRecord(@Param(value = "userId") Long userId);

}
