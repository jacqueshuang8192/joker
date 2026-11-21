package com.hbi.service.schedule;

import com.core.util.ConfigUtil;
import com.core.util.RedisUtil;
import com.core.util.RedisUtil3;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.FreeGameCacheController;
import com.hbi.mapper.TActivityHistoryMapper;
import com.hbi.mapper.TActivityMapper;
import com.hbi.mapper.TFreeGameActivityMapper;
import com.hbi.model.TActivity;
import com.hbi.model.TActivityHistory;
import com.hbi.model.TFreeGameActivity;
import com.hbi.service.game.FreeGameService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import java.util.Date;
import java.util.Map;

/**
 * Create by Mars on 2019/7/20 19:31
 */
@Service
public class scheduleCloseGameService {

    private static final Log info = LogFactory.getLog("closegame");

//    private static final String WAIT_CLOSE_GROUP = "WAIT_CLOSE_GROUP";
//    private static final String WAIT_CLOSE_GROUP_EXCEPTION = "WAIT_CLOSE_GROUP_EXCEPTION";
//    private static final String WAIT_CLOSE_GROUP_LOCK = "WAIT_CLOSE_GROUP_LOCK";

    private static final String WAIT_CLOSE_GROUP = "WAIT_CLOSE_GROUP_NEW";
    private static final String WAIT_CLOSE_GROUP_EXCEPTION = "WAIT_CLOSE_GROUP_EXCEPTION";
    private static final String WAIT_CLOSE_GROUP_LOCK = "WAIT_CLOSE_GROUP_LOCK";

    @Autowired
    private TActivityHistoryMapper activityHistoryMapper;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private TActivityMapper activityMapper;
    @Autowired
    private TFreeGameActivityMapper freeGameActivityMapper;

    @Scheduled(cron="0/2 * * * * ?")
    public void scheduleJisuan() {

        RedisUtil ru = RedisUtil.getRu();
        long lock = ru.incr(WAIT_CLOSE_GROUP_LOCK);
        if (lock <= 1 ) {

            try {

                Map<String, String> closeGroup = ru.hgetall(WAIT_CLOSE_GROUP);
                if (!closeGroup.isEmpty()) {

                    String[] strs;
                    for (String key : closeGroup.keySet()) {
                        String value = closeGroup.get(key);
                        strs = value.split("_");
                        if (StringUtil.isEmpty(strs[0]) || StringUtil.isEmpty(strs[1]) || StringUtil.isEmpty(strs[2]) ) {
                            ru.hset(WAIT_CLOSE_GROUP_EXCEPTION,key,closeGroup.get(key));
                            ru.hdel(WAIT_CLOSE_GROUP,key);
                        }

                        if (strs.length == 3) {

                            long a = System.currentTimeMillis();
                            boolean result = closeGame(strs[0],strs[1],strs[2],ru);
                            long b = System.currentTimeMillis();
                            info.info("result-->" + result + (b-a));

                            if (!result) {
                                ru.hset(WAIT_CLOSE_GROUP_EXCEPTION,key,closeGroup.get(key));
                                ru.del(WAIT_CLOSE_GROUP,key);
                            }else {
                                ru.del(WAIT_CLOSE_GROUP,key);
                            }
                        }
                    }

                }

            }catch (Exception e ) {
                info.info(e);
            }finally {
                ru.del(WAIT_CLOSE_GROUP_LOCK);
            }

        }
    }

    private boolean closeGame(String inviteCode,String gameActivityId,String rounds,RedisUtil ru) {

        ICache cache = null;
        RedisUtil3 ru3 = RedisUtil3.getRu();
        try {
            info.info("inviteCode->" + inviteCode + " activityId=>" + gameActivityId + " round=>" + rounds);
            TFreeGameActivity freeGameActivity = freeGameActivityMapper.selectByPrimaryKey(Long.parseLong(gameActivityId));
            if (!StringUtil.isEmpty(freeGameActivity) ) {
                inviteCode = freeGameActivity.getInviteCode();
            }else {
                return false;
            }

            cache = CacheManager.getCache();
            String userId = cache.hget("GAME_ACTIVITY_" + inviteCode, "creatorId");
            String level = cache.hget("GAME_ACTIVITY_" + inviteCode, "level");
            String paytype = cache.hget("USERPLAY_ROUND_" + gameActivityId, "pay_type");

            if ("AA".equals(paytype)) {
                String cardCount = cache.hget("USERPLAY_ROUND_" + gameActivityId, "cardCount");
                Map<String, String> players = ru3.hgetall("USER_GAME_AA_" + gameActivityId);
                String others = cache.hget("USERPLAY_ROUND_" + gameActivityId, "others");


                // 插入扣房卡历史记录
                for (Map.Entry<String, String> entry : players.entrySet()) {
                    Long uid = Long.parseLong(entry.getKey());
                    //如果是代开就全部扣卡
                    if	("0".equals(others)) {
                        baseCacheController.updateRoomCard(uid,-Integer.parseInt(cardCount));
                    }else {
                        if (!userId.toString().equals(uid.toString())){
                            baseCacheController.updateRoomCard(uid,-Integer.parseInt(cardCount));
                        }
                    }
                    String nickName = cache.hget("PLAYER_"+uid,"nickName");

                    TActivityHistory activityHistory = new TActivityHistory();
                    activityHistory.setActivityId(Long.parseLong(gameActivityId));
                    activityHistory.setUserId(uid);
                    activityHistory.setLevel(Integer.parseInt(level));
                    activityHistory.setGameId(Long.parseLong(level));
                    activityHistory.setRound(Integer.parseInt(rounds));
                    activityHistory.setCardCount(Integer.parseInt(cardCount));
                    activityHistory.setUserNames(nickName);
                    activityHistory.setStartDate(new Date());
                    activityHistoryMapper.insert(activityHistory);
                }
            }

            TActivity activity =  activityMapper.selectByPrimaryKey(Long.parseLong(gameActivityId));
            if (!StringUtil.isEmpty(activity) && activity.getIsDeduct() == 0 ) {
                int cards = activity.getCards();
                long owner_id = activity.getOwnerId();
                if (cards > 0 ) {
                    String groupOwerId = cache.hget("USERPLAY_ROUND_" + gameActivityId, "groupOwerId");
                    String curGroupMasterRoomCard = ConfigUtil.get("curGroupMasterRoomCard");
                    //如果有联盟群主的ID并且配置了群主扣卡,则证明扣除扣的是群主的卡
                    if (StringUtil.isNotEmpty(groupOwerId) && "1".equals(curGroupMasterRoomCard)) {
                        baseCacheController.updateRoomCard(Long.parseLong(groupOwerId),cards);
                    }else {
                        baseCacheController.updateRoomCard(owner_id,cards);
                    }
                }
            }
            activityMapper.updateStatus22(Long.parseLong(gameActivityId));

            String creatorId = cache.hget("GAME_ACTIVITY_" + inviteCode, "creatorId");
            if (StringUtil.isNotEmpty(creatorId)) {
                cache.hdel("GAME_ACTIVITY_"+creatorId,gameActivityId);
            }
            //关闭组局
            cache.del("GAME_ACTIVITY_"+inviteCode);

            //删除组局最大人数
            cache.hdel("GROUP_GAME_MAX_PLAYER_KEY_",gameActivityId);

            //释放InviteCode
            cache.del("FREE_GAME_INVITE_CODE_"+inviteCode);

            //清除组局
            ru.hdel(WAIT_CLOSE_GROUP,gameActivityId);

            //关闭创建房间的时候的Josn
            cache.del("USERPLAY_ROUND_"+gameActivityId);

            //删除AA记录
            ru3.del("USER_GAME_AA_" + gameActivityId);

            //删除续房的activityId
            if (!StringUtil.isEmpty(activity.getExtendActivityId()) ) {
                cache.hdel(FreeGameService.GAME_EXTEND_ACTIVITY,activity.getActivityId()+"" );
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
