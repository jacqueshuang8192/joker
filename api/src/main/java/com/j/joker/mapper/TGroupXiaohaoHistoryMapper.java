package com.j.joker.mapper;

import com.j.joker.model.TGroupXiaohaoHistory;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;

public interface TGroupXiaohaoHistoryMapper extends EntityMapper<TGroupXiaohaoHistory> {

    List<TGroupXiaohaoHistory> getXiaohaoList(@Param("groupId") Integer groupId, @Param("hehuorenId") Integer hehuorenId, @Param("startTime") String startTime,
                                              @Param("endTime") String endTime, @Param("startIndex") Integer startIndex, @Param("pageSize") Integer pageSize,
                                              @Param("searchUid") Integer searchUid);

    Integer getXiaohaoListLen(@Param("groupId") Integer groupId, @Param("hehuorenId") Integer hehuorenId, @Param("startTime") String startTime, @Param("endTime") String endTime,
                              @Param("searchUid") Integer searchUid);

    Integer getXiaoHaoCount(@Param("groupId") Integer groupId, @Param("hehuorenId") Integer hehuorenId, @Param("startTime") String startTime, @Param("endTime") String endTime,
                            @Param("searchUid") Integer searchUid);
}