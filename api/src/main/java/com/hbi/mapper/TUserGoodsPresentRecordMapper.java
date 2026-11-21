//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TUserGoodsPresentRecord;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TUserGoodsPresentRecordMapper extends Mapper<TUserGoodsPresentRecord> {
//
//	List<TUserGoodsPresentRecord> queryPresentRecordByRoom(@Param("roomId") Long roomId);
//
//	List<TUserGoodsPresentRecord> queryPresentRecordByDateRange(@Param("compereId") Long compereId,
//			@Param("startDate") String startDate, @Param("endDate") String endDate);
//}