//package com.hbi.schedule.service;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.schedule.core.ScheduleJobInf;
//import com.hbi.service.common.CaptureCompereService;
//import com.hbi.utils.CommonUtil;
//
//@Service
//public class UnProtectCompereService implements ScheduleJobInf {
//    private static final Log log = LogFactory.getLog(UnProtectCompereService.class);
//
//    @Autowired
//    private CaptureCompereService captureCompereService;
//
//    @Override
//    public void executeSchedule(int methodType, Object obj) {
//        ICache cache = CacheManager.getCache();
//        try {
//            Long compereId = (Long)obj;
//            captureCompereService.unProtectCompere(compereId);
//        } catch (Exception e) {
//            log.error(CommonUtil.buildErrorLog(e));
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//}
