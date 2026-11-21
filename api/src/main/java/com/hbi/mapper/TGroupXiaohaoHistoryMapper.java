package com.hbi.mapper;

import com.hbi.model.TGroupXiaohaoHistory;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;

public interface TGroupXiaohaoHistoryMapper extends Mapper<TGroupXiaohaoHistory> {

    List<TGroupXiaohaoHistory> getXiaohaoList(@Param("groupId") Integer groupId, @Param("hehuorenId") Integer hehuorenId, @Param("startTime") String startTime,
                                              @Param("endTime") String endTime, @Param("startIndex") Integer startIndex, @Param("pageSize") Integer pageSize,
                                              @Param("searchUid") Integer searchUid);

    Integer getXiaohaoListLen(@Param("groupId") Integer groupId, @Param("hehuorenId") Integer hehuorenId, @Param("startTime") String startTime, @Param("endTime") String endTime,
                              @Param("searchUid") Integer searchUid);

    Integer getXiaoHaoCount(@Param("groupId") Integer groupId, @Param("hehuorenId") Integer hehuorenId, @Param("startTime") String startTime, @Param("endTime") String endTime,
                            @Param("searchUid") Integer searchUid);
}