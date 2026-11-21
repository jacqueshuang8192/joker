package com.hbi.mapper;

import com.hbi.model.TFreeGameResult;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TFreeGameResultMapper extends EntityMapper<TFreeGameResult> {
    List<TFreeGameResult> queryActivitiesByUserId(@Param(value = "userId") Long userId);
    
    List<TFreeGameResult> queryActivitiesByOwner(@Param(value = "userId") Long userId);

    void insertPlayerRound(@Param("l") int l, @Param("uid") Integer uid, @Param("activityId") String activityId, @Param("index") String index, @Param("is_gold") int is_gold,@Param("groupId")Integer groupId);

    void insertFreeGameRound(@Param("activityId") String activityId, @Param("toJSONString") String toJSONString, @Param("replayUrl") String replayUrl, @Param("level") String level, @Param("index") String index, @Param("time") String time,@Param("groupId")Integer groupId);

    Integer selectPlayerResult(@Param("l") long l, @Param("uid") Integer uid, @Param("activityId") String activityId);

    void updatePlayerResult(@Param("l") long l, @Param("index") String index, @Param("uid") Integer uid, @Param("activityId") String activityId);

    void insertPlayerResult(@Param("l") long l, @Param("uid") Integer uid, @Param("activityId") String activityId, @Param("index") String index, @Param("is_gold") int is_gold, @Param("groupGameTime") String groupGameTime,
                            @Param("groupId")Integer groupId);

    Integer selectFreeGameResult(@Param("activityId") String activityId);

    void updateFreeGameResult(@Param("toJSONString") String toJSONString, @Param("index") String index, @Param("activityId") String activityId);

    void insertFreeGameResult(@Param("activityId") String activityId, @Param("toJSONString") String toJSONString, @Param("level") String level, @Param("groupGameTime") String groupGameTime, @Param("index") String index, @Param("groupId")Integer groupId);

    List<TFreeGameResult> queryActivitiesResult(@Param("l") Integer l, @Param("userId") Integer userId, @Param("groupId") Integer groupId, @Param("type") Integer type, @Param("startPage") int startPage, @Param("pageSize") Integer pageSize, @Param("level") Integer level);

    Integer queryActivitiesResultCount(@Param("l") Integer l, @Param("userId") Integer userId, @Param("groupId") Integer groupId, @Param("type") Integer type, @Param("level") Integer level);
}