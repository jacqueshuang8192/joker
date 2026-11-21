//package com.hbi.schedule.service;
//
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
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
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.mapper.TCompereIncomeMapper;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.model.TCompere;
//import com.hbi.model.TCompereIncome;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.CommonUtil;
//
//public class CompereIncomeScheduleService {
//
//	private static final Log log = LogFactory.getLog(CompereIncomeScheduleService.class);
//
//	@Autowired
//	private TCompereMapper compereMapper;
//	@Autowired
//	private TCompereIncomeMapper compereIncomeMapper;
//	@Autowired
//	private CompereCacheController compereCacheController;
//	@Autowired
//	private GenerateIdService generateIdService;
//
//	@Transactional
//	public void deleteCompereYesterdayCacheGiftIncome() {
//		ICache cache = null;
//		try {
//			cache = CacheManager.getCache();
//			compereCacheController.deleteYesterdayGifts(cache);
//		} catch (Exception e) {
//			log.error(CommonUtil.buildErrorLog(e));
//		} finally {
//			if (cache != null) {
//				CacheManager.releaseCache(cache);
//			}
//		}
//	}
//
//	@Transactional
//    public void createCompereTomorrowTotalIncome() {
//        ICache cache = null;
//        try {
//            Calendar calendar = Calendar.getInstance();
//            Date nowDate = calendar.getTime();
//            calendar.add(Calendar.DAY_OF_YEAR, 1);
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            Date incomeDate = sdf.parse(sdf.format(calendar.getTime()));
//            cache = CacheManager.getCache();
//            List<TCompere> comperes = compereMapper.queryAvailComperes();
//            if (CollectionUtils.isNotEmpty(comperes)) {
////                Long incomeId = generateIdService.generateIdForList(TCompereIncome.class.getName(), comperes.size());
//                List<TCompereIncome> compereIncomes = new ArrayList<TCompereIncome>();
//                for (TCompere compere : comperes) {
//                    Long id = generateIdService.generateId();
//                    TCompereIncome compereIncome = new TCompereIncome();
//                    compereIncome.setId(id);
//                    compereIncome.setCompereId(compere.getCompereId());
//                    compereIncome.setMatchExtractIncome(0);
//                    compereIncome.setLiveRoomGiftIncome(0);
//                    compereIncome.setLiveRoomGameExtractIncome(0);
//                    compereIncome.setDatingIncome(0);
//                    compereIncome.setTaskIncome(0);
//                    compereIncome.setMiningIncome(0);
//                    compereIncome.setCaptureCompereDefendIncome(0);
//                    compereIncome.setCaptureCompereRansomIncome(0);
//                    compereIncome.setHasIncome("0");
//                    compereIncome.setIncomeDate(incomeDate);
//                    compereIncome.setLastmodifyDate(nowDate);
//                    compereIncomes.add(compereIncome);
//                }
//                compereIncomeMapper.batchInsertCompereIncomes(compereIncomes);
//
//                String month = new SimpleDateFormat("yyyy-MM").format(calendar.getTime());
//                compereCacheController.batchAddCompereIncome(compereIncomes, month, cache);
//            }
//        } catch (Exception e) {
//            log.error(CommonUtil.buildErrorLog(e));
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//}
