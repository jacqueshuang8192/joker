package com.j.joker.mapper;

import com.j.joker.model.TCluRepositoryHandleHistory;
import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

import java.util.List;

public interface TCluRepositoryHandleHistoryMapper extends EntityMapper<TCluRepositoryHandleHistory> {
    List<TCluRepositoryHandleHistory> selectMyHistory(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId, @Param("type") String type, @Param("startPage") Integer startPage, @Param("pageSize") Integer pageSize);

    Integer selectMyHistoryCount(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId, @Param("type") String type);

}
