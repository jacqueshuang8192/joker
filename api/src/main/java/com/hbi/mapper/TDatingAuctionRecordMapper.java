//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheDatingAuctionRecordProfile;
//import com.hbi.model.TDatingAuctionRecord;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TDatingAuctionRecordMapper extends Mapper<TDatingAuctionRecord> {
//
//	List<CacheDatingAuctionRecordProfile> queryDatingAuctionRecordsByUserId(@Param("userId") Long userId);
//
//	void cancelAllAuctionRecordByActivityId(@Param("activityId") Long activityId);
//
//	int modifyBidWinnerRecord(@Param("activityId") Long activityId, @Param("userId") Long userId);
//
//	List<TDatingAuctionRecord> queryDatingAuctionRankByActivityId(@Param("activityId") Long activityId);
//}