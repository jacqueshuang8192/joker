//package com.hbi.mapper;
//
//import java.util.Date;
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheCompereListProfile;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CacheCompereRelation;
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.model.CompereVo;
//import com.hbi.model.TCompere;
//import com.hbi.vo.response.user.UserGoodsPresentDetail;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TCompereMapper extends Mapper<TCompere> {
//	List<CompereVo> getCompereNearby(@Param("cityId") String cityId);
//
//	List<CompereVo> getCompereByStatus(@Param("status") String status);
//
//	List<Long> getCompereBySocietyId(@Param("societyId") Long societyId);
//
//	List<CompereVo> queryComperesNearBy(@Param("idList") List<Long> idList);
//
//	CacheCompereProfile queryCompereDetails(@Param("compereId") Long compereId);
//
//	List<CachePlayerListProfile> queryFansByCompereId(
//			@Param("compereId") Long compereId);
//
//	List<CachePlayerListProfile> queryContributionRank(
//			@Param("compereId") Long compereId);
//
//	List<CacheCompereListProfile> queryCompereRank();
//
//	List<CacheCompereListProfile> queryAttentionCompereList(@Param("playerId") Long playerId);
//
//	List<CacheCompereListProfile> queryCompereNearbyCityId(@Param("cityId") String cityId);
//
//	List<UserGoodsPresentDetail> queryCategoryDetailByDateRange(@Param("compereId") Long compereId,
//			@Param("startDate") String startDate, @Param("endDate") String endDate, @Param("categoryId") Long categoryId);
//
//	CacheCompereRelation queryCompereAllRelation(@Param("compereId") Long compereId);
//
//	List<Long> queryMyWives(@Param("playerId") Long playerId);
//
//	int updateCompereCoinAmount(@Param("coinAmount") Integer coinAmount);
//
//	int releaseCompere(@Param("protectTime") Date protectTime, @Param("captureStatus") Integer captureStatus, @Param("compereId") Long compereId);
//
//	int unProtectCompere(@Param("captureStatus") Integer captureStatus, @Param("compereId") Long compereId);
//
//	int modifyCaptureLife(@Param("compereId") Long compereId, @Param("life") Long life);
//
//	int updateCompereAttributes(
//            @Param("compereId")Long compereId,
//            @Param("attack")Long attack,
//            @Param("defense")Long defense,
//            @Param("life")Long life);
//
//    int updateCompereExp(
//            @Param("compereId")Long compereId,
//            @Param("exp")Integer exp,
//            @Param("level")Integer level);
//
//    int updatePlayerNum(
//            @Param("compereId")Long compereId,
//            @Param("playerNum")Integer playerNum);
//
//    List<TCompere> queryAvailComperes();
//
//    int addCompereSharedProfit(@Param("sharedProfitAmount") Integer sharedProfitAmount, @Param("compereId") Long compereId);
//
//    List<CacheCompereProfile> queryCompereByPhone(@Param("phone") String phone);
//}