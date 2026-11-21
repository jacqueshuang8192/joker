//package com.hbi.cache.controller;
//
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.List;
//import java.util.Map;
//
//import com.hbi.cache.model.*;
//import com.hbi.mapper.TSocietyMapper;
//import com.hbi.model.*;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.collections.MapUtils;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.beanUtil.BeanMapUtils;
//import com.core.util.DateUtils;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.CommonCacheLoader;
//import com.hbi.cache.cacheWritter.CompereCacheLoader;
//import com.hbi.cache.redis.RedisLock;
//import com.hbi.constants.Constants;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.user.AccountVo;
//
//@Service
//public class CompereCacheController {
//
//    private static final String COMPERE_KEY_PREFIX = "COMPERE_";
//
//    private static final String COMPERE_FIELD_USERID = "userId";
//
//    private static final String COMPERE_FIELD_ADMINS = "admins";
//
//    private static final String COMPERE_VALUE_ADMINS_SPLIT = "_";
//
//    private static final String MYCOMPERE_KEY_PREFIX = "MYCOMPERE_";
//
//    private static final String COMPERE_PRIORITY_KEY_PREFIX = "COMPERE_PRIORITY";
//
//    private static final String FANS_KEY_PREFIX = "FANS_";
//
//    private static final String GIFT_ALL_PREFIX = "GIFT_ALL_";
//    private static final String CONTRIBUTION_RANK_PREFIX = "CONTRIBUTION_RANK_";
//
//    private static final String COMPERE_LIST_KEY_PREFIX = "COMPERE_LIST_";
//
//    private static final String COMPERE_MONTHLY_INCOME_KEY_PREFIX = "COMPERE_INCOME_";
//    private static final String COMPERE_TODAY_INCOME_KEY_PREFIX = "COMPERE_TODAY_INCOME_";
//
//    private static final String COMPERE_RELATION_KEY_PREFIX = "COMPERE_RELATION_";
//
//    private static final String COMPERE_FIELD_PHOTOURL = "photoUrl";
//    private static final String COMPERE_FIELD_ROOM_PHOTO = "roomPhoto";
//    private static final String COMPERE_FIELD_LIVE_PHOTO = "livePhoto";
//    private static final String COMPERE_FIELD_NICKNAME = "nickName";
//    private static final String COMPERE_FIELD_NAME = "name";
//    private static final String COMPERE_FIELD_BIRTHDAY = "birthday";
//    private static final String COMPERE_FIELD_PROVINCEID = "provinceId";
//    private static final String COMPERE_FIELD_PROVINCE = "province";
//    private static final String COMPERE_FIELD_CITYID = "cityId";
//    private static final String COMPERE_FIELD_CITY = "city";
//    private static final String COMPERE_FIELD_TOWNID = "townId";
//    private static final String COMPERE_FIELD_TOWN = "town";
//    private static final String COMPERE_FIELD_SIGN = "sign";
//    private static final String COMPERE_FIELD_COINAMOUNT = "coinAmount";
//    private static final String COMPERE_FIELD_JEWELAMOUNT = "jewelAmount";
//    private static final String COMPERE_FIELD_FANSCOUNT = "fansCount";
//    private static final String COMPERE_FIELD_ROOMID = "roomId";
//    private static final String COMPERE_FIELD_ROOMNAME = "roomName";
//    private static final String COMPERE_FIELD_ROOMPASSWORD = "roomPassword";
//    private static final String COMPERE_FIELD_LIVE_ACTIVITY_TYPE = "liveActivityType";
//    private static final String COMPERE_FIELD_LIVE_ACTIVITY_NAME = "liveActivityName";
//    private static final String COMPERE_FIELD_ONLINE_STATUS = "onlineStatus";
//    public static final String COMPERE_FIELD_SHARED_PROFIT = "sharedProfit";
//
//    private static final String USER_FIELD_LATITUDE = "latitude";
//    private static final String USER_FIELD_LONGITUDE = "longitude";
//
//    private static final String COMPERE_TOTAL_INCOME_ID_LIST_KEY_PREFIX = "COMPERE_TOTAL_INCOME_ID_LIST_";
//    private static final String COMPERE_TOTAL_INCOME_KEY_PREFIX = "COMPERE_TOTAL_INCOME_";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME = "hasIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_MATCH_EXTRACT_INCOME = "matchExtractIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_LIVE_ROOM_GAME_EXTRACT_INCOME = "liveRoomGameExtractIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_LIVE_ROOM_GIFT_INCOME = "liveRoomGiftIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_DATING_INCOME = "datingIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_TASK_INCOME = "taskIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_MINING_INCOME = "miningIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_CAPTURE_COMPERE_DEFEND_INCOME = "captureCompereDefendIncome";
//    private static final String COMPERE_TOTAL_INCOME_FIELD_CAPTURE_COMPERE_RANSOM_INCOME = "captureCompereRansomIncome";
//
//    @Autowired
//    private CompereCacheLoader compereCacheLoader;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private SocietyCacheController societyCacheController;
//    @Autowired
//    private CommonCacheController commonCacheController;
//    @Autowired
//    private CommonCacheLoader commonCacheLoader;
//    @Autowired
//    private TSocietyMapper societyMapper;
//
//    public void updateCompereForRoomInfo(CacheCompereProfile compere, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compere.getUserId();
//        if (compere.getRoomId() != null) {
//            cache.hset(key, COMPERE_FIELD_ROOMID, compere.getRoomId());
//            cache.hset(key, COMPERE_FIELD_ROOMNAME, compere.getRoomName());
//            if (compere.getRoomPassword() != null) {
//                cache.hset(key, COMPERE_FIELD_ROOMPASSWORD,
//                        compere.getRoomPassword());
//            }
//        }
//        if (compere.getLiveActivityType() != null) {
//            cache.hset(key, COMPERE_FIELD_LIVE_ACTIVITY_TYPE,
//                    compere.getLiveActivityType());
//            cache.hset(key, COMPERE_FIELD_LIVE_ACTIVITY_TYPE,
//                    compere.getLiveActivityType());
//        }
//    }
//
//    public void updateForCloseLiveActivity(String compereId, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compereId;
//
//        cache.hdel(key, COMPERE_FIELD_LIVE_ACTIVITY_TYPE);
//        cache.hdel(key, COMPERE_FIELD_LIVE_ACTIVITY_NAME);
//    }
//
//    public void updateForCloseRoom(String compereId, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compereId;
//
//        cache.hdel(key, COMPERE_FIELD_ROOMID);
//        cache.hdel(key, COMPERE_FIELD_ROOMNAME);
//        cache.hdel(key, COMPERE_FIELD_ROOMPASSWORD);
//        cache.hdel(key, COMPERE_FIELD_LIVE_ACTIVITY_TYPE);
//        cache.hdel(key, COMPERE_FIELD_LIVE_ACTIVITY_NAME);
//    }
//
//    public void updateLocation(String userId, float latitude, float longitude,
//            ICache cache) throws Exception {
//        if (isExist(userId, cache)) {
//            String key = COMPERE_KEY_PREFIX + userId;
//            cache.hset(key, USER_FIELD_LATITUDE, latitude + "");
//            cache.hset(key, USER_FIELD_LONGITUDE, longitude + "");
//        } else {
//            loadCompereDetail(userId, cache);
//        }
//    }
//
//    public boolean isExist(String userId, ICache cache) {
//        return cache.hget(COMPERE_KEY_PREFIX + userId,
//                COMPERE_FIELD_USERID) != null;
//    }
//
////    public void incomeCoin(Long userId, int income, ICache cache)
////            throws Exception {
////        if (isExist(userId + "", cache)) {
////            cache.hincrby(COMPERE_KEY_PREFIX + userId, COMPERE_FIELD_COINAMOUNT,
////                    income);
////        } else {
////            getCompereDetail(userId + "", cache);
////        }
////    }
//
////    public void incomeJewel(Long userId, int income, ICache cache)
////            throws Exception {
////        if (isExist(userId + "", cache)) {
////            cache.hincrby(COMPERE_KEY_PREFIX + userId,
////                    COMPERE_FIELD_JEWELAMOUNT, income);
////        } else {
////            getCompereDetail(userId + "", cache);
////        }
////    }
//
//    public void addAttention(String userId, String attentedId, ICache cache) throws Exception {
//        String mycompereKey = MYCOMPERE_KEY_PREFIX + userId;
//        Map<String, String> comperesKeyValues = cache.hgetAll(mycompereKey);
//
//        if (MapUtils.isNotEmpty(comperesKeyValues)) {
//            CacheCompereListProfile m = new CacheCompereListProfile();
//            m.setUserId(attentedId);
//
//            String compereKey = COMPERE_KEY_PREFIX + attentedId;
//
//            String userid = cache.hget(compereKey, COMPERE_FIELD_USERID);
//
//            if (userid == null) {
//                try {
//                    CacheCompereProfile profile = compereCacheLoader.loadCompereDetails(attentedId);
//
//                    cache.hmset(COMPERE_KEY_PREFIX + attentedId, profile.generateHashMapBySelective());
//
//                    m.setPhotoUrl(profile.getPhotoUrl());
//                    m.setNickName(profile.getNickName());
//
//                } catch (Exception e) {
//                    // TODO Auto-generated catch block
//                    return;
//                }
//            } else {
//                m.setPhotoUrl(cache.hget(compereKey, COMPERE_FIELD_PHOTOURL));
//                m.setNickName(cache.hget(compereKey, COMPERE_FIELD_NICKNAME));
//                cache.hincrby(COMPERE_KEY_PREFIX + attentedId, COMPERE_FIELD_FANSCOUNT, 1);
//            }
//
//            cache.hset(MYCOMPERE_KEY_PREFIX + userId, attentedId, JSON.toJSONString(m));
//        } else {
//            playerCacheController.queryAttentionCompereByPlayerId(Long.parseLong(userId), cache);
//        }
//
//        String fansKey = FANS_KEY_PREFIX + attentedId;
//        Map<String, String> fansKeyValues = cache.hgetAll(fansKey);
//        if (MapUtils.isNotEmpty(fansKeyValues)) {
//            CachePlayerListProfile m = new CachePlayerListProfile();
//            m.setUserId(userId);
//
//            CachePlayerProfile userProfile = playerCacheController
//                    .queryPlayerDetail(Long.parseLong(userId), cache, false, false);
//
//            m.setPhotoUrl(userProfile.getPhotoUrl());
//            m.setNickName(userProfile.getNickName());
//            m.setStatus(userProfile.getStatus());
//            m.setOnlineStatus(userProfile.getOnlineStatus());
//            m.setSex(userProfile.getSex());
//            m.setBirthday(userProfile.getBirthday());
//            m.setLongitude(userProfile.getLongitude());
//            m.setLatitude(userProfile.getLatitude());
//            m.setSign(userProfile.getSign());
//            m.setVipLevel(userProfile.getVipLevel().toString());
//            cache.hset(fansKey, m.getUserId(), JSON.toJSONString(m));
//        } else {
//            queryFansPlayerByCompereId(Long.parseLong(attentedId), cache);
//        }
//    }
//
//    public void removeAttention(String userId, String compereId, ICache cache) throws Exception {
//        if (isExist(compereId, cache)) {
//            cache.hincrby(COMPERE_KEY_PREFIX + compereId, COMPERE_FIELD_FANSCOUNT, -1);
//        } else {
//            loadCompereDetail(compereId, cache);
//        }
//
//        String fansKey = FANS_KEY_PREFIX + compereId;
//        if (isExistFans(compereId, cache)) {
//            cache.hdel(fansKey, userId);
//        } else {
//            queryFansPlayerByCompereId(Long.parseLong(compereId), cache);
//        }
//
//        String attentionKey = MYCOMPERE_KEY_PREFIX + userId;
//
//        if (playerCacheController.isExistAttention(userId, cache)) {
//            cache.hdel(attentionKey, compereId);
//        } else {
//            playerCacheController.queryAttentionCompereByPlayerId(Long.parseLong(userId), cache);
//        }
//    }
//
//    private boolean isExistFans(String compereId, ICache cache) throws Exception {
//        String key = FANS_KEY_PREFIX + compereId;
//        Map<String, String> fansKeyValues = cache.hgetAll(key);
//        return !fansKeyValues.isEmpty();
//    }
//
//    public void setAdmin(String compereId, String adminId, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compereId;
//
//        String ids = cache.hget(key, COMPERE_FIELD_ADMINS);
//
//        if (StringUtils.isEmpty(ids)) {
//            return;
//        } else {
//            ids += "_" + adminId;
//
//            cache.hset(key, COMPERE_FIELD_ADMINS, ids);
//        }
//    }
//
//    public void cancelAdmin(String compereId, String adminId, ICache cache) {
//        String key = COMPERE_KEY_PREFIX + compereId;
//
//        String ids = cache.hget(key, COMPERE_FIELD_ADMINS);
//
//        if (StringUtils.isEmpty(ids)) {
//            return;
//        } else {
//            String[] adminIds = ids.split(COMPERE_VALUE_ADMINS_SPLIT);
//
//            String newIds = "";
//            for (int i = 0; i < adminIds.length; i++) {
//                if (!adminIds[i].equals(adminId)) {
//                    newIds += COMPERE_VALUE_ADMINS_SPLIT + adminIds[i];
//                }
//            }
//
//            cache.hset(key, COMPERE_FIELD_ADMINS, newIds.substring(1));
//
//        }
//    }
//
//    private CacheCompereProfile loadCompereDetail(String compereId, ICache cache) throws Exception {
//        CacheCompereProfile compereDetail = compereCacheLoader.loadCompereDetails(compereId);
//        if (compereDetail != null) {
//            cache.hmset(COMPERE_KEY_PREFIX + compereId, compereDetail.generateHashMapBySelective());
//        }
//
//        return compereDetail;
//    }
//
//    /**
//     * 获取主播详情
//     *
//     * @param compereId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public CacheCompereProfile getCompereDetail(String compereId, ICache cache, boolean needAccount, boolean needMoments)
//            throws Exception {
//        CacheCompereProfile compereDetail = null;
//        String key = COMPERE_KEY_PREFIX + compereId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map != null && map.size() > 0) {
//            compereDetail = (CacheCompereProfile) BeanMapUtils.toBeanBySelective(CacheCompereProfile.class, map);
//        } else {
//            compereDetail = loadCompereDetail(compereId, cache);
//            cache.hmset(key, compereDetail.generateHashMapBySelective());
//        }
//        if (compereDetail != null) {
//            if(needMoments) {
//                // 获取朋友圈状态
//                List<TMoments> moments = commonCacheController.queryMoments(Long.parseLong(compereId), cache);
//                if (moments.size() > Constants.MOMENT_PAGE_COUNT) {
//                    moments = moments.subList(0, Constants.MOMENT_PAGE_COUNT);
//                }
//                compereDetail.setMoments(moments);
//            }
//
//            if(needAccount) {
//                String coinResult = GameServerUtil.invokeQuery(Long.parseLong(compereId));
//                JSONObject jsonObject = JSONObject.parseObject(coinResult);
//                if (jsonObject.containsKey("coinAmount") && StringUtils.isNotBlank(jsonObject.getString("coinAmount"))) {
//                    compereDetail.setCoinAmount(jsonObject.getLong("coinAmount"));
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "宝贝币账户不存在");
//                }
//                if (jsonObject.containsKey("jewelAmount") && StringUtils.isNotBlank(jsonObject.getString("jewelAmount"))) {
//                    compereDetail.setJewelAmount(jsonObject.getInteger("jewelAmount"));
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "房卡账户不存在");
//                }
//            }
//
//            if (compereDetail.getOwnerId() != null) {
//                CachePlayerProfile player = playerCacheController.queryPlayerDetail(compereDetail.getOwnerId(), cache, false, false);
//                if (player != null) {
//                    compereDetail.setOwnerNickname(player.getNickName());
//                    compereDetail.setOwnerPhotoUrl(player.getPhotoUrl());
//                }
//            }
//        }
//        String societyIdStr = compereDetail.getSocietyId();
//        if (StringUtils.isNotBlank(societyIdStr)) {
//            Long societyId = Long.parseLong(societyIdStr);
//            TSociety society = societyMapper.selectByPrimaryKey(societyId);
//            compereDetail.setSocietyMasterPhone(society.getMasterPhone());
//            compereDetail.setSocietyMasterId(society.getMasterId().toString());
//        }
//
//        //主播直播优先级字段
//        String priorityKey = COMPERE_PRIORITY_KEY_PREFIX;
//        String priorityStr = cache.hget(priorityKey, compereId.toString());
//        if (StringUtils.isBlank(priorityStr)) {
//            Integer priority = compereCacheLoader.loadComperePriority(compereId);
//            compereDetail.setPriority(priority);
//            if (priority != null) {
//                cache.hset(priorityKey, compereId.toString(), priority.toString());
//            }
//        } else {
//            compereDetail.setPriority(Integer.parseInt(priorityStr));
//        }
//        return compereDetail;
//    }
//
//    public CacheCompereProfile getCompereDetail4GameServer(String compereId, ICache cache) throws Exception {
//        CacheCompereProfile compereDetail = null;
//        String key = COMPERE_KEY_PREFIX + compereId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map != null && map.size() > 0) {
//            compereDetail = (CacheCompereProfile) BeanMapUtils.toBeanBySelective(CacheCompereProfile.class, map);
//        } else {
//            compereDetail = loadCompereDetail(compereId, cache);
//            AccountVo vo = commonCacheLoader.getUserAccount(Long.parseLong(compereId));
//            compereDetail.setCoinAmount(vo.getCoinAmount());
//            compereDetail.setJewelAmount(vo.getJewelAmount().intValue());
//            cache.hmset(key, compereDetail.generateHashMapBySelective());
//        }
//        return compereDetail;
//    }
//
//    /**
//     * 更新缓存
//     *
//     * @param compere
//     * @param oldCity
//     * @param cache
//     * @throws Exception
//     */
//    public void updateCacheCompere(TCompere compere, String oldCity, ICache cache) throws Exception {
//        // 更新主播详情
//        String compereDetailKey = COMPERE_KEY_PREFIX + compere.getCompereId();
//        if (StringUtils.isNotBlank(compere.getUser().getSmallIcon())) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_PHOTOURL, compere.getUser().getSmallIcon());
//        }
//        if (StringUtils.isNotBlank(compere.getUser().getRoomPhoto())) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_ROOM_PHOTO, compere.getUser().getRoomPhoto());
//        }
//        if (StringUtils.isNotBlank(compere.getUser().getLivePhoto())) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_LIVE_PHOTO, compere.getUser().getLivePhoto());
//        }
//        if (StringUtils.isNotBlank(compere.getUser().getNickName())) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_NICKNAME, compere.getUser().getNickName());
//        }
//        if (StringUtils.isNotBlank(compere.getUser().getName())) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_NAME, compere.getUser().getName());
//        }
//        if (compere.getUser().getBirthday() != null) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_BIRTHDAY, JSON.toJSONString(compere.getUser().getBirthday()));
//        }
//        if (compere.getProvinceId() != null) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_PROVINCEID, compere.getProvinceId().toString());
//        }
//        if (compere.getCityId() != null) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_CITYID, compere.getCityId().toString());
//        }
//        if (compere.getTownId() != null) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_TOWNID, compere.getTownId().toString());
//        }
//
//        CacheCountry country = baseCacheController.queryCountry("CN", cache);
//        if (country != null) {
//            boolean isAddressMatched = false;
//            List<TProvince> provinces = country.getProvinces();
//            if (CollectionUtils.isNotEmpty(provinces)) {
//                for (TProvince province : provinces) {
//                    if (isAddressMatched) {
//                        break;
//                    } else if (compere.getProvinceId() == province.getProvinceId()) {
//                        cache.hset(compereDetailKey, COMPERE_FIELD_PROVINCE, province.getName());
//                        List<TCity> cities = province.getCities();
//                        if (CollectionUtils.isNotEmpty(cities)) {
//                            for (TCity city : cities) {
//                                if (isAddressMatched) {
//                                    break;
//                                } else if (compere.getCityId() == city.getCityId()) {
//                                    cache.hset(compereDetailKey, COMPERE_FIELD_CITY, city.getName());
//                                    List<TTown> towns = city.getTowns();
//                                    if (CollectionUtils.isNotEmpty(towns)) {
//                                        for (TTown town : towns) {
//                                            if (compere.getTownId() == town.getTownId()) {
//                                                cache.hset(compereDetailKey, COMPERE_FIELD_TOWN, town.getName());
//                                                isAddressMatched = true;
//                                                break;
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        if (StringUtils.isNotBlank(compere.getUser().getSign())) {
//            cache.hset(compereDetailKey, COMPERE_FIELD_SIGN, compere.getUser().getSign());
//        }
//
//        /*
//         * 更新玩家关注的主播列表
//         */
//        // 主播粉丝列表
//        Map<String, String> fansKeyValues = cache.hgetAll(FANS_KEY_PREFIX + compere.getCompereId());
//        if (!fansKeyValues.isEmpty()) {
//            for (String keyT : fansKeyValues.keySet()) {
//                CachePlayerListProfile cacheUser = JSON.parseObject(fansKeyValues.get(keyT),
//                        CachePlayerListProfile.class);
//                if (cacheUser != null) {
//                    Long userId = Long.parseLong(cacheUser.getUserId());
//                    // 玩家关注的主播列表
//                    List<CacheCompereListProfile> attentionComperes = playerCacheController
//                            .queryAttentionCompereByPlayerId(userId, cache);
//                    if (CollectionUtils.isNotEmpty(attentionComperes)) {
//                        for (int i = 0; i < attentionComperes.size(); i++) {
//                            CacheCompereListProfile attentionCompere = attentionComperes.get(i);
//                            if (attentionCompere.getUserId().equals(compere.getCompereId().toString())) {
//                                attentionCompere.setPhotoUrl(compere.getUser().getSmallIcon());
//                                attentionCompere.setNickName(compere.getUser().getNickName());
//                                attentionCompere.setBirthday(compere.getUser().getBirthday());
//                                attentionCompere.setSign(compere.getUser().getSign());
//                                playerCacheController.updateAttentionCompere(userId, attentionCompere, cache);
//                                break;
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    /**
//     * 通过实体类批量更新主播详情
//     *
//     * @param profile
//     * @param cache
//     * @throws Exception
//     */
//    // public void updateCompereDetail(CacheUserProfile profile, ICache cache)
//    // throws Exception {
//    // String key = COMPERE_KEY_PREFIX + profile.getUserId();
//    // Map<String, String> map = BeanMapUtils.toMapBySelective(profile);
//    // cache.hmset(key, map);
//    // }
//
//    /**
//     * 查询主播粉丝
//     *
//     * @param compereId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CachePlayerListProfile> queryFansPlayerByCompereId(Long compereId, ICache cache) throws Exception {
//        List<CachePlayerListProfile> fans = null;
//        String key = FANS_KEY_PREFIX + compereId;
//        Map<String, String> keyValues = cache.hgetAll(key);
//        if (!keyValues.isEmpty()) {
//            fans = new ArrayList<CachePlayerListProfile>();
//            for (String keyT : keyValues.keySet()) {
//                fans.add(JSON.parseObject(keyValues.get(keyT), CachePlayerListProfile.class));
//            }
//        } else {
//            fans = compereCacheLoader.loadFans(compereId.toString());
//            if (CollectionUtils.isNotEmpty(fans)) {
//                for (CacheUserListProfile culp : fans) {
//                    cache.hset(key, culp.getUserId(), JSON.toJSONString(culp));
//                }
//            }
//        }
//        return fans;
//    }
//
//    /**
//     * 查询玩家是否是某个主播的粉丝
//     *
//     * @param compereId
//     * @param playerId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public String isFanPlayerByCompereId(String compereId, String playerId, ICache cache) throws Exception {
//        String isFan = Constants.NOT_FAN;
//        String key = FANS_KEY_PREFIX + compereId;
//        Map<String, String> keyValues = cache.hgetAll(key);
//        if (keyValues.isEmpty()) {
//            List<CachePlayerListProfile> fans = compereCacheLoader.loadFans(compereId.toString());
//            if (CollectionUtils.isNotEmpty(fans)) {
//                for (CachePlayerListProfile culp : fans) {
//                    cache.hset(key, culp.getUserId(), JSON.toJSONString(culp));
//                }
//            }
//        }
//        keyValues = cache.hgetAll(key);
//        if (!keyValues.isEmpty()) {
//            if (keyValues.containsKey(playerId)) {
//                isFan = Constants.IS_FAN;
//            }
//        }
//        return isFan;
//    }
//
//    /**
//     * 更新主播粉丝列表
//     *
//     * @param userId
//     * @param cacheUser
//     * @param cache
//     */
//    public void updateFansUser(Long userId, CachePlayerListProfile cacheUser, ICache cache) {
//        String key = FANS_KEY_PREFIX + userId;
//        cache.hset(key, cacheUser.getUserId(), JSON.toJSONString(cacheUser));
//    }
//
//    /**
//     * 查询主播收到的礼物
//     *
//     * @param compereId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<TUserGoods> queryAllGiftsByCompereId(String compereId, ICache cache) throws Exception {
//        List<TUserGoods> userGoods = null;
//        String key = GIFT_ALL_PREFIX + compereId;
//        List<String> goodsStrs = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(goodsStrs)) {
//            userGoods = new ArrayList<TUserGoods>();
//            for (String gStr : goodsStrs) {
//                userGoods.add(JSON.parseObject(gStr, TUserGoods.class));
//            }
//        } else {
//            userGoods = compereCacheLoader.loadAllGifts(compereId);
//            if (CollectionUtils.isNotEmpty(userGoods)) {
//                String[] temp = new String[userGoods.size()];
//                for (int i = 0; i < userGoods.size(); i++) {
//                    temp[i] = JSON.toJSONString(userGoods.get(i));
//                }
//                cache.rpush(key, temp);
//            }
//        }
//        return userGoods;
//    }
//
//    /**
//     * 查询玩家对主播贡献排行
//     *
//     * @param compereId
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public List<CachePlayerListProfile> queryContributionRank(String compereId, ICache cache) throws Exception {
//        List<CachePlayerListProfile> players = null;
//        String key = CONTRIBUTION_RANK_PREFIX + compereId;
//        List<String> playerStrs = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(playerStrs)) {
//            players = new ArrayList<CachePlayerListProfile>();
//            for (String pStr : playerStrs) {
//                players.add(JSON.parseObject(pStr, CachePlayerListProfile.class));
//            }
//        } else {
//            players = compereCacheLoader.loadContributionRank(compereId);
//            if (CollectionUtils.isNotEmpty(players)) {
//                String[] temp = new String[players.size()];
//                for (int i = 0; i < players.size(); i++) {
//                    temp[i] = JSON.toJSONString(players.get(i));
//                }
//                cache.rpush(key, temp);
//            }
//        }
//        return players;
//    }
//
//    /**
//     * 查询附近主播列表
//     *
//     * @param cityId
//     * @param cache
//     * @return
//     */
//    public List<CacheCompereListProfile> queryCompereNearbyCityId(String cityId, ICache cache) {
//        List<CacheCompereListProfile> comperes = null;
//        String key = COMPERE_LIST_KEY_PREFIX + cityId;
//        Map<String, String> comperesMap = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(comperesMap)) {
//            comperes = new ArrayList<CacheCompereListProfile>();
//            for (String k : comperesMap.keySet()) {
//                comperes.add(JSON.parseObject(comperesMap.get(k), CacheCompereListProfile.class));
//            }
//        } else {
//            comperes = compereCacheLoader.loadCompereNearbyCityId(cityId);
//        }
//        return comperes;
//    }
//
//    public List<TUserGoodsPresentRecord> queryGiftsForMonth(Long compereId, String month, ICache cache)
//            throws Exception {
//        List<TUserGoodsPresentRecord> presentRecords = null;
//        Date date = DateUtils.getParseDate(month, "yyyy-MM");
//        Calendar calendar = Calendar.getInstance();
//        calendar.setTime(date);
//        Date startDate = calendar.getTime();
//        calendar.add(Calendar.MONTH, 1);
//        Date endDate = calendar.getTime();
//        String key = COMPERE_MONTHLY_INCOME_KEY_PREFIX + compereId + "_" + month;
//        List<String> list = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(list)) {
//            presentRecords = new ArrayList<TUserGoodsPresentRecord>();
//            for (String s : list) {
//                presentRecords.add(JSONObject.parseObject(s, TUserGoodsPresentRecord.class));
//            }
//        } else {
//            presentRecords = compereCacheLoader.loadPresentRecordByDateRange(compereId,
//                    DateUtils.getParseDate(startDate, "yyyy-MM-dd"), DateUtils.getParseDate(endDate, "yyyy-MM-dd"));
//            if (CollectionUtils.isNotEmpty(presentRecords)) {
//                for (TUserGoodsPresentRecord gpr : presentRecords) {
//                    cache.rpush(key, JSON.toJSONString(gpr));
//                }
//            }
//        }
//        return presentRecords;
//    }
//
//    public List<TUserGoodsPresentRecord> queryTodayGifts(Long compereId, ICache cache) throws Exception {
//        List<TUserGoodsPresentRecord> presentRecords = null;
//        Date nowDate = new Date();
//        String key = COMPERE_TODAY_INCOME_KEY_PREFIX + compereId;
//        List<String> list = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(list)) {
//            presentRecords = new ArrayList<TUserGoodsPresentRecord>();
//            for (String s : list) {
//                presentRecords.add(JSONObject.parseObject(s, TUserGoodsPresentRecord.class));
//            }
//        } else {
//            String startDate = DateUtils.getParseDate(nowDate, "yyyy-MM-dd");
//            presentRecords = compereCacheLoader.loadPresentRecordByDateRange(compereId, startDate,
//                    startDate + "23:59:59");
//            if (CollectionUtils.isNotEmpty(presentRecords)) {
//                for (TUserGoodsPresentRecord gpr : presentRecords) {
//                    cache.rpush(key, JSON.toJSONString(gpr));
//                }
//            }
//        }
//        return presentRecords;
//    }
//
//    public void deleteYesterdayGifts(ICache cache) throws Exception {
//        List<TCompere> comperes = compereCacheLoader.loadAllComperes();
//        if (CollectionUtils.isNotEmpty(comperes)) {
//            for (TCompere compere : comperes) {
//                String key = COMPERE_TODAY_INCOME_KEY_PREFIX + compere.getCompereId();
//                cache.del(key);
//            }
//        }
//    }
//
//    public CacheCompereRelation queryCompereRelation(Long compereId, ICache cache) throws Exception {
//        CacheCompereRelation compereRelation = null;
//        String key = COMPERE_RELATION_KEY_PREFIX + compereId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            compereRelation = (CacheCompereRelation) BeanMapUtils.toBeanBySelective(CacheCompereRelation.class, map);
//        } else {
//            compereRelation = compereCacheLoader.loadCompereRelation(compereId);
//            if (compereRelation != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereRelation));
//            }
//        }
//        return compereRelation;
//    }
//
//    public void updateCompereDetailField(Long compereId, String field, String value, ICache cache) throws Exception {
//        String key = COMPERE_KEY_PREFIX + compereId;
//        if (cache.hlen(key) == 0) {
//            this.getCompereDetail(compereId.toString(), cache, false, false);
//        } else {
//            cache.hset(key, field, value);
//        }
//    }
//
//    public void increaseCompereDetailField(Long compereId, String field, Integer value, ICache cache) throws Exception {
//        String key = COMPERE_KEY_PREFIX + compereId;
//        if (cache.hlen(key) == 0) {
//            this.getCompereDetail(compereId.toString(), cache, false, false);
//        } else {
//            cache.hincrby(key, field, value);
//        }
//    }
//
//
//    /**
//     * 登陆的时候修改缓存
//     *
//     * @param compereId
//     * @throws Exception
//     */
//    public void login(Long compereId, ICache cache) throws Exception {
//        // 主播详情
//        CacheUserProfile compere = getCompereDetail(compereId.toString(),
//                cache, true, true);
//        compere.setOnlineStatus(Constants.ON_LINE);
//        updateCompereDetailField(compereId, COMPERE_FIELD_ONLINE_STATUS, Constants.ON_LINE, cache);
//    }
//
//    public boolean lockCompere(Long compereId) {
//        String key = COMPERE_KEY_PREFIX + compereId;
//        RedisLock lock = new RedisLock(key);
//        return lock.lock(1000 * 5); // 等待超时时间5秒
//    }
//
//    public void unlockCompere(Long compereId) {
//        String key = COMPERE_KEY_PREFIX + compereId;
//        RedisLock lock = new RedisLock(key);
//        lock.unlock();
//    }
//
//    public List<TCompereIncome> queryCompereIncomesForMonth(Long compereId, String month, ICache cache)
//            throws Exception {
//        Date nowDate = new Date();
//        List<TCompereIncome> compereIncomes = null;
//        List<String> compereIncomeDates = this.queryCompereIncomeDatesForMonth(compereId, month, cache);
//        if (CollectionUtils.isNotEmpty(compereIncomeDates)) {
//            List<String> newDates = new ArrayList<String>();
//            compereIncomes = new ArrayList<TCompereIncome>();
//            for (int i = 0; i < compereIncomeDates.size(); i++) {
//                TCompereIncome compereIncome = this.queryCompereIncomeByDate(compereId, compereIncomeDates.get(i), cache);
//                if ("0".equals(compereIncome.getHasIncome())) {
//                    if (DateUtils.isSameDate(nowDate, compereIncome.getIncomeDate())) {
//                        compereIncomes.add(compereIncome);
//                        newDates.add(compereIncomeDates.get(i));
//                    } else if (compereIncome.getIncomeDate().after(nowDate)) {
//                        newDates.add(compereIncomeDates.get(i));
//                    }
//                } else {
//                    compereIncomes.add(compereIncome);
//                    newDates.add(compereIncomeDates.get(i));
//                }
//            }
//            if (compereIncomeDates.size() != newDates.size()) {
//                String idKey = COMPERE_TOTAL_INCOME_ID_LIST_KEY_PREFIX + compereId + "_" + month;
//                cache.del(idKey);
//                cache.rpush(idKey, newDates);
//                for (String oldDate : compereIncomeDates) {
//                    if (!newDates.contains(oldDate)) {
//                        cache.del(COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + oldDate);
//                    }
//                }
//            }
//        }
//        return compereIncomes;
//    }
//
//    public List<String> queryCompereIncomeDatesForMonth(Long compereId, String month, ICache cache) throws Exception {
//        List<String> compereIncomeDates = null;
//        Date date = DateUtils.getParseDate(month, "yyyy-MM");
//        Calendar calendar = Calendar.getInstance();
//        String nowDateStr = DateUtils.getParseDate(calendar.getTime(), "yyyy-MM-dd");
//        calendar.setTime(date);
//        Date startDate = calendar.getTime();
//        calendar.add(Calendar.MONTH, 1);
//        Date endDate = calendar.getTime();
//        String key = COMPERE_TOTAL_INCOME_ID_LIST_KEY_PREFIX + compereId + "_" + month;
//        List<String> list = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(list)) {
//            compereIncomeDates = new ArrayList<String>();
//            for (String s : list) {
//                compereIncomeDates.add(s);
//            }
//        } else {
//            compereIncomeDates = compereCacheLoader.loadCompereIncomeDatesByByDateRange(compereId,
//                    DateUtils.getParseDate(startDate, "yyyy-MM-dd"), DateUtils.getParseDate(endDate, "yyyy-MM-dd"), nowDateStr);
//            if (CollectionUtils.isNotEmpty(compereIncomeDates)) {
////                List<String> ids = new ArrayList<String>();
////                for (Long id : compereIncomeIds) {
////                    ids.add(id.toString());
////                }
//                cache.rpush(key, compereIncomeDates);
//            }
//        }
//        return compereIncomeDates;
//    }
//
//    public TCompereIncome queryCompereIncomeByDate(Long compereId, String date, ICache cache) throws Exception {
//        TCompereIncome compereIncome = null;
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + date;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            compereIncome = (TCompereIncome) BeanMapUtils.toBeanBySelective(TCompereIncome.class, map);
//        } else {
//            compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, date);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//        return compereIncome;
//    }
//
//    /**
//     * 批量插入主播收入记录
//     * @param compereIncomes
//     * @param month
//     * @param cache
//     * @throws Exception
//     */
//    public void batchAddCompereIncome(List<TCompereIncome> compereIncomes, String month, ICache cache)
//            throws Exception {
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//        for (TCompereIncome ci : compereIncomes) {
//            String dateKey = COMPERE_TOTAL_INCOME_ID_LIST_KEY_PREFIX + ci.getCompereId() + "_" + month;
//            List<String> ciDates = this.queryCompereIncomeDatesForMonth(ci.getCompereId(), month, cache);
//            String incomeDateStr = sdf.format(ci.getIncomeDate());
//            if (CollectionUtils.isNotEmpty(ciDates)) {
//                if (!ciDates.contains(incomeDateStr)) {
//                    cache.rpush(dateKey, incomeDateStr);
//                }
//            } else {
//                cache.rpush(dateKey, incomeDateStr);
//            }
//            cache.hmset(COMPERE_TOTAL_INCOME_KEY_PREFIX + ci.getCompereId() + "_" + incomeDateStr, BeanMapUtils.toMapBySelective(ci));
//        }
//    }
//
//    /**
//     * 插入主播收入记录
//     * @param compereIncome
//     * @param month
//     * @param cache
//     * @throws Exception
//     */
//    public void addCompereIncome(TCompereIncome compereIncome, String month, ICache cache) throws Exception {
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//        String dateKey = COMPERE_TOTAL_INCOME_ID_LIST_KEY_PREFIX + compereIncome.getCompereId() + "_" + month;
//        List<String> ciDates = this.queryCompereIncomeDatesForMonth(compereIncome.getCompereId(), month, cache);
//        String incomeDateStr = sdf.format(compereIncome.getIncomeDate());
//        if (CollectionUtils.isNotEmpty(ciDates)) {
//            if (!ciDates.contains(incomeDateStr)) {
//                cache.rpush(dateKey, incomeDateStr);
//            }
//        } else {
//            cache.rpush(dateKey, incomeDateStr);
//        }
//        cache.hmset(COMPERE_TOTAL_INCOME_KEY_PREFIX + compereIncome.getCompereId() + "_" + incomeDateStr,
//                BeanMapUtils.toMapBySelective(compereIncome));
//    }
//
//    public void addGameMatchExtractIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_MATCH_EXTRACT_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//
//    }
//
//    public void addLiveRoomGameExtractIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_LIVE_ROOM_GAME_EXTRACT_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//    }
//
//    public void addLiveRoomGiftIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_LIVE_ROOM_GIFT_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//    }
//
//    public void addDatingIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_DATING_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//
//    }
//
//    public void addTaskIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_TASK_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//    }
//
//    public void addMiningIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_MINING_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//    }
//
//    public void addCaptureCompereDefendIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_CAPTURE_COMPERE_DEFEND_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//    }
//
//    public void addCaptureCompereRansomIncome(Long compereId, String incomeDate, int income, ICache cache) throws Exception {
//        String key = COMPERE_TOTAL_INCOME_KEY_PREFIX + compereId + "_" + incomeDate;
//        if (cache.hlen(key) != 0) {
//            cache.hincrby(key, COMPERE_TOTAL_INCOME_FIELD_CAPTURE_COMPERE_RANSOM_INCOME, income);
//            cache.hset(key, COMPERE_TOTAL_INCOME_FIELD_HAS_INCOME, "1");
//        } else {
//            TCompereIncome compereIncome = compereCacheLoader.loadCompereIncomeByDate(compereId, incomeDate);
//            if (compereIncome != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(compereIncome));
//            }
//        }
//    }
//}
