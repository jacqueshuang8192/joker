//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.model.TAccount;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TAccountMapper extends Mapper<TAccount> {
//
//	List<CachePlayerListProfile> queryWealthRank();
//
//	public int costCoinByUserId(
//			@Param("userId") Long userId,
//			@Param("cost") int cost);
//
//	public int incomeCoinByUserId(
//			@Param("userId") Long userId,
//			@Param("cost") int cost);
//}