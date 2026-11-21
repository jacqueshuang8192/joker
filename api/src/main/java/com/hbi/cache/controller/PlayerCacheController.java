package com.hbi.cache.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.beanUtil.BeanMapUtils;
import com.core.util.HttpUtil;
import com.hbi.cache.ICache;
import com.hbi.cache.cacheWritter.CommonCacheLoader;
import com.hbi.cache.cacheWritter.PlayerCacheLoader;
import com.hbi.cache.model.CacheCompereListProfile;
import com.hbi.cache.model.CacheCountry;
import com.hbi.cache.model.CachePlayerProfile;
import com.hbi.constants.Constants;
import com.hbi.model.TCity;
import com.hbi.model.TPlayer;
import com.hbi.model.TProvince;
import com.hbi.model.TTown;
import com.hbi.model.TUser;
import com.hbi.utils.GameServerUtil;
import com.hbi.utils.InfServerException;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.hbi.mapper.TUserMapper;

import java.beans.IntrospectionException;
import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class PlayerCacheController {

    @Autowired
    private PlayerCacheLoader playerCacheLoader;
    @Autowired
    private BaseCacheController baseCacheController;
//    @Autowired
//    private SocietyCacheController societyCacheController;
    @Autowired
    private CommonCacheController commonCacheController;
    @Autowired
    private CommonCacheLoader commonCacheLoader;
    @Autowired
    private TUserMapper tUserMapper;

    private static final String PLAYER_KEY_PREFIX = "PLAYER_";
    private static final String MYCOMPERE_KEY_PREFIX = "MYCOMPERE_";
    private static final String PLAYER_RELATION_KEY_PREFIX = "PLAYER_RELATION_";
    private static final String PLATFORM_LEVEL_KEY = "PLATFORM_LEVEL";
    private static final String VIP_LEVEL_KEY = "VIP_LEVEL";

//    private static final String PLAYER_FIELD_COINAMOUNT = "coinAmount";

    private static final String PLAYER_FIELD_USERID = "userId";
    private static final String PLAYER_FIELD_PHOTOURL = "photoUrl";
    private static final String PLAYER_FIELD_NICKNAME = "nickName";
    private static final String PLAYER_FIELD_NAME = "name";
    private static final String PLAYER_FIELD_PHONE = "phone";
    private static final String PLAYER_FIELD_BIRTHDAY = "birthday";
    private static final String PLAYER_FIELD_PROVINCEID = "provinceId";
    private static final String PLAYER_FIELD_PROVINCE = "province";
    private static final String PLAYER_FIELD_CITYID = "cityId";
    private static final String PLAYER_FIELD_CITY = "city";
    private static final String PLAYER_FIELD_TOWNID = "townId";
    private static final String PLAYER_FIELD_GENDER = "sex";
    private static final String PLAYER_FIELD_TOWN = "town";
    private static final String PLAYER_FIELD_SIGN = "sign";
    private static final String PLAYER_FIELD_BINDCOMPEREID = "bindCompereId";
    private static final String PLAYER_FIELD_EXPRIENCE = "experience";
    private static final String PLAYER_FIELD_VIP_LEVEL = "vipLevel";
    private static final String USER_FIELD_LATITUDE = "latitude";
    private static final String USER_FIELD_LONGITUDE = "longitude";
//    private static final String PLAYER_FIELD_JEWELAMOUNT = "jewelAmount";
    private static final String PLAYER_FIELD_PROMOTER_ID = "promoterId";
    private static final String PLAYER_FIELD_CHARGE_SUM = "chargeSum";
    
    private static final String PROMO_CODE_SUB_PLAYER_KEY_PREFIX = "PROMO_CODE_SUB_PLAYER_";

    private static final String ROBOT_NICKNAME_KEY_PREFIX = "ROBOT_NICKNAME_KEY";

    public void updateLocation(String userId, float latitude, float longitude,
            ICache cache) throws Exception {
        if (isExist(userId, cache)) {
            String key = PLAYER_KEY_PREFIX + userId;
            cache.hset(key, USER_FIELD_LATITUDE, latitude + "");
            cache.hset(key, USER_FIELD_LONGITUDE, longitude + "");
        } else {
            queryPlayerDetail(Long.parseLong(userId), cache, true, true);
        }
    }

    public boolean isExist(String userId, ICache cache) {
        return cache.hget(PLAYER_KEY_PREFIX + userId,
                PLAYER_FIELD_USERID) != null;
    }

    public boolean isExistAttention(String userId, ICache cache) {
        String key = MYCOMPERE_KEY_PREFIX + userId;
        Map<String, String> keyValues = cache.hgetAll(key);
        return !keyValues.isEmpty();
    }

    public String getNickName(Long userId, ICache cache) throws Exception {
        String result = cache.hget(PLAYER_KEY_PREFIX + userId,
                PLAYER_FIELD_NICKNAME);

        if (StringUtils.isEmpty(result)) {
            CachePlayerProfile p = queryPlayerDetail(userId, cache, false, false);
            result = p.getNickName();
        }

        return result;
    }

    public String getPhotoUrl(Long userId, ICache cache) throws Exception {
        String result = cache.hget(PLAYER_KEY_PREFIX + userId,
                PLAYER_FIELD_PHOTOURL);

        if (StringUtils.isEmpty(result)) {
            CachePlayerProfile p = queryPlayerDetail(userId, cache, false, false);
            result = p.getPhotoUrl();
        }

        return result;
    }
    
    public String getPhone(Long userId, ICache cache) throws Exception {
        String result = cache.hget(PLAYER_KEY_PREFIX + userId,
                PLAYER_FIELD_PHONE);

        if (StringUtils.isEmpty(result)) {
            CachePlayerProfile p = queryPlayerDetail(userId, cache, false, false);
            result = p.getPhone();
        }
        return result;
    }

    // public Integer viewAccount(Long userId, ICache cache) throws Exception {
    // String playerKey = PLAYER_KEY_PREFIX + userId;
    // String str = cache.hget(playerKey, PLAYER_FIELD_COINAMOUNT);
    // if (str == null) {
    // TAccount account = commonCacheLoader.loadAccountByUserId(userId);
    // Map<String, String> map = BeanMapUtils.toMap(account);
    // cache.hmset(playerKey, map);
    // return account.getCoinAmount();
    // }
    // return Integer.parseInt(str);
    // }

    /**
     * 获取玩家详细信息
     * 
     * @param playerId
     * @param cache
     * @return
     * @throws Exception
     */
    public CachePlayerProfile queryPlayerDetail(Long playerId, ICache cache, boolean needAccount, boolean needMoments)
            throws Exception {
        CachePlayerProfile playerDetail = null;
        String key = PLAYER_KEY_PREFIX + playerId;
        Map<String, String> fieldsMap = cache.hgetAll(key);
        if (fieldsMap != null && fieldsMap.size() > 0) {
            playerDetail = (CachePlayerProfile) BeanMapUtils
                    .toBeanBySelective(CachePlayerProfile.class, fieldsMap);
            if (StringUtils.isBlank(playerDetail.getAccount()) || playerDetail.getIsRobot() == null) {
                playerDetail = playerCacheLoader.loadPlayerDetails(playerId);
                if (playerDetail != null) {
                    cache.hmset(key, BeanMapUtils.toMapBySelective(playerDetail));
                }
            }
        } else {
            playerDetail = playerCacheLoader.loadPlayerDetails(playerId);
            if (playerDetail != null) {
                cache.hmset(key, BeanMapUtils.toMapBySelective(playerDetail));
            }
        }
        if (playerDetail != null) {
            if(needAccount) {
                TUser user = tUserMapper.selectByPrimaryKey(playerId);
                if (user != null && user.getPoint() != null) {
                    playerDetail.setCoinAmount(Long.valueOf(user.getPoint()));
                } else {
                    playerDetail.setCoinAmount(0L);
                }
                playerDetail.setJewelAmount(0);
//                String coinResult = GameServerUtil.invokeQuery(playerId);
//                JSONObject jsonObject = JSONObject.parseObject(coinResult);
//                if (jsonObject.containsKey("coinAmount")) {
//                    playerDetail.setCoinAmount(jsonObject.getLong("coinAmount"));
//                }
//                if (jsonObject.containsKey("jewelAmount") && StringUtils
//                        .isNotBlank(jsonObject.getString("jewelAmount"))) {
//                    playerDetail
//                            .setJewelAmount(jsonObject.getInteger("jewelAmount"));
//                } else {
//                    throw new InfServerException(
//                            Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR,
//                            "房卡账户不存在");
//                }
            }
        }
        return playerDetail;
    }

    /**
     * 查询平台等级特权列表
     * 
     * @param cache
     * @return
     */
//    public List<TPlatformLevel> queryPlatformLevelList(ICache cache) {
//        String key = PLATFORM_LEVEL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TPlatformLevel> platformLevels = playerCacheLoader
//                    .queryPlatformLevelList();
//            for (TPlatformLevel tPlatformLevel : platformLevels) {
//                cache.hset(key, tPlatformLevel.getLevel().toString(),
//                        JSONObject.toJSONString(tPlatformLevel));
//            }
//            return platformLevels;
//        } else {
//            List<TPlatformLevel> platformLevels = new ArrayList<TPlatformLevel>();
//            for (String keyT : map.keySet()) {
//                platformLevels.add(
//                        JSON.parseObject(map.get(keyT), TPlatformLevel.class));
//            }
//            return platformLevels;
//        }
//    }

    /**
     * 根据等级查询平台等级特权
     * 
     * @param level
     * @param cache
     * @return
     */
//    public TPlatformLevel queryPlatformLevel(Integer level, ICache cache) {
//        List<TPlatformLevel> list = queryPlatformLevelList(cache);
//        for (TPlatformLevel tPlatformLevel : list) {
//            if (tPlatformLevel.getLevel().equals(level)) {
//                return tPlatformLevel;
//            }
//        }
//        return null;
//    }

    /**
     * 查询VIP等级特权列表
     * 
     * @param cache
     * @return
     */
//    public List<TVipLevel> queryVipLevelList(ICache cache) {
//        String key = VIP_LEVEL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TVipLevel> vipLevels = playerCacheLoader.queryVipLevelList();
//            for (TVipLevel vipLevel : vipLevels) {
//                cache.hset(key, vipLevel.getLevel().toString(),
//                        JSONObject.toJSONString(vipLevel));
//            }
//            return vipLevels;
//        } else {
//            List<TVipLevel> vipLevels = new ArrayList<TVipLevel>();
//            for (String keyT : map.keySet()) {
//                vipLevels.add(JSON.parseObject(map.get(keyT), TVipLevel.class));
//            }
//            return vipLevels;
//        }
//    }

    /**
     * 根据等级查询VIP等级特权
     * 
     * @param level
     * @param cache
     * @return
     */
//    public TVipLevel queryVipLevel(Integer level, ICache cache) {
//        List<TVipLevel> levels = queryVipLevelList(cache);
//        for (TVipLevel tVipLevel : levels) {
//            if (tVipLevel.getLevel().equals(level)) {
//                return tVipLevel;
//            }
//        }
//        return null;
//    }

    /**
     * 查询玩家关注的主播列表
     * 
     * @param cache
     * @return
     */
//    public List<CacheCompereListProfile> queryAttentionCompereByPlayerId(
//            Long playerId, ICache cache) {
//        List<CacheCompereListProfile> attentionComperes = null;
//        String key = MYCOMPERE_KEY_PREFIX + playerId;
//        Map<String, String> keyValues = cache.hgetAll(key);
//        if (!keyValues.isEmpty()) {
//            attentionComperes = new ArrayList<CacheCompereListProfile>();
//            for (String keyT : keyValues.keySet()) {
//                attentionComperes.add(JSON.parseObject(keyValues.get(keyT),
//                        CacheCompereListProfile.class));
//            }
//        } else {
//            attentionComperes = playerCacheLoader
//                    .loadAttentionCompereByPlayerId(playerId);
//            if (CollectionUtils.isNotEmpty(attentionComperes)) {
//                for (CacheCompereListProfile cclp : attentionComperes) {
//                    cache.hset(key, cclp.getUserId(), JSON.toJSONString(cclp));
//                }
//            }
//        }
//        return attentionComperes;
//    }

//    public CachePlayerRelation queryPlayerRelation(Long playerId, ICache cache)
//            throws Exception {
//        CachePlayerRelation playerRelation = null;
//        String key = PLAYER_RELATION_KEY_PREFIX + playerId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            playerRelation = (CachePlayerRelation) BeanMapUtils
//                    .toBeanBySelective(CachePlayerRelation.class, map);
//        } else {
//            playerRelation = playerCacheLoader.loadPlayerRelation(playerId);
//            if (playerRelation != null) {
//                cache.hmset(key, BeanMapUtils.toMapBySelective(playerRelation));
//            }
//        }
//        return playerRelation;
//    }

    /**
     * 更新关注的主播列表
     * 
     * @param playerId
     * @param cacheCompere
     * @param cache
     */
    public void updateAttentionCompere(Long playerId,
            CacheCompereListProfile cacheCompere, ICache cache) {
        String key = MYCOMPERE_KEY_PREFIX + playerId;
        cache.hset(key, cacheCompere.getUserId(),
                JSON.toJSONString(cacheCompere));
    }

    /**
     * 通过实体类批量更新玩家详情
     * 
     * @param profile
     * @param cache
     * @throws IntrospectionException
     * @throws InvocationTargetException
     * @throws IllegalAccessException
     */
    public void updatePlayerDetail(CachePlayerProfile profile, ICache cache)
            throws Exception {
        String key = PLAYER_KEY_PREFIX + profile.getUserId();
        Map<String, String> map = BeanMapUtils.toMapBySelective(profile);
        cache.hmset(key, map);
    }

    public void updatePlayerField(Long userId, String field, String value, ICache cache) {
        String key = PLAYER_KEY_PREFIX + userId;
        if (cache.exist(key)) {
            cache.hset(key, field, value);
        }
    }
    
    

    /**
     * 更新缓存 @param player @param cache @throws Exception @throws
     */
    public void updateCachePlayer(TPlayer player, ICache cache)
            throws Exception {
        // 更新主播详情
        String playerDetailKey = PLAYER_KEY_PREFIX + player.getPlayerId();
        if (StringUtils.isNotBlank(player.getUser().getSmallIcon())) {
            cache.hset(playerDetailKey, PLAYER_FIELD_PHOTOURL,
                    player.getUser().getSmallIcon());
        }
        if (StringUtils.isNotBlank(player.getUser().getNickName())) {
            cache.hset(playerDetailKey, PLAYER_FIELD_NICKNAME,
                    player.getUser().getNickName());
        }
       
        if (StringUtils.isNotBlank(player.getUser().getName())) {
            cache.hset(playerDetailKey, PLAYER_FIELD_NAME,
                    player.getUser().getName());
        }
        if (player.getUser().getBirthday() != null) {
            cache.hset(playerDetailKey, PLAYER_FIELD_BIRTHDAY,
                    JSON.toJSONString(player.getUser().getBirthday()));
        }
        
        if (player.getProvinceId() != null) {
            cache.hset(playerDetailKey, PLAYER_FIELD_PROVINCEID,
                    player.getProvinceId().toString());
        }
        if (player.getCityId() != null) {
            cache.hset(playerDetailKey, PLAYER_FIELD_CITYID,
                    player.getCityId().toString());
        }

        if (player.getTownId() != null) {
            cache.hset(playerDetailKey, PLAYER_FIELD_TOWNID,
                    player.getTownId().toString());
        }

        if (player.getUser().getGender() != null) {
            cache.hset(playerDetailKey, PLAYER_FIELD_GENDER,
                    player.getUser().getGender());
        }

        CacheCountry country = baseCacheController.queryCountry("CN", cache);
        if (country != null) {
            boolean isAddressMatched = false;
            List<TProvince> provinces = country.getProvinces();
            if (CollectionUtils.isNotEmpty(provinces)) {
                for (TProvince province : provinces) {
                    if (isAddressMatched) {
                        break;
                    } else if (player.getProvinceId() == province
                            .getProvinceId()) {
                        cache.hset(playerDetailKey, PLAYER_FIELD_PROVINCE,
                                province.getName());
                        List<TCity> cities = province.getCities();
                        if (CollectionUtils.isNotEmpty(cities)) {
                            for (TCity city : cities) {
                                if (isAddressMatched) {
                                    break;
                                } else if (player.getCityId() == city
                                        .getCityId()) {
                                    cache.hset(playerDetailKey,
                                            PLAYER_FIELD_CITY, city.getName());
                                    List<TTown> towns = city.getTowns();
                                    if (CollectionUtils.isNotEmpty(towns)) {
                                        for (TTown town : towns) {
                                            if (player.getTownId() == town
                                                    .getTownId()) {
                                                cache.hset(playerDetailKey,
                                                        PLAYER_FIELD_TOWN,
                                                        town.getName());
                                                isAddressMatched = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if (StringUtils.isNotBlank(player.getUser().getSign())) {
            cache.hset(playerDetailKey, PLAYER_FIELD_SIGN,
                    player.getUser().getSign());
        }

        /*
         * 更新主播粉丝列表
         */
        // 获取我关注的主播
        Map<String, String> myCompereKeyValues = cache
                .hgetAll(MYCOMPERE_KEY_PREFIX + player.getPlayerId());
        if (!myCompereKeyValues.isEmpty()) {
            for (String myCompereKey : myCompereKeyValues.keySet()) {
                CacheCompereListProfile cacheUser = JSON.parseObject(
                        myCompereKeyValues.get(myCompereKey),
                        CacheCompereListProfile.class);
                if (cacheUser != null) {
                    Long userId = Long.parseLong(cacheUser.getUserId());
                    // 更新主播粉丝信息
//                    List<CachePlayerListProfile> fans = compereCacheController
//                            .queryFansPlayerByCompereId(userId, cache);
//                    if (CollectionUtils.isNotEmpty(fans)) {
//                        for (int i = 0; i < fans.size(); i++) {
//                            CachePlayerListProfile fan = fans.get(i);
//                            if (fan.getUserId()
//                                    .equals(player.getPlayerId().toString())) {
//                                fan.setPhotoUrl(
//                                        player.getUser().getSmallIcon());
//                                fan.setNickName(player.getUser().getNickName());
//                                fan.setBirthday(player.getUser().getBirthday());
//                                fan.setSign(player.getUser().getSign());
//                                compereCacheController.updateFansUser(userId,
//                                        fan, cache);
//                                break;
//                            }
//                        }
//                    }
                }
            }
        }
    }

    public void updatePlayerExprience(String playerId, Integer exprience,
            ICache cache) throws Exception {
        if (isExist(playerId, cache)) {
            cache.hset(PLAYER_KEY_PREFIX + playerId, PLAYER_FIELD_EXPRIENCE,
                    exprience.toString());
        } else {
            queryPlayerDetail(Long.parseLong(playerId), cache, true, true);
        }
    }
    
    public void updatePlayerVipLevelAndChargeSum(CachePlayerProfile player, ICache cache) throws Exception {
        if (isExist(player.getUserId(), cache)) {
            cache.hset(PLAYER_KEY_PREFIX + player.getUserId(), PLAYER_FIELD_VIP_LEVEL, player.getVipLevel().toString());
            cache.hset(PLAYER_KEY_PREFIX + player.getUserId(), PLAYER_FIELD_CHARGE_SUM,
                    player.getChargeSum().toString());

        } else {
            queryPlayerDetail(Long.parseLong(player.getUserId()), cache, true, true);
        }
    }

    public void bindCompere(String userId, String compereId, ICache cache)
            throws Exception {
        if (isExist(userId, cache)) {
            cache.hset(PLAYER_KEY_PREFIX + userId, PLAYER_FIELD_BINDCOMPEREID,
                    compereId);
        } else {
            queryPlayerDetail(Long.parseLong(userId), cache, true, true);
        }
    }

    public void login(Long playerId, ICache cache) throws Exception {
        // 玩家详情
        CachePlayerProfile player = queryPlayerDetail(playerId, cache, true, true);
        player.setOnlineStatus(Constants.ON_LINE);
        updatePlayerDetail(player, cache);

    }
    
    /**
     * 查询玩家下线
     * @param playerId
     * @param cache
     * @return
     */
    public List<String> findPromoCodePlayer(Long playerId, ICache cache) {
        String key = PROMO_CODE_SUB_PLAYER_KEY_PREFIX + playerId;
        List<String> subPlayers = cache.lgetAll(key);
        if (CollectionUtils.isEmpty(subPlayers)) {
            subPlayers = playerCacheLoader.loadSubPlayers(playerId);
        }
        return subPlayers;
    }
    
    /**
     * 新增玩家下线
     * @param playerId
     * @param subPlayerId
     * @param cache
     */
    public void addPromoCodePlayer(Long playerId, Long subPlayerId, ICache cache) {
        String key = PROMO_CODE_SUB_PLAYER_KEY_PREFIX + playerId;
        List<String> subPlayers = cache.lgetAll(key);
        if (CollectionUtils.isNotEmpty(subPlayers)) {
            cache.rpush(key, subPlayerId.toString());
        } else {
            subPlayers = playerCacheLoader.loadSubPlayers(playerId);
            cache.rpush(key, subPlayers);
        }
        
        String playerKey = PLAYER_KEY_PREFIX + subPlayerId;
        Map<String, String> fieldsMap = cache.hgetAll(playerKey);
        if (MapUtils.isNotEmpty(fieldsMap)) {
            cache.hset(playerKey, PLAYER_FIELD_PROMOTER_ID, playerId.toString());
        }
    }

    public String generateNickname(ICache cache) throws Exception {
        String key = ROBOT_NICKNAME_KEY_PREFIX;
        String name = "";
        if (cache.llen(key) < 5) {
            String url = "http://www.xuanpai.com/tool/names";
            String response = HttpUtil.sendPost(url, "pop=0");
            System.out.println(response);
            String regExp = "<li><font color=red>(\\S{1,4})</font><font color=blue>(\\S{1,4})</font></li>";
            Pattern pattern = Pattern.compile(regExp);
            Matcher matcher = pattern.matcher(response);
            while (matcher.find()) {
                name = matcher.group(1) + matcher.group(2);
                cache.rpush(key, name);
            }
        }
        name = cache.lpop(key);
        return name;
    }
}
