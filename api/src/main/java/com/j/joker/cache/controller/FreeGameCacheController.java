package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.RedisUtil;
import com.j.joker.cache.ICache;
import com.j.joker.cache.cacheWritter.FreeGameCacheLoader;
import com.j.joker.model.TFreeGameResult;
import com.j.joker.model.TFreeGameRound;
import com.j.joker.model.TFreeGameSingleresult;
import com.j.joker.model.TFreeGameTotal;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

//import com.j.joker.model.TGameLevelCard;

/**
 * Created by ceeuoo on 8/19/2016.
 */
@Service
public class FreeGameCacheController {
    @Autowired
    private FreeGameCacheLoader freeGameCacheLoader;
    
    @Autowired
    private GameCacheController gameCacheController;

    private static final String FREE_GAME_ROUND_KEY = "FREE_GAME_ROUND";
    private static final String FREE_GAME_RESULT_KEY = "FREE_GAME_RESULT";
    private static final String FREE_GAME_TOTALRANKING_KEY = "FREE_GAME_TOTALRANKING";

    private static final String FREEGAME_USER_TABLE_STATE_PREFIX = "GROUP_USER_TABLE_STATE_";
    private static final String FREEGAME_USER_TABLE_STATE = "STATE";
    private static final String FREE_GAME_ACTIVITY_DISCRIPTION_KEY = "FREE_GAME_ACTIVITY_DISCRIPTION";
    private static final String GROUP_GAME_MAX_PLAYER_KEY = "GROUP_GAME_MAX_PLAYER_KEY_";
    private static final String FREE_GAME_ACTIVITY_PLAYER_COUNT_KEY="FREE_GAME_ACTIVITY_PLAYER_COUNT";
    
    private static final String WAIT_CLOSE_GROUP_KEY = "WAIT_CLOSE_GROUP";

    public void uploadFreeGameRound(TFreeGameRound round, ICache cache) {
        String key = FREE_GAME_ROUND_KEY + round.getActivityId();
        cache.hset(key, round.getRoundIndex().toString(), JSON.toJSONString(round));
    }

    public void uploadFreeGameResult(TFreeGameResult result, ICache cache) {
        String key = FREE_GAME_RESULT_KEY;
        cache.hset(key, result.getActivityId().toString(), JSON.toJSONString(result));
    }

    public TFreeGameRound queryFreeGameRound(Long activityId, Integer roundIndex, ICache cache) {
        String key = FREE_GAME_ROUND_KEY + activityId;
        TFreeGameRound round = null;
        if (cache.exist(key)) {
            String value = cache.hget(key, roundIndex.toString());
            if (StringUtils.isNotBlank(value)) {
                round = JSON.parseObject(value, TFreeGameRound.class);
                return round;
            } else {
                round = freeGameCacheLoader.queryRoundByRoundIndex(activityId, roundIndex);
                if (round != null) {
                    cache.hset(key, roundIndex.toString(), JSON.toJSONString(round));
                }
            }
        } else {
            round = freeGameCacheLoader.queryRoundByRoundIndex(activityId, roundIndex);
            if (round != null) {
                cache.hset(key, roundIndex.toString(), JSON.toJSONString(round));
            }
        }

        return round;
    }


    public TFreeGameResult queryFreeGameResult(Long activityId, ICache cache) {
        String key = FREE_GAME_RESULT_KEY;
        TFreeGameResult result = null;
        if (cache.exist(key)) {
            String value = cache.hget(key, activityId.toString());
            if (StringUtils.isNotBlank(value)) {
                result = JSON.parseObject(value, TFreeGameResult.class);
            }
        } else {
            result = freeGameCacheLoader.queryResultByActivityId(activityId);
            if (result != null) {
                cache.hset(key, activityId.toString(), JSON.toJSONString(result));
            }
        }
        return result;
    }

    public List<TFreeGameRound> querRoundsByActivityId(Long activityId, ICache cache) {
        String key = FREE_GAME_ROUND_KEY + activityId;
        List<TFreeGameRound> list = new ArrayList<TFreeGameRound>();
        if (cache.exist(key)) {
            Map<String, String> map = cache.hgetAll(key);
            Set<String> keySet = map.keySet();
            for (String roundIndex : keySet) {
                list.add(JSONObject.parseObject(map.get(roundIndex), TFreeGameRound.class));
            }
        } else {
            list = freeGameCacheLoader.querRoundsByActivityId(activityId);
            for (TFreeGameRound round : list) {
                cache.hset(key, round.getRoundIndex().toString(), JSON.toJSONString(round));
            }
        }
        return list;
    }
    
    public TFreeGameTotal queryTotalGroupGeRenRank(Long userId,ICache cache) {
        return freeGameCacheLoader.queryTotalGroupGeRenRank(userId);
    }
    public TFreeGameTotal queryTotalGroupGeRenRank2(Long userId,ICache cache) {
        return freeGameCacheLoader.queryTotalGroupGeRenRank2(userId);
    }
   
    public List<TFreeGameTotal> queryTotalGroupRank(Long rankcount,ICache cache) {
        return freeGameCacheLoader.queryTotalGroupRank(rankcount);
    }
    public TFreeGameSingleresult queryGeRenSingleResult(Long userId,String startTime,String endTime,ICache cache) {
        return freeGameCacheLoader.queryGeRenSingleResult(userId,startTime,endTime);
    }
    public TFreeGameSingleresult queryGeRenSingleResult2(Long userId,String startTime,String endTime,ICache cache) {
        return freeGameCacheLoader.queryGeRenSingleResult2(userId,startTime,endTime);
    }
    public List<TFreeGameSingleresult> querySingleResult(Long rankcount,String startTime,String endTime,ICache cache) {
        return freeGameCacheLoader.querySingleResult(rankcount,startTime,endTime);
    }
    public List<TFreeGameResult> queryActivitiesByUserId(Long userId, ICache cache) {
        return freeGameCacheLoader.queryActivitiesByUserId(userId);
    }
    
    public List<TFreeGameResult> queryActivitiesByOwner(Long userId, ICache cache) {
        return freeGameCacheLoader.queryActivitiesByOwner(userId);
    }

    public Integer queryGroupGameStatus(Long userId, Long activityId, ICache cache) {
        String key = FREEGAME_USER_TABLE_STATE_PREFIX + userId;

        String state = RedisUtil.getRu().hget(key, activityId + "");

        if (StringUtils.isBlank(state)) {
            return 0;
        }

        return Integer.parseInt(state);
    }
    
    public void delGroupGameStatus(Long userId, Long activityId, ICache cache) {
    	String key = FREEGAME_USER_TABLE_STATE_PREFIX + userId;
    	
    	RedisUtil.getRu().hdel(key, activityId + "");
    }
    
    public void delWaitCloseGroup(Long activityId, ICache cache) {
    	cache.hdel(WAIT_CLOSE_GROUP_KEY, activityId + "");
    }
    
    public Map<String, String> queryWaitCloseGroup(ICache cache) {
    	return cache.hgetAll(WAIT_CLOSE_GROUP_KEY);
    }

    public void addFreeGameActivityDiscription(Long activityId, String discription, ICache cache) {
        String key = FREE_GAME_ACTIVITY_DISCRIPTION_KEY;
        cache.hset(key, activityId.toString(), discription);
    }

    public String queryFreeGameActivityDiscription(Long activityId, ICache cache) {
        String key = FREE_GAME_ACTIVITY_DISCRIPTION_KEY;
        return cache.hget(key, activityId.toString());
    }

    /**
     * 斗牛游戏查询选择的最大人数
     * @param content
     * @return
     */
    public Integer queryMaxPlayerCount(String content) {
        JSONObject game = JSONObject.parseObject(content);
        Integer count = game.getInteger("peopleNum");
        if (count == null) {
            return 0;
        }
        return count;
    }

    public void updateMaxPlayerCountByActivityId(Long activityId, Integer count, ICache cache) {
        String key = GROUP_GAME_MAX_PLAYER_KEY;
        cache.hset(key, activityId.toString(), count.toString());
    }

    public Integer queryMaxPlayerCountByActivityId(Long activityId, ICache cache) {
        String key = GROUP_GAME_MAX_PLAYER_KEY;
        String content = cache.hget(key, activityId.toString());
        if (StringUtils.isNotBlank(content)) {
            return Integer.parseInt(content);
        }
        return 0;
    }


    public long addFreeGamePlayerCount(String activityId, ICache cache) throws Exception {
        String key = FREE_GAME_ACTIVITY_PLAYER_COUNT_KEY;
        return cache.hincrby(key, activityId, 1);
    }

//    public void reduceFreeGamePlayerCount(Long activityId, Long userId, ICache cache) throws Exception {
//        String key = FREE_GAME_ACTIVITY_PLAYER_COUNT_KEY + activityId;
//        cache.hdel(key, userId.toString());
//    }
}
