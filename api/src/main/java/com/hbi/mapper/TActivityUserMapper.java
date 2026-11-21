package com.hbi.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.hbi.cache.model.CacheGameActivityPlayer;
import com.hbi.model.TActivityUser;
import com.core.mapper.EntityMapper;

public interface TActivityUserMapper extends EntityMapper<TActivityUser> {
	public List<CacheGameActivityPlayer> queryFreeGamePlayers(
			@Param("activityId") Long activityId);
	public List<CacheGameActivityPlayer> queryAllFreeGamePlayers(
			@Param("activityId") Long activityId);
	
	public List<TActivityUser> selectUserId(
			@Param("activityId") Long activityId);

    public List<Long> selectUserIdByActivityId(@Param("gameActivityId") String gameActivityId);

    Integer selectIsGoldTypeByLevel(@Param("level") Integer level);
}