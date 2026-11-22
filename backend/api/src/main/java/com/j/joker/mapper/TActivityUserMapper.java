package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.cache.model.CacheGameActivityPlayer;
import com.j.joker.model.TActivityUser;
import com.j.joker.core.mapper.EntityMapper;

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