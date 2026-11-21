//package com.hbi.cache.controller;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.serializer.RectangleCodec;
//import com.core.beanUtil.BeanMapUtils;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.OnlineTreasureCacheLoader;
//import com.hbi.cache.redis.RedisLock;
//import com.hbi.model.*;
//import com.hbi.vo.response.onlineTreasure.MyTreasureActivityVo;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.util.*;
//
///**
// * Created by ceeuoo on 4/20/2016.
// */
//@Service
//public class OnlineTreasuerCacheController {
//    @Autowired
//    private OnlineTreasureCacheLoader onlineTreasureCacheLoader;
//
//    /**
//     * 发布状态的夺宝活动列表
//     */
//    private static final String ACTIVE_TREASURE_KEY_PREFIX = "ACTIVE_TREASURE_KEY";
//
//    /**
//     * 往期夺宝活动列表
//     */
//    private static final String PREVIOUCE_TREASURE_KEY_PREFIX = "PREVIOUCE_TREASURE_KEY";
//
//    /**
//     * 最新揭晓活动列表
//     */
//    private static final String DRAW_TREASURE_KEY_PREFIX = "DRAW_TREASURE_KEY";
//
//    private static final String USER_ADDRESS_KEY = "USER_ADDRESS";
//
//    /**
//     * 夺宝活动详情
//     */
//    private static final String TREASURE_ACTIVITY_DETAIL_PREFIX = "TREASURE_ACTIVITY_DETAIL_";
//
//    /**
//     * 用户参与过的夺宝ID缓存
//     */
//    private static final String TREASURE_ACTIVITY_USER_JOINED_PREFIX = "TREASURE_ACTIVITY_USER_JOINED_";
//
//    /**
//     * 活动ID作为key的参与记录
//     */
//    private static final String TREASURE_ACTIVITY_RECORD_BY_ACTIVITYID_PREFIX = "TREASURE_ACTIVITY_RECORD_BY_ACTIVITYID_";
//    private static final String TREASURE_ACTIVITY_RECORD_BY_USERID_PREFIX = "TREASURE_ACTIVITY_RECORD_BY_USERID_";
//
//    public List<TOnlineTreasureActivity> queryActiveTreasureList(ICache cache) throws Exception{
//        String key = ACTIVE_TREASURE_KEY_PREFIX;
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX;
//        List<TOnlineTreasureActivity> list = new ArrayList<TOnlineTreasureActivity>();
//        if(cache.exist(key)) {
//            List<String> strList = cache.lgetAll(key);
//            for (String s : strList) {
//                TOnlineTreasureActivity activity = activityDetail(Long.parseLong(s), cache);
//                list.add(activity);
//            }
//        } else {
//            list = onlineTreasureCacheLoader.queryActiveTreasureList();
//            for (TOnlineTreasureActivity t : list) {
//                cache.rpush(key, t.getId().toString());
//                cache.hmset(detailKey + t.getId(), BeanMapUtils.toMapBySelective(t));
//            }
//        }
//        return list;
//    }
//
//    public List<TOnlineTreasureActivity> drawActivities(ICache cache) throws Exception{
//        String key = DRAW_TREASURE_KEY_PREFIX;
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX;
//        List<TOnlineTreasureActivity> list = new ArrayList<TOnlineTreasureActivity>();
//        if(cache.exist(key)) {
//            List<String> strList = cache.lgetAll(key);
//            for (String s : strList) {
//                TOnlineTreasureActivity activity = activityDetail(Long.parseLong(s), cache);
//                list.add(activity);
//            }
//        } else {
//            list = onlineTreasureCacheLoader.drawActivities();
//            for (TOnlineTreasureActivity t : list) {
//                cache.rpush(key, t.getId().toString());
//                cache.hmset(detailKey + t.getId(), BeanMapUtils.toMapBySelective(t));
//            }
//        }
//        return list;
//    }
//
//    public List<TOnlineTreasureActivity> queryPreviousTreasureList(ICache cache) throws Exception{
//        String key = PREVIOUCE_TREASURE_KEY_PREFIX;
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX;
//        List<TOnlineTreasureActivity> list = new ArrayList<TOnlineTreasureActivity>();
//        if(cache.exist(key)) {
//            List<String> strList = cache.lgetAll(key);
//            for (String s : strList) {
//                TOnlineTreasureActivity activity = activityDetail(Long.parseLong(s), cache);
//                list.add(activity);
//            }
//        } else {
//            list = onlineTreasureCacheLoader.queryPreviousTreasureList();
//            for (TOnlineTreasureActivity t : list) {
//                cache.rpush(key, t.getId().toString());
//                cache.hmset(detailKey + t.getId(), BeanMapUtils.toMapBySelective(t));
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 查询最近五个往期揭晓名单
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<TOnlineTreasureActivity> queryNearestPreviouceActivities(ICache cache) throws Exception{
//        String key = PREVIOUCE_TREASURE_KEY_PREFIX;
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX;
//        List<TOnlineTreasureActivity> list = new ArrayList<TOnlineTreasureActivity>();
//        if(cache.exist(key)) {
//            List<String> strList = cache.lgetAll(key);
//            if (strList.size() > 5) {
//                strList = strList.subList(strList.size() - 5, strList.size());
//            }
//            for (String s : strList) {
//                TOnlineTreasureActivity activity = activityDetail(Long.parseLong(s), cache);
//                list.add(activity);
//            }
//        } else {
//            list = queryPreviousTreasureList(cache);
//            if (list.size() > 5) {
//                list = list.subList(list.size() - 5, list.size());
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 夺宝详情
//     * @param activityId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public TOnlineTreasureActivity activityDetail(Long activityId, ICache cache) throws Exception{
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX + activityId;
//        if (cache.exist(detailKey)) {
//            Map<String, String> map = cache.hgetAll(detailKey);
//            TOnlineTreasureActivity activity = (TOnlineTreasureActivity)BeanMapUtils.toBeanBySelective(TOnlineTreasureActivity.class, map);
//            return activity;
//        } else {
//            TOnlineTreasureActivity activity = onlineTreasureCacheLoader.activityDetail(activityId);
//            cache.hmset(detailKey, BeanMapUtils.toMapBySelective(activity));
//            return activity;
//        }
//    }
//
//    public void addActivityDetail(TOnlineTreasureActivity activity, ICache cache) throws Exception{
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX + activity.getId();
//        cache.hmset(detailKey, BeanMapUtils.toMapBySelective(activity));
//    }
//
//    public List<String> queryMyCodeByActivityId(Long activityId, Long userId, ICache cache) {
//        String key = TREASURE_ACTIVITY_RECORD_BY_ACTIVITYID_PREFIX + activityId;
//        List<String> codes = new ArrayList<String>();
//        List<String> records = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(records)) {
//            for (String record : records) {
//                TOnlineTreasureRecord r = JSON.parseObject(record, TOnlineTreasureRecord.class);
//                if (r.getUserId().equals(userId)) {
//                    codes.add(r.getCode());
//                }
//            }
//        }
//        return codes;
//    }
//
//    public void updateActivityField(Long activityId, String filed, String value, ICache cache) {
//        String detailKey = TREASURE_ACTIVITY_DETAIL_PREFIX + activityId;
//        cache.hset(detailKey, filed, value);
//    }
//
//    public void addActiveActivity(Long activityId, ICache cache) {
//        String key = ACTIVE_TREASURE_KEY_PREFIX;
//        if (cache.exist(key)) {
//            cache.rpush(key, activityId.toString());
//        }
//    }
//
//    public void removeActiveActivity(Long activityId, ICache cache) {
//        String key = ACTIVE_TREASURE_KEY_PREFIX;
//        cache.lrem(key, 0, activityId.toString());
//    }
//
//    public void addToDrawActivities(Long activityId, ICache cache) {
//        String key = DRAW_TREASURE_KEY_PREFIX;
//        if (cache.exist(key)) {
//            cache.rpush(key, activityId.toString());
//        }
//    }
//
//    public void removeDrawActivity(Long activityId, ICache cache) {
//        String key = DRAW_TREASURE_KEY_PREFIX;
//        cache.lrem(key, 0, activityId.toString());
//    }
//
//    public void addToPreviousActivities(Long activityId, ICache cache) {
//        String key = PREVIOUCE_TREASURE_KEY_PREFIX;
//        if (cache.exist(key)) {
//            cache.rpush(key, activityId.toString());
//        }
//    }
//
//    /**
//     * 参与夺宝
//     * @param activityId
//     * @param jewelAmount
//     * @param cache
//     */
//    public void joinActivity(Long activityId, Integer jewelAmount, ICache cache) {
//        String key = TREASURE_ACTIVITY_DETAIL_PREFIX + activityId;
//        if (cache.exist(key)) {
//            cache.hincrby(key, "selledAmount", jewelAmount);
//        }
//    }
//
//    public void addRecord(TOnlineTreasureRecord record, ICache cache) {
//        addRecordByActivityId(record, cache);
//        addRecordByUserId(record, cache);
//    }
//
//    public void addRecordByActivityId(TOnlineTreasureRecord record, ICache cache) {
//        String key = TREASURE_ACTIVITY_RECORD_BY_ACTIVITYID_PREFIX + record.getActivityId();
//        if (cache.exist(key)) {
//            cache.rpush(key, JSON.toJSONString(record));
//        }
//    }
//
//    public List<TOnlineTreasureRecord> queryRecordsByActivityId(Long activityId, ICache cache) {
//        String key = TREASURE_ACTIVITY_RECORD_BY_ACTIVITYID_PREFIX + activityId;
//        List<String> list = cache.lgetAll(key);
//        List<TOnlineTreasureRecord> records = new ArrayList<TOnlineTreasureRecord>();
//        if (CollectionUtils.isNotEmpty(list)) {
//            for (String s : list) {
//                TOnlineTreasureRecord r = JSON.parseObject(s, TOnlineTreasureRecord.class);
//                records.add(r);
//            }
//        } else {
//            records = onlineTreasureCacheLoader.queryRecordsByActivityId(activityId);
//            for (TOnlineTreasureRecord r : records) {
//                cache.rpush(key, JSON.toJSONString(r));
//            }
//        }
//        return records;
//    }
//
//    public void addRecordByUserId(TOnlineTreasureRecord record, ICache cache) {
//        String key = TREASURE_ACTIVITY_RECORD_BY_USERID_PREFIX + record.getUserId();
//        if (cache.exist(key)) {
//            cache.rpush(key, JSON.toJSONString(record));
//        }
//    }
//
//    public void addAddress(TOnlineTreasureAddress address, ICache cache) {
//        String key = USER_ADDRESS_KEY + address.getUserId();
//        if(cache.exist(key)) {
//            cache.hset(key, address.getId().toString(), JSON.toJSONString(address));
//        }
//    }
//
//    public List<TOnlineTreasureAddress> queryAddress(Long userId, ICache cache) {
//        String key = USER_ADDRESS_KEY + userId;
//        List<TOnlineTreasureAddress> list = new ArrayList<TOnlineTreasureAddress>();
//        if(cache.exist(key)) {
//            Map<String, String> map = cache.hgetAll(key);
//            Set<String> keySet = map.keySet();
//            for (String k : keySet) {
//                String s = map.get(k);
//                list.add(JSON.parseObject(s, TOnlineTreasureAddress.class));
//            }
//        } else {
//            list = onlineTreasureCacheLoader.queryAddress(userId);
//            for (TOnlineTreasureAddress a : list) {
//                cache.hset(key, a.getId().toString(), JSON.toJSONString(a));
//            }
//        }
//        return list;
//    }
//
//    public TOnlineTreasureAddress queryAddressById(Long addressId, Long userId, ICache cache) {
//        String key = USER_ADDRESS_KEY + userId;
//        String str = cache.hget(key, addressId.toString());
//        if (StringUtils.isBlank(str)) {
//            queryAddress(userId, cache);
//        }
//        str = cache.hget(key, addressId.toString());
//        if (StringUtils.isBlank(str)) {
//            return null;
//        }
//        return JSON.parseObject(str, TOnlineTreasureAddress.class);
//    }
//
//    public List<MyTreasureActivityVo> queryMyActivities(Long userId, ICache cache) throws Exception {
//        String key = TREASURE_ACTIVITY_RECORD_BY_USERID_PREFIX + userId;
//        List<MyTreasureActivityVo> list = new ArrayList<MyTreasureActivityVo>();
//        List<TOnlineTreasureRecord> records = new ArrayList<TOnlineTreasureRecord>();
//        List<String> recordsStr = cache.lgetAll(key);
//        Set<Long> set = new HashSet<Long>();
//        if (CollectionUtils.isNotEmpty(recordsStr)) {
//            for (String re : recordsStr) {//遍历用户所有参与记录
//                TOnlineTreasureRecord record = JSON.parseObject(re, TOnlineTreasureRecord.class);
//                set.add(record.getActivityId());
//                records.add(record);
//            }
//        } else {
//            List<TOnlineTreasureRecord> newRe = onlineTreasureCacheLoader.queryRecordsByUserId(userId);
//            for (TOnlineTreasureRecord r : newRe) {//遍历用户所有参与记录
//                set.add(r.getActivityId());
//                records.add(r);
//                cache.rpush(key, JSON.toJSONString(r));
//            }
//        }
//        for (Long activityId : set) {//遍历用户所有参与的夺宝活动
//            TOnlineTreasureActivity activity = activityDetail(activityId, cache);
//            Integer times = 0;
//            MyTreasureActivityVo vo = new MyTreasureActivityVo();
//            vo.setActivity(activity);
//            for (TOnlineTreasureRecord r : records) {
//                if (r.getActivityId().equals(activityId)) {
//                    times += r.getJewelAmount();
//                }
//            }
//            vo.setTimes(times);
//            list.add(vo);
//        }
//        return list;
//    }
//
//    public boolean lockActivity(Long activityId) {
//        String key = TREASURE_ACTIVITY_DETAIL_PREFIX + activityId;
//        RedisLock lock = new RedisLock(key);
//        return lock.lock(1000 * 5); // 等待超时时间5秒
//    }
//
//    public void unlockActivity(Long activityId) {
//        String key = TREASURE_ACTIVITY_DETAIL_PREFIX + activityId;
//        RedisLock lock = new RedisLock(key);
//        lock.unlock();
//    }
//}
