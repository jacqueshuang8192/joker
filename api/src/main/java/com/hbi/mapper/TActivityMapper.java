package com.hbi.mapper;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TActivity;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TActivityMapper extends EntityMapper<TActivity> {
	
	Long insertActivity(TActivity activity);
	Long selectActivityIdByuserId(@Param("userId") Long userId);
	Integer selectcardSumByuserId(@Param("userId") Long userId);
	void updateIsdeduct(@Param("activityId") Long activityId);

    public void updateStatus22(@Param("activityId") Long activityId);

	List<TActivity> selectByGroupIdAndPlayerId(
			@Param("groupId") Integer groupId,
			@Param("playerId") Integer playerId,
			@Param("dateStr") String dateStr,
			@Param("pageIndex") Integer pageIndex,
			@Param("pageSize") Integer pageSize);

    Integer selectClubTables(@Param("clubId") String clubId, @Param("gameLevel") String gameLevel);
}