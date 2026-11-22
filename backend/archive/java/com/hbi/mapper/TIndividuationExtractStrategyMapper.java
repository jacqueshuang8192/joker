//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheExtractStrategyProfile;
//import com.hbi.model.TIndividuationExtractStrategy;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TIndividuationExtractStrategyMapper extends Mapper<TIndividuationExtractStrategy> {
//
//    List<CacheExtractStrategyProfile> findIndividuationExtractStrategiesByManagerId(@Param("source") String source,
//            @Param("managerId") Long managerId);
//}