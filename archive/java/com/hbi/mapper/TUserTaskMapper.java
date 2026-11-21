//package com.hbi.mapper;
//
//import java.util.Date;
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.cache.model.CacheTask;
//import com.hbi.model.TUserTask;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TUserTaskMapper extends Mapper<TUserTask> {
//	List<CacheTask> queryTasksByUserId(@Param("userId") Long userId, @Param("taskId") Long taskId);
//
//	void processTask(@Param("userId") Long userId, @Param("taskId") Long taskId, @Param("amount") Integer amount, @Param("nowDate") Date nowDate);
//
//	List<Long> queryDailyTaskIdByUserId(@Param("userId") Long userId, @Param("nowDate") Date nowDate);
//
//	List<Long> queryOneTimeTaskIdByUserId(@Param("userId") Long userId);
//
//	void deletePreviousUserDailyTasks(@Param("endDate") Date endDate);
//
//}