//package com.hbi.cache.controller;
//
//import java.awt.color.ICC_ColorSpace;
//import java.text.SimpleDateFormat;
//import java.util.*;
//
//import com.hbi.model.*;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.beanUtil.BeanMapUtils;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.CaptureCacheLoader;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.constants.Constants;
//import org.springframework.web.servlet.tags.form.SelectTag;
//
//@Service
//public class CaptureCacheController {
//    /**
//     * 守护主播Key
//     */
//    private static final String CAPTURE_DEFENDER_COMPERE_KEY = "CAPTURE_DEFENDER_COMPERE_";
//
//    /**
//     * 守护玩家Key
//     */
//    private static final String CAPTURE_DEFENDER_PLAYER_KEY = "CAPTURE_DEFENDER_PLAYER_";
//
//    /**
//     * 玩家后宫Key，存的是后宫的ID
//     */
//    private static final String CAPTURE_WIFE_KEY = "CAPTURE_WIFE_";
//
//    /**
//     * 主播详情Key
//     */
//    private static final String COMPERE_KEY_PREFIX = "COMPERE_";
//
////    /**
////     * 玩家详情Key
////     */
////    private static final String PLAYER_KEY_PREFIX = "PLAYER_";
//
//    /**
//     * 物品背包Key
//     */
//    private static final String USER_ITEM_KEY_PREFIX = "USER_ITEM_";
//
//    private static final String CAPTURE_SPELL_KEY = "CAPTURE_SPELL";
//
//    /**
//     * 抓主播血量Key
//     */
//    private static final String CAPTURE_LIFE_KEY = "CAPTURE_LIFE_";
//
//    private static final String CAPTURE_LEFT_LIFE_KEY = "CAPTURE_LEFT_LIFE_";
//
//    private static final String CAPTURE_TOTAL_LIFE_KEY = "CAPTURE_TOTAL_LIFE_";
//
//    /**
//     * 抓主播攻击玩家Key
//     */
//    private static final String CAPTURE_ATTACKER_PLAYER_KEY = "CAPTURE_ATTACKER_PLAYER_";
//
//    /**
//     * 抓主播剩余次数
//     */
//    private static final String CAPTURE_TIMES = "CAPTURE_TIMES_";
//
//    private static final String CAPTURE_STATUS = "captureStatus";
//
//    private static final String OWNER_ID = "ownerId";
//
//    private static final String RELEASE_TIME = "releaseTime";
//
//    private static final String PROTECT_TIME = "protectTime";
//
//    private static final String TITLE = "title";
//
//    private static final String SHARED_PROFIT = "sharedProfit";
//
////    private static final String LEFT_LIFE = "leftLife";
//
//    private static final String CAPTURE_LIFE = "captureLife";
//
//    @Autowired
//    private CaptureCacheLoader captureCacheLoader;
//
//    @Autowired
//    private CommonCacheController commonCacheController;
//
//    @Autowired
//    private PlayerCacheController playerCacheController;
//
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private CompereCacheController compereCacheController;
//
//    /**
//     * 查询主播的守护者列表
//     *
//     * @param compereId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<TCaptureDefender> queryCaptureInfoByCompere(Long compereId,
//            ICache cache) throws Exception {
//        String key = CAPTURE_DEFENDER_COMPERE_KEY + compereId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TCaptureDefender> list = captureCacheLoader
//                    .queryDefenderListByCompereId(compereId);
//            for (TCaptureDefender t : list) {
//                cache.hset(key, t.getPlayerId().toString(), JSON.toJSONString(t));
//                CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(t.getPlayerId(), cache, false, false);
//                t.setPlayerVipLevel(playerProfile.getVipLevel());
//            }
//            return list;
//        } else {
//            List<TCaptureDefender> list = new ArrayList<TCaptureDefender>();
//            for (String k : map.keySet()) {
//                list.add(JSON.parseObject(map.get(k), TCaptureDefender.class));
//            }
//            Iterator<TCaptureDefender> iterator = list.iterator();
//            while (iterator.hasNext()) { //去掉当前不生效的守护
//                TCaptureDefender t = (TCaptureDefender) iterator.next();
//                Date nowDate = new Date();
//                if (t.getStartDate().getTime() > nowDate.getTime()) {
//                    iterator.remove();
//                    continue;
//                }
//                if (t.getEndDate().getTime() < nowDate.getTime()) {
//                    iterator.remove();
//                    continue;
//                }
//                CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(t.getPlayerId(), cache, false, false);
//                t.setPlayerVipLevel(playerProfile.getVipLevel());
//            }
//            return list;
//        }
//    }
//
//    /**
//     * 查询主播的守护者的头像等信息
//     * @param compereId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CacheUserListProfile> queryDefenderInfoByCompereId(Long compereId, ICache cache) throws Exception {
//        List<TCaptureDefender> defenders = queryCaptureInfoByCompere(compereId, cache);
//        List<CacheUserListProfile> list = new ArrayList<CacheUserListProfile>();
//        for (TCaptureDefender t : defenders) {
//            CacheUserListProfile profile = new CacheUserListProfile();
//            CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(t.getPlayerId(), cache, false, false);
//
//            profile.setUserId(playerProfile.getUserId().toString());
//            profile.setNickName(playerProfile.getNickName());
//            profile.setPhotoUrl(playerProfile.getPhotoUrl());
//            profile.setPhone(playerProfile.getPhone());
//            if (!list.contains(profile)) {
//                list.add(profile);
//            }
//        }
//        return list;
//    }
//
//    /**
//     * 查询玩家守护的主播列表
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<TCaptureDefender> queryCaptureInfoByPlayer(Long playerId,
//            ICache cache) throws Exception {
//        String key = CAPTURE_DEFENDER_PLAYER_KEY + playerId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TCaptureDefender> list = captureCacheLoader
//                    .queryDefenderListByPlayerId(playerId);
//            for (TCaptureDefender t : list) {
//                cache.hset(key, t.getCompereId().toString(), JSON.toJSONString(t));
//                CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(t.getCompereId().toString(), cache, false, false);
//                t.setCaptureStatus(compereProfile.getCaptureStatus());
//                t.setCompereLevel(compereProfile.getLevel());
//                TCompereLevel level = baseCacheController.queryCompereLevelByLevel(compereProfile.getLevel(), cache);
//                t.setCompereLevelBadge(level.getBadge());
//            }
//            return list;
//        } else {
//            List<TCaptureDefender> list = new ArrayList<TCaptureDefender>();
//            for (String k : map.keySet()) {
//                list.add(JSON.parseObject(map.get(k), TCaptureDefender.class));
//            }
//            Iterator<TCaptureDefender> iterator = list.iterator();
//            while (iterator.hasNext()) { //去掉当前不生效的守护
//                TCaptureDefender t = (TCaptureDefender) iterator.next();
//                Date nowDate = new Date();
//                if (t.getStartDate().getTime() > nowDate.getTime()) {
//                    iterator.remove();
//                    continue;
//                }
//                if (t.getEndDate().getTime() < nowDate.getTime()) {
//                    iterator.remove();
//                    continue;
//                }
//                CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(t.getCompereId().toString(), cache, false, false);
//                t.setCaptureStatus(compereProfile.getCaptureStatus());
//                t.setCompereLevel(compereProfile.getLevel());
//                TCompereLevel level = baseCacheController.queryCompereLevelByLevel(compereProfile.getLevel(), cache);
//                t.setCompereLevelBadge(level.getBadge());
//            }
//            return list;
//        }
//    }
//
//    /**
//     * 查询我的后宫ID
//     *
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<Long> queryMyWivesId(Long playerId, ICache cache)
//            throws Exception {
//        String key = CAPTURE_WIFE_KEY + playerId;
//        List<String> list = cache.lgetAll(key);
//        if (list == null || list.isEmpty()) {
//            List<Long> wives = captureCacheLoader.queryMyWivesById(playerId);
//            for (Long wife : wives) {
//                cache.lpush(key, wife.toString());
//            }
//            return wives;
//        } else {
//            List<Long> wives = new ArrayList<Long>();
//            for (String string : list) {
//                wives.add(Long.parseLong(string));
//            }
//            return wives;
//        }
//    }
//
//    /**
//     * 查询抢主播攻击玩家的缓存
//     *
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public CachePlayerProfile queryCaptureAttacker(Long playerId, ICache cache)
//            throws Exception {
//        String key = CAPTURE_ATTACKER_PLAYER_KEY + playerId;
//        Map<String, String> attacker = cache.hgetAll(key);
//        if (attacker.isEmpty()) {
//            CachePlayerProfile profile = playerCacheController
//                    .queryPlayerDetail(playerId, cache, false, false);
//            attacker = BeanMapUtils.toMapBySelective(profile);
//            cache.hmset(key, attacker);
//            return profile;
//        } else {
//            CachePlayerProfile profile = (CachePlayerProfile) BeanMapUtils
//                    .toBeanBySelective(CachePlayerProfile.class, attacker);
//            if (profile.getCaptureLife().equals(0L)) {
//                profile = playerCacheController
//                        .queryPlayerDetail(playerId, cache, false, false);
//                updateAttackerLife(playerId, cache, profile.getCaptureLife().intValue());
//            }
//            return profile;
//        }
//    }
//
//    // /**
//    // * 查询抢主播防守主播的缓存
//    // * @param compereId
//    // * @param cache
//    // * @return
//    // * @throws Exception
//    // */
//    // public CacheCompereProfile queryCaptureCompere(Long compereId, ICache
//    // cache) throws Exception {
//    // String key = CAPTURE_DEFENDER_COMPERE_KEY + compereId;
//    // Map<String, String> defender = cache.hgetAll(key);
//    // if (defender.isEmpty()) {
//    // CacheCompereProfile profile = compereCacheController
//    // .getCompereDetail(compereId.toString(), cache);
//    // defender = BeanMapUtils.toMapBySelective(profile);
//    // cache.hmset(key, defender);
//    // return profile;
//    // } else {
//    // return (CacheCompereProfile)
//    // BeanMapUtils.toBeanBySelective(CacheCompereProfile.class, defender);
//    // }
//    // }
//
//    /**
//     * 查询玩家抢主播剩余战斗次数
//     *
//     * @param userId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public Integer queryCaptureLeftTimes(Long userId, ICache cache)
//            throws Exception {
//        String key = CAPTURE_TIMES;
//        String str = cache.hget(key, userId.toString());
//        if (str == null || str.isEmpty()) {
//            str = queryCaptureTotalTimes(userId, cache).toString();
//            cache.hset(key, userId.toString(), str);
//        }
//        return Integer.parseInt(str);
//    }
//
//    public Integer queryCaptureTotalTimes(Long userId, ICache cache)
//            throws Exception {
//        CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(userId, cache, false, false);
//        TVipLevel vipLevel = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//        return vipLevel.getCaptureTimes();
//    }
//
//    /**
//     * 查询技能列表
//     *
//     * @param cache
//     * @return
//     */
//    public List<TCaptureSpell> querySpells(ICache cache) {
//        String key = CAPTURE_SPELL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TCaptureSpell> list = captureCacheLoader.querySpells();
//            for (TCaptureSpell tCaptureSpell : list) {
//                cache.hset(key, tCaptureSpell.getId().toString(),
//                        JSONObject.toJSONString(tCaptureSpell));
//            }
//            return list;
//        } else {
//            List<TCaptureSpell> list = new ArrayList<TCaptureSpell>();
//            for (String k : map.keySet()) {
//                list.add(JSON.parseObject(map.get(k), TCaptureSpell.class));
//            }
//            return list;
//        }
//    }
//
//    /**
//     * 根据id查询技能
//     *
//     * @param spellId
//     * @param cache
//     * @return
//     */
//    public TCaptureSpell querySpell(Long spellId, ICache cache) {
//        List<TCaptureSpell> spells = querySpells(cache);
//        for (TCaptureSpell tCaptureSpell : spells) {
//            if (tCaptureSpell.getId().equals(spellId)) {
//                return tCaptureSpell;
//            }
//        }
//        return null;
//    }
//
////    /**
////     * 根据城市查询主播的血量（剩余，总）血量列表，直播间列表显示用
////     * @param cityId
////     * @return
////     */
////    public Map<String, String> queryCompereLifeList(Long cityId, ICache cache) {
////        String key = CAPTURE_LIFE_KEY + cityId;
////        Map map = cache.hgetAll(key);
////        Set<String> keySet = map.keySet();
////        if (map.isEmpty()) {
////            List<TCompere> comperes = captureCacheLoader.queryCaptureLifes(cityId);
////            for (TCompere compere : comperes) {
////                String field = CAPTURE_LEFT_LIFE_KEY + compere.getCompereId();
////                cache.hset(key, field, compere.getTotalLife().toString());
////                field = CAPTURE_TOTAL_LIFE_KEY + compere.getCompereId();
////                cache.hset(key, field, compere.getTotalLife().toString());
////            }
////        }
////        boolean hasTotalLife = false;
////        for(String mapKey : keySet) {
////            if (mapKey.indexOf(CAPTURE_TOTAL_LIFE_KEY) > -1) {
////                hasTotalLife = true;
////                break;
////            }
////        }
////        if(!hasTotalLife) { //缓存中没有总血量
////            List<TCompere> comperes = captureCacheLoader.queryCaptureLifes(cityId);
////            for (TCompere compere : comperes) {
////                String field = CAPTURE_TOTAL_LIFE_KEY + compere.getCompereId();
////                cache.hset(key, field, compere.getTotalLife().toString());
////            }
////        }
////        map = cache.hgetAll(key);
////        return map;
////    }
//
//    /**
//     * 查询主播剩余血量
//     * @param cityId
//     * @param compereId
//     * @param cache
//     * @return
//     */
//    public Long queryCompereLeftLife(String cityId, Long compereId, ICache cache) {
//        String key = CAPTURE_LIFE_KEY + cityId;
//        String field = CAPTURE_LEFT_LIFE_KEY + compereId;
//        String left = cache.hget(key, field);
//        if (StringUtils.isNotBlank(left)) {
//            return Long.parseLong(left);
//        } else {
//            Long life = queryCompereTotalLife(cityId, compereId, cache);
//            cache.hset(key, field, life.toString());
//            return life;
//        }
//    }
//
//    /**
//     * 查询主播总血量
//     * @param cityId
//     * @param compereId
//     * @param cache
//     * @return
//     */
//    public Long queryCompereTotalLife(String cityId, Long compereId, ICache cache) {
//        String key = CAPTURE_LIFE_KEY + cityId;
//        String field = CAPTURE_TOTAL_LIFE_KEY + compereId;
//        String total = cache.hget(key, field);
//        if (StringUtils.isNotBlank(total)) {
//            return Long.parseLong(total);
//        } else {
//            TCompere c = captureCacheLoader.queryCaptureTotalLife(compereId);
//            Long totalLife = c.getTotalLife();
//            if (totalLife == null) {
//                cache.hset(key, field, "0");
//                return 0L;
//            } else {
//                cache.hset(key, field, totalLife.toString());
//                return totalLife;
//            }
//        }
//    }
//
//    public void addCaptureCache(TCaptureDefender defender, ICache cache) {
//        addCaptureCompereCache(defender, cache);
//        addCapturePlayerIdCache(defender, cache);
//    }
//
//    /**
//     * 新加守护到主播的守护缓存中
//     * @param defender
//     * @param cache
//     */
//    public void addCaptureCompereCache(TCaptureDefender defender, ICache cache) {
//        Long compereId = defender.getCompereId();
//        String key = CAPTURE_DEFENDER_COMPERE_KEY + compereId;
//        cache.hset(key, defender.getPlayerId().toString(), JSON.toJSONString(defender));
//    }
//
//    /**
//     * 新加守护到玩家的守护缓存中
//     * @param defender
//     * @param cache
//     */
//    public void addCapturePlayerIdCache(TCaptureDefender defender, ICache cache) {
//        Long playerId = defender.getPlayerId();
//        String key = CAPTURE_DEFENDER_PLAYER_KEY + playerId;
//        cache.hset(key, defender.getCompereId().toString(), JSON.toJSONString(defender));
//    }
//
//    /**
//     * 更新守护缓存
//     * @param defender
//     * @param cache
//     */
//    public void updateCaptureCache(TCaptureDefender defender, ICache cache) {
//        updateCaptureCompereCache(defender,cache);
//        updateCapturePlayerCache(defender,cache);
//    }
//
//    /**
//     * 更新守护主播的玩家列表缓存
//     * @param defender
//     * @param cache
//     */
//    public void updateCaptureCompereCache(TCaptureDefender defender, ICache cache) {
//        String key = CAPTURE_DEFENDER_COMPERE_KEY + defender.getCompereId();
//        cache.hset(key, defender.getPlayerId().toString(), JSON.toJSONString(defender));
//    }
//
//    /**
//     * 更新玩家守护的主播列表缓存
//     * @param defender
//     * @param cache
//     */
//    public void updateCapturePlayerCache(TCaptureDefender defender, ICache cache) {
//        String key = CAPTURE_DEFENDER_PLAYER_KEY + defender.getPlayerId();
//        cache.hset(key, defender.getCompereId().toString(), JSON.toJSONString(defender));
//    }
//
//    /**
//     * 释放主播
//     *
//     * @param compereId
//     * @throws Exception
//     */
//    public void releaseCompere(Long playerId, Long compereId, Date protectTime, ICache cache)
//            throws Exception {
//        String key = COMPERE_KEY_PREFIX + compereId;
//        cache.hset(key, CAPTURE_STATUS, Constants.CAPTURE_PROTECT.toString());
//        cache.hset(key, OWNER_ID, "");
//        cache.hset(key, RELEASE_TIME, "");
//        cache.hset(key, PROTECT_TIME, JSON.toJSONString(protectTime));
//        cache.hset(key, TITLE, "");
//        cache.hset(key, SHARED_PROFIT, "");
//        key = CAPTURE_WIFE_KEY + playerId;
//        cache.lrem(key, 0, compereId.toString());
//    }
//
//    /**
//     * 使用赎身卡
//     *
//     * @param userId
//     * @param leftCount
//     *            使用之后剩余的卡数
//     * @param cache
//     */
//    public void useRansomCard(Long userId, int leftCount, ICache cache) {
////        String key = USER_ITEM_KEY_PREFIX + Constants.GOODS_TYPE_RANSOM_CARD + "_"
////                + userId;
////        TUserGoods card = commonCacheController.queryUserGoodsByUserId(userId,
////                Constants.GOODS_TYPE_RANSOM_CARD, cache).get(0);
////        // Integer singlePrice = card.getTotalPrice() / card.getAmount();
////        card.setAmount(leftCount);
////        // card.setTotalPrice(singlePrice * card.getAmount());
////        if (leftCount > 0) {
////            cache.hset(key, card.getCategoryId().toString(),
////                    JSON.toJSONString(card));
////        } else {
////            boolean result = cache.hdel(key, card.getCategoryId().toString());
////            System.out.println(result);
////        }
//    }
//
//    /**
//     * 更新释放时间
//     *
//     * @param compereId
//     * @param releaseTime
//     * @param cache
//     */
//    public void updateReleaseTime(Long compereId, Date releaseTime,
//            ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compereId;
////        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//        cache.hset(key, RELEASE_TIME, JSON.toJSONString(releaseTime));
//    }
//
//    /**
//     * 更新主播血量
//     *
//     * @param compereId
//     * @param damage
//     * @param cache
//     */
////    public void updateCompereLife(Long compereId, Long damage, ICache cache) {
////        String key = COMPERE_KEY_PREFIX + compereId;
////        cache.hincrby(key, LEFT_LIFE, damage.intValue());
////    }
//
//    /**
//     * 更新玩家血量
//     *
//     * @param playerId
//     * @param cache
//     * @param life
//     */
//    public void updateAttackerLife(Long playerId, ICache cache, Integer life) {
//        String key = CAPTURE_ATTACKER_PLAYER_KEY + playerId;
//        cache.hincrby(key, CAPTURE_LIFE, life.intValue());
//    }
//
//    /**
//     * 更新玩家抓主播次数
//     *
//     * @param userId
//     * @param count
//     * @param cache
//     * @throws Exception
//     */
//    public void updateCaptureTimes(Long userId, Integer count, ICache cache)
//            throws Exception {
//        String key = CAPTURE_TIMES;
//        String str = cache.hget(key, userId.toString());
//        if (str == null || str.isEmpty()) {
//            str = queryCaptureTotalTimes(userId, cache).toString();
//            cache.hset(key, userId.toString(), str);
//        } else {
//            cache.hincrby(key, userId.toString(), count);
//        }
//    }
//
//    public void updateCompereTotalLife(String cityId, Long compereId, Long totalLife, ICache cache) {
//        String key = CAPTURE_LIFE_KEY + cityId;
//        String field = CAPTURE_TOTAL_LIFE_KEY + compereId;
//        cache.hset(key, field, totalLife.toString());
//    }
//
//    public void updateCompereLeftLife(Long cityId, Long compereId, Long leftLife, ICache cache) {
//        String key = CAPTURE_LIFE_KEY + cityId;
//        String field = CAPTURE_LEFT_LIFE_KEY + compereId;
//        cache.hset(key, field, leftLife.toString());
//    }
//
//    public void increaseCompereLeftLife(String cityId, Long compereId, Long increaseLife, ICache cache) {
//        String key = CAPTURE_LIFE_KEY + cityId;
//        String field = CAPTURE_LEFT_LIFE_KEY + compereId;
//        cache.hincrby(key, field, increaseLife.intValue());
//    }
//
//    /**
//     * 删除主播守护缓存
//     * @param defender
//     * @param cache
//     */
//    public void deleteCaptureCache(TCaptureDefender defender, ICache cache) {
//        deleteCaptureCompereCache(defender,cache);
//        deleteCapturePlayerCache(defender,cache);
//    }
//
//    public void deleteCaptureCompereCache(TCaptureDefender defender, ICache cache) {
//        String key = CAPTURE_DEFENDER_COMPERE_KEY + defender.getCompereId();
//        cache.hdel(key, defender.getPlayerId().toString());
//    }
//
//    public void deleteCapturePlayerCache(TCaptureDefender defender, ICache cache) {
//        String key = CAPTURE_DEFENDER_PLAYER_KEY + defender.getPlayerId();
//        cache.hdel(key, defender.getCompereId().toString());
//    }
//
//    /**
//     * 主播被打死后更新主播被抓状态，主人等
//     *
//     */
//    public void captureCompere(TCompere modifyCompere, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + modifyCompere.getCompereId();
//        String playerId = modifyCompere.getOwnerId().toString();
//        cache.hset(key, CAPTURE_STATUS,
//                modifyCompere.getCaptureStatus().toString());
////        cache.hset(key, LEFT_LIFE, modifyCompere.getLeftLife().toString());
//        updateCompereLeftLife(modifyCompere.getCityId(), modifyCompere.getCompereId(), modifyCompere.getLeftLife(), cache);
//        cache.hset(key, OWNER_ID, playerId);
//        cache.hset(key, RELEASE_TIME,
//                JSON.toJSONString(modifyCompere.getReleaseTime()));
//        cache.hset(key, SHARED_PROFIT,
//                modifyCompere.getSharedProfit().toString());
////        cache.hset(key, TITLE_ID, modifyCompere.getTitleId().toString());
//        cache.hset(key, TITLE, modifyCompere.getTitle());
//        key = CAPTURE_WIFE_KEY + playerId;
//        cache.rpush(key, modifyCompere.getCompereId().toString());
//    }
//
//    public void modifyTitle(TCompere compere, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compere.getCompereId();
//        cache.hset(key, TITLE, compere.getTitle());
//    }
//
//    /**
//     * 解除主播保护
//     * @param compereId 主播ID
//     * @param cache 缓存实例
//     * @throws Exception
//     */
//    public void unProtectCompere(Long compereId, ICache cache) throws Exception {
//        String key = COMPERE_KEY_PREFIX + compereId;
//        CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(compereId.toString(), cache, false, false);
//        cache.hset(key, CAPTURE_STATUS, Constants.CAPTURE_FREE.toString());
//        cache.hset(key, PROTECT_TIME, "");
////        cache.hset(key, LEFT_LIFE, compereProfile.getTotalLife().toString());
//        Long totalLife = queryCompereTotalLife(compereProfile.getCityId(), compereId, cache);
//        updateCompereLeftLife(Long.parseLong(compereProfile.getCityId()), compereId, totalLife, cache);
//    }
//
//}
