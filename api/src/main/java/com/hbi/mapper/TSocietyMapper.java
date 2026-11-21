//package com.hbi.mapper;
//
//import java.util.List;
//
//import com.hbi.cache.model.*;
//import org.apache.ibatis.annotations.Param;
//
//import tk.mybatis.mapper.common.Mapper;
//
//import com.hbi.model.TSociety;
//
//public interface TSocietyMapper extends Mapper<TSociety> {
//    List<Long> getPlayerListBySocietyId(@Param("societyId") Long societyId);
//
//    List<CacheUserListProfile> getManagerListBySocietyId(@Param("societyId") Long societyId);
//
//    CacheSocietyProfile getSocietyDetail(@Param("societyId") Long societyId, @Param("nowTime") String nowTime);
//
//    List<CacheSocietyListProfile> getSocietyList();
//
//    List<Long> getSocietyListByCity(@Param("cityId") Long cityId);
//
//    int updateSocietyMine(@Param("societyId") Long societyId, @Param("mineCount") Long mineCount);
//
//    int changeSocietyStatusToMining(@Param("societyId") Long societyId, @Param("fullAmount") Long fullAmount);
//
//    int updateSocietyStatus(@Param("societyId") Long societyId, @Param("status") Integer status);
//}