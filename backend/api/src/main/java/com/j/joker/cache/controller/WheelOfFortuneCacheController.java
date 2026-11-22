package com.j.joker.cache.controller;

import com.j.joker.core.util.DateUtils;
import com.j.joker.cache.ICache;
import org.apache.commons.lang.StringUtils;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * Created by dzesla on 2017/2/20.
 */
@Service
public class WheelOfFortuneCacheController {

    private static final String ROLL_TIME_KEY = "ROLL_TIME";

    /**
     * 检查时间戳，判断是否能抽奖，如果能抽奖，更新时间戳
     * @param userId
     * @param cache
     * @return
     */
    public boolean checkAndSetRollTime(Long userId, ICache cache) {
        String key = ROLL_TIME_KEY;
        String lastStr = cache.hget(key, userId.toString());
        if (StringUtils.isBlank(lastStr)) {
            cache.hset(key, userId.toString(), String.valueOf(new Date().getTime()));
            return true;
        }
        Long lastRollTime =Long.parseLong(lastStr);
        Date date = new Date(lastRollTime);
        if (DateUtils.isSameDate(date, new Date())) {
            return false;
        }
        cache.hset(key, userId.toString(), String.valueOf(new Date().getTime()));
        return true;
    }

    public void cleanRollTime(Long userId, ICache cache) {
        String key = ROLL_TIME_KEY;
        cache.hdel(key, userId.toString());
    }
}
