package com.hbi.service.schedule;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.util.RedisUtil;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.GroupPlayerCacheController;
import com.hbi.constants.ClubConstants;
import com.hbi.controller.playerGroup.ClubConstant;
import com.hbi.mapper.TPlayerGroupMapper;
import com.hbi.model.TGame;
import com.hbi.service.playerGroup.TPointChangeRecordService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.util.Map;
import java.util.Set;

/**
 * Create by Mars on 2019/7/20 19:32
 */
@Service
public class schedulePointService {

    private static final Log info = LogFactory.getLog("point");

    private static final String USER_POINT_CHANGE_LOCK = "USER_POINT_CHANGE_LOCK";
    private static final String USER_POINT_CHANGE = "USER_POINT_CHANGE";
    private static final String USER_POINT_CHANGE_EXCEPTION = "USER_POINT_CHANGE_EXCEPTION";

    private static final String changeClubIds = "changeClubIds";

    @Autowired
    private TPointChangeRecordService pointChangeRecordService;

    @Autowired
    private TPlayerGroupMapper playerGroupMapper;

    @Autowired
    private BaseCacheController baseCacheController;

    @Scheduled(cron="0/3 * * * * ?")
    public void schedulePoint() {

        RedisUtil ru2 = RedisUtil.getRu();
        long times = ru2.incr(USER_POINT_CHANGE_LOCK);
        if (times <= 1 ) {

            int i = 0;  //防止死循环

            try {
                while (true) {

                    String pointChangeStr = ru2.lindex(USER_POINT_CHANGE,0);
                    if (!StringUtil.isEmpty(pointChangeStr)) {
                        long a = System.currentTimeMillis();
                        boolean result = procPointChange(pointChangeStr,ru2);
                        long b = System.currentTimeMillis();
                        info.info("result--> " + result + (b-a));
                        if (result) {
                            ru2.lpop(USER_POINT_CHANGE);
                        }else {
                            ru2.rpush(USER_POINT_CHANGE_EXCEPTION,pointChangeStr);
                            ru2.lpop(USER_POINT_CHANGE);
                        }

                    }else {
                        break;
                    }

                    if (i >= 50) {
                        break;
                    }
                }
            }catch (Exception e ) {
                info.info(e);
            }finally {
                ru2.del(USER_POINT_CHANGE_LOCK);
            }
        }

    }


//    @Scheduled(cron="0 */1 * * * ?")
//    public void updatePoint2Db() {
//
//        RedisUtil ru2 = RedisUtil.getRu();
//        Set<String> clubIds = ru2.smembers(changeClubIds);
//
//        for (String clubId : clubIds ) {
//            Map<String, String> clubInfos = ru2.hgetall(GroupPlayerCacheController.GROUP_USER_CHIPS_ + clubId);
//            for (Map.Entry<String, String> entry : clubInfos.entrySet() ) {
//                info.info("save point 2 Db-->" + clubId + "--" + entry.getKey() + "---" + entry.getValue());
//                playerGroupMapper.updateClubPoingCount(clubId, entry.getKey(),entry.getValue());
//            }
//        }
//
//        ru2.del(changeClubIds);
//    }

    /**
     * 处理积分变化
     * redis2 rpush  USER_POINT_CHANGE
     *
     * {
     * 	activityId:
     * 	index:
     * 	changeTime:
     * 	level:
     * 	clubId:
     * 	change: [
     *                {
     * 			uid:
     * 			before:
     * 			change:
     * 			now:
     * 			profit:
     * 			//如果有profit before + change + profit = now
     *        }
     * 	]
     * }
     * @param pointChangeStr
     * @return
     */
    private boolean procPointChange(String pointChangeStr, RedisUtil ru2 ) {
        info.info("gameString-->"  + pointChangeStr);
        ICache cache = null;
        try {

            cache = CacheManager.getCache();
            JSONObject changeJson = JSONObject.parseObject(pointChangeStr);
            Integer activityId = changeJson.getInteger("activityId");
            Integer index = changeJson.getInteger("index");
            Integer level = changeJson.getInteger("level");
            Integer clubId = changeJson.getInteger("clubId");
            String time = StringUtil.stampToDate(changeJson.getInteger("changeTime") + "000");
            JSONArray changeUsers = changeJson.getJSONArray("change");

            if (StringUtil.isEmpty(activityId) || StringUtil.isEmpty(clubId) || StringUtil.isEmpty(changeUsers) || changeUsers.size() <= 0 ) {

                return false;

            }

            ru2.sadd(changeClubIds, clubId + "");

            JSONObject remarkInfoJson = new JSONObject();
            TGame g = baseCacheController.queryGameById(Long.parseLong(level + ""), cache);
            if (!StringUtil.isEmpty(g)) {
                remarkInfoJson.put("gameName", g.getName());
            }

            for (int i = 0; i < changeUsers.size(); i++) {
                JSONObject userInfo = changeUsers.getJSONObject(i);
                Integer uid = userInfo.getInteger("uid");
                Integer change = userInfo.getInteger("change");
                Integer now = userInfo.getInteger("now");
                Integer profit = userInfo.getInteger("profit");
                Integer type = userInfo.getInteger("type");
                profit = StringUtil.isEmpty(profit) ? 0 : profit;

                if (StringUtil.isEmpty(uid) || StringUtil.isEmpty(change) || StringUtil.isEmpty(now) || StringUtil.isEmpty(now) ) {
                    return false;
                }
                Integer beform = now - change;

                if (change != 0 ) {
                    Integer changeType = ClubConstants.PointChange_game;
                    String remarkInfo = null;
                    if (!StringUtil.isEmpty(type) && type == 1) {
                        changeType = ClubConstants.PointChange_BaiRenGame;
                        if (remarkInfoJson.size() > 0) {
                            remarkInfo = remarkInfoJson.toJSONString();
                        }
                    }
                    pointChangeRecordService.addOne(clubId, uid, changeType, beform, change, now, level,activityId, index, remarkInfo, time);
                }

                if (profit != 0) {
                    pointChangeRecordService.addOne(clubId, uid, ClubConstants.PointChange_game_profit, now, -profit, now-profit, level,activityId, index, null, time);
                }

            }

            return true;
        }catch (Exception e ) {
            info.info(e);
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        }finally {
            CacheManager.releaseCache(cache);
        }

        return false;
    }

}
