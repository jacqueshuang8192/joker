//package com.hbi.mapper;
//
//import java.util.Date;
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TMiningGame;
//import com.hbi.vo.response.user.MiningVo;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TMiningGameMapper extends Mapper<TMiningGame> {
//
//    List<TMiningGame> queryMiningGame(@Param("societyId") Long societyId, @Param("nowDate") Date nowDate);
//
//    int updateRealAmount(@Param("amount") Long amount, @Param("activityId") Long activityId);
//}