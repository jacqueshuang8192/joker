//package com.hbi.schedule.service;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.MiningCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TSocietyMapper;
//import com.hbi.model.TMiningGame;
//import com.hbi.schedule.core.ScheduleJobInf;
//import com.hbi.utils.CommonUtil;
//
//@Service
//public class BoomMineScheduleService implements ScheduleJobInf {
//    private static final Log log = LogFactory.getLog(BoomMineScheduleService.class);
//
//    @Autowired
//    private MiningCacheController miningCacheController;
//    @Autowired
//    private TSocietyMapper societyMapper;
//
//    @Override
//    public void executeSchedule(int methodType, Object obj){
//        ICache cache = CacheManager.getCache();
//        try {
//            String str = (String) obj;
//            Long societyId = Long.parseLong(str);
////            societyService.changeSocietyStatus(societyId, 0L, Constants.SOCIETY_VALID);
//            //公会状态修改为爆矿
//            societyMapper.updateSocietyStatus(societyId, Constants.SOCIETY_VALID);
//
//            TMiningGame game = new TMiningGame();
//            game.setSocietyId(societyId);
//            miningCacheController.boomMine(game, Constants.SOCIETY_VALID, cache);
//        } catch (Exception e) {
//            log.error(CommonUtil.buildErrorLog(e));
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//}
