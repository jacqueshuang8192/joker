//package com.hbi.mapper;
//
//import java.util.List;
//
//import com.hbi.cache.model.CacheAuctionRank;
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheDatingActivityListProfile;
//import com.hbi.cache.model.CacheDatingActivityProfile;
//import com.hbi.model.TDatingActivity;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TDatingActivityMapper extends Mapper<TDatingActivity> {
//
//    List<CacheDatingActivityListProfile> queryDatingActivitiesByCityId(@Param("cityId") String cityId);
//
//    int queryDatingActivityCountByUserIdAndPeriod(@Param("userId") Long userId, @Param("period") String period,
//            @Param("startDate") String startDate, @Param("endDate") String endDate);
//
//    CacheDatingActivityProfile queryDatingActivityByActivityId(@Param("activityId") Long activityId);
//
//    List<CacheDatingActivityListProfile> queryDatingActivitiesByUserId(@Param("userId") Long userId);
//
//    int updateDatingActivityAuction(@Param("activityId") Long activityId, @Param("userId") Long userId,
//            @Param("auctionCount") int auctionCount, @Param("auctionDate") String auctionDate);
//}