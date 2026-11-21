package com.hbi.mapper;

import com.hbi.model.TTestConfig;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * Created by Administrator on 2017/7/21.
 */
public interface TTestConfigMapper {
    public TTestConfig getVerifyByUidAndLevel(@Param("uid") String uid,
                                              @Param("level") String level);

    List<TTestConfig> getAllTestConfig(@Param("level") String level);

    public void updateByCeshi(@Param("l") Long l);

    public void delByCeshi();
}
