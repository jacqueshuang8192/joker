//package com.hbi.service.common;
//
//import java.util.concurrent.ExecutorService;
//import java.util.concurrent.Executors;
//
//import org.apache.commons.lang.StringUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.utils.CommonUtil;
//import com.hbi.utils.PushUtil;
//
//@Service
//public class LoudSpeakerService {
//
//    private static final Log log = LogFactory.getLog(LoudSpeakerService.class);
//
//	@Autowired
//	private CommonCacheController commonCacheController;
//
//	private ExecutorService loudSpeakerPool = Executors.newFixedThreadPool(10);
//
//
//    public void pushLoudSpeakerMessage() {
//        final ICache cache = CacheManager.getCache();
//        try {
//            while(commonCacheController.getLoudSpeakerCount(cache) > 0) {
//                final String message = commonCacheController.getLoudSpeakerMessage(cache);
//                if (StringUtils.isNotBlank(message)) {
//                    loudSpeakerPool.submit(new Runnable() {
//                        public void run() {
//                            try {
//                                JSONObject json = new JSONObject();
//                                json.put("msg", message);
//                                PushUtil.push(Constants.LOUD_SPEAKER, json);
//
//                                Thread.sleep(3000);
//                            } catch (Exception e) {
//                                log.error(CommonUtil.buildErrorLog(e));
//                            }
//                        }
//                    });
//                }
//
//            }
//        } catch (Exception e) {
//            log.error(CommonUtil.buildErrorLog(e));
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//
//    }
//
//}
