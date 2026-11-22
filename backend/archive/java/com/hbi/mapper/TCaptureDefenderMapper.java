//package com.hbi.mapper;
//
//import java.util.Date;
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TCaptureDefender;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TCaptureDefenderMapper extends Mapper<TCaptureDefender> {
//    public int updateCaptureTime(
//            @Param("id") Long id,
//            @Param("endDate") Date endDate,
//            @Param("type") Integer type);
//
//    public List<TCaptureDefender> queryDefendersByCompereId(
//            @Param("compereId") Long compereId,
//            @Param("nowDate") Date nowDate);
//
//    public List<TCaptureDefender> queryDefendersByPlayerId(
//            @Param("playerId") Long playerId,
//            @Param("nowDate") Date nowDate);
//}
