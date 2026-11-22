//package com.hbi.mapper;
//
//import java.util.Date;
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TGameAwardPool;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TGameAwardPoolMapper extends Mapper<TGameAwardPool> {
//
//    List<TGameAwardPool> queryAvailGameAwardPool();
//
//	int updateGameAwardPoolCoinAmount(@Param("coinAmount") Integer coinAmount, @Param("nowDate") Date nowDate);
//
//	int changeGameAwardPoolToRemind(@Param("remindAmount") Integer remindAmount, @Param("nowDate") Date nowDate);
//
//	int changeGameAwardPoolToBreakOut(@Param("fullAmount") Integer fullAmount, @Param("nowDate") Date nowDate);
//}