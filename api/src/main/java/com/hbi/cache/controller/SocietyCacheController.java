//package com.hbi.cache.controller;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONArray;
//import com.alibaba.fastjson.JSONObject;
//import com.core.beanUtil.BeanMapUtils;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.SocietyCacheLoader;
//import com.hbi.cache.model.*;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.mapper.TSocietyMapper;
//import com.hbi.utils.InfServerException;
//import org.apache.commons.lang.StringUtils;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.beans.BeanUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.util.*;
//
//@Service
//public class SocietyCacheController {
//    private static final Logger LOGGER = LoggerFactory
//            .getLogger(SocietyCacheController.class);
//
//    /**
//     * 公会详情
//     */
//    private static String SOCIETY_KEY = "SOCIETY_";
//
//    private static final String SOCIETY_FIELD_COMPERENUM = "compereNum";
////
//    private static final String SOCIETY_FIELD_PLAYERNUM = "playerNum";
//
//    /**
//     * 公会列表
//     */
//    private static String SOCIETIES = "SOCIETIES_";
//
//    /**
//     * 公会成员列表
//     */
//    private static String SOCIETY_PLAYER_LIST_KEY = "SOCIETY_MEMBER_LIST_";
//
//    /**
//     * 公会主播列表
//     */
//    private static String SOCIETY_COMPERE_LIST_KEY = "SOCIETY_COMPERE_LIST_";
//
//    /**
//     * 公会管理员列表
//     */
//    // private static String SOCIETY_MANAGER_LIST_KEY = "SOCIETY_MANAGER_LIST_";
//
//    /**
//     * 主播详情
//     */
//    private static final String COMPERE_KEY_PREFIX = "COMPERE_";
//
//    /**
//     * 玩家详情
//     */
//    private static final String PLAYER_KEY_PREFIX = "PLAYER_";
//
//    /**
//     * 采矿活动攻击人数
//     */
//    private static final String ACTIVITY_ATTACKER_COUNT = "ACTIVITY_ATTACKER_COUNT_";
//
//    @Autowired
//    private SocietyCacheLoader societyCacheLoader;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private TSocietyMapper societyMapper;
//    @Autowired
//    private TCompereMapper compereMapper;
//
//    /**
//     * 根据公会id查询公会详情
//     *
//     * @param societyId
//     * @param cache
//     * @return CacheSocietyProfile
//     * @throws Exception
//     */
//    public CacheSocietyProfile querySocietyDetail(Long societyId, ICache cache)
//            throws Exception {
//        String key = SOCIETY_KEY + societyId;
//        Map<String, String> map = cache.hgetAll(key);
//        CacheSocietyProfile societyProfile;
//        if (map.isEmpty()) {
//            societyProfile = societyCacheLoader.loadSocietyProfile(societyId);
//            if (societyProfile == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL,
//                        "公会不存在！");
//            }
//
//            // 最大抢夺人数
//            Integer mineLocationCount = Integer.parseInt(baseCacheController
//                    .queryConfig(Constants.MINE_LOCATION_COUNT, cache));
//            societyProfile.setMaxAttackNum(mineLocationCount);
//
//            map = societyProfile.generateHashMapBySelective();
//            cache.hmset(key, map);
//
//            // 爆矿基线
//            Long boomLine = Long.parseLong(baseCacheController
//                    .queryConfig(Constants.FULL_MINE_REQUIREMENT, cache));
//            societyProfile.setBoomLine(boomLine);
//
//        } else {
//            societyProfile = (CacheSocietyProfile) BeanMapUtils
//                    .toBeanBySelective(CacheSocietyProfile.class, map);
//            // 爆矿基线
//            Long boomLine = Long.parseLong(baseCacheController
//                    .queryConfig(Constants.FULL_MINE_REQUIREMENT, cache));
//            societyProfile.setBoomLine(boomLine);
//        }
//        List<CacheCompereProfile> comperes = querySocietyComperes(
//                societyProfile.getSocietyId(), cache);
//        if (comperes.size() > 0) {
//            CacheCompereProfile compere = comperes.get(0);
//            for (CacheCompereProfile c : comperes) {
//                if (c.getLevel() > compere.getLevel()) {
//                    compere = c;
//                }
//            }
//            societyProfile.setCompereName(compere.getNickName());
//        }
//        return societyProfile;
//    }
//
//    /**
//     * 根据field查询公会详情字段
//     *
//     * @param societyId
//     * @param cache
//     * @return String
//     * @throws Exception
//     */
//    public String querySocietyField(Long societyId, ICache cache,
//            String fieldKey) throws Exception {
//        String key = SOCIETY_KEY + societyId;
//        String value = cache.hget(key, fieldKey);
//        if (StringUtils.isEmpty(value)) {
//            querySocietyDetail(societyId, cache);
//            value = cache.hget(key, fieldKey);
//        }
//        return value;
//    }
//
//    /**
//     * 按城市查询公会列表
//     *
//     * @param cache
//     * @param cityId
//     * @return
//     */
//    // public List<CacheSocietyListProfile> querySocietyListByCity(ICache cache,
//    // Long cityId) throws Exception {
//    // String key = SOCIETIES + cityId;
//    // Map<String, String> keyValues = cache.hgetAll(key);
//    // List<CacheSocietyListProfile> societies;
//    // if (keyValues.isEmpty()) {
//    // societies = societyMapper.getSocietyListByCity(cityId);
//    //
//    // Long boomLine = Long.parseLong(baseCacheController
//    // .queryConfig(Constants.FULL_MINE_REQUIREMENT, cache));
//    //
//    // Integer mineLocationCount = Integer.parseInt(baseCacheController
//    // .queryConfig(Constants.MINE_LOCATION_COUNT, cache));
//    //
//    // Map<String, String> newMap = new HashMap<String, String>();
//    // for (CacheSocietyListProfile cacheSocietyListProfile : societies) {
//    // // 爆矿基线
//    // cacheSocietyListProfile.setBoomLine(boomLine);
//    // // 防守人数
//    // List<CachePlayerListProfile> playerList = querySocietyOnlinePlayers(
//    // cacheSocietyListProfile.getSocietyId(), cache);
//    // Iterator<CachePlayerListProfile> iterator = playerList
//    // .iterator();
//    // while (iterator.hasNext()) {
//    // CachePlayerListProfile profile = iterator.next();
//    // if (profile.getLife() == 0) {
//    // iterator.remove();
//    // }
//    // }
//    // cacheSocietyListProfile.setDefenseNum(playerList.size());
//    // // 最大抢夺人数
//    // cacheSocietyListProfile.setMaxAttackNum(mineLocationCount);
//    //
//    // //抢夺人数
//    // Integer attackerCount =
//    // queryMiningActivityAttackerCount(cacheSocietyListProfile.getActivityId(),
//    // cache);
//    // cacheSocietyListProfile.setAttackerNum(attackerCount);
//    //
//    // newMap.put(cacheSocietyListProfile.getSocietyId().toString(),
//    // JSON.toJSONString(cacheSocietyListProfile, filter,
//    // SerializerFeature.WriteMapNullValue));
//    // }
//    // if (!newMap.isEmpty()) {
//    // cache.hmset(key, newMap);
//    // }
//    // } else {
//    // societies = new ArrayList<CacheSocietyListProfile>();
//    // for (String k : keyValues.keySet()) {
//    // societies.add(JSON.parseObject(keyValues.get(k),
//    // CacheSocietyListProfile.class));
//    // }
//    // }
//    // Iterator<CacheSocietyListProfile> iterator = societies.iterator();
//    // while (iterator.hasNext()) {
//    // CacheSocietyListProfile t = iterator.next();
//    // List<CacheCompereListProfile> comperes = querySocietyComperes(
//    // t.getSocietyId(), cache);
//    // if (comperes.size() > 0) {
//    // CacheCompereListProfile compere = comperes.get(0);
//    // for (CacheCompereListProfile c : comperes) {
//    // if (Integer.parseInt(c.getLevel()) > Integer
//    // .parseInt(compere.getLevel())) {
//    // compere = c;
//    // }
//    // }
//    // t.setCompereName(compere.getNickName());
//    // }
//    // }
//    // return societies;
//    // }
//
//    public List<CacheSocietyProfile> queryAllSocieties(ICache cache) throws Exception {
//        List<CacheSocietyProfile> societyProfiles = new ArrayList<CacheSocietyProfile>();
//        List<Long> ids = societyCacheLoader.queryAllSocieties();
//        for (Long id : ids) {
//            societyProfiles.add(querySocietyDetail(id, cache));
//        }
//        return societyProfiles;
//    }
//
//    public List<CacheSocietyProfile> querySocietyListByCity(ICache cache, Long cityId) throws Exception {
//        String key = SOCIETIES + cityId;
//        List<String> list = cache.lgetAll(key);
//        List<CacheSocietyProfile> societyProfiles = new ArrayList<CacheSocietyProfile>();
//        if (list.isEmpty()) {
//            List<Long> societies = societyMapper.getSocietyListByCity(cityId);
//            for (Long societyId : societies) {
//                cache.lpush(key, societyId.toString());
//                societyProfiles.add(querySocietyDetail(societyId, cache));
//            }
//        } else {
//            for (String str : list) {
//                Long societyId = Long.parseLong(str);
//                societyProfiles.add(querySocietyDetail(societyId, cache));
//            }
//        }
//        Iterator<CacheSocietyProfile> iterator = societyProfiles.iterator();
//        while (iterator.hasNext()) {
//            CacheSocietyProfile t = iterator.next();
//            List<CacheCompereProfile> comperes = querySocietyComperes(
//                    t.getSocietyId(), cache);
//            if (comperes.size() > 0) {
//                CacheCompereProfile compere = comperes.get(0);
//                for (CacheCompereProfile c : comperes) {
//                    if (c.getLevel() > compere.getLevel()) {
//                        compere = c;
//                    }
//                }
//                t.setCompereName(compere.getNickName());
//            }
//        }
//        return societyProfiles;
//    }
//
//    /**
//     * 根据公会id查询城市公会列表中的公会
//     *
//     * @param cityId
//     * @param societyId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public CacheSocietyProfile querySocietyFromList(Long cityId, Long societyId,
//            ICache cache) throws Exception {
//        List<CacheSocietyProfile> list = querySocietyListByCity(cache, cityId);
//        for (CacheSocietyProfile p : list) {
//            if (p.getSocietyId() == societyId) {
//                return p;
//            }
//        }
//        return null;
//    }
//
//    /**
//     * 查询公会玩家列表
//     *
//     * @param societyId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CachePlayerProfile> querySocietyPlayers(Long societyId,
//            ICache cache) throws Exception {
//        if(!societyHasPlayer(societyId, cache)) {
//            return new ArrayList<CachePlayerProfile>();
//        }
//        String key = SOCIETY_PLAYER_LIST_KEY + societyId;
//        Map<String, String> keyValues = cache.hgetAll(key);
//        List<CachePlayerProfile> list = new ArrayList<CachePlayerProfile>();;
//        if (keyValues.isEmpty()) {
//            List<Long> ids = societyMapper.getPlayerListBySocietyId(societyId);
//            Map<String, String> newMap = new HashMap<String, String>();
//            for (Long id : ids) {
//                newMap.put(id + "", id + "");
//            }
//            if (!newMap.isEmpty()) {
//                cache.hmset(key, newMap);
//            }
//            for (Long id : ids) {
//                CachePlayerProfile player = playerCacheController.queryPlayerDetail(id, cache, false, false);
//                list.add(player);
//            }
//        } else {
//            for (String keyT : keyValues.keySet()) {
//                Long userId = Long.parseLong(keyValues.get(keyT));
//                CachePlayerProfile player = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//                list.add(player);
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 通过玩家id查询公会玩家
//     *
//     * @param societyId
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
////    public CachePlayerListProfile querySocietyPlayerById(Long societyId,
////            Long playerId, ICache cache) throws Exception {
////        List<CachePlayerListProfile> list = querySocietyPlayers(societyId,
////                cache);
////        for (CachePlayerListProfile profile : list) {
////            if (Long.parseLong(profile.getUserId()) == playerId) {
////                return profile;
////            }
////        }
////        return null;
////    }
//
//    /**
//     * 查询公会在线玩家列表
//     *
//     * @param societyId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CachePlayerProfile> querySocietyOnlinePlayers(
//            Long societyId, ICache cache) throws Exception {
//        List<CachePlayerProfile> list = querySocietyPlayers(societyId,
//                cache);
//        Iterator<CachePlayerProfile> iterator = list.iterator();
//        while (iterator.hasNext()) {
//            CachePlayerProfile t = iterator.next();
//            if (t.getOnlineStatus() == null) {
//                iterator.remove();
//            } else if (t.getOnlineStatus().equals(Constants.OFF_LINE)) {
//                iterator.remove();
//            } else if (StringUtils.isBlank(t.getOnlineStatus())) {
//                iterator.remove();
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 查询公会主播列表
//     *
//     * @param societyId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CacheCompereProfile> querySocietyComperes(Long societyId,
//            ICache cache) throws Exception {
//        if(!societyHasCompere(societyId, cache)) {
//            return new ArrayList<CacheCompereProfile>();
//        }
//        String key = SOCIETY_COMPERE_LIST_KEY + societyId;
//        Map<String, String> keyValues = cache.hgetAll(key);
//        List<CacheCompereProfile> list = new ArrayList<CacheCompereProfile>();;
//        if (keyValues.isEmpty()) {
//            List<Long> ids = compereMapper.getCompereBySocietyId(societyId);
//            Map<String, String> newMap = new HashMap<String, String>();
//            for (Long id : ids) {
//                newMap.put(id.toString(), id.toString());
//                CacheCompereProfile compere = compereCacheController.getCompereDetail(id.toString(), cache, false, false);
//                list.add(compere);
//            }
//            if (!newMap.isEmpty()) {
//                cache.hmset(key, newMap);
//            }
//        } else {
//            for (String keyT : keyValues.keySet()) {
//                String compereId = keyValues.get(keyT);
//                CacheCompereProfile compere = compereCacheController.getCompereDetail(compereId, cache, false, false);
//                list.add(compere);
//            }
//        }
//        return list;
//    }
//
////    public CacheCompereProfile querySocietyCompereById(
////            Long societyId, Long compereId, ICache cache) throws Exception {
////        List<CacheCompereProfile> list = querySocietyComperes(societyId, cache);
////        for (CacheCompereListProfile l : list) {
////            if (l.getUserId().equals(compereId.toString())) {
////                return l;
////            }
////        }
////        return null;
////    }
//
//    /**
//     * 查询公会在线主播列表
//     *
//     * @param societyId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CacheCompereProfile> querySocietyOnlineComperes(
//            Long societyId, ICache cache) throws Exception {
//        List<CacheCompereProfile> list = querySocietyComperes(societyId,
//                cache);
//        Iterator<CacheCompereProfile> iterator = list.iterator();
//        while (iterator.hasNext()) {
//            CacheCompereProfile t = iterator.next();
//            if (t.getOnlineStatus() == null) {
//                iterator.remove();
//            } else if (t.getOnlineStatus().equals(Constants.OFF_LINE)) {
//                iterator.remove();
//            } else if (StringUtils.isBlank(t.getOnlineStatus())) {
//                iterator.remove();
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 查询公会在线用户列表
//     *
//     * @param societyId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CacheUserProfile> querySocietyOnlineUsers(Long societyId, ICache cache) throws Exception {
//        List<CacheUserProfile> list = new ArrayList<CacheUserProfile>();
//        list.addAll(querySocietyOnlinePlayers(societyId, cache));
//        list.addAll(querySocietyOnlineComperes(societyId, cache));
//        return list;
//    }
//
//    /**
//     * 加入公会
//     *
//     * @param societyId
//     * @param userId
//     * @param type
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public boolean joinSociety(Long societyId, Long userId, String type,
//            ICache cache) throws Exception {
//        String key = SOCIETY_KEY + societyId;
//        String typeKey = null;
//        if (type.equalsIgnoreCase(Constants.USER_TYPE_C)) {
//            // 1.更新公会人数，公会是否有主播；
//            if (cache.exist(key)) {// 缓存没有数据则不用更新缓存
//                cache.hincrby(key, "compereNum", 1);
//            }
//            // 2.更新公会主播/玩家列表；
//            typeKey = SOCIETY_COMPERE_LIST_KEY + societyId;
//            if (cache.exist(typeKey)) {// 缓存没有数据则不用更新缓存
//                CacheCompereListProfile profile = new CacheCompereListProfile();
//                CacheCompereProfile compere = compereCacheController
//                        .getCompereDetail(userId.toString(), cache, false, false);
//                BeanUtils.copyProperties(compere, profile);
//                cache.hset(typeKey, userId.toString(),
//                        userId.toString());
//            }
//            // 3.更新主播/玩家详情；
//            String compereKey = COMPERE_KEY_PREFIX + userId;
//            if (cache.exist(compereKey)) {// 缓存没有数据则不用更新缓存
//                cache.hset(compereKey, "societyId", societyId.toString());
//                CacheSocietyProfile societyProfile = querySocietyDetail(
//                        societyId, cache);
//                cache.hset(compereKey, "society", societyProfile.getName());
//            }
//            LOGGER.info(cache.hgetAll(key).toString());
//            return true;
//        } else if (type.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//            // 1.更新公会人数，公会是否有玩家；
//            if (cache.exist(key)) {// 缓存没有数据则不用更新缓存
//                cache.hincrby(key, "playerNum", 1);
//            }
//            // 2.更新公会主播/玩家列表；
//            typeKey = SOCIETY_PLAYER_LIST_KEY + societyId;
//            if (cache.exist(typeKey)) {// 缓存没有数据则不用更新缓存
//                cache.hset(typeKey, userId.toString(), userId.toString());
//            }
//            // 3.更新主播/玩家详情；
//            String playerKey = PLAYER_KEY_PREFIX + userId;
//            if (cache.exist(playerKey)) {// 缓存没有数据则不用更新缓存
//                cache.hset(playerKey, "societyId", societyId.toString());
//                CacheSocietyProfile societyProfile = querySocietyDetail(
//                        societyId, cache);
//                cache.hset(playerKey, "society", societyProfile.getName());
//            }
//            LOGGER.info(cache.hgetAll(key).toString());
//            return true;
//        } else {
//            return false;
//        }
//    }
//
//    /**
//     * 退出公会
//     *
//     * @author yrou
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public boolean exitSociety(Long societyId, Long userId, String type,
//            ICache cache) throws Exception {
//        String key = SOCIETY_KEY + societyId;
//        String typeKey = null;
//        String typeNum = null;
//        if (type.equalsIgnoreCase(Constants.USER_TYPE_C)) {
//            typeKey = SOCIETY_COMPERE_LIST_KEY + societyId;
//            typeNum = "compereNum";
//            // 4.更新主播/玩家详情；
//
//            String compereKey = COMPERE_KEY_PREFIX + userId;
//            if (isMapCacheExist(compereKey, cache)) {// 缓存没有数据则不用更新缓存
//                cache.hset(compereKey, "societyId", "");
//                cache.hset(compereKey, "society", "");
//            }
//        } else if (type.equalsIgnoreCase(Constants.USER_TYPE_P)) {
//            typeKey = SOCIETY_PLAYER_LIST_KEY + societyId;
//            typeNum = "playerNum";
//            // 4.更新主播/玩家详情；
//            String playerKey = PLAYER_KEY_PREFIX + userId;
//            if (isMapCacheExist(playerKey, cache)) {// 缓存没有数据则不用更新缓存
//                cache.hset(playerKey, "societyId", "");
//                cache.hset(playerKey, "society", "");
//            }
//        } else {
//            return false;
//        }
//        // 1.更新公会人数；
//        if (isMapCacheExist(key, cache)) {// 缓存没有数据则不用更新缓存
//            cache.hincrby(key, typeNum, -1);
//        }
//        // 2.更新公会主播/玩家列表；
//        if (isMapCacheExist(typeKey, cache)) {// 缓存没有数据则不用更新缓存
//            cache.hdel(typeKey, userId.toString());
//        }
//        // 3.更新公会详情中的管理员id列表
//        cancelSocietyManager(societyId, userId, cache);
//        LOGGER.info(cache.hgetAll(key).toString());
//        return true;
//    }
//
//    /**
//     * 设置公会管理员
//     *
//     * @param societyId
//     * @param userId
//     * @param type
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public boolean setSocietyManager(Long societyId, Long userId, String type,
//            ICache cache) throws Exception {
//        String key = SOCIETY_KEY + societyId;
//        if (!isMapCacheExist(key, cache)) {// 缓存没有数据则不用更新缓存
//            return true;
//        }
//        String managers = cache.hget(key, "admins");
//        JSONArray array;
//        if (StringUtils.isNotEmpty(managers)) {
//            array = JSONArray.parseArray(managers);
//            array.add(userId.toString());
//        } else {
//            array = new JSONArray();
//            array.add(userId.toString());
//        }
//        cache.hset(key, "admins", array.toString());
//        return true;
//    }
//
//    /**
//     * 取消公会管理员
//     *
//     * @param societyId
//     * @param userId
//     * @param cache
//     * @return
//     */
//    public boolean cancelSocietyManager(Long societyId, Long userId,
//            ICache cache) {
//        String key = SOCIETY_KEY + societyId;
//        if (!isMapCacheExist(key, cache)) {// 缓存没有数据则不用更新缓存
//            return true;
//        }
//        String managers = cache.hget(key, "admins");
//        if (StringUtils.isNotEmpty(managers)) {
//            JSONArray array = JSONArray.parseArray(managers);
//            array.remove(userId.toString());
//            cache.hset(key, "admins", array.toString());
//            return true;
//        }
//        return false;
//    }
//
//    public void updateSocietyField(Long societyId, ICache cache, String field, String value) {
//        String key = SOCIETY_KEY + societyId;
//        cache.hset(key, field, value);
//    }
//
//    public void increaseSocietyField(Long societyId, ICache cache, String field, int value) {
//        String key = SOCIETY_KEY + societyId;
//        cache.hincrby(key, field, value);
//    }
//
//    /**
//     * 根据用户实体更新公会玩家
//     *
//     * @param societyId
//     * @param profile
//     * @param cache
//     */
////    public void updateSocietyPlayerById(Long societyId,
////            CacheUserListProfile profile, ICache cache) {
////        String key = SOCIETY_PLAYER_LIST_KEY + societyId;
////        cache.hset(key, profile.getUserId(), JSON.toJSONString(profile));
////    }
//
//    /**
//     * 更新公会主播列表缓存
//     *
//     * @param compere
//     * @param cache
//     * @throws Exception
//     */
//    public void updateSocietyCompereList(CacheCompereListProfile compere,
//            ICache cache) throws Exception {
//        String key = SOCIETY_COMPERE_LIST_KEY + compere.getSocietyId();
//        cache.hset(key, compere.getUserId(), JSONObject.toJSONString(compere));
//    }
//
//    private boolean isMapCacheExist(String key, ICache cache) {
//        Map<String, String> map = cache.hgetAll(key);
//        if (map != null && !map.isEmpty()) {
//            return true;
//        }
//        return false;
//    }
//
//    private boolean societyHasCompere(Long societyId, ICache cache) throws Exception {
//        String compereNum = querySocietyField(societyId, cache,
//                SOCIETY_FIELD_COMPERENUM);
//        if (compereNum == null) {
//            return false;
//        } else {
//            Integer hasCompere = Integer.parseInt(compereNum);
//            if (hasCompere <= 0) {
//                return false;
//            }
//        }
//        return true;
//    }
//
//    private boolean societyHasPlayer(Long societyId, ICache cache) throws Exception {
//        String playerNum = querySocietyField(societyId, cache,
//                SOCIETY_FIELD_PLAYERNUM);
//        if (playerNum == null) {
//            return false;
//        } else {
//            Integer hasPlayer = Integer.parseInt(playerNum);
//            if (hasPlayer <= 0) {
//                return false;
//            }
//        }
//        return true;
//    }
//
//    // private static ValueFilter filter = new ValueFilter() {
//    // @Override
//    // public Object process(Object obj, String s, Object v) {
//    // if (v == null)
//    // return "";
//    // return v;
//    // }
//    // };
//}
