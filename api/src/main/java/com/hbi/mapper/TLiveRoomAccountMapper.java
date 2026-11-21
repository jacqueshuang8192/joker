//package com.hbi.mapper;
//
//import java.util.Date;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TLiveRoomAccount;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TLiveRoomAccountMapper extends Mapper<TLiveRoomAccount> {
//
//    int updateLiveRoomAccountUseStatus(@Param("compereId") Long compereId, @Param("accountId") Long accountId, @Param("liveStartTime") Date nowDate,
//            @Param("liveLastTime") Float liveLastTime, @Param("determineTime") Date date);
//
//    int releaseLiveRoomAccount(@Param("compereId") Long compereId);
//
//}