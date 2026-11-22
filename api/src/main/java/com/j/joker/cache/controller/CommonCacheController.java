package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.beanUtil.BeanMapUtils;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.ICache;
import com.j.joker.cache.cacheWritter.CommonCacheLoader;
import com.j.joker.cache.model.CacheGameActivity;
import com.j.joker.cache.model.CacheGameActivityPlayer;
import com.j.joker.cache.model.CacheUserProfile;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TActivityUserMapper;
import com.j.joker.mapper.TFreeGameActivityMapper;
import com.j.joker.model.*;
import com.j.joker.utils.InfServerException;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class CommonCacheController {

    private static final String KEY_SPLIT = "_";

    private static final String RANDOM_CODE_KEY = "RANDOM_CODE";

    private static final String TASK_KEY_PREFIX = "TASK_";
    private static final String TASK_LIST_KEY_PREFIX = "TASK_LIST_";
    
    private static final String GAME_TGDOUNIU_ROUND_KEY = "USERPLAY_TGDOUNIU_ROUND_";
    
    private static final String GAME_PEOPLE_NUM = "peopleNum";
    
    private static final String TASK_FIELD_ACTUALAMOUNT = "actualAmount";
    private static final String TASK_FIELD_STATUS = "status";

    private static final String USER_ITEM_KEY_PREFIX = "USER_ITEM_";

    private static final String USER_ACCOUNT_PREFIX = "USER_";
    
    private static final String MOMENTS_PREFIX = "MOMENTS_";
    
    private static final String ALBUM_PREFIX = "ALBUM_";

    private static final String GAME_MASTER_PREFIX = "GAME_MASTER_";

    private static final String WEALTH_RANK = "WEALTH_RANK";

    private static final String DATING_ACTIVITIES_KEY_PREFIX = "DATING_ACTIVITIES_";

    private static final String DATING_ACTIVITY_KEY_PREFIX = "DATING_ACTIVITY_";

    private static final String DATING_AUCTION_RANK_PREFIX = "DATING_AUCTION_RANK_";

    private static final String USER_DATING_ACTIVITY_KEY_PREFIX = "USER_DATING_ACTIVITY_";

    private static final String DATING_ACTIVITY_FIELD_HIGHEST_AUCTION_USER_ID = "highestAuctionUserId";
    private static final String DATING_ACTIVITY_FIELD_HIGHEST_AUCTION_COUNT = "highestAuctionCount";
    private static final String DATING_ACTIVITY_FIELD_LAST_AUCTION_DATE = "lastAuctionDate";
    private static final String DATING_ACTIVITY_FIELD_TOTAL_AUCTION_NUM = "totalAuctionNum";
    private static final String DATING_ACTIVITY_FIELD_STATUS = "status";
    private static final String DATING_ACTIVITY_FIELD_END_TYPE = "endType";
    private static final String DATING_ACTIVITY_FIELD_IS_EVALUATION = "isEvaluation";
    private static final String DATING_ACTIVITY_FIELD_ON_TIME_GRADE = "onTimeGrade";
    private static final String DATING_ACTIVITY_FIELD_SATISFACTION = "satisfaction";
    
    private static final String DATING_AUCTION_RECORD_KEY_PREFIX = "DATING_AUCTION_RECORD_";

    private static final String GAME_ACTIVITY_KEY_PREFIX = "GAME_ACTIVITY_";
    
    private static final String GAME_TYPE_KEY = "USERPLAY_TYPE_";
    private static final String GAME_ROUND_KEY = "USERPLAY_ROUND_";
    private static final String GAME_TYPE = "winer_pay";
    private static final String GAME_ROUND = "round";
    private static final String PAY_TYPE = "pay_type";
    
    
    private static final String TEST_CONFIG_CARD_KEY = "TEST_CONFIG_CARD_";
    private static final String COUNTENT = "content";
    private static final String LOCATION = "location";

    private static final String GAME_ACTIVITY_FIELD_PLAYERS = "players";

    private static final String GAME_ACTIVITY_FIELD_ORICOINS = "oriCoins";

    private static final String GAME_ACTIVITY_FIELD_ACTIVITY_ID = "gameActivityId";

    private static final String GAME_ACTIVITY_FIELD_STATUS = "status";

    private static final String VARIFY_PHONES_KEY = "VARIFY_PHONES";

    private static final String SHARE_COMPERE_KEY_PREFIX = "SHARE_COMPERE_";
    
    private static final String LOUD_SPEAKER_KEY = "LOUD_SPEAKER";
    
    private static final String USER_TYPE_KEY = "USER_TYPE";

    private static final String DEFAULT_PHOTOS_KEY = "DEFAULT_PHOTOS";

    private static final String GAME_CATEGORY_LIST_KEY = "GAME_CATEGORY_LIST";


    @Autowired
    private CommonCacheLoader commonCacheLoader;
    @Autowired
    private PlayerCacheController playerCacheController;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private TFreeGameActivityMapper freeGameActivityMapper;
    @Autowired
    private TActivityUserMapper activityUserMapper;

    public CacheGameActivity queryGameActivity(String invitationCode, ICache cache) {
        String key = GAME_ACTIVITY_KEY_PREFIX + invitationCode;

        Map<String, String> keyValues = cache.hgetAll(key);

        if (keyValues.isEmpty()) {
        	List<CacheGameActivity> list = freeGameActivityMapper.queryFreeGameByInviteCode(invitationCode);
        	
        	if (CollectionUtils.isEmpty(list)) {
        		return null;
        	} else {
        		CacheGameActivity result = list.get(0);
        		List<CacheGameActivityPlayer> players = activityUserMapper.queryFreeGamePlayers(Long.parseLong(result.getGameActivityId()));
        		result.setPlayers(players);
        		
        		try {
					cache.hmset(key, result.generateHashMapBySelective());
				} catch (Exception e) {
					// TODO Auto-generated catch block
					return result;
				}
        		
        		return result;
        	}
        }

        try {
            CacheGameActivity result = (CacheGameActivity) BeanMapUtils.toBeanBySelective(CacheGameActivity.class,
                    keyValues);
            List<CacheGameActivityPlayer> l = JSONArray.parseArray(cache.hget(key, GAME_ACTIVITY_FIELD_PLAYERS),
                    CacheGameActivityPlayer.class);

            result.setPlayers(l);

            return result;
        } catch (Exception e) {
            // TODO Auto-generated catch block
            return null;
        }
    }

    public String closeFreeGame(String inviteCode, ICache cache) {
        String key = GAME_ACTIVITY_KEY_PREFIX + inviteCode;

        String activityId = cache.hget(key, GAME_ACTIVITY_FIELD_ACTIVITY_ID);

        if (StringUtils.isEmpty(activityId)) {
            return activityId;
        }

        cache.del(key);

        return activityId;
    }

    public void playerTgDouniuRound(Long activityId,String peopleNum,ICache cache) {
        String key = GAME_TGDOUNIU_ROUND_KEY + activityId;
        cache.hset(key,GAME_PEOPLE_NUM, peopleNum);
       
    }
    
    public String startFreeGame(String inviteCode, ICache cache) {
        String key = GAME_ACTIVITY_KEY_PREFIX + inviteCode;

        String activityId = cache.hget(key, GAME_ACTIVITY_FIELD_ACTIVITY_ID);

        if (StringUtils.isEmpty(activityId)) {
            return activityId;
        }

        cache.hset(key, GAME_ACTIVITY_FIELD_STATUS, "1");
        return activityId;
    }
    
    

    public CacheGameActivity createFreeGameActivity(TFreeGameActivity m, TActivity t, String gameCode, int tableId, String inviteCode,
            int oriCoins, String type, String chatRoomId, ICache cache) throws Exception {
        CacheUserProfile userProfile = null;
        if (Constants.USER_TYPE_P.equalsIgnoreCase(type)) {
            userProfile = playerCacheController.queryPlayerDetail(t.getOwnerId(), cache, false, false);
        } else {
//            userProfile = compereCacheController.getCompereDetail(t.getOwnerId() + "", cache, false, false);
        }

        CacheGameActivityPlayer player = new CacheGameActivityPlayer();

        player.setDrawRounds(0);
        player.setLoseRounds(0);
        player.setNickName(userProfile.getNickName());
        player.setNowCoins(oriCoins);
        player.setOriCoins(oriCoins);
        player.setPhotoUrl(userProfile.getPhotoUrl());
        player.setUserId(t.getOwnerId() + "");
        player.setWinRounds(0);

        List<CacheGameActivityPlayer> players = new ArrayList<CacheGameActivityPlayer>();
        players.add(player);

        TGame game = baseCacheController.queryGameById(m.getGameId(), cache);
        
        CacheGameActivity activity = new CacheGameActivity();
        activity.setCoins(m.getCoins());
        activity.setOriCoins(oriCoins);
        activity.setGameActivityId(m.getActivityId() + "");
        activity.setGameId(m.getGameId() + "");
        activity.setInviteCode(inviteCode);
        activity.setStatus(0);
        activity.setPlayers(players);
        activity.setCreatorId(userProfile.getUserId());
        activity.setCreatorNickname(userProfile.getNickName());
        activity.setCreatorPhotoUrl(userProfile.getPhotoUrl());
        activity.setChatRoomId(chatRoomId);
        activity.setActivityName(t.getActivityName());
        activity.setTableId(tableId);
        activity.setGameName(game.getName());
        activity.setGamePhoto(game.getPhoto());
        activity.setStartDate(t.getStartDate());
        activity.setLevel(m.getLevel());
        activity.setGameCode(gameCode);

        cache.hmset(GAME_ACTIVITY_KEY_PREFIX + inviteCode, activity.generateHashMapBySelective());

        return activity;
    }
    
    public CacheGameActivity createFreeGameActivityByOthers(TFreeGameActivity m, TActivity t, String gameCode, int tableId, String inviteCode,
            int oriCoins, String type, String chatRoomId, ICache cache,Integer maxPlayerCount) throws Exception {
        CacheUserProfile userProfile = null;
        if (Constants.USER_TYPE_P.equalsIgnoreCase(type)) {
            userProfile = playerCacheController.queryPlayerDetail(t.getOwnerId(), cache, false, false);
        } else {
//            userProfile = compereCacheController.getCompereDetail(t.getOwnerId() + "", cache, false, false);
        }

//        CacheGameActivityPlayer player = new CacheGameActivityPlayer();
//
//        player.setDrawRounds(0);
//        player.setLoseRounds(0);
//        player.setNickName(userProfile.getNickName());
//        player.setNowCoins(oriCoins);
//        player.setOriCoins(oriCoins);
//        player.setPhotoUrl(userProfile.getPhotoUrl());
//        player.setUserId(t.getOwnerId() + "");
//        player.setWinRounds(0);

        List<CacheGameActivityPlayer> players = new ArrayList<CacheGameActivityPlayer>();
//        players.add(player);

        TGame game = baseCacheController.queryGameById(m.getGameId(), cache);
        
        CacheGameActivity activity = new CacheGameActivity();
        activity.setLevel(m.getLevel());
        activity.setGameActivityId(m.getActivityId() + "");
        activity.setTableId(tableId);

        activity.setCoins(m.getCoins());
        activity.setOriCoins(oriCoins);
        activity.setActivityName(t.getActivityName());
        activity.setGameId(m.getGameId() + "");
        activity.setInviteCode(inviteCode);
        activity.setStatus(0);
        activity.setPlayers(players);
        activity.setCreatorId(userProfile.getUserId());
        activity.setCreatorNickname(userProfile.getNickName());
        activity.setCreatorPhotoUrl(userProfile.getPhotoUrl());
        activity.setChatRoomId(chatRoomId);
        activity.setGameName(game.getName());
        activity.setGamePhoto(game.getPhoto());
        activity.setStartDate(t.getStartDate());
        activity.setGameCode(gameCode);
        activity.setCards(t.getCards());
        activity.setMaxPlayer(maxPlayerCount);

        //查询是否是房卡场
        String tGame = cache.hget(GAME_CATEGORY_LIST_KEY, m.getLevel().toString());
        Integer i = 0;
        if (!StringUtils.isEmpty(tGame) && JSONObject.parseObject(tGame).getInteger("isGold") != null && !"".equals(JSONObject.parseObject(tGame).getInteger("isGold")) ) {
            i = JSONObject.parseObject(tGame).getInteger("isGold");
        }else {
            i = activityUserMapper.selectIsGoldTypeByLevel(m.getLevel());
        }
        activity.setIsGold(i);

        cache.hmset(GAME_ACTIVITY_KEY_PREFIX + inviteCode, activity.generateHashMapBySelective());

        CacheGameActivity activityResult = new CacheGameActivity();
        activityResult.setLevel(activity.getLevel());
        activityResult.setTableId(activity.getTableId());
        activityResult.setGameActivityId(activity.getGameActivityId());

        return activityResult;
    }

    public CacheGameActivity joinFreeGame(String userId, String invitationCode, String type, ICache cache,
            Map<String, String> outputParams) throws Exception {
        CacheUserProfile userProfile = null;

        String key = GAME_ACTIVITY_KEY_PREFIX + invitationCode;

        Map<String, String> keyValues = cache.hgetAll(key);

        if (keyValues.isEmpty()) {
            throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "组局数据异常");
        }

        CacheGameActivity activity = (CacheGameActivity) BeanMapUtils.toBeanBySelective(CacheGameActivity.class,
                keyValues);

        int oriCoins = Integer.parseInt(cache.hget(key, GAME_ACTIVITY_FIELD_ORICOINS));

        if (Constants.USER_TYPE_P.equalsIgnoreCase(type)) {
            userProfile = playerCacheController.queryPlayerDetail(Long.parseLong(userId), cache, false, false);
        } else {
//            userProfile = compereCacheController.getCompereDetail(userId, cache, false, false);
        }

        CacheGameActivityPlayer player = new CacheGameActivityPlayer();

        player.setDrawRounds(0);
        player.setLoseRounds(0);
        player.setNickName(userProfile.getNickName());
        player.setNowCoins(oriCoins);
        player.setOriCoins(oriCoins);
        player.setPhotoUrl(userProfile.getPhotoUrl());
        player.setUserId(userId);
        player.setWinRounds(0);

        activity.getPlayers().add(player);

        cache.hsetObj(key, GAME_ACTIVITY_FIELD_PLAYERS, activity.getPlayers());

        outputParams.put("nickname", player.getNickName());
        outputParams.put("photo", player.getPhotoUrl());
        outputParams.put("phone", userProfile.getPhone());

        return activity;
    }

    public String varifyPhones(String phones, ICache cache) {
        String check = cache.hget(VARIFY_PHONES_KEY, VARIFY_PHONES_KEY);

        if (StringUtils.isEmpty(check)) {
            List<TUser> users = commonCacheLoader.queryAllUsers();

            cache.hset(VARIFY_PHONES_KEY, VARIFY_PHONES_KEY, VARIFY_PHONES_KEY);
            for (TUser user : users) {
                cache.hset(VARIFY_PHONES_KEY, user.getPhone(), user.getPhone());
            }
        }

        String[] phoneArray = phones.split(":");

        StringBuilder sb = new StringBuilder();
        for (String phone : phoneArray) {
            if (cache.hget(VARIFY_PHONES_KEY, phone) != null) {
                sb.append(":").append(phone);
            }
        }

        String result = sb.toString();
        if (result.length() > 0) {
            result = result.substring(1);
        }

        return result;
    }
    
    

    public void share(String taskId, String userId, ICache cache) {
        String key = TASK_KEY_PREFIX + userId + KEY_SPLIT + taskId;
        cache.hincrby(key, TASK_FIELD_ACTUALAMOUNT, 1);
    }

    /**
     * 获取玩家分享主播记录
     * @param userId
     * @param cache
     * @return
     */
    public List<String> findMyShareCompereRecord(String userId, ICache cache) {
        String key = SHARE_COMPERE_KEY_PREFIX + userId;
        return cache.lgetAll(key);
    }
    
    /**
     * 添加玩家分享主播记录
     * @param userId
     * @param compereId
     * @param cache
     */
    public void addShareCompereRecord(String userId, String compereId, ICache cache) {
        String key = SHARE_COMPERE_KEY_PREFIX + userId;
        cache.rpush(key, compereId);
    }
    
    /**
     * 添加喇叭推送消息
     * @param message
     */
    public void addLoudSpeakerMessage(String message, ICache cache) {
        cache.rpush(LOUD_SPEAKER_KEY, message);
    }
    
    /**
     * 获取喇叭推送消息
     * @param cache
     * @return
     */
    public String getLoudSpeakerMessage(ICache cache) {
        return cache.lpop(LOUD_SPEAKER_KEY);
    }
    
    /**
     * 获取喇叭消息数量
     * @param cache
     * @return
     */
    public long getLoudSpeakerCount(ICache cache) {
        return cache.llen(LOUD_SPEAKER_KEY);
    }

    public void setRandomCode(CheckCodeInfo info, ICache cache) {
        String key = RANDOM_CODE_KEY;
        cache.hset(key, info.getPhone(), JSON.toJSONString(info));
    }
    
    public void isWiner(Long activityId,String round,ICache cache) {
        String key = GAME_TYPE_KEY + activityId;
        cache.hset(key,GAME_TYPE, "1");
        cache.hset(key,GAME_ROUND, round);
       
    }
    
    public void uploadConfigCard(String invitationCode, String content, String location,ICache cache) {
        String key = TEST_CONFIG_CARD_KEY + invitationCode;
        
        cache.hset(key,location, content);
		
       
        
       
    }
    
    public void playerRound(Long activityId,String round,String paytype, ICache cache) {
        String key = GAME_ROUND_KEY + activityId;
        cache.hset(key,GAME_ROUND, round);
        cache.hset(key,PAY_TYPE, paytype);
       
    }

    public void putJson(String json,long activityId,String round,ICache cache,Integer others,Integer groupId,Long groupOwerId,String password,String inviteCode) {
        String key = GAME_ROUND_KEY + activityId;
        cache.hset(key,GAME_ROUND, round);
        JSONObject jsonObject = JSONObject.parseObject(json);
        Set<String> strings = jsonObject.keySet();
        for (String s :strings) {
            cache.hset(key,s,jsonObject.getString(s));
        }
        System.out.println(others.toString() + "开放json");
        cache.hset(key,"others",others.toString());
        if (StringUtil.isNotEmpty(groupId) && 0 != groupId ) {
            cache.hset(key,"groupOwerId",groupOwerId+"");
            cache.hset(key,"groupId",groupId+"");
        }
        if (StringUtil.isNotEmpty(password)) {
            cache.hset(key,"password",password);
        }
        cache.hset(key,"inviteCode", inviteCode);
    }


    public CheckCodeInfo getRandomCode(String phone, ICache cache) {
        String key = RANDOM_CODE_KEY;
        String info = cache.hget(key, phone);
        if(StringUtils.isNotBlank(info)) {
            return JSON.parseObject(info, CheckCodeInfo.class);
        }
        return null;
    }
    
    /**
     * 根据用户ID查询用户类型
     * @param userId
     * @param cache
     * @return
     */
    public String queryUserTypeByUserId(String userId, ICache cache) {
        String key = USER_TYPE_KEY;
        if (cache.hlen(key) > 0) {
            return cache.hget(key, userId);
        } else {
            Map<String, String> userTypeMap = commonCacheLoader.loadUserTypes();
            if (MapUtils.isNotEmpty(userTypeMap)) {
                cache.hmset(key, userTypeMap);
                return userTypeMap.get(userId);
            } else {
                return null;
            }
        }
    }
    
    public void addUserType(String userId, String userType, ICache cache) {
        String key = USER_TYPE_KEY;
        if (cache.hlen(key) > 0) {
            cache.hset(key, userId, userType);
        } else {
            Map<String, String> userTypeMap = commonCacheLoader.loadUserTypes();
            if (MapUtils.isNotEmpty(userTypeMap)) {
                cache.hmset(key, userTypeMap);
            }
        }
    }

    public List<TDefaultPhoto> queryDefaultPhotoList(ICache cache) {
        String key = DEFAULT_PHOTOS_KEY;
        List<TDefaultPhoto> photos = new ArrayList<TDefaultPhoto>();
        if (cache.exist(key)) {
            List<String> list = cache.lgetAll(key);
            for (String s : list) {
                photos.add(JSON.parseObject(s, TDefaultPhoto.class));
            }
        } else {
            photos = commonCacheLoader.queryDefaultPhotoList();
            for (TDefaultPhoto photo : photos) {
                cache.rpush(key, JSON.toJSONString(photo));
            }
        }
        return photos;
    }

    public TDefaultPhoto queryRandomPhoto(ICache cache) {
        List<TDefaultPhoto> list = queryDefaultPhotoList(cache);

        if (list == null || list.isEmpty()) {
            // 返回一个默认的 TDefaultPhoto 对象
            TDefaultPhoto defaultPhoto = new TDefaultPhoto();
            defaultPhoto.setId(0L);
            defaultPhoto.setPhoto("default_photo_url");
            return defaultPhoto;
        }

        int index = RandomUtils.nextInt(list.size());
        return list.get(index);
    }
    
    /**
     * 转换约饭记录缓存对象
     * 
     * @param datingActivity
     * @return
     */
//    private CacheDatingActivityListProfile transDatingActivityToCacheObj(TDatingActivity datingActivity) {
//        CacheDatingActivityListProfile activityListProfile = new CacheDatingActivityListProfile();
//        activityListProfile.setActivityId(datingActivity.getId());
//        activityListProfile.setInitiatorId(datingActivity.getUserId());
//        activityListProfile.setUserType(datingActivity.getUserType());
//        activityListProfile.setTime(datingActivity.getTime());
//        activityListProfile.setPeriod(datingActivity.getPeriod());
//        activityListProfile.setCategoryId(datingActivity.getCategoryId());
//        activityListProfile.setCategoryName(datingActivity.getCategoryName());
//        activityListProfile.setAuctionCount(datingActivity.getAuctionCount());
//        activityListProfile.setHighestAuctionCount(datingActivity.getHighestAuctionCount());
//        activityListProfile.setLastAuctionDate(datingActivity.getLastAuctionDate());
//        activityListProfile.setIsEvaluation(datingActivity.getIsEvaluation());
//        activityListProfile.setStatus(datingActivity.getStatus());
//        activityListProfile.setEndType(datingActivity.getEndType());
//        activityListProfile.setEndDate(datingActivity.getEndDate());
//        activityListProfile.setChatroomId(datingActivity.getChatroomId());
//        activityListProfile.setCreateDate(datingActivity.getCreateDate());
//        return activityListProfile;
//    }

    /**
     * 转换详情对象
     * 
     * @param datingActivity
     * @return
     */
//    private CacheDatingActivityProfile transDatingActivitytoDetailCacheObj(TDatingActivity datingActivity) {
//        CacheDatingActivityProfile activityProfile = new CacheDatingActivityProfile();
//        activityProfile.setActivityId(datingActivity.getId());
//        activityProfile.setInitiatorId(datingActivity.getUserId());
//        activityProfile.setUserType(datingActivity.getUserType());
//        activityProfile.setTime(datingActivity.getTime());
//        activityProfile.setPeriod(datingActivity.getPeriod());
//        activityProfile.setAuctionDeclaration(datingActivity.getAuctionDeclaration());
//        activityProfile.setCategoryId(datingActivity.getCategoryId());
//        activityProfile.setCategoryName(datingActivity.getCategoryName());
//        activityProfile.setAuctionCount(datingActivity.getAuctionCount());
//        activityProfile.setHighestAuctionUserId(datingActivity.getHighestAuctionUserId());
//        activityProfile.setHighestAuctionCount(datingActivity.getHighestAuctionCount());
//        activityProfile.setLastAuctionDate(datingActivity.getLastAuctionDate());
//        activityProfile.setTotalAuctionNum(datingActivity.getTotalAuctionNum());
//        activityProfile.setOnTimeGrade(datingActivity.getOnTimeGrade());
//        activityProfile.setSatisfaction(datingActivity.getSatisfaction());
//        activityProfile.setStatus(datingActivity.getStatus());
//        activityProfile.setEndType(datingActivity.getEndType());
//        activityProfile.setEndDate(datingActivity.getEndDate());
//        activityProfile.setChatroomId(datingActivity.getChatroomId());
//        activityProfile.setCreateDate(datingActivity.getCreateDate());
//        activityProfile.setReplyDate(datingActivity.getReplyDate());
//        activityProfile.setGradeDate(datingActivity.getGradeDate());
//        return activityProfile;
//    }

    /**
     * 转换缓存记录对象
     * 
     * @param datingAuctionRecord
     * @return
     */
//    private CacheDatingAuctionRecordProfile transDatingAuctionRecordToCacheObj(
//            TDatingAuctionRecord datingAuctionRecord) {
//        CacheDatingAuctionRecordProfile cacheAuctionRecord = new CacheDatingAuctionRecordProfile();
//        cacheAuctionRecord.setRecordId(datingAuctionRecord.getId());
//        cacheAuctionRecord.setAuctionUserId(datingAuctionRecord.getAuctionUserId());
//        cacheAuctionRecord.setDatingActivityId(datingAuctionRecord.getDatingActivityId());
//        // cacheAuctionRecord.setCategoryId(datingAuctionRecord.getCategoryId());
//        // cacheAuctionRecord.setCategoryName(datingAuctionRecord.getCategoryName());
//        cacheAuctionRecord.setAuctionCount(datingAuctionRecord.getAuctionCount());
//        cacheAuctionRecord.setStatus(datingAuctionRecord.getStatus());
//        cacheAuctionRecord.setLastAuctionDate(datingAuctionRecord.getLastAuctionDate());
//        return cacheAuctionRecord;
//    }

}
