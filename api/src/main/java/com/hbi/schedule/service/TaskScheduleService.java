//package com.hbi.schedule.service;
//
//import java.util.Calendar;
//import java.util.Set;
//
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.mapper.TUserTaskMapper;
//import com.hbi.utils.CommonUtil;
//
//public class TaskScheduleService {
//
//    private static final Log log = LogFactory.getLog(TaskScheduleService.class);
//
//    @Autowired
//    private TUserTaskMapper userTaskMapper;
//    @Autowired
//    private CommonCacheController commonCacheController;
//
//    /**
//     * 删除三天前的每日任务
//     * @throws Exception
//     */
//    public void deletePreviousUserDailyTasks() throws Exception {
//        ICache cache = null;
//        try {
//            Calendar calendar = Calendar.getInstance();
//            calendar.add(Calendar.DAY_OF_YEAR, -3);
//            userTaskMapper.deletePreviousUserDailyTasks(calendar.getTime());
//
//            //删除缓存
//            cache = CacheManager.getCache();
//            Set<String> keys = cache.keys("TASK_[1234567890]*");
//            if (CollectionUtils.isNotEmpty(keys)) {
//                for (String key : keys) {
//                    cache.del(key);
//                }
//            }
//        } catch (Exception e) {
//            log.error(CommonUtil.buildErrorLog(e));
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//
//    }
//
//}
