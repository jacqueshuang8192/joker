//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TGameAwardPoolApplyRecord;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TGameAwardPoolApplyRecordMapper extends Mapper<TGameAwardPoolApplyRecord> {
//
//    List<TGameAwardPoolApplyRecord> queryApplyRecordByPoolIdDistinctUserId(@Param("gameAwardPoolId") Long gameAwardPoolId);
//
//}