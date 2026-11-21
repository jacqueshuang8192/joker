package com.hbi.mapper;

import com.hbi.model.TGroupZhanji;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TGroupZhanjiMapper extends EntityMapper<TGroupZhanji> {

    List<TGroupZhanji> selectByTime(@Param("groupId") Integer groupId,
                                    @Param("startTime") String startTime,
                                    @Param("endTime") String endTime);

    List<TGroupZhanji> selectByActivityId(@Param("activityId") Integer activityId);

    void updateZhanjiPoint(@Param("activityId") String activityId, @Param("uid") int uid, @Param("score") int score);

    List<TGroupZhanji> selectByMyExample(@Param("groupId") Integer groupId,
                                         @Param("tempUid") Integer tempUid,
                                         @Param("dateStr") String dateStr,
                                         @Param("pageIndex") Integer pageIndex,
                                         @Param("pageSize") Integer pageSize);
}