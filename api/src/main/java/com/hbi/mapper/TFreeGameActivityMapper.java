package com.hbi.mapper;

import com.hbi.cache.model.CacheGameActivity;
import com.hbi.model.*;
import com.hbi.vo.request.common.MapVo;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TFreeGameActivityMapper extends EntityMapper<TFreeGameActivity> {
	
	public List<FreeGameActivityInfo> queryFreeGameRecord(
			@Param("userId") Long userId);
	
	public List<FreeGameActivityInfo> queryOwnFreeGameRecord(
			@Param("userId") Long userId);
	public Long queryGameIdByInviteCode(
			@Param("inviteCode") String inviteCode);
	
	public List<CacheGameActivity> queryFreeGameByInviteCode(
			@Param("inviteCode") String inviteCode);
	
	public List<CacheGameActivity> queryNonCloseFreeGameByLevel(
			@Param("level") Integer level);
	
	public List<CacheGameActivity> queryAllNonCloseFreeGame();
	
	public List<FreeGameActivityInfoForPlayer> queryFreeGameByOwner(
			@Param("userId") Long userId,
			@Param("roomType") Integer roomType);

	public List<MapVo> selectActivityIds2Gold(@Param("l") long l,
										 @Param("userId") Long userId,
										 @Param("beginRowIndex") Integer beginRowIndex,
										 @Param("pageSize") int pageSize);
	public List<TFreeGameRound> queryGoldActivitiesByUserIdAndLevel(@Param("l") long l,
														   @Param("userId") Long userId,
														   @Param("beginRowIndex") Integer beginRowIndex,
														   @Param("pageSize") int pageSize,
														   @Param("level") Long level);
	public List<MapVo> selectActivityIds2Card(@Param("l") long l,
											  @Param("userId") Long userId,
											  @Param("beginRowIndex") Integer beginRowIndex,
											  @Param("pageSize") int pageSize);

	public TFreeGameRound selectFreeActivityRound(@Param("mapKey") String mapKey,
														@Param("mapValue") String mapValue);
	public TFreeGameResult selectFreeActivityResult(@Param("mapKey") String mapKey);

    public List<TFreeGameRound> queryCardActivities2RoundByUserI(@Param("userId") Long userId,
														   @Param("activityId") Long activityId);

	List<TFreeGameRound> selectFreeActivityResultAll(@Param("l")long l,
													 @Param("userId")Long userId,
													 @Param("beginRowIndex")Integer beginRowIndex,
													 @Param("pageSize")int pageSize);

	Long queryActivityIdByInviteCode(@Param("inviteCode") String inviteCode);
}