//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.SendJewelHistoryVo;
//import com.hbi.model.TJewelGives;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TJewelGivesMapper extends Mapper<TJewelGives> {
//
//    List<SendJewelHistoryVo> findHistory(
//            @Param("compereId") Long compereId,
//            @Param("startDate") String startDate,
//            @Param("endDate") String endDate);
//}