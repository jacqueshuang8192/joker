package com.hbi.mapper;

import com.hbi.model.TCluRepositoryHandleHistory;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;

public interface TCluRepositoryHandleHistoryMapper extends Mapper<TCluRepositoryHandleHistory> {
    List<TCluRepositoryHandleHistory> selectMyHistory(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId, @Param("type") String type, @Param("startPage") Integer startPage, @Param("pageSize") Integer pageSize);

    Integer selectMyHistoryCount(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId, @Param("type") String type);

}
