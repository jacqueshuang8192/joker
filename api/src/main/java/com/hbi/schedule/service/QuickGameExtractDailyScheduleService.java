//package com.hbi.schedule.service;
//
//import java.util.Calendar;
//import java.util.Date;
//import java.util.List;
//
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.transaction.annotation.Transactional;
//
//import com.hbi.mapper.TQuickGameMapper;
//import com.hbi.mapper.TQuickGameProfitMapper;
//import com.hbi.model.TQuickGame;
//import com.hbi.model.TQuickGameProfit;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.CommonUtil;
//
//public class QuickGameExtractDailyScheduleService {
//
//	private static final Log log = LogFactory.getLog(QuickGameExtractDailyScheduleService.class);
//
//	@Autowired
//	private TQuickGameProfitMapper quickGameProfitMapper;
//	@Autowired
//	private TQuickGameMapper quickGameMapper;
//	@Autowired
//	private GenerateIdService generateIdService;
//
//	@Transactional
//	public void createTomorrowQuickGameProfit() {
//		try {
//			List<TQuickGame> quickGames = quickGameMapper.queryAllValidQuickGames();
//			if (CollectionUtils.isNotEmpty(quickGames)) {
//				Calendar nowDate = Calendar.getInstance();
//				nowDate.add(Calendar.DATE, 1);
//				nowDate.set(nowDate.get(Calendar.YEAR), nowDate.get(Calendar.MONTH), nowDate.get(Calendar.DATE), 0, 0, 0);
//				for (TQuickGame qg : quickGames) {
//					TQuickGameProfit quickGameProfit = new TQuickGameProfit();
//					Long id = generateIdService.generateId(TQuickGameProfit.class.getName());
//					quickGameProfit.setId(id);
//					quickGameProfit.setQuickGameId(qg.getId());
//					quickGameProfit.setPercentage(qg.getExtract());
//					quickGameProfit.setActivityTotalIncome(0);
//					quickGameProfit.setExtractIncome(0);
//					quickGameProfit.setActivityDate(nowDate.getTime());
//					quickGameProfit.setLastModifyDate(new Date());
//					quickGameProfitMapper.insert(quickGameProfit);
//				}
//			}
//		} catch (Exception e) {
//			log.error(CommonUtil.buildErrorLog(e));
//		}
//	}
//
//}
