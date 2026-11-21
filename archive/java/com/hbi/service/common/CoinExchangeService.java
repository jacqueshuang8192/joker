//package com.hbi.service.common;
//
//import java.util.List;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.core.service.BaseService;
//import com.hbi.mapper.TCoinExchangeMapper;
//import com.hbi.model.TCoinExchange;
//
//@Service
//public class CoinExchangeService extends BaseService<TCoinExchange> {
//
//	@Autowired
//	private TCoinExchangeMapper coinExchangeMapper;
//
//	/**
//	 * 查询宝贝币兑换历史记录
//	 * @param userId
//	 * @param startDate
//	 * @param endDate
//	 * @return
//	 */
//	public List<TCoinExchange> findCoinExchangeHistory(Long userId, String startDate, String endDate) {
//		return coinExchangeMapper.findCoinExchangeHistory(userId, startDate + " 00:00:00", endDate + " 23:59:59");
//	}
//
//}
