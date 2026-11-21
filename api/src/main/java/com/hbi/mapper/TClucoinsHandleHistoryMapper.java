package com.hbi.mapper;

import com.hbi.model.TClucoinsHandleHistory;
import org.apache.ibatis.annotations.Param;
import tk.mybatis.mapper.common.Mapper;

import java.util.List;

public interface TClucoinsHandleHistoryMapper extends Mapper<TClucoinsHandleHistory> {
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