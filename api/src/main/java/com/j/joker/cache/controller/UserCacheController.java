package com.j.joker.cache.controller;

import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.ICache;
import com.j.joker.cache.cacheWritter.UserCacheLoader;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TUser;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.Date;

/**
 * Created by ceeuoo on 8/1/2016.
 */
@Service
public class UserCacheController {
    @Autowired
    private UserCacheLoader userCacheLoader;
    @Autowired
    private TUserMapper userMapper;

    private static final String USER_MONTH_CARD_KEY = "USER_MONTH_CARD_";

    private static final String MONTH_CARD_CONFIG_KEY = "USER_MONTH_CARD_";

//    private static final String USER_HAS_MONTH_CARD_KEY = "USER_HAS_MONTH_CARD";

    private static final String USER_ALLOWANCE_LEVEL_KEY = "USER_ALLOWANCE_LEVEL";

    private static final String IS_FIRST_CHARGE_KEY = "IS_FIRST_CHARGE";

    private static final String IS_FIRST_LOGIN_KEY = "IS_FIRST_LOGIN";

    /**
     * 连续签到天数
     */
    private static final String SIGN_IN_DAY_KEY = "SIGN_IN_DAY";

    /**
     * 连续签到奖励表
     */
    private static final String CON_SIGN_IN_AWARD_KEY = "CON_SIGN_IN_AWARD";

    private static final String FIELD_DAY_INT = "dayInt";
    private static final String FIELD_SIGN_IN_TIME = "signInTime";

//    public TMonthCard queryMonthCardByUserId(Long userId, Integer cardType, ICache cache) throws Exception {
//        String key = USER_MONTH_CARD_KEY + cardType;
//        String value = cache.hget(key, userId.toString());
//        if (StringUtils.isBlank(value)) {
//            TMonthCard card = userCacheLoader.queryMonthCardById(userId, cardType);
//            if (card != null) {
//                cache.hset(key, userId.toString(), JSON.toJSONString(card));
//            }
//            return card;
//        } else {
//            TMonthCard card = JSON.parseObject(value, TMonthCard.class);
//            return card;
//        }
//    }
//
//    public void addMonthCard(Long userId, TMonthCard card, ICache cache) throws Exception {
//        String key = USER_MONTH_CARD_KEY + card.getType();
//        cache.hset(key, userId.toString(), JSON.toJSONString(card));
//    }
//
//    public Integer getMonthCardStatus(Long userId, Integer cardType, ICache cache) throws Exception {
//        TMonthCard card = queryMonthCardByUserId(userId, cardType, cache);
//        if (card == null) { //没买过月卡
//            return 0;
//        } else {
//            Date now = new Date();
//            if (now.getTime() > card.getEndDate().getTime()) { //已过期
//                return 0;
//            } else {
//                return 1;
//            }
//        }
//    }

//    public void setMonthCardStatus(Long userId, Integer status, ICache cache) {
//        String key = USER_HAS_MONTH_CARD_KEY;
//        cache.hset(key, userId.toString(), status.toString());
//    }

    public Integer getCurrentAllowanceLevel(Long userId, ICache cache) {
        String key = USER_ALLOWANCE_LEVEL_KEY;
        String value = cache.hget(key, userId.toString());
        String timestampStr = cache.hget(key, "timestamp" + userId);
        if (StringUtils.isNotBlank(timestampStr)) {
            Long timestamp = Long.parseLong(timestampStr);
            Long now = new Date().getTime();
            if (now > timestamp) { //已经到了第二天
                cache.hdel(key, userId.toString());
            }
        }
        if (StringUtils.isBlank(value)) { //补助等级是将要领取的等级，没领过为1
            cache.hset(key, userId.toString(), "1");
            cache.hset(key, "timestamp" + userId, getTommorrow0dian().toString());
            return 1;
        } else {
            return Integer.parseInt(value);
        }
    }

    public void increaseAllowanceLevel(Long userId, ICache cache) {
        String key = USER_ALLOWANCE_LEVEL_KEY;
        cache.hincrby(key, userId.toString(), 1);
    }

    public Integer isFirstCharged(Long userId, ICache cache) {
        String key = IS_FIRST_CHARGE_KEY;
        Integer isFirstCharged = 0;
        String value = cache.hget(key, userId.toString());
        if (StringUtils.isBlank(value)) {
            isFirstCharged = userCacheLoader.isFirstCharged(userId);
            if (isFirstCharged == null) {
                isFirstCharged = 0;
            }
            cache.hset(key, userId.toString(), isFirstCharged.toString());
        } else {
            isFirstCharged = Integer.parseInt(value);
        }
        return isFirstCharged;
    }

    public void setFirstCharged(Long userId, ICache cache) {
        String key = IS_FIRST_CHARGE_KEY;
        cache.hset(key, userId.toString(), "1");
    }

//    public List<TMonthCardConfig> queryMonthCardConfigs(ICache cache) {
//        String key = MONTH_CARD_CONFIG_KEY;
//        List<TMonthCardConfig> result = new ArrayList<TMonthCardConfig>();
//        if (cache.exist(key)) {
//            List<String> list = cache.lgetAll(key);
//            for (String s : list) {
//                result.add(JSON.parseObject(s, TMonthCardConfig.class));
//            }
//        } else {
//            result = userCacheLoader.queryMonthCardConfigs();
//            for (TMonthCardConfig c : result) {
//                cache.rpush(key, JSON.toJSONString(c));
//            }
//        }
//        return result;
//    }
//
//    public TMonthCardConfig queryMonthCardConfigByType(Integer type, ICache cache) {
//        List<TMonthCardConfig> list = queryMonthCardConfigs(cache);
//        for (TMonthCardConfig c : list) {
//            if (c.getType().equals(type)) {
//                return c;
//            }
//        }
//        return null;
//    }
//
//    public Date queryMonthCardEndDate(Long userId, Integer type, ICache cache) throws Exception {
//        TMonthCard card = queryMonthCardByUserId(userId, type, cache);
//        if (card == null) {
//            return null;
//        }
//        return card.getEndDate();
//    }

    /**
     * 查询连续签到奖励
     * @param cache
     * @return
     */
//    public List<TGameSignIn> queryConSignInAward(ICache cache) {
//        String key = CON_SIGN_IN_AWARD_KEY;
//        List<TGameSignIn> result;
//        if (cache.exist(key)) {
//            List<String> list = cache.lgetAll(key);
//            result = new ArrayList<TGameSignIn>();
//            for (String s : list) {
//                result.add(JSON.parseObject(s, TGameSignIn.class));
//            }
//        } else {
//            result = userCacheLoader.queryConSignInAward();
//            for (TGameSignIn g : result) {
//                cache.rpush(key, JSON.toJSONString(g));
//            }
//        }
//        return result;
//    }

    /**
     * 查询当前连续签到天数
     * @param userId
     * @param cache
     * @return
     */
    public Integer queryCurSignInDay(Long userId, ICache cache) {
        String key = SIGN_IN_DAY_KEY;
        Integer day = 0;
        if (cache.exist(key)) {
            String temp = cache.hget(key, FIELD_DAY_INT + userId);
            if (StringUtils.isNotBlank(temp)) {
                day = Integer.parseInt(temp);
            }
        }
        return day;
    }

    /**
     * 查询当前连续天数所能获得的房卡
     * @param day 当前连续天数
     * @param cache
     * @return
     */
//    public Integer querySignInAmountBaseData(Integer day, ICache cache) {
//        List<TGameSignIn> list = queryConSignInAward(cache);
//        Integer amount = 0;
//        for (TGameSignIn g : list) {
//            if (g.getDay() > day) {
//                break;
//            }
//            amount = g.getCoin();
//        }
//        return amount;
//    }

    /**
     * 用户是否是连续签到
     * @param userId
     * @param cache
     * @return
     */
    public boolean isConSignIn(Long userId, ICache cache) {
        String key = SIGN_IN_DAY_KEY;
        Calendar yesterdayCalendar = Calendar.getInstance();
        yesterdayCalendar.add(Calendar.DATE, -1);
        if (cache.exist(key)) {
            String temp = cache.hget(key, FIELD_SIGN_IN_TIME + userId);
            Date lastDate = new Date(Long.parseLong(temp));
            Calendar lastCalendar = DateUtils.toCalendar(lastDate);
            if (DateUtils.isSameDay(lastCalendar, yesterdayCalendar)) { //是连续签到
                return true;
            }
        }
        return false;
    }

    /**
     * 查询用户今日签到获得的额外房卡
     * @param userId
     * @param cache
     * @return
     */
//    public Integer queryConSignAmount(Long userId, ICache cache) {
//        String key = SIGN_IN_DAY_KEY;
//        if (isConSignIn(userId, cache)) {
//            Integer day = queryCurSignInDay(userId, cache);
//            Integer amount = querySignInAmountBaseData(day, cache);
//            return amount;
//        }
//        return 0;
//    }

    public Integer isFirstLogin(Long userId, ICache cache) {
        String key = IS_FIRST_LOGIN_KEY;
        Integer isFirstLogin = 0;
        String value = cache.hget(key, userId.toString());
        if (StringUtils.isBlank(value)) {
            isFirstLogin = userCacheLoader.isFirstLogin(userId);
            if (isFirstLogin == null) {
                isFirstLogin = 0;
            }
            cache.hset(key, userId.toString(), isFirstLogin.toString());
        } else {
            isFirstLogin = Integer.parseInt(value);
        }
        return isFirstLogin;
    }

    public void setFirstLogin(Long userId, ICache cache) {
        String key = IS_FIRST_LOGIN_KEY;
        cache.hset(key, userId.toString(), "1");
    }

    public Integer getIsFirstLogin(Long userId, ICache cache) {
        String key = IS_FIRST_LOGIN_KEY;
        String isFirst = cache.hget(key, userId.toString());
        if (StringUtil.isEmpty(isFirst)) {
            TUser tUser = userMapper.findById(userId);
            if (null ==tUser) {
                return 0;
            }else {
                cache.hset(key, userId.toString(),tUser.getFirstLogin().toString());
                return Integer.parseInt(cache.hget(key,userId.toString()));
            }
        }else {
          return Integer.parseInt(isFirst);
        }
    }

    private Long getTommorrow0dian() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        cal.add(Calendar.DAY_OF_YEAR, 1);
        return cal.getTimeInMillis();
    }
}
