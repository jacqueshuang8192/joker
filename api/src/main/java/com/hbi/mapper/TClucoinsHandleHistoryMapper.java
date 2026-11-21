package com.hbi.mapper;

import com.hbi.model.TClucoinsHandleHistory;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TClucoinsHandleHistoryMapper extends EntityMapper<TClucoinsHandleHistory> {
    List<TClucoinsHandleHistory> selectList(@Param("groupId") Integer groupId,
                                            @Param("startTime") String startTime,
                                            @Param("endTime") String endTime,
                                            @Param("beginRowIndex") Integer beginRowIndex,
                                            @Param("pageSize") Integer pageSize,
                                            @Param("ownerId") Integer ownerId,
                                            @Param("playerId") Integer playerId);

    Integer selectListCount(@Param("groupId") Integer groupId,
                            @Param("startTime") String startTime,
                            @Param("endTime") String endTime,
                            @Param("ownerId") Integer ownerId,
                            @Param("playerId") Integer playerId);
}