//package com.hbi.cache.controller;
//
//
//import java.util.*;
//
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.redis.RedisLock;
//import com.hbi.constants.Constants;
//import com.hbi.model.TLiveHotWords;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.collections.MapUtils;
//import org.apache.commons.collections.map.HashedMap;
//import org.apache.commons.lang.StringUtils;
//import org.apache.commons.lang.math.IntRange;
//import org.apache.commons.lang.math.RandomUtils;
//import org.apache.log4j.Logger;
//import org.springframework.beans.BeanUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSON;
//import com.alibaba.fastjson.JSONObject;
//import com.core.beanUtil.BeanMapUtils;
//import com.hbi.cache.ICache;
//import com.hbi.cache.cacheWritter.CompereCacheLoader;
//import com.hbi.cache.cacheWritter.RoomCacheLoader;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CacheGameActivity;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheRoomListProfile;
//import com.hbi.cache.model.CacheRoomProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.model.TGoods;
//import com.hbi.model.TLiveRoomAccount;
//import com.hbi.model.TUserGoodsPresentRecord;
//
//@Service
//public class RoomCacheController {
//	private final Logger log = Logger.getLogger(RoomCacheController.class);
//
//	private static final String LIVE_ROOM_KEY_PREFIX = "LIVE_ROOM_";
//
//	private static final String LIVE_ROOM_RED_PACKET_AMOUNT_KEY = "LIVE_ROOM_RED_PACKET_AMOUNT";
//
//	private static final String LIVE_ROOM_RED_PACKET_HISTORY_KEY = "LIVE_ROOM_RED_PACKET_HISTORY";
//
//	private static final String COMPERE_LIVE_ROOM_RELATION_PREFIX = "COMPERE_LIVE_ROOM_RELATION_";
//
//	private static final String ROOM_MEMBER_LIST_KEY_PREFIX = "ROOM_MEMBER_LIST_";
//
//	private static final String LIVE_MIC_KEY_PREFIX = "LIVE_MIC_";
//
//	private static final String LIVE_FM_KEY_PREFIX = "LIVE_FM_";
//
//	private static final String USER_ITEM_KEY_PREFIX = "USER_ITEM_";
//
//	private static final String ROOM_LIST_KEY = "ROOM_LIST_";
//
//	private static final String LIVE_GIFT_KEY_PREFIX = "LIVE_GIFT_";
//
//	private static final String LIVE_HOT_WORDS = "LIVE_HOT_WORDS";
//
//	private static final String ROOM_FIELD_RED_PACKET_INDEX = "redPacketIndex";
//
//	private static final String ROOM_FIELD_RED_PACKET_AMOUNT = "redPacketAmount";
//
//	private static final String ROOM_FIELD_LIVEID = "liveId";
//
//	private static final String ROOM_FIELD_STATUS = "status";
//
//	private static final String ROOM_FIELD_RESOLUTION = "resolution";
//
//	private static final String ROOM_FIELD_MICPHONE = "microphone";
//
//	private static final String ROOM_FIELD_COUNT = "count";
//
//	private static final String ROOM_FIELD_PLAYINGGAMEID = "playingGameId";
//
//	private static final String ROOM_FIELD_PLAYINGGAMECODE = "playingGameCode";
//
//	private static final String ROOM_FIELD_PLAYINGGAME = "playingGame";
//
//	private static final String ROOM_FIELD_TOPIC_ID = "fmTopicId";
//
//	private static final String ROOM_FIELD_TOPIC = "fmTopic";
//
//	private static final String ROOM_FIELD_FM_TICKET_GOODS = "fmTicketGoods";
//
//	private static final String ROOM_FIELD_CHATROOMID = "chatRoomId";
//
////	private static final String ROOM_FIELD_COMPEREID = "compereId";
//
//	private static final String ROOM_FIELD_IS_FM_START = "isFmStart";
//
//	private static final String ROOM_FIELD_YSIG_WORD = "ysigWord";
//
//	private static final String ROOM_FIELD_FM_ROUNDS = "fmRounds";
//
//	private static final String ROOM_FIELD_COMPERE = "compere";
//	private static final String ROOM_FIELD_ROOM_NAME = "roomName";
//    private static final String ROOM_FIELD_ROOM_PASSWORD = "roomPassword";
//    private static final String ROOM_FIELD_ROOM_PHOTO = "roomPhoto";
//    private static final String ROOM_FIELD_LIVE_USER_NAME = "liveUsername";
//    private static final String ROOM_FIELD_LIVE_PASSWORD = "livePassword";
//    private static final String ROOM_FIELD_LIVE_TYPE = "liveType";
//    private static final String ROOM_FIELD_ACTIVITY_PHOTO_URL = "activityPhotoUrl";
//
//	private static final String GAME_ACTIVITY_INVITATION_CODE_KEY_PREFIX = "GAME_ACTIVITY_";
//
//	private static final String LIVE_ROOM_ACCOUNT_KEY_PREFIX = "LIVE_ROOM_ACCOUNT";
//
//	@Autowired
//	private RoomCacheLoader roomCacheLoader;
//
//	@Autowired
//	private CompereCacheLoader compereCacheLoader;
//
//	@Autowired
//	private CompereCacheController compereCacheController;
//
//	@Autowired
//	private PlayerCacheController playerCacheController;
//
//	@Autowired
//	private CaptureCacheController captureCacheController;
//
//	@Autowired
//	private RobotsCacheController robotsCacheController;
//	@Autowired
//	private BaseCacheController baseCacheController;
//
//	public String getChatRoomId(Long roomId, ICache cache) throws Exception {
//		String chatRoomId = cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isBlank(chatRoomId)) {
//			CacheRoomProfile m = queryRoomDetail(roomId, cache);
//			if (m != null) {
//			    chatRoomId = m.getChatRoomId();
//			}
//		}
//
//		return chatRoomId;
//	}
//
//	public String getFmStartStatus(String roomId, ICache cache) throws Exception {
//	    String fmStatus = cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_IS_FM_START);
//	    if (fmStatus == null) {
//            CacheRoomProfile m = queryRoomDetail(Long.parseLong(roomId), cache);
//            if (m != null) {
//                fmStatus = m.getIsFmStart();
//            }
//        }
//		return fmStatus;
//	}
//
//	/**
//	 * 创建房间
//	 * @param cache
//	 * @return
//	 */
//	public void createRoom(CacheRoomListProfile room, CacheRoomProfile roomDetail, ICache cache) throws Exception {
//		compereCacheController.updateCompereForRoomInfo(roomDetail.getCompere(), cache);
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomDetail.getRoomId();
//		cache.hmset(roomKey, BeanMapUtils.toMapBySelective(roomDetail));
//		String roomListKey = ROOM_LIST_KEY + room.getCityId();
//        Long mapLength = cache.hlen(roomListKey);
//        if (mapLength != null && mapLength > 0) {
//            cache.hset(roomListKey, room.getRoomId(), JSON.toJSONString(room));
//        } else {
//            List<CacheRoomListProfile> list = roomCacheLoader.loadRoomList(Long.parseLong(room.getCityId()));
//            for(CacheRoomListProfile r : list) {
//                cache.hset(roomListKey, r.getRoomId(), JSON.toJSONString(r));
//            }
//        }
//
//        robotsCacheController.doCreateRoom(roomDetail.getRoomId(), cache);
//	}
//
//	public void updateRoomInfo(CacheRoomListProfile room, CacheRoomProfile roomDetail, ICache cache) throws Exception {
//	    compereCacheController.updateCompereForRoomInfo(roomDetail.getCompere(), cache);
//	    String roomKey = LIVE_ROOM_KEY_PREFIX + roomDetail.getRoomId();
//	    if (cache.hlen(roomKey) > 0) {
//	        if (StringUtils.isNotBlank(roomDetail.getRoomName())) {
//	            cache.hset(roomKey, ROOM_FIELD_ROOM_NAME, roomDetail.getRoomName());
//	        }
//	        if (StringUtils.isNotBlank(roomDetail.getRoomPassword())) {
//	            cache.hset(roomKey, ROOM_FIELD_ROOM_PASSWORD, roomDetail.getRoomPassword());
//	        } else {
//	            cache.hdel(roomKey, ROOM_FIELD_ROOM_PASSWORD);
//	        }
//	        if (StringUtils.isNotBlank(roomDetail.getRoomPhoto())) {
//	            cache.hset(roomKey, ROOM_FIELD_ROOM_PHOTO, roomDetail.getRoomPhoto());
//	        }
//	        if (StringUtils.isNotBlank(roomDetail.getLiveUsername())) {
//	            cache.hset(roomKey, ROOM_FIELD_LIVE_USER_NAME, roomDetail.getLiveUsername());
//	        }
//	        if (StringUtils.isNotBlank(roomDetail.getLivePassword())) {
//                cache.hset(roomKey, ROOM_FIELD_LIVE_PASSWORD, roomDetail.getLivePassword());
//            }
//	        if (StringUtils.isNotBlank(roomDetail.getLiveType())) {
//                cache.hset(roomKey, ROOM_FIELD_LIVE_TYPE, roomDetail.getLiveType());
//            }
//	        if (StringUtils.isNotBlank(roomDetail.getActivityPhotoUrl())) {
//	        	cache.hset(roomKey, ROOM_FIELD_ACTIVITY_PHOTO_URL, roomDetail.getActivityPhotoUrl());
//	        }
//	    } else {
//	        cache.hmset(roomKey, BeanMapUtils.toMapBySelective(roomDetail));
//	    }
//
//        String roomListKey = ROOM_LIST_KEY + room.getCityId();
//        Long mapLength = cache.hlen(roomListKey);
//        if (mapLength != null && mapLength > 0) {
//            CacheRoomListProfile oldRoom = JSONObject.parseObject(cache.hget(roomListKey, room.getRoomId()), CacheRoomListProfile.class);
//            oldRoom.setRoomName(room.getRoomName());
//            oldRoom.setPassword(room.getPassword());
//            oldRoom.setRoomPhoto(room.getRoomPhoto());
//            oldRoom.setLiveType(room.getLiveType());
//            cache.hset(roomListKey, room.getRoomId(), JSON.toJSONString(oldRoom));
//        } else {
//            List<CacheRoomListProfile> list = roomCacheLoader.loadRoomList(Long.parseLong(room.getCityId()));
//            for(CacheRoomListProfile r : list) {
//                cache.hset(roomListKey, r.getRoomId(), JSON.toJSONString(r));
//            }
//        }
//	}
//
//	public boolean doStartLive(String cityId, String roomId, String liveId, String resolution, ICache cache, Map<String, String> outputParams) throws Exception, Exception {
//		String key = LIVE_ROOM_KEY_PREFIX + roomId;
//		Long mapLength = cache.hlen(key);
//		if (mapLength != null && mapLength > 0) {
//		    cache.hset(key, ROOM_FIELD_LIVEID, liveId);
//	        cache.hset(key, ROOM_FIELD_STATUS, "living");
//	        cache.hset(key, ROOM_FIELD_RESOLUTION, resolution);
//		} else {
//		    CacheRoomProfile profile = roomCacheLoader.loadRoomDetails(Long.parseLong(roomId));
//            if (profile != null) {
//                cache.hmset(key, profile.generateHashMapBySelective());
//            }
//		}
//
//
//		CacheRoomListProfile m = null;
//		String roomListKey = ROOM_LIST_KEY + cityId;
//		Map<String, String> maps = cache.hgetAll(roomListKey);
//		if (MapUtils.isNotEmpty(maps)) {
//		    String json = maps.get(roomId);
//		    if (StringUtils.isNotEmpty(json)) {
//                m = JSON.parseObject(json, CacheRoomListProfile.class);
//            }
//		} else {
//		    List<CacheRoomListProfile> list = roomCacheLoader.loadRoomList(Long.parseLong(cityId));
//	        for(CacheRoomListProfile tb : list) {
//	            cache.hset(roomListKey, tb.getRoomId(), JSON.toJSONString(tb));
//	            if (tb.getRoomId().equals(roomId)) {
//	                m = tb;
//	            }
//	        }
//		}
//
//		if (m == null) {
//		    return false;
//		}
//
//		m.setStatus("1");
//		m.setLiveId(liveId);
//		cache.hset(roomListKey, roomId, JSON.toJSONString(m));
//
//		outputParams.put("nickname", m.getCompereName());
//		outputParams.put("chatRoomId", cache.hget(key, ROOM_FIELD_CHATROOMID));
//
//		return true;
//	}
//
//	public boolean setMicphone(String roomId, String status, ICache cache, Map<String, String> outputParams) throws Exception {
//	    String key = LIVE_ROOM_KEY_PREFIX + roomId;
//	    Long mapLength = cache.hlen(key);
//        if (mapLength != null && mapLength > 0) {
//            cache.hset(key, ROOM_FIELD_MICPHONE, status);
//            outputParams.put("chatRoomId", cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID));
//        } else {
//            CacheRoomProfile profile = roomCacheLoader.loadRoomDetails(Long.parseLong(roomId));
//            if (profile != null) {
//                cache.hmset(key, profile.generateHashMapBySelective());
//                outputParams.put("chatRoomId", profile.getChatRoomId());
//            }
//        }
//		return true;
//	}
//
//	public boolean queueMicphone(String roomId, String playerId, ICache cache, Map<String, String> outputParams) throws Exception {
//		CacheUserListProfile m = new CacheUserListProfile();
//		m.setUserId(playerId);
//
//		CachePlayerProfile player = playerCacheController.queryPlayerDetail(Long.parseLong(playerId), cache, false, false);
//
//		if (player == null) {
//			return false;
//		}
//
//		m.setNickName(player.getNickName());
//		m.setPhotoUrl(player.getPhotoUrl());
//
//		outputParams.put("photoUrl", player.getPhotoUrl());
//		outputParams.put("nickname", player.getNickName());
//
//		//取用户数据
//		cache.rpush(LIVE_MIC_KEY_PREFIX + roomId, JSON.toJSONString(m));
//
//		outputParams.put("chatRoomId", cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID));
//
//		return true;
//	}
//
//	public CacheUserListProfile joinFm(String roomId, String playerId, String position, ICache cache, Map<String, String> outputParams) throws Exception {
//		CacheUserListProfile m = new CacheUserListProfile();
//		m.setUserId(playerId);
//
//		CachePlayerProfile player = playerCacheController.queryPlayerDetail(Long.parseLong(playerId), cache, false, false);
//
//		if (player == null) {
//			return null;
//		}
//
//		m.setNickName(player.getNickName());
//		m.setPhotoUrl(player.getPhotoUrl());
//
//		outputParams.put("photoUrl", player.getPhotoUrl());
//		outputParams.put("nickname", player.getNickName());
//
//		String key = LIVE_FM_KEY_PREFIX + roomId;
//		String json = cache.hget(key, position);
//
//		if (!StringUtils.isEmpty(json)) {
//			return null;
//		}
//
//		m.setPosition(position);
//		//取用户数据
//		cache.hset(key, position, JSON.toJSONString(m));
//
//		outputParams.put("chatRoomId", cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID));
//
//		return m;
//	}
//
//	public boolean changeMicphoneQueue(String roomId, String playerId, String position, ICache cache, Map<String, Object> outputParams) {
//		String keyTemp = LIVE_MIC_KEY_PREFIX + roomId;
//
//		List<String> jsonStrs = cache.lgetAll(keyTemp);
//
//		String currentPlayer = null;
//
//		List<CacheUserListProfile> outputList = new ArrayList<CacheUserListProfile>();
//		int currentIndex = 0;
//		for (int i = 0; i < jsonStrs.size(); i++) {
//			CacheUserListProfile m = JSON.parseObject(jsonStrs.get(i), CacheUserListProfile.class);
//
//			if (m.getUserId().equals(playerId)) {
//				currentPlayer = jsonStrs.get(i);
//				currentIndex = i;
//			}
//
//			outputList.add(m);
//		}
//
//		if (currentPlayer == null) {
//			return false;
//		}
//		int positionI = Integer.parseInt(position);
//		if (currentIndex < positionI) {
//			outputList.add(positionI, outputList.get(currentIndex));
//			outputList.remove(currentIndex);
//		} else if (currentIndex > positionI) {
//			outputList.add(positionI, outputList.get(currentIndex));
//			outputList.remove(currentIndex + 1);
//		}
//
//		outputParams.put("micList", outputList);
//		outputParams.put("chatRoomId", cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID));
//
//		long len = cache.llen(keyTemp);
//
//		if (positionI >= len - 1) {
//			cache.lrem(keyTemp, 1, currentPlayer);
//
//			cache.rpush(keyTemp, currentPlayer);
//
//			return true;
//		} else if (positionI == 0) {
//			cache.lrem(keyTemp, 1, currentPlayer);
//
//			cache.lpush(keyTemp, currentPlayer);
//
//			return true;
//		} else {
//			String before = cache.lindex(keyTemp, positionI - 1);
//
//			cache.lrem(keyTemp, 1, currentPlayer);
//
//			cache.linsertAfter(keyTemp, before, currentPlayer);
//
//			return true;
//		}
//
//
//	}
//
//	public boolean removeFromMicrophoneQueue(String roomId, String playerId, ICache cache, Map<String, String> outputParams) {
//		String keyTemp = LIVE_MIC_KEY_PREFIX + roomId;
//
//		List<String> jsonStrs = cache.lgetAll(keyTemp);
//
//		String currentPlayer = null;
//		for (int i = 0; i < jsonStrs.size(); i++) {
//			CacheUserListProfile m = JSON.parseObject(jsonStrs.get(i), CacheUserListProfile.class);
//
//			if (m.getUserId().equals(playerId)) {
//				currentPlayer = jsonStrs.get(i);
//			}
//		}
//
//		if (currentPlayer == null) {
//			return false;
//		}
//
//		outputParams.put("chatRoomId", cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID));
//
//		return cache.lrem(keyTemp, 1, currentPlayer) == 1;
//	}
//
//	public boolean removeFm(String roomId, String playerId, String position, ICache cache, Map<String, String> outputParams) {
//		String keyTemp = LIVE_FM_KEY_PREFIX + roomId;
//
//		cache.hdel(keyTemp, position);
//
//		outputParams.put("chatRoomId", cache.hget(LIVE_ROOM_KEY_PREFIX + roomId, ROOM_FIELD_CHATROOMID));
//
//		return true;
//	}
//
//	public List<CacheUserListProfile> viewRoomPlayers(String roomId, ICache cache) {
//		String keyTemp = ROOM_MEMBER_LIST_KEY_PREFIX + roomId;
//
//		List<String> jsonStrs = cache.lgetAll(keyTemp);
//
//		if (CollectionUtils.isEmpty(jsonStrs)) {
//			return new ArrayList<CacheUserListProfile>();
//		} else {
//			List<CacheUserListProfile> result = new ArrayList<CacheUserListProfile>();
//
//			for (String json : jsonStrs) {
//				result.add(JSON.parseObject(json, CacheUserListProfile.class));
//			}
//
//			return result;
//		}
//	}
//
//	public List<CacheUserListProfile> viewMicphonePlayers(String roomId, ICache cache) {
//		String keyTemp = LIVE_MIC_KEY_PREFIX + roomId;
//
//		List<String> jsonStrs = cache.lgetAll(keyTemp);
//
//		if (CollectionUtils.isEmpty(jsonStrs)) {
//			return new ArrayList<CacheUserListProfile>();
//		} else {
//			List<CacheUserListProfile> result = new ArrayList<CacheUserListProfile>();
//
//			for (String json : jsonStrs) {
//				result.add(JSON.parseObject(json, CacheUserListProfile.class));
//			}
//
//			return result;
//		}
//	}
//
//	public List<CacheUserListProfile> viewFmPlayers(String roomId, ICache cache) {
//		String keyTemp = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> jsonStrs = cache.hgetAll(keyTemp);
//
//		if (jsonStrs.isEmpty()) {
//			return new ArrayList<CacheUserListProfile>();
//		} else {
//			List<CacheUserListProfile> result = new ArrayList<CacheUserListProfile>();
//
//			for (String k : jsonStrs.keySet()) {
//				CacheUserListProfile u = JSON.parseObject(jsonStrs.get(k), CacheUserListProfile.class);
//				u.setPosition(k);
//				result.add(u);
//			}
//
//			return result;
//		}
//	}
//
//	public boolean removeMember(String cityId, String roomId, String userId, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String memberListKey = ROOM_MEMBER_LIST_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			return false;
//		}
//
//		Long memberCount = cache.hincrby(roomKey, ROOM_FIELD_COUNT, -1);
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		String keyTemp = LIVE_MIC_KEY_PREFIX + roomId;
//
//		List<String> jsonStrs = cache.lgetAll(keyTemp);
//
//		for (int i = 0; i < jsonStrs.size(); i++) {
//			CacheUserListProfile m = JSON.parseObject(jsonStrs.get(i), CacheUserListProfile.class);
//
//			if (m.getUserId().equals(userId)) {
//				cache.lrem(keyTemp, 1, jsonStrs.get(i));
//				break;
//			}
//		}
//
//		String keyFm = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> allFmJsons = cache.hgetAll(keyFm);
//
//		for (String keyT : allFmJsons.keySet()) {
//			CacheUserListProfile m = JSON.parseObject(allFmJsons.get(keyT), CacheUserListProfile.class);
//
//			if (m.getUserId().equals(userId)) {
//				cache.hdel(keyFm, m.getPosition());
//				break;
//			}
//		}
//
//		List<String> jsons = cache.lgetAll(memberListKey);
//
//		for (String json : jsons) {
//			CacheUserListProfile p = JSON.parseObject(json, CacheUserListProfile.class);
//
//			if (p.getUserId().equals(userId)) {
//				outputParams.put("nickname", p.getNickName());
//				cache.lrem(memberListKey, 1, json);
//			}
//		}
//
//		String roomListKey = ROOM_LIST_KEY + cityId;
//
//		String json = cache.hget(roomListKey, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//
//			m.setCount(memberCount.intValue());
//
//			cache.hset(roomListKey, roomId, JSON.toJSONString(m));
//		}
//
//		String micMemberKey = LIVE_MIC_KEY_PREFIX + roomId;
//		List<String> micJsons = cache.lgetAll(micMemberKey);
//
//		if (!CollectionUtils.isEmpty(micJsons)) {
//			for (int i = 0; i < micJsons.size(); i++) {
//				CacheUserListProfile mT = JSON.parseObject(micJsons.get(i),
//						CacheUserListProfile.class);
//
//				if (mT.getUserId().equals(userId)) {
//					cache.lrem(micMemberKey, 1, micJsons.get(i));
//					return true;
//				}
//			}
//		}
//
//		return true;
//	}
//
//	public boolean endLive(String cityId, String roomId, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			return false;
//		}
//
//		cache.hdel(roomKey, ROOM_FIELD_LIVEID);
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setStatus("0");
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//			return true;
//		}
//
//		return false;
//	}
//
//	public boolean closeRoom(String cityId, String roomId, String compereId, ICache cache, Map<String, String> outputParams) throws Exception {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		compereCacheController.updateForCloseRoom(compereId, cache);
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			CacheRoomProfile profile = queryRoomDetail(Long.parseLong(roomId), cache);
//
//			if (profile == null) {
//				return true;
//			}
//
//			chatRoomId = profile.getChatRoomId();
//		}
//		outputParams.put("chatRoomId", chatRoomId);
//
//		cache.del(COMPERE_LIVE_ROOM_RELATION_PREFIX + compereId);
//
//		cache.del(roomKey);
//
//		String roomMemberKey = ROOM_MEMBER_LIST_KEY_PREFIX + roomId;
//
//		cache.del(roomMemberKey);
//
//		String micListKey = LIVE_MIC_KEY_PREFIX + roomId;
//
//		cache.del(micListKey);
//
//		robotsCacheController.doCloseRoom(roomId, cache);
//
//		return cache.hdel(ROOM_LIST_KEY + cityId, roomId);
//	}
//
//	public boolean startGame(String cityId, String roomId, String gameId, String gameCode, String game, ICache cache, Map<String, String> outputParams) throws Exception {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			CacheRoomProfile profile = queryRoomDetail(Long.parseLong(roomId), cache);
//
//			if (profile == null) {
//				return false;
//			}
//
//			chatRoomId = profile.getChatRoomId();
//		}
//		String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//		CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//		String compereId = compere.getUserId();
//
//		CacheCompereProfile c = new CacheCompereProfile();
//		c.setUserId(compereId);
//		c.setLiveActivityType("1");
//		c.setLiveActivityName(game);
//
//		compereCacheController.updateCompereForRoomInfo(c, cache);
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		cache.hset(roomKey, ROOM_FIELD_PLAYINGGAMEID, gameId);
//		cache.hset(roomKey, ROOM_FIELD_PLAYINGGAME, game);
//		cache.hset(roomKey, ROOM_FIELD_PLAYINGGAMECODE, gameCode);
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setPlayingGame(game);
//
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//
//			return true;
//		}
//
//		return false;
//	}
//
//	public boolean startFm(String cityId, String roomId, String topicId, String topic, ICache cache, Map<String, String> outputParams) throws Exception {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			CacheRoomProfile profile = queryRoomDetail(Long.parseLong(roomId), cache);
//
//			if (profile == null) {
//				return false;
//			}
//
//			chatRoomId = profile.getChatRoomId();
//		}
//		String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//		CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//		String compereId = compere.getUserId();
//
//		CacheCompereProfile c = new CacheCompereProfile();
//
//		c.setUserId(compereId);
//		c.setLiveActivityType("2");
//		c.setLiveActivityName(topic);
//
//		compereCacheController.updateCompereForRoomInfo(c, cache);
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		cache.hset(roomKey, ROOM_FIELD_TOPIC_ID, topicId);
//		cache.hset(roomKey, ROOM_FIELD_TOPIC, topic);
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setFmTopic(topic);
//
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//
//			return true;
//		}
//
//		return false;
//	}
//
//	public boolean closeGame(String cityId, String roomId, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String gameId = cache.hget(roomKey, ROOM_FIELD_PLAYINGGAMEID);
//		String gameName = cache.hget(roomKey, ROOM_FIELD_PLAYINGGAME);
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId) || StringUtils.isEmpty(gameId) || StringUtils.isEmpty(gameName)) {
//			return false;
//		}
//
//		String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//		CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//		String compereId = compere.getUserId();
//		compereCacheController.updateForCloseLiveActivity(compereId, cache);
//
//		outputParams.put("chatRoomId", chatRoomId);
//		outputParams.put("gameId", gameId);
//		outputParams.put("gameName", gameName);
//
//		cache.hdel(roomKey, ROOM_FIELD_PLAYINGGAMEID);
//		cache.hdel(roomKey, ROOM_FIELD_PLAYINGGAME);
//		cache.hdel(roomKey, ROOM_FIELD_PLAYINGGAMECODE);
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setPlayingGame(null);
//
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//
//			return true;
//		}
//
//		return false;
//	}
//
//	public boolean closeFm(String cityId, String roomId, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String topic = cache.hget(roomKey, ROOM_FIELD_TOPIC);
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId) || StringUtils.isEmpty(topic)) {
//			return false;
//		}
//		String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//		CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//		String compereId = compere.getUserId();
//
//		compereCacheController.updateForCloseLiveActivity(compereId, cache);
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		cache.hdel(roomKey, ROOM_FIELD_TOPIC_ID);
//		cache.hdel(roomKey, ROOM_FIELD_TOPIC);
//		cache.hdel(roomKey, ROOM_FIELD_FM_TICKET_GOODS);
//		cache.hdel(roomKey, ROOM_FIELD_IS_FM_START);
//
//		cache.del(LIVE_FM_KEY_PREFIX + roomId);
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setFmTopic(null);
//
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//
//			return true;
//		}
//
//		return false;
//	}
//
//	public boolean isExistGift(String roomId, ICache cache) {
//		return !CollectionUtils.isEmpty(cache.lgetAll(LIVE_GIFT_KEY_PREFIX + roomId));
//	}
//
//	public List<TUserGoodsPresentRecord> loadGiftForRoom(String roomId, ICache cache) throws Exception {
//		List<TUserGoodsPresentRecord> goodsPresentRecords = compereCacheLoader.loadGiftsByRoom(roomId);
//
//		String[] jsons = new String[goodsPresentRecords.size()];
//
//		for (int i = 0; i < goodsPresentRecords.size(); i++) {
//			jsons[i] = JSON.toJSONString(goodsPresentRecords.get(i));
//		}
//		cache.rpush(LIVE_GIFT_KEY_PREFIX + roomId, jsons);
//
//		return goodsPresentRecords;
//	}
//
//	public List<Object> queryGiftForRoom(String roomId, ICache cache) throws Exception {
//		String roomGiftKey = LIVE_GIFT_KEY_PREFIX + roomId;
//
//		List<String> jsons = cache.lgetAll(roomGiftKey);
//
//		if (CollectionUtils.isEmpty(jsons)) {
//			List<TUserGoodsPresentRecord> goodsPresentRecords = compereCacheLoader.loadGiftsByRoom(roomId);
//			for (TUserGoodsPresentRecord r : goodsPresentRecords) {
//				cache.rpush(roomGiftKey, JSON.toJSONString(r));
//			}
//			List<Object> result = new ArrayList<Object>();
//			result.addAll(goodsPresentRecords);
//			return result;
//		}
//
//		List<Object> result = new ArrayList<Object>();
//		for (String json : jsons) {
//			result.add(JSON.parse(json));
//		}
//		return result;
//	}
//
//	public void givePresents(TUserGoodsPresentRecord goodsPresentRecord, ICache cache, Map<String, String> outputParams) throws Exception {
////		playerCacheController.costCoin(goodsPresentRecord.getGiverId(), goodsPresentRecord.getTotalPrice(), cache);
////
////		compereCacheController.incomeCoin(goodsPresentRecord.getUserId(), goodsPresentRecord.getTotalPrice(), cache);
//
//		if (isExistGift(goodsPresentRecord.getRoomId() + "", cache)) {
//			cache.rpush(LIVE_GIFT_KEY_PREFIX + goodsPresentRecord.getRoomId(), JSON.toJSONString(goodsPresentRecord));
//		} else {
//			queryGiftForRoom(goodsPresentRecord.getRoomId() + "", cache);
//		}
//
//		outputParams.put("chatRoomId", getChatRoomId(goodsPresentRecord.getRoomId(), cache));
//
//		outputParams.put("nickname", playerCacheController.getNickName(goodsPresentRecord.getGiverId(), cache));
//
//		outputParams.put("photoUrl", playerCacheController.getPhotoUrl(goodsPresentRecord.getGiverId(), cache));
//
//		outputParams.put("phone", playerCacheController.getPhone(goodsPresentRecord.getGiverId(), cache));
//	}
//
//	public boolean enterRoom(String userId, CacheRoomProfile profile, ICache cache) throws Exception {
//	    String roomId = profile.getRoomId();
//	    String cityId = profile.getCompere().getCityId();
//        String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//        String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//        String chatRoomId = profile.getChatRoomId();
//
//        if (!StringUtils.isEmpty(json) && !StringUtils.isEmpty(chatRoomId)) {
//
//        	long currentCount = cache.hincrby(roomKey, ROOM_FIELD_COUNT, 1);
//
//            CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//            m.setCount((int)currentCount);
//
//            cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//
//            CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(Long.parseLong(userId), cache, false, false);
//
//            CacheUserListProfile userListProfile = new CacheUserListProfile();
//
//            BeanUtils.copyProperties(playerProfile, userListProfile);
//
//            String roomMemberKey = ROOM_MEMBER_LIST_KEY_PREFIX + roomId;
//
//            cache.rpush(roomMemberKey, JSONObject.toJSONString(userListProfile));
//
//            return true;
//        } else {
//            return false;
//        }
//    }
//
//	public boolean exitRoom(String cityId, String userId, String roomId, ICache cache, Map<String, String> outputParams) throws Exception {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String roomMemberKey = ROOM_MEMBER_LIST_KEY_PREFIX + roomId;
//		List<String> jsons = cache.lgetAll(roomMemberKey);
//
//		boolean isExistUser = false;
//		if (!CollectionUtils.isEmpty(jsons)) {
//			for (int i = 0; i < jsons.size(); i++) {
//				CacheUserListProfile m = JSON.parseObject(jsons.get(i),
//						CacheUserListProfile.class);
//
//				if (m.getUserId().equals(userId)) {
//					outputParams.put("nickname", m.getNickName());
//					cache.lrem(roomMemberKey, 1, jsons.get(i));
//
//					isExistUser = true;
//				}
//			}
//		}
//
//		String micMemberKey = LIVE_MIC_KEY_PREFIX + roomId;
//		List<String> micJsons = cache.lgetAll(micMemberKey);
//
//		if (!CollectionUtils.isEmpty(micJsons)) {
//			for (int i = 0; i < micJsons.size(); i++) {
//				CacheUserListProfile m = JSON.parseObject(micJsons.get(i),
//						CacheUserListProfile.class);
//
//				if (m.getUserId().equals(userId)) {
//					cache.lrem(micMemberKey, 1, micJsons.get(i));
//				}
//			}
//		}
//
//		String keyFm = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> allFmJsons = cache.hgetAll(keyFm);
//
//		for (String keyT : allFmJsons.keySet()) {
//			CacheUserListProfile m = JSON.parseObject(allFmJsons.get(keyT), CacheUserListProfile.class);
//
//			if (m.getUserId().equals(userId)) {
//				cache.hdel(keyFm, m.getPosition());
//				break;
//			}
//		}
//
//		if (!isExistUser) {
//			return true;
//		}
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			return true;
//		}
//		outputParams.put("chatRoomId", chatRoomId);
//
//		long currentCount = cache.hincrby(roomKey, ROOM_FIELD_COUNT, -1);
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setCount((int)currentCount);
//
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//		}
//
//		return true;
//	}
//
//	/**
//	 * 获取游戏组局
//	 * @param invitationCode
//	 * @param cache
//	 * @return
//	 * @throws Exception
//	 */
//	public CacheGameActivity queryGroupGameByInvitationCode(String invitationCode, ICache cache) throws Exception {
//		CacheGameActivity groupGame = null;
//		String key = GAME_ACTIVITY_INVITATION_CODE_KEY_PREFIX + invitationCode;
//		Map<String, String> fieldsMap = cache.hgetAll(key);
//		if (fieldsMap != null && fieldsMap.size() > 0) {
//			groupGame = (CacheGameActivity) BeanMapUtils.toBean(CacheGameActivity.class, fieldsMap);
//		} else {
//			return null;
//		}
//		return groupGame;
//	}
//
//	/**
//	 * 获取房间列表
//	 * @param cache
//	 * @return
//	 */
//	public List<CacheRoomListProfile> queryRoomList(Long cityId, ICache cache) throws Exception{
//	    String key = ROOM_LIST_KEY + cityId.toString();
//	    Map<String, String> keyValues = cache.hgetAll(key);
//	    if(MapUtils.isEmpty(keyValues)) {
//	            List<CacheRoomListProfile> list = roomCacheLoader.loadRoomList(cityId);
//
//	            for(CacheRoomListProfile tb : list) {
//	                cache.hset(key, tb.getRoomId(), JSON.toJSONString(tb));
//					Long totalLife = captureCacheController.queryCompereTotalLife(cityId.toString(), Long.parseLong(tb.getCompereId()), cache);
//					Long leftLife = captureCacheController.queryCompereLeftLife(cityId.toString(), Long.parseLong(tb.getCompereId()), cache);
//					tb.setLeftLife(leftLife);
//					tb.setTotalLife(totalLife);
//	            }
//	            return list;
//	    } else {
//            List<CacheRoomListProfile> result = new ArrayList<CacheRoomListProfile>();
//            for (String keyT : keyValues.keySet()) {
//                CacheRoomListProfile profile = JSON.parseObject(keyValues.get(keyT), CacheRoomListProfile.class);
//				Long totalLife = captureCacheController.queryCompereTotalLife(cityId.toString(), Long.parseLong(profile.getCompereId()), cache);
//				Long leftLife = captureCacheController.queryCompereLeftLife(cityId.toString(), Long.parseLong(profile.getCompereId()), cache);
//				profile.setLeftLife(leftLife);
//				profile.setTotalLife(totalLife);
//                result.add(profile);
//            }
//            return result;
//        }
//	}
//
//	public List<CacheRoomListProfile> queryAllRoomList(ICache cache) throws Exception {
//		List<CacheRoomListProfile> profiles = roomCacheLoader.loadAllRooms();
//		List<CacheRoomListProfile> newProfiles = new ArrayList<CacheRoomListProfile>();
//		for (CacheRoomListProfile room : profiles) {
//			String key = ROOM_LIST_KEY + room.getCityId().toString();
//			String str = cache.hget(key, room.getRoomId());
//			if (StringUtils.isNotBlank(str)) {
//				CacheRoomListProfile temp = JSON.parseObject(str, CacheRoomListProfile.class);
//				Long totalLife = captureCacheController.queryCompereTotalLife(room.getCityId().toString(), Long.parseLong(room.getCompereId()), cache);
//				Long leftLife = captureCacheController.queryCompereLeftLife(room.getCityId().toString(), Long.parseLong(room.getCompereId()), cache);
//				temp.setLeftLife(leftLife);
//				temp.setTotalLife(totalLife);
//				newProfiles.add(temp);
//			}
//		}
//		return newProfiles;
////		Set<String> roomListKeys = queryRoomKeys(cache);
////		if (roomListKeys.isEmpty()) {
////			profiles = roomCacheLoader.loadAllRoomList();
////			for(CacheRoomListProfile r : profiles) {
////				writeCityRoomListCache(r, cache);
////			}
////		} else {
////			Iterator<String> iterator = roomListKeys.iterator();
////			while (iterator.hasNext()) {
////				String key = iterator.next();
////				Map<String, String> keyValues = cache.hgetAll(key);
////				for (String keyT : keyValues.keySet()) {
////					CacheRoomListProfile profile = JSON.parseObject(keyValues.get(keyT), CacheRoomListProfile.class);
////					Long totalLife = captureCacheController.queryCompereTotalLife(profile.getCityId().toString(), Long.parseLong(profile.getCompereId()), cache);
////					Long leftLife = captureCacheController.queryCompereLeftLife(profile.getCityId().toString(), Long.parseLong(profile.getCompereId()), cache);
////					profile.setLeftLife(leftLife);
////					profile.setTotalLife(totalLife);
////					profiles.add(profile);
////				}
////			}
////		}
////		return profiles;
//	}
//
//	/**
//	 * 通过城市ID将房间列表写入缓存
//	 * @param r 房间列表缓存实体类
//	 * @param cache 缓存实例
//     */
//	public void writeCityRoomListCache(CacheRoomListProfile r, ICache cache) {
//		String roomListKey = ROOM_LIST_KEY + r.getCityId();
//		cache.hset(roomListKey, r.getRoomId(), JSON.toJSONString(r));
//	}
//
//	public Set<String> queryRoomKeys(ICache cache) {
//		return cache.keys(ROOM_LIST_KEY + "*");
//	}
//
//	public CacheRoomProfile queryRoomDetail(Long roomId, ICache cache) throws Exception {
//		CacheRoomProfile profile = null;
//	    String key = LIVE_ROOM_KEY_PREFIX + roomId;
//	    Map<String, String> map = cache.hgetAll(key);
//	    if(MapUtils.isEmpty(map)) {
//	        profile = roomCacheLoader.loadRoomDetails(roomId);
//	        if (profile != null) {
//	        	map = profile.generateHashMapBySelective();
//	        	cache.hmset(key, map);
//	        }
//	    } else {
//	        profile = (CacheRoomProfile) BeanMapUtils.toBeanBySelective(CacheRoomProfile.class, map);
//	    }
//	    if (profile != null) {
//	    	 if (profile.getCompere() != null) {
//	     		CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(profile.getCompere().getUserId(), cache, false, false);
//	     		profile.setCompere(compereProfile);
//	     	}
//	    }
//	    return profile;
//	}
//
//	public boolean uploadLiveCut(String roomId, String photoUrl, String cityId, ICache cache) {
//		String key = ROOM_LIST_KEY + cityId;
//
//		String json = cache.hget(key, roomId);
//
//		if (StringUtils.isEmpty(json)) {
//
//			return false;
//
//		}
//
//		CacheRoomListProfile room = JSON.parseObject(json, CacheRoomListProfile.class);
//
//		room.setLiveCut(photoUrl);
//
//		cache.hset(key, roomId, JSON.toJSONString(room));
//
//		return true;
//	}
//
//	/**
//	 * 根据主播-房间中间缓存对象，获取房间ID
//	 * @param compereId
//	 * @param cache
//	 * @return
//	 */
//	public String getRelationRoomId(String compereId, ICache cache) {
//		String key = COMPERE_LIVE_ROOM_RELATION_PREFIX + compereId;
//		String roomId = cache.get(key);
//		if (StringUtils.isBlank(roomId)) {
//			roomId = roomCacheLoader.loadRoomByCompereId(Long.parseLong(compereId));
//		}
//		return roomId;
//	}
//
//	public boolean addCompereRoomRelation(String compereId, String roomId, ICache cache) {
//		String key = COMPERE_LIVE_ROOM_RELATION_PREFIX + compereId;
//		return cache.set(key, roomId);
//	}
//
//	public boolean openYouSayIGuess(String cityId, String roomId, String topicId, String topic, TGoods goods, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			return false;
//		}
//		String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//		CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//		String compereId = compere.getUserId();
//
//		CacheCompereProfile c = new CacheCompereProfile();
//
//		c.setUserId(compereId);
//		c.setLiveActivityType("2");
//		c.setLiveActivityName(topic);
//
//		compereCacheController.updateCompereForRoomInfo(c, cache);
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		cache.hset(roomKey, ROOM_FIELD_TOPIC_ID, topicId);
//		cache.hset(roomKey, ROOM_FIELD_TOPIC, topic);
//		cache.hset(roomKey, ROOM_FIELD_FM_TICKET_GOODS, JSON.toJSONString(goods));
//		cache.hset(roomKey, ROOM_FIELD_FM_ROUNDS, 0 + "");
//
//		String json = cache.hget(ROOM_LIST_KEY + cityId, roomId);
//
//		if (!StringUtils.isEmpty(json)) {
//			CacheRoomListProfile m = JSON.parseObject(json, CacheRoomListProfile.class);
//			m.setFmTopic(topic);
//
//			cache.hset(ROOM_LIST_KEY + cityId, roomId, JSON.toJSONString(m));
//		}
//
//		return true;
//	}
//
//	public Map<String, CacheUserListProfile> startYouSayIGuess(String roomId, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			return null;
//		}
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		String key = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> keyValues = cache.hgetAll(key);
//
//		if (keyValues.size() < 1) {
//			return null;
//		}
//
//		cache.hset(roomKey, ROOM_FIELD_IS_FM_START, "true");
//		cache.hset(roomKey, ROOM_FIELD_FM_ROUNDS, "1");
//
//		Map<String, CacheUserListProfile> result = new HashMap<String, CacheUserListProfile>();
//		for (String k : keyValues.keySet()) {
//			String json = keyValues.get(k);
//			result.put(k, JSON.parseObject(json, CacheUserListProfile.class));
//		}
//
//		return result;
//	}
//
//	public boolean selectWordForYouSayIGuess(String roomId, String word, ICache cache, Map<String, String> outputParams) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String chatRoomId = cache.hget(roomKey, ROOM_FIELD_CHATROOMID);
//
//		if (StringUtils.isEmpty(chatRoomId)) {
//			return false;
//		}
//
//		outputParams.put("chatRoomId", chatRoomId);
//
//		cache.hset(roomKey, ROOM_FIELD_YSIG_WORD, word);
//
//		return true;
//	}
//
//	public Map<String, CacheUserListProfile> queryYouSayIGuess(String roomId, ICache cache) {
//		String key = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> keyValues = cache.hgetAll(key);
//
//		Map<String, CacheUserListProfile> result = new HashMap<String, CacheUserListProfile>();
//
//		for (String k : keyValues.keySet()) {
//			result.put(k, JSON.parseObject(keyValues.get(k), CacheUserListProfile.class));
//		}
//		return result;
//	}
//
//	public void endYouSayIGuess(String roomId, ICache cache) {
//		String key = LIVE_FM_KEY_PREFIX + roomId;
//
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		cache.hdel(roomKey, ROOM_FIELD_YSIG_WORD);
//
//		cache.hincrby(roomKey, ROOM_FIELD_FM_ROUNDS, 1);
//
//		Map<String, String> keyValues = cache.hgetAll(key);
//
//		for (String k : keyValues.keySet()) {
//			CacheUserListProfile m = JSON.parseObject(keyValues.get(k), CacheUserListProfile.class);
////			m.setFmTotalScore(m.getFmTotalScore() + m.getFmCurrentScore());
//			m.setFmCurrentRank(99);
//			m.setFmCurrentScore(0);
//
//			cache.hset(key, m.getPosition(), JSON.toJSONString(m));
//		}
//	}
//
//	public int queryYouSayIGuessRounds(String roomId, ICache cache) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		String roundsStr = cache.hget(roomKey, ROOM_FIELD_FM_ROUNDS);
//
//		return Integer.parseInt(roundsStr);
//	}
//
//	public List<CacheUserListProfile> endYouSayIGuessMatch(String roomId, ICache cache) {
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//
//		cache.hset(roomKey, ROOM_FIELD_FM_ROUNDS, "0");
//
//		String key = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> keyValues = cache.hgetAll(key);
//
//		List<CacheUserListProfile> players = new ArrayList<CacheUserListProfile>();
//		for (String k : keyValues.keySet()) {
//			CacheUserListProfile m = JSON.parseObject(keyValues.get(k), CacheUserListProfile.class);
//			m.setFmTotalScore(m.getFmTotalScore() + m.getFmCurrentScore());
//			m.setFmCurrentRank(99);
//			m.setFmCurrentScore(0);
//
//			players.add(m);
//		}
//
//		Collections.sort(players, new Comparator<CacheUserListProfile>(){
//            public int compare(CacheUserListProfile arg0, CacheUserListProfile arg1) {
//            	if (arg0.getFmTotalScore() < arg1.getFmTotalScore()) {
//            		return 1;
//            	} else if (arg0.getFmTotalScore() == arg1.getFmTotalScore()) {
//            		return 0;
//            	} else {
//            		return -1;
//            	}
//            }
//        });
//
//		CacheUserListProfile m = players.get(0);
//		m.setFmTotalMatch(m.getFmTotalMatch() + 1);
//
//		cache.hset(key, m.getPosition(), JSON.toJSONString(m));
//
//		cache.hdel(roomKey, ROOM_FIELD_IS_FM_START);
////		List<CacheUserListProfile> kickList = new ArrayList<CacheUserListProfile>();
////
////		for (int i = 1; i < players.size(); i++) {
////			kickList.add(players.get(i));
////		}
//
//		return players;
//	}
//
//	public Map<String, Object> answerYouSayIGuess(String roomId, String position, ICache cache) {
//		String key = LIVE_FM_KEY_PREFIX + roomId;
//
//		Map<String, String> keyValues = cache.hgetAll(key);
//
//		int rank = 0;
//		for (String k : keyValues.keySet()) {
//			CacheUserListProfile m = JSON.parseObject(keyValues.get(k), CacheUserListProfile.class);
//
//			if (!m.getPosition().equals(position) && m.getFmCurrentRank() >= rank && m.getFmCurrentRank() < 10) {
//				rank = m.getFmCurrentRank() + 1;
//			}
//		}
//
//		CacheUserListProfile m = JSON.parseObject(keyValues.get(position), CacheUserListProfile.class);
//
//		m.setFmCurrentRank(rank);
//		m.setFmCurrentScore(keyValues.size() - rank);
//		m.setFmTotalScore(m.getFmTotalScore() + m.getFmCurrentScore());
//
//		cache.hset(key, position, JSON.toJSONString(m));
//
//		Map<String, Object> result = new HashMap<String, Object>();
//		result.put("player", m);
//		if (rank >= keyValues.size() - 1) {
//			result.put("isEnded", "true");
//		} else {
//			result.put("isEnded", "false");
//		}
//
//		return result;
//	}
//
//	/**
//	 * 根据经理ID获取骏视账号
//	 * @param cache
//	 * @return
//	 */
//	public List<TLiveRoomAccount> queryLiveRoomAccounts(ICache cache) {
//	    List<TLiveRoomAccount> liveRoomAccounts = null;
//	    String key = LIVE_ROOM_ACCOUNT_KEY_PREFIX;
//	    Map<String, String> map = cache.hgetAll(key);
//	    if (MapUtils.isNotEmpty(map)) {
//	        liveRoomAccounts = new ArrayList<TLiveRoomAccount>();
//	        for (String k : map.keySet()) {
//	            liveRoomAccounts.add(JSONObject.parseObject(map.get(k), TLiveRoomAccount.class));
//            }
//	    } else {
//	        liveRoomAccounts = roomCacheLoader.loadLiveRoomAccount();
//	        if (CollectionUtils.isNotEmpty(liveRoomAccounts)) {
//	            for (TLiveRoomAccount lra : liveRoomAccounts) {
//                    cache.hset(key, lra.getId().toString(), JSON.toJSONString(lra));
//                }
//	        }
//	    }
//	    return liveRoomAccounts;
//	}
//
//	public void updateLiveRoomAccount(TLiveRoomAccount liveRoomAccount, ICache cache) {
//        String key = LIVE_ROOM_ACCOUNT_KEY_PREFIX;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            cache.hset(key, liveRoomAccount.getId().toString(), JSON.toJSONString(liveRoomAccount));
//        } else {
//            List<TLiveRoomAccount> liveRoomAccounts = roomCacheLoader.loadLiveRoomAccount();
//            if (CollectionUtils.isNotEmpty(liveRoomAccounts)) {
//                for (TLiveRoomAccount lra : liveRoomAccounts) {
//                    cache.hset(key, lra.getId().toString(), JSON.toJSONString(lra));
//                }
//            }
//        }
//    }
//
//	public List<TLiveHotWords> hotWords(ICache cache) {
//		String key = LIVE_HOT_WORDS;
//		List<TLiveHotWords> words = new ArrayList<TLiveHotWords>();
//		if(cache.exist(key)) {
//			List<String> list = cache.lgetAll(key);
//			for (String s : list) {
//				words.add(JSON.parseObject(s, TLiveHotWords.class));
//			}
//		} else {
//			words = roomCacheLoader.hotWords();
//			for (TLiveHotWords word : words) {
//				cache.lpush(key, JSON.toJSONString(word));
//			}
//		}
//		return words;
//	}
//
//	public void increaseRoomRedPacketAmountAndSendPacket(Long roomId, String chatroomId, Integer price, ICache cache) throws Exception {
//		String key = LIVE_ROOM_KEY_PREFIX + roomId;
//		String curIndexStr = cache.hget(key, ROOM_FIELD_RED_PACKET_INDEX);
//		Long amount = cache.hincrby(key, ROOM_FIELD_RED_PACKET_AMOUNT, price);
//		Integer maxLevel = baseCacheController.queryRedPacketMaxLevel(cache);
//		Integer curIndex = 1;
//		if (StringUtils.isNotBlank(curIndexStr)) {
//			curIndex = Integer.parseInt(curIndexStr);
//		}
//		if (curIndex > maxLevel) { //超过上限，不发红包
//			return ;
//		}
//		Integer value = baseCacheController.queryRedPacketValueByLevel(curIndex, cache);
//		if (value == null) {
//			log.error("查询红包基础数据失败");
//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "查询红包基础数据失败");
//		} else {
//			if (amount > value) {
//				cache.hincrby(key, ROOM_FIELD_RED_PACKET_INDEX, 1);
//				sendPacketAndSendEasemobMessage(roomId, chatroomId, curIndex, cache);
//			}
//		}
//	}
//
//	public void sendPacketAndSendEasemobMessage(Long roomId, String chatroomId, Integer curIndex, final ICache cache) throws Exception {
//		final String roomRedPacketKey = LIVE_ROOM_RED_PACKET_AMOUNT_KEY + roomId + "_" + curIndex;
//		final String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//		String coinAmountStr = baseCacheController.queryConfig("redPacketCoinAmount", cache);
//		String compereRateStr = baseCacheController.queryConfig("redPacketCompereRate", cache);
//		String lastSecondStr = baseCacheController.queryConfig("redPacketLastSecond", cache);
//		Integer coinAmount = Integer.parseInt(coinAmountStr);
//		Integer compereRate = Integer.parseInt(compereRateStr);
//		Integer lastSecond = Integer.parseInt(lastSecondStr);
//		Integer compereAmount = coinAmount * compereRate / 100;
//		Integer playerAmount = coinAmount - compereAmount;
//
//		cache.hset(roomRedPacketKey, "compereAmount", compereAmount.toString());
//		cache.hset(roomRedPacketKey, "playerAmount", playerAmount.toString());
//		new Timer().schedule(new TimerTask() {
//			@Override
//			public void run() {
//				ICache cache1 = null;
//				try {
//					cache1 = CacheManager.getCache();
//					String amountLeftStr = cache1.hget(roomRedPacketKey, "playerAmount");
//					if (StringUtils.isNotBlank(amountLeftStr)) {
//						Integer amountLeft = Integer.parseInt(amountLeftStr);
//						if (amountLeft > 0) { //剩余红包加给主播
//							String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//							CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//							String compereId = compere.getUserId();
//							GameServerUtil.invokeUpdateCoin(Long.parseLong(compereId), amountLeft);
//						}
//					}
//					cache1.hdel(roomRedPacketKey, "compereAmount");
//					cache1.hdel(roomRedPacketKey, "playerAmount");
//				} catch (Exception e) {
//					e.printStackTrace();
//				} finally {
//					if (cache1 != null) {
//						CacheManager.releaseCache(cache1);
//					}
//				}
//			}
//		}, lastSecond * 1000);
////		easeMobService.sendRedPacketMessage(coinAmount, chatroomId);
//	}
//
//	public void compereGetRedPacket(String roomId, Integer index, ICache cache) throws Exception {
//		String roomRedPacketKey = LIVE_ROOM_RED_PACKET_AMOUNT_KEY + roomId + "_" + index;
//		String roomKey = LIVE_ROOM_KEY_PREFIX + roomId;
//		String compereAmountStr = cache.hget(roomRedPacketKey, "compereAmount");
//		if (StringUtils.isBlank(compereAmountStr)) {
//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "红包已过期！");
//		}
//		Integer compereAmount = Integer.parseInt(compereAmountStr);
//		String compereJson = cache.hget(roomKey, ROOM_FIELD_COMPERE);
//		CacheCompereProfile compere = JSON.parseObject(compereJson, CacheCompereProfile.class);
//		String compereId = compere.getUserId();
//		GameServerUtil.invokeUpdateCoin(Long.parseLong(compereId), compereAmount);
//	}
//
//	public void playerGetRedPacket(String roomId, Integer index, Long playerId, ICache cache) throws Exception {
//		String roomRedPacketKey = LIVE_ROOM_RED_PACKET_AMOUNT_KEY + roomId + "_" + index;
//		String historyKey = LIVE_ROOM_RED_PACKET_HISTORY_KEY + roomId + "_" + index;
//		String playerAmountStr = cache.hget(roomRedPacketKey, "playerAmount");
//		if (StringUtils.isBlank(playerAmountStr)) {
//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "红包已过期！");
//		}
//		Integer playerAmountLeft = Integer.parseInt(playerAmountStr);
//		Integer amount = 0;
//		if (playerAmountLeft <= 0) {
//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "红包已被领完！");
//		} else if (playerAmountLeft <= 50) { //少于等于50就一次性发完
//			amount = playerAmountLeft;
//		} else { //随机1~剩余红包金额
//			amount = RandomUtils.nextInt(playerAmountLeft - 1) + 1;
//		}
//		GameServerUtil.invokeUpdateCoin(playerId, amount);
//		JSONObject obj = new JSONObject();
//		obj.put("userId", playerId);
//		obj.put("amount", amount);
//		cache.rpush(historyKey, obj.toJSONString());
//		cache.hincrby(roomRedPacketKey, "playerAmount", -amount);
//	}
//
//	private void getTopThreeRedPackets(String key, ICache cache) {
//		List<String> list = cache.lgetAll(key);
//		Map<Long, Integer> map = new HashMap<Long, Integer>();
//		for (String s : list) {
//			JSONObject obj = JSONObject.parseObject(s);
//			Long userId = obj.getLong("userId");
//			Integer amount = obj.getInteger("amount");
//			if (map.get(userId) == null) {
//				map.put(userId, amount);
//			} else {
//				map.put(userId, amount + map.get("amount"));
//			}
//		}
//		List<JSONObject> result = sortPacketHistory(map);
//
//	}
//
//	private List<JSONObject> sortPacketHistory(Map map) {
//		List<JSONObject> list = new ArrayList<JSONObject>();
//		Set<Long> set = map.keySet();
//		for (Long userId : set) {
//			JSONObject obj = new JSONObject();
//			obj.put("userId", userId);
//			obj.put("amount", map.get(userId));
//			list.add(obj);
//		}
//		for (int i = 0; i < list.size(); i++) {
//			int index = i;
//			for (int j = i + 1; j < list.size(); j++) {
//				if (list.get(index).getInteger("amount") > list.get(j).getInteger("amount")) {
//					index = j;
//				}
//			}
//			if (i != index) {
//				Collections.swap(list, i, index);
//			}
//		}
//		if (list.size() > 3) {
//			list = list.subList(list.size() - 3, list.size());
//		}
//		return list;
//	}
//
//
//	public boolean lockRedPacket(String roomId, Integer index) {
//		String roomRedPacketKey = LIVE_ROOM_RED_PACKET_AMOUNT_KEY + roomId + "_" + index;
//		RedisLock lock = new RedisLock(roomRedPacketKey);
//		return lock.lock(1000 * 5); // 等待超时时间5秒
//	}
//
//	public void unlockRedPacket(String roomId, Integer index) {
//		String roomRedPacketKey = LIVE_ROOM_RED_PACKET_AMOUNT_KEY + roomId + "_" + index;
//		RedisLock lock = new RedisLock(roomRedPacketKey);
//		lock.unlock();
//	}
//}
