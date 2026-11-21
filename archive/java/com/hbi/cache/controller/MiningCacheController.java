//package com.hbi.cache.controller;
//
//import java.util.*;
//
//import com.hbi.model.TVipLevel;
////import com.sun.tools.internal.jxc.ap.Const;
//import org.apache.commons.lang.StringUtils;
////import org.apache.tools.ant.util.ContainerMapper;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.util.DateUtils;
//import com.core.util.JSONUtil;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.SocietyCacheLoader;
//import com.hbi.cache.model.CacheCompereListProfile;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheSocietyListProfile;
//import com.hbi.cache.model.CacheSocietyProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.cache.model.CacheUserProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TMiningGameMapper;
//import com.hbi.model.TMiningGame;
//import com.hbi.model.TMiningGameSection;
//import com.hbi.utils.InfServerException;
//import tk.mybatis.mapper.entity.Example;
//
//import javax.annotation.PostConstruct;
//
//@Service
//public class MiningCacheController {
//    /**
//     * 公会详情
//     */
//    private static String SOCIETY_KEY = "SOCIETY_";
//
//    private static final String SOCIETY_FIELD_CUMULATION = "cumulation";
//
//    private static final String SOCIETY_FIELD_ACTIVITY_ID = "activityId";
//
//    private static final String SOCIETY_FIELD_STATUS = "status";
//
//    private static final String SOCIETY_FIELD_LONGITUDE = "longitude";
//
//    private static final String SOCIETY_FIELD_LATITUDE = "latitude";
//
//    /**
//     * 公会列表
//     */
//    private static String SOCIETIES = "SOCIETIES_";
//
//    /**
//     * 攻击玩家缓存
//     */
//    private static String MINE_ATTACKER_KEY = "MINE_ATTACKER_";
//
//    /**
//     * 防守玩家缓存
//     */
//    private static String MINE_DEFENDER_KEY = "MINE_DEFENDER_";
//
//    /**
//     * 可抢矿活动列表
//     */
//    private static final String MINING_ACTIVITY = "MINING_ACTIVITY_";
//
//    /**
//     * 矿位列表
//     */
//    private static final String MINING_SEG_LIST = "MINING_SEG_LIST_";
//
//    /**
//     * 玩家剩余采矿次数
//     */
//    private static final String LEFT_DIG_COUNT = "LEFT_DIG_COUNT_";
//
//    /**
//     * 一次采矿剩余挖次数
//     */
//    private static final String LEFT_DIG_PER_ROUND = "LEFT_DIG_PER_ROUND_";
//
//    /**
//     * 采矿活动攻击人数
//     */
//    private static final String ACTIVITY_ATTACKER_COUNT = "ACTIVITY_ATTACKER_COUNT_";
//
//    /**
//     * 单日收益
//     */
//    private static final String DAY_PROFIT = "DAY_PROFIT_";
//
//    /**
//     * 挖一次矿收益
//     */
//    private static final String DIG_PROFIT = "DIG_PROFIT";
//
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private TMiningGameMapper miningGameMapper;
//    @Autowired
//    private SocietyCacheController societyCacheController;
//
//    /**
//     * 根据采矿活动id查询矿位
//     *
//     * @param activityId
//     * @param cache
//     * @return
//     */
//    public List<TMiningGameSection> queryMineSegs(Long activityId,
//            ICache cache) throws Exception {
//        String key = MINING_SEG_LIST + activityId;
//        List<TMiningGameSection> list;
//        if (!cache.exist(key)) { //矿坑不存在
//            TMiningGame activity = queryMiningGameByActivityId(cache, activityId);
//            Long mineLeft = activity.getRealAmount();
//            initMineSection(activityId, mineLeft, cache);
//        }
//        Map<String, String> keyValues = cache.hgetAll(key);
//        list = new ArrayList<TMiningGameSection>();
//        for (String keyT : keyValues.keySet()) {
//            list.add(JSON.parseObject(keyValues.get(keyT),
//                    TMiningGameSection.class));
//        }
//        return list;
//    }
//
//    public TMiningGameSection queryMineSegById(Long activityId, Long segId,
//            ICache cache) throws Exception {
//        List<TMiningGameSection> list = queryMineSegs(activityId, cache);
//        for (TMiningGameSection s : list) {
//            if (s.getMineSectionId() == segId) {
//                return s;
//            }
//        }
//        return null;
//    }
//
////    @PostConstruct
////    public void init() {
////        System.out.println("miningCacheController initialized.");
////        resetMiningSegs();
////    }
////
////    public void resetMiningSegs() {
////
////    }
//
//    /**
//     * 查询采矿活动当前攻击人数
//     *
//     * @param activityId
//     * @param cache
//     * @return
//     */
//    public Integer queryMiningActivityAttackerCount(Long activityId,
//            ICache cache) {
//        String key = ACTIVITY_ATTACKER_COUNT + activityId;
//
//        String miningKey = MINING_ACTIVITY;
//        if (StringUtils.isBlank(cache.hget(miningKey, activityId.toString()))) {
//            throw new InfServerException(Constants.RETURN_CODE_MINING_ACTIVITY_NOT_EXIST, "抢矿活动不存在！");
//        }
//
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            return 0;
//        } else {
//            return map.size();
//        }
//    }
//
//    /**
//     * 查询攻击玩家信息
//     *
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public CachePlayerProfile queryAttacker(Long playerId, ICache cache)
//            throws Exception {
//        String key = MINE_ATTACKER_KEY;
//        String field = playerId.toString();
//        String attacker = cache.hget(key, field);
//        if (StringUtils.isEmpty(attacker)) {
//            CachePlayerProfile profile = playerCacheController
//                    .queryPlayerDetail(playerId, cache, false, false);
//
//            cache.hset(key, field, JSONUtil.parseJSONContainsNull(profile));
//            return profile;
//        } else {
//            return JSONObject.parseObject(attacker, CachePlayerProfile.class);
//        }
//    }
//
//    /**
//     * 查看防守玩家信息
//     *
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
////    public CachePlayerProfile queryDefender(Long playerId, ICache cache)
////            throws Exception {
////        String key = MINE_DEFENDER_KEY + playerId;
////        String field = playerId.toString();
////        String defender = cache.hget(key, field);
////        if (StringUtils.isEmpty(defender)) {
////            CachePlayerProfile profile = playerCacheController
////                    .queryPlayerDetail(playerId, cache, false, false);
////            cache.hset(key, field, JSON.toJSONString(profile));
////            return profile;
////        } else {
////            return JSONObject.parseObject(defender, CachePlayerProfile.class);
////        }
////    }
//
//    /**
//     * 查询采矿活动列表
//     *
//     * @param cache
//     * @return
//     * @throws Exception
//     * @throws NumberFormatException
//     */
//    public List<TMiningGame> querySocietyMineActivity(ICache cache)
//            throws Exception {
//        String key = MINING_ACTIVITY;
//        Map<String, String> keyValues = cache.hgetAll(key);
//        List<TMiningGame> list;
//        if (keyValues.isEmpty()) {
//            Example example = new Example(TMiningGame.class);
//            Date now = new Date();
//            Example.Criteria criteria = example.createCriteria();
//            criteria.andLessThan("startDate", now);
//            criteria.andGreaterThan("endDate", now);
//            list = miningGameMapper.selectByExample(example);
////            list = miningGameMapper.select(new TMiningGame());
//
//            Integer mineLocationCount = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.MINE_LOCATION_COUNT, cache));
//
//            Map<String, String> newMap = new HashMap<String, String>();
//            for (TMiningGame profile : list) {
//
//                // 最大抢夺人数
//                profile.setMaxAttackNum(mineLocationCount);
//
//                newMap.put(profile.getActivityId().toString(),
//                        JSON.toJSONString(profile));
//
//                // 防守人数
//                List<CacheUserProfile> userList = societyCacheController.querySocietyOnlineUsers(
//                        profile.getSocietyId(), cache);
//                Iterator<CacheUserProfile> iterator = userList.iterator();
//                while (iterator.hasNext()) {
//                    CacheUserProfile player = iterator.next();
//                    if (player.getLife() == null || player.getLife() == 0) {
//                        iterator.remove();
//                    }
//                }
//                profile.setDefenseNum(userList.size());
//
//                // 抢夺人数
//                Integer attackerCount = queryMiningActivityAttackerCount(
//                        profile.getActivityId(), cache);
//                profile.setAttackerNum(attackerCount);
//
//                // 经纬度
//                String longituteStr = societyCacheController.querySocietyField(profile.getSocietyId(),
//                        cache, SOCIETY_FIELD_LONGITUDE);
//                String latitudeStr = societyCacheController.querySocietyField(profile.getSocietyId(),
//                        cache, SOCIETY_FIELD_LATITUDE);
//                Double longitute = 0D;
//                Double latitude = 0D;
//                if (StringUtils.isNotBlank(longituteStr)) {
//                    longitute = Double.parseDouble(longituteStr);
//                }
//                if (StringUtils.isNotBlank(latitudeStr)) {
//                    latitude = Double.parseDouble(latitudeStr);
//                }
//                profile.setLongitude(longitute);
//                profile.setLatitude(latitude);
//            }
//            if (!newMap.isEmpty()) {
//                cache.hmset(key, newMap);
//            }
//        } else {
//            list = new ArrayList<TMiningGame>();
//
//            for (String keyT : keyValues.keySet()) {
//                TMiningGame profile = JSON.parseObject(keyValues.get(keyT),
//                        TMiningGame.class);
//                // 防守人数
//                List<CacheUserProfile> userList = societyCacheController.querySocietyOnlineUsers(
//                        profile.getSocietyId(), cache);
//                Iterator<CacheUserProfile> iterator = userList.iterator();
//                while (iterator.hasNext()) {
//                    CacheUserProfile player = iterator.next();
//                    if (player.getLife() == null || player.getLife() == 0) {
//                        iterator.remove();
//                    }
//                }
//                profile.setDefenseNum(userList.size());
//
//                // 抢夺人数
//                Integer attackerCount = queryMiningActivityAttackerCount(
//                        profile.getActivityId(), cache);
//                profile.setAttackerNum(attackerCount);
//
//                // 经纬度
//                String longituteStr = societyCacheController.querySocietyField(profile.getSocietyId(),
//                        cache, SOCIETY_FIELD_LONGITUDE);
//                String latitudeStr = societyCacheController.querySocietyField(profile.getSocietyId(),
//                        cache, SOCIETY_FIELD_LATITUDE);
//                Double longitute = 0D;
//                Double latitude = 0D;
//                if (StringUtils.isNotBlank(longituteStr)) {
//                    longitute = Double.parseDouble(longituteStr);
//                }
//                if (StringUtils.isNotBlank(latitudeStr)) {
//                    latitude = Double.parseDouble(latitudeStr);
//                }
//                profile.setLongitude(longitute);
//                profile.setLatitude(latitude);
//                list.add(profile);
//            }
//        }
//        Iterator<TMiningGame> iterator = list.iterator();
//        while (iterator.hasNext()) {
//            TMiningGame t = iterator.next();
//            if (!DateUtils.isBetweenTime(t.getStartDate(), t.getEndDate())) {
//                iterator.remove();
//            } else {
//                t.setSocietyName(
//                        societyCacheController.querySocietyField(t.getSocietyId(), cache, "name"));
//                t.setPlayerNum(Integer.parseInt(societyCacheController.querySocietyField(
//                        t.getSocietyId(), cache, "playerNum")));
//                t.setCompereNum(Integer.parseInt(societyCacheController.querySocietyField(
//                        t.getSocietyId(), cache, "compereNum")));
//                t.setPhoto(
//                        societyCacheController.querySocietyField(t.getSocietyId(), cache, "photoUrl"));
//                if (t.getCompereNum() != null && t.getCompereNum() != 0) {
//                    List<CacheCompereProfile> comperes = societyCacheController.querySocietyComperes(
//                            t.getSocietyId(), cache);
//                    if (comperes.size() > 0) {
//                        CacheCompereProfile compere = comperes.get(0);
//                        for (CacheCompereProfile c : comperes) {
//                            if (c.getLevel() > compere.getLevel()) {
//                                compere = c;
//                            }
//                        }
//                        t.setCompereName(compere.getNickName());
//                    }
//                }
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 通过抢矿活动id查询抢矿活动
//     *
//     * @param cache
//     * @param activityId
//     * @return
//     * @throws Exception
//     * @throws NumberFormatException
//     */
//    public TMiningGame queryMiningGameByActivityId(ICache cache,
//            Long activityId) throws NumberFormatException, Exception {
//        List<TMiningGame> list = querySocietyMineActivity(cache);
//        for (TMiningGame tMiningGame : list) {
//            if (activityId.equals(tMiningGame.getActivityId())) {
//                return tMiningGame;
//            }
//        }
//        return null;
//    }
//
//    /**
//     * 查询采矿活动攻击人员列表
//     *
//     * @param activityId
//     * @return
//     * @throws Exception
//     */
//    public List<CacheUserProfile> queryAttackerList(Long activityId,
//            ICache cache) throws Exception {
//        String key = ACTIVITY_ATTACKER_COUNT + activityId;
//        Map<String, String> map = cache.hgetAll(key);
//        Set<String> keySet = map.keySet();
//        List<CacheUserProfile> list = new ArrayList<CacheUserProfile>();
//        for (String string : keySet) {
//            Long userId = Long.parseLong(map.get(string));
//            CachePlayerProfile player = playerCacheController
//                    .queryPlayerDetail(userId, cache, false, false);
//            if (player == null) {
//                CacheCompereProfile compere = compereCacheController
//                        .getCompereDetail(userId.toString(), cache, false, false);
//                if (compere != null) {
//                    list.add(compere);
//                }
//            } else {
//                list.add(player);
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 查询玩家当日剩余挖矿次数
//     *
//     * @param userId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public Integer queryUserLeftDigCount(Long userId, ICache cache, String userType)
//            throws Exception {
//        String key = LEFT_DIG_COUNT;
//        String countStr = cache.hget(key, userId.toString());
//        if (StringUtils.isEmpty(countStr)) {
//            Integer count = queryUserTotalDigCount(userId, cache, userType);
//            cache.hset(key, userId.toString(), count.toString());
//            return count;
//        } else {
//            return Integer.parseInt(countStr);
//        }
//    }
//
//    public Integer queryUserTotalDigCount(Long userId, ICache cache, String userType)
//            throws Exception {
//        Integer count = 2;
//        if (userType.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//            CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//            TVipLevel level = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//            if (level != null) {
//                count = level.getMaxDigCount();
//            }
//        }
//        return count;
//    }
//
//    public Integer queryLeftDigPerRound(Long userId, ICache cache)
//            throws Exception {
//        String key = LEFT_DIG_PER_ROUND;
//        String countString = cache.hget(key, userId.toString());
//        if (StringUtils.isEmpty(countString)) {
//            String str = baseCacheController.queryConfig(Constants.MAX_FIGHT_ROUND, cache);
//            cache.hset(key, userId.toString(), str);
//            return Integer.parseInt(str);
//        } else {
//            return Integer.parseInt(countString);
//        }
//    }
//
//    /**
//     * 查询玩家当日收益
//     *
//     * @param userId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public Long queryUserDayProfit(Long userId, ICache cache) throws Exception {
//        String key = DAY_PROFIT + userId;
//        String profit = cache.get(key);
//        if (StringUtils.isEmpty(profit)) {
//            Long temp = 0L;
//            cache.set(key, temp.toString());
//            return temp;
//        }
//        return Long.parseLong(profit);
//    }
//
//    /**
//     * 查询单词采矿的收益
//     * @param userId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public Long queryDigProfit(Long userId, ICache cache) throws Exception {
//        String key = DIG_PROFIT;
//        String str = cache.hget(key, userId.toString());
//        if (StringUtils.isBlank(str)) {
//            return 0L;
//        }
//        return Long.parseLong(str);
//    }
//
//    /**
//     * 增加收益
//     * @param userId
//     * @param profit 增加量
//     * @param cache
//     * @throws Exception
//     */
//    public void increaseDigProfit(Long userId, Long profit, ICache cache) throws Exception {
//        String key = DIG_PROFIT;
//        cache.hincrby(key, userId.toString(), profit.intValue());
//    }
//
//    /**
//     * 更新收益
//     * @param userId
//     * @param profit 新收益
//     * @param cache
//     * @throws Exception
//     */
//    public void updateDigProfit(Long userId, Long profit, ICache cache) throws Exception {
//        String key = DIG_PROFIT;
//        cache.hset(key, userId.toString(), profit.toString());
//    }
//
//    /**
//     * 更新矿坑
//     *
//     * @param section
//     * @param cache
//     */
//    public void updateMineSeg(TMiningGameSection section, ICache cache) throws Exception {
//        Long activityId = section.getActivityId();
//        List<TMiningGameSection> list = queryMineSegs(activityId, cache);
//        if (list == null || list.isEmpty()) {
//            return;
//        }
//        Long mineSectionId = section.getMineSectionId();
//        String key = MINING_SEG_LIST + activityId;
//        for (TMiningGameSection t : list) {
//            if (t.getMineSectionId() == mineSectionId) {
//                cache.hset(key, mineSectionId.toString(),
//                        JSON.toJSONString(section));
//            }
//        }
//    }
//
//    /**
//     * 剩余挖矿次数减一次
//     *
//     * @param userId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public void decreaseUserLeftDigCount(Long userId, ICache cache, String userType)
//            throws Exception {
//        String key = LEFT_DIG_COUNT;
//        Integer leftCount = queryUserLeftDigCount(userId, cache, userType);
//        if (leftCount <= 0) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                    "已没有剩余抢矿次数！");
//        }
//        cache.hincrby(key, userId.toString(), -1);
//    }
//
//    public void updateUserLeftDigCount(Long userId, int digCount, String userType, ICache cache)
//            throws Exception {
//        String key = LEFT_DIG_COUNT;
//        String str = cache.hget(key, userId.toString());
//        if (StringUtils.isEmpty(str)) {
//            queryUserLeftDigCount(userId, cache, userType).toString();
//        } else {
//            cache.hincrby(key, userId.toString(), digCount);
//        }
//    }
//
//    /**
//     * 更新每次挖矿剩余采集轮数
//     * @param userId
//     * @param cache
//     * @param count
//     * @throws Exception
//     */
//    public void updateLeftDigPerRound(Long userId, ICache cache, Integer count)
//            throws Exception {
//        String key = LEFT_DIG_PER_ROUND;
//        cache.hset(key, userId.toString(), count.toString());
//    }
//
//    /**
//     * 更新玩家收益
//     *
//     * @param userId
//     * @param cache
//     * @param count
//     * @throws Exception
//     */
//    public void updateUserProfit(Long userId, ICache cache, Long count)
//            throws Exception {
//        String key = DAY_PROFIT + userId;
//        Long profit = queryUserDayProfit(userId, cache);
//        profit += count;
//        cache.set(key, profit.toString());
//    }
//
//    /**
//     * 更新攻击者缓存
//     *
//     * @param attacker
//     * @param cache
//     */
//    public void updateAttacker(CacheUserProfile attacker, ICache cache) {
//        String key = MINE_ATTACKER_KEY;
//        String field = attacker.getUserId().toString();
//        cache.hset(key, field, JSON.toJSONString(attacker));
//    }
//
//    /**
//     * 更新防守者缓存
//     *
//     * @param defender
//     * @param cache
//     */
//    public void updateDefender(CacheUserProfile defender, Long activityId, ICache cache) {
//        String key = MINE_DEFENDER_KEY + activityId;
//        String field = defender.getUserId().toString();
//        cache.hset(key, field, JSON.toJSONString(defender));
//    }
//
//    /**
//     * 更新采矿活动缓存
//     *
//     * @param activityId
//     * @param game
//     * @param cache
//     */
//    public void updateMiningGame(Long activityId, TMiningGame game,
//            ICache cache) {
//        String key = MINING_ACTIVITY;
//        cache.hset(key, activityId.toString(), JSON.toJSONString(game));
//    }
//
////    /**
////     * 更新公会详情缓存矿量
////     *
////     * @param societyId
////     * @param mine
////     * @param cache
////     * @throws Exception
////     */
////    public void updateSocietyListProfileMine(String cityId, String societyId,
////            Long mine, ICache cache) throws Exception {
////
////        String key = SOCIETIES + cityId;
////        String societyStr = cache.hget(key, societyId);
////        if (StringUtils.isNotBlank(societyStr)) {
////            CacheSocietyListProfile society = JSONObject.parseObject(societyStr,
////                    CacheSocietyListProfile.class);
////            society.setCumulation(society.getCumulation() + mine);
////            cache.hset(key, societyId, JSON.toJSONString(society));
////        }
////    }
//
//    /**
//     * 添加矿坑到缓存
//     *
//     * @param section
//     * @param cache
//     */
//    public void addMineSection(TMiningGameSection section, ICache cache) {
//        Long activityId = section.getActivityId();
//        String key = MINING_SEG_LIST + activityId;
//        cache.hset(key, section.getMineSectionId().toString(),
//                JSONObject.toJSONString(section));
//    }
//
//    /**
//     * 添加采矿活动到缓存，更新公会详情缓存的采矿活动id字段
//     *
//     * @param activity
//     * @param cache
//     */
//    public void addMiningGameActivity(TMiningGame activity, ICache cache) {
//        String key = MINING_ACTIVITY;
//        cache.hset(key, activity.getActivityId().toString(),
//                JSONObject.toJSONString(activity));
//        // 修改公会详情缓存
//        key = SOCIETY_KEY + activity.getSocietyId();
//        if (!cache.hgetAll(key).isEmpty()) {
//            cache.hset(key, SOCIETY_FIELD_ACTIVITY_ID,
//                    activity.getActivityId().toString());
//        }
//    }
//
//    /**
//     * redis中初始化该采矿活动的矿坑
//     */
//    public void initMineSection(Long activityId, Long fullAmount, ICache cache)
//            throws Exception {
//        try {
//            Integer mineLocationCount = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.MINE_LOCATION_COUNT, cache));
//            Long availableAmount = fullAmount / mineLocationCount;
//            for (int i = 0; i < mineLocationCount; i++) {
//                TMiningGameSection section = new TMiningGameSection();
//                section.setActivityId(activityId);
//                section.setMineSectionId((long) i);
//                section.setMineSectionPosition(i);
//                section.setStatus(Constants.MINE_SEC_STATUS_AVALIABLE);
//                section.setMineSectionAmount(availableAmount);
//                section.setMinedAmount(0l);
//                section.setAvailableAmount(availableAmount);
//                addMineSection(section, cache);
//            }
//        } catch (Exception e) {
//            throw e;
//        }
//    }
//
//    /**
//     * 爆矿修改公会状态
//     *
//     * @param status
//     * @param cache
//     * @throws Exception
//     */
//    public void boomMine(TMiningGame gameActivity, Integer status, ICache cache)
//            throws Exception {
//        // 修改公会详情缓存
//        Long societyId = gameActivity.getSocietyId();
//        String key = SOCIETY_KEY + societyId;
//        if (!cache.hgetAll(key).isEmpty()) {
//            cache.hset(key, SOCIETY_FIELD_STATUS, status.toString());
//        }
//        if (status.equals(Constants.SOCIETY_VALID)) {// 爆矿结束，清除矿坑和采矿活动
//            CacheSocietyProfile societyProfile = societyCacheController.querySocietyDetail(societyId,
//                    cache);
//            Long tempActivityId = societyProfile.getActivityId();
//            key = MINING_SEG_LIST + tempActivityId;
//            cache.del(key);
//            key = MINING_ACTIVITY;
//            cache.hdel(key, tempActivityId.toString());
//            key = SOCIETY_KEY + societyId;
//            if (!cache.hgetAll(key).isEmpty()) {
//                cache.hset(key, SOCIETY_FIELD_ACTIVITY_ID, "0");
//            }
//            key = ACTIVITY_ATTACKER_COUNT + tempActivityId;
//            cache.del(key);
//            key = MINE_DEFENDER_KEY + tempActivityId;
//            cache.del(key);
//        } else {// 开始爆矿，缓存中加入采矿活动
//            addMiningGameActivity(gameActivity, cache);
//        }
//    }
//
//    public void updateMiningCache(Long userId, Long activityId, Long profit, ICache cache) throws Exception {
//        // 更新我的收益
//        updateUserProfit(userId, cache, profit);
//
//        // 更新采矿活动缓存
//        TMiningGame game = queryMiningGameByActivityId(cache, activityId);
//        game.setRealAmount(game.getRealAmount() - profit);
//        updateMiningGame(activityId, game, cache);
//
//        //更新公会详情矿量
//        societyCacheController.increaseSocietyField(game.getSocietyId(),
//                cache, SOCIETY_FIELD_CUMULATION, - profit.intValue());
//
//        //重置digProfit
//        updateDigProfit(userId, 0L ,cache);
//    }
//
//    /**
//     * 更新公会详情缓存矿量
//     *
//     * @param cache
//     * @throws Exception
//     */
//    public void updateSocietyProfileMine(String societyId, Long mine,
//            ICache cache) throws Exception {
//        String key = SOCIETY_KEY + societyId;
//        if (cache.hlen(key) > 0) {
//            cache.hincrby(key, SOCIETY_FIELD_CUMULATION, mine.intValue());
//        } else {
//            societyCacheController.querySocietyDetail(Long.parseLong(societyId), cache);
//        }
//    }
//
//    /**
//     * 进入采矿活动界面
//     *
//     * @param userId
//     */
//    public void enterMiningActivity(Long activityId, Long userId, ICache cache)
//            throws Exception {
//        String key = ACTIVITY_ATTACKER_COUNT + activityId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            cache.hset(key, userId.toString(), userId.toString());
//            map = cache.hgetAll(key);
//        }
//        if (map.size() >= 20) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                    "该采矿活动人数已满！");
//        }
//        cache.hset(key, userId.toString(), userId.toString());
//    }
//
//    /**
//     * 退出采矿活动界面
//     * @param activityId 活动ID
//     * @param userId 用户ID
//     * @param cache 缓存
//     * @throws Exception
//     */
//    public void exitMiningActivity(Long activityId, Long userId, ICache cache)
//            throws Exception {
//        String key = ACTIVITY_ATTACKER_COUNT + activityId;
//        cache.hdel(key, userId.toString(), userId.toString());
//    }
//}
