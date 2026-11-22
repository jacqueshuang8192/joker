//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheCompereListProfile;
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.model.TBlack;
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TBlackMapper extends Mapper<TBlack> {
//
//	List<CachePlayerListProfile> queryPlayerBlacklistByUserId(@Param("userId") Long userId);
//
//	List<CacheCompereListProfile> queryCompereBlacklistByUserId(@Param("userId") Long userId);
//}