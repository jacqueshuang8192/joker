//package com.hbi.mapper;
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Param;
//
//import com.hbi.model.TCoinExchange;
//
//import tk.mybatis.mapper.common.Mapper;
//
//public interface TCoinExchangeMapper extends Mapper<TCoinExchange> {
//
//	List<TCoinExchange> findCoinExchangeHistory(
//			@Param("userId") Long userId,
//			@Param("startDate") String startDate,
//			@Param("endDate") String endDate);
//}