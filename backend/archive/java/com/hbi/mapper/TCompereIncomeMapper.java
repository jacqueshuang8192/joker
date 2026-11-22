//package com.hbi.mapper;
//
//import java.util.Date;
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TCompereIncome;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TCompereIncomeMapper extends Mapper<TCompereIncome> {
//
//    int batchInsertCompereIncomes(List<TCompereIncome> compereIncomes);
//
//    List<String> queryCompereIncomeDatesByDateRange(@Param("compereId") Long compereId,
//            @Param("startDate") String startDate, @Param("endDate") String endDate, @Param("nowDate") String nowDate);
//
//    int addGameMatchExtractIncome(@Param("compereId") Long compereId, @Param("matchExtractIncome") int matchExtractIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addLiveRoomGameExtractIncome(@Param("compereId") Long compereId, @Param("liveRoomGameExtractIncome") int liveRoomGameExtractIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addLiveRoomGiftIncome(@Param("compereId") Long compereId, @Param("liveRoomGiftIncome") int liveRoomGiftIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addDatingIncome(@Param("compereId") Long compereId, @Param("datingIncome") int datingIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addCaptureCompereDefendIncome(@Param("compereId") Long compereId, @Param("captureCompereDefendIncome") int captureCompereDefendIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addCaptureCompereRansomIncome(@Param("compereId") Long compereId, @Param("captureCompereRansomIncome") int captureCompereRansomIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addTaskIncome(@Param("compereId") Long compereId, @Param("taskIncome") int taskIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    int addMiningIncome(@Param("compereId") Long compereId, @Param("miningIncome") int miningIncome,
//            @Param("lastmodifyDate") Date lastmodifyDate, @Param("nowDate") String nowDate);
//
//    TCompereIncome queryCompereIncomeByDate(@Param("compereId") Long compereId, @Param("date") String date);
//}