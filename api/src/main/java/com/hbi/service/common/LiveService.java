//package com.hbi.service.common;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.service.BaseService;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.*;
//import com.hbi.cache.model.*;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.mapper.TLiveRoomAccountMapper;
//import com.hbi.mapper.TRoomMapper;
//import com.hbi.model.*;
//import com.hbi.service.compere.CompereService;
//import com.hbi.service.player.PlayerService;
//import com.hbi.utils.InfServerException;
//import com.hbi.utils.PushUtil;
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.lang.StringUtils;
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.util.*;
//
//@Service
//public class LiveService extends BaseService<TRoom> {
//
//    private static Log log = LogFactory.getLog(LiveService.class);
//
//    @Autowired
//    private CompereService compereService;
//    @Autowired
//    private RoomService roomService;
//    @Autowired
//    private UserService userService;
//    @Autowired
//    private TRoomMapper roomMapper;
//    @Autowired
//    private TCompereMapper compereMapper;
//    @Autowired
//    private TLiveRoomAccountMapper liveRoomAccountMapper;
//    @Autowired
//    private RoomCacheController roomCacheController;
//    @Autowired
//    private CompereCacheController compereCacheController;
//    @Autowired
//    private PlayerCacheController playerCacheController;
//    @Autowired
//    private BaseCacheController baseCacheController;
//    @Autowired
//    private PlayerService playerService;
//    @Autowired
//    private RobotsCacheController robotsCacheController;
//
//    private static Map<String, Timer> roomTimerMap = new HashMap<String, Timer>();
//
//    private static Map<String, TimerTask> roomTimerTaskMap = new HashMap<String, TimerTask>();
//
//    /**
//     * 创建房间
//     *
//     * @param compereId
//     * @param password
//     * @throws Exception
//     */
//    public CacheRoomProfile createRoom(String compereId, String roomName, String roomPhoto, String roomListPhoto,
//            String password, Float liveLastTime, String liveType, String liveActivityCode) throws Exception {
//        liveLastTime = 999F;
//        Long cid = Long.parseLong(compereId);
//        CacheRoomProfile roomDetail = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            Date nowDate = new Date();
//            CacheCompereProfile compere = compereCacheController.getCompereDetail(compereId, cache, false, true);
//            if (compere != null) {
//                String roomIdStr = roomCacheController.getRelationRoomId(compereId, cache);
//                if (StringUtils.isNotBlank(roomIdStr)) {
//
//                    roomDetail = roomCacheController.queryRoomDetail(Long.parseLong(roomIdStr), cache);
//                }
//                if (roomDetail != null) {
//                    Long roomId = Long.parseLong(roomIdStr);
//                    roomMapper.updateLiveRoomInfo(roomId, roomName, roomListPhoto, roomPhoto, password, liveType);
//
//                    CacheRoomListProfile cacheRoomListProfile = new CacheRoomListProfile();
//                    cacheRoomListProfile.setRoomId(roomId + "");
//                    cacheRoomListProfile.setPassword(password);
//                    cacheRoomListProfile.setCityId(compere.getCityId());
//                    cacheRoomListProfile.setRoomPhoto(roomListPhoto);
//                    cacheRoomListProfile.setRoomName(roomName);
//                    cacheRoomListProfile.setLiveType(liveType);
//
//                    compere.setRoomId(roomId + "");
//                    compere.setRoomName(roomName);
//                    compere.setRoomPassword(password);
//
//                    roomDetail.setRoomName(roomName);
//                    roomDetail.setCompere(compere);
//                    roomDetail.setRoomPassword(password);
//                    roomDetail.setRoomPhoto(roomPhoto);
//
//                    TLiveRoomAccount liveRoomAccount = this.getRandomLiveRoomAccount(compere, liveLastTime, cache);
//                    roomDetail.setLiveUsername(liveRoomAccount.getAccount());
//                    roomDetail.setLivePassword(liveRoomAccount.getPassword());
//
//                    roomDetail.setLiveType(liveType);
//
//                    if (liveActivityCode != null) {
//                    	String activityPhoto = "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/activity_" + liveActivityCode + ".png";
//                    	roomDetail.setActivityPhotoUrl(activityPhoto);
//                    }
//
//                    roomCacheController.updateRoomInfo(cacheRoomListProfile, roomDetail, cache);
//                } else {
//                    // 创建环信聊天室
//                    String chatRoomId = compere.getChatroomId();
//
//                    if (StringUtils.isEmpty(chatRoomId)) {
//                    	chatRoomId = compereService.createChatroom(Long.parseLong(compereId), compere.getPhone(), cache);
//
//                    	if (StringUtils.isEmpty(chatRoomId)) {
//                    		throw new InfServerException(Constants.RETURN_CODE_FAIL, "聊天室异常");
//                    	}
//                    }
//
//                    TRoom room = new TRoom();
//                    room.setCompereId(cid);
//                    room.setName(roomName);
//                    room.setChatroomId(chatRoomId);
//                    room.setCreateDate(nowDate);
//                    room.setRoomPassword(password);
//                    room.setStatus(0);
//                    room.setRoomListPhoto(roomListPhoto);
//                    room.setRoomPhoto(roomPhoto);
//                    room.setLiveType(liveType);
//                    room.setStartDate(new Date());
//                    int count = roomService.save(room);
//                    if (count == 1) {
//                        Long roomId = roomMapper.queryNotClosedRoomByCompre(Long.parseLong(compereId));
//                        // 写入Redis
//                        CacheRoomListProfile cacheRoomListProfile = new CacheRoomListProfile();
//                        cacheRoomListProfile.setCompereId(compereId);
//                        cacheRoomListProfile.setRoomId(roomId + "");
//                        cacheRoomListProfile.setPassword(password);
//                        cacheRoomListProfile.setGender(compere.getSex());
//                        cacheRoomListProfile.setChatRoomId(chatRoomId);
//                        cacheRoomListProfile.setCityId(compere.getCityId());
//                        cacheRoomListProfile.setPhotoUrl(compere.getPhotoUrl());
//                        cacheRoomListProfile.setRoomPhoto(roomListPhoto);
//                        cacheRoomListProfile.setRoomName(roomName);
//                        cacheRoomListProfile.setCityId(compere.getCityId());
//                        cacheRoomListProfile.setLiveType(liveType);
//
//                        if (compere.getLatitude() != null) {
//                            cacheRoomListProfile.setLatitude(compere.getLatitude());
//                        }
//                        if (compere.getLongitude() != null) {
//                            cacheRoomListProfile.setLongitude(compere.getLongitude());
//                        }
//                        cacheRoomListProfile.setStatus(Constants.NOT_LIVE);
//                        if (compere != null) {
//                            cacheRoomListProfile.setCompereName(compere.getNickName());
//
//                            List<TMoments> moments = compere.getMoments();
//                            if (CollectionUtils.isNotEmpty(moments)) {
//                                List<String> photoUrls = new ArrayList<String>();
//                                for (TMoments moment : moments) {
//                                    List<TAlbum> albums = moment.getList();
//                                    if (CollectionUtils.isNotEmpty(albums)) {
//                                        for (TAlbum album : albums) {
//                                            if (Constants.PHOTO.equals(album.getType())) {
//                                                photoUrls.add(album.getFilename());
//                                            }
//                                        }
//                                    }
//                                }
//                                cacheRoomListProfile.setPhotos(photoUrls);
//                            }
//                        }
//
//                        compere.setRoomId(roomId + "");
//                        compere.setRoomName(roomName);
//                        compere.setRoomPassword(password);
//
//                        roomDetail = new CacheRoomProfile();
//
//                        roomDetail.setRoomId(roomId + "");
//                        roomDetail.setRoomName(roomName);
//                        roomDetail.setCompere(compere);
//                        roomDetail.setChatRoomId(chatRoomId);
//                        roomDetail.setRoomPassword(password);
//                        roomDetail.setCompereId(compereId);
//                        roomDetail.setRoomPhoto(roomPhoto);
//
//                        TLiveRoomAccount liveRoomAccount = this.getRandomLiveRoomAccount(compere, liveLastTime, cache);
//                        roomDetail.setLiveUsername(liveRoomAccount.getAccount());
//                        roomDetail.setLivePassword(liveRoomAccount.getPassword());
//                        if (liveRoomAccount.getLiveId() != null) {
//                            roomDetail.setLiveId(liveRoomAccount.getLiveId().toString());
//                            cacheRoomListProfile.setLiveId(liveRoomAccount.getLiveId().toString());
//                        }
//
//                        roomDetail.setLiveType(liveType);
//
////                        if (compereId.equals("505")) {
////                            int playerCount = RandomUtils.nextInt(20) + 10;
////                            cacheRoomListProfile.setCount(playerCount);
////                            roomDetail.setCount(playerCount);
////                        }
//
//                        if (liveActivityCode != null) {
//                        	String activityPhoto = "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/activity_" + liveActivityCode + ".png";
//                        	roomDetail.setActivityPhotoUrl(activityPhoto);
//                        }
//
//                        if (!roomCacheController.addCompereRoomRelation(compereId, roomId.toString(), cache)) {
//                            throw new InfServerException(Constants.RETURN_CODE_FAIL, "缓存房间数据插入失败");
//                        }
//                        roomCacheController.createRoom(cacheRoomListProfile, roomDetail, cache);
//                    } else {
//                        throw new InfServerException(Constants.RETURN_CODE_FAIL, "房间数据插入失败");
//                    }
//                }
//
//                final String compereNickName = compere.getNickName();
//                final String comperePhotoUrl = compere.getPhotoUrl();
//                final String userId = compere.getUserId();
//                final String roomId = compere.getRoomId();
//                final String chatRoomId = compere.getChatroomId();
//                final String longitude = String.valueOf(compere.getLongitude());
//                final String latitude = String.valueOf(compere.getLatitude());
//
//                List<CachePlayerListProfile> fansList = (List<CachePlayerListProfile>)compereService.queryMyFans(compereId);
//                final String[] fans = new String[fansList.size()];
//                for (int i = 0; i < fansList.size(); i++) {
//                    fans[i] = fansList.get(i).getUserId();
//                }
//
//                new Thread(new Runnable() {
//                    public void run() {
//                      //推送
//                        JSONObject jsonObject = new JSONObject();
//                        jsonObject.put("users", fans);
//                        jsonObject.put("nickname", compereNickName);
//                        jsonObject.put("photoUrl", comperePhotoUrl);
//                        jsonObject.put("userId", userId);
//                        jsonObject.put("roomId", roomId);
//                        jsonObject.put("chatRoomId", chatRoomId);
//                        jsonObject.put("longitude", longitude);
//                        jsonObject.put("latitude", latitude);
//                        try {
//                            PushUtil.push(Constants.START_LIVE, jsonObject);
//                        } catch (Exception e) {
//                            log.error(e.getMessage());
//                        }
//                    }
//                }).start();
//                roomDetail.setPriority(compere.getPriority());
//                return roomDetail;
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有此主播信息");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//
//    }
//
//    public void startLive(String cityId, String roomID, String liveID, String compereId, String resolution) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TRoom room = new TRoom();
//
//            room.setRoomId(Long.parseLong(roomID));
//            room.setLiveId(Long.parseLong(liveID));
//            room.setResolution(resolution);
//
//            roomService.updateBySelective(room);
//
//            Map<String, String> map = new HashMap<String, String>();
//            if (!roomCacheController.doStartLive(cityId, roomID, liveID, resolution, cache, map)) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "缓存开启直播失败");
//            }
////            easeMobService.openLiveMessage(liveID, compereId, map.get("nickname"), resolution, map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void openMicrophone(String roomID) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TRoom room = new TRoom();
//            room.setRoomId(Long.parseLong(roomID));
//            room.setMicrophone(TRoom.MICPHONE_QUEUE);
//            roomService.updateBySelective(room);
//
//            Map<String, String> map = new HashMap<String, String>();
//            if (!roomCacheController.setMicphone(roomID, TRoom.MICPHONE_QUEUE, cache, map)) {
//                throw new InfServerException();
//            }
////            easeMobService.openMicMessage(map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void resetMicrophone(String roomID, String userId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TRoom room = new TRoom();
//            room.setRoomId(Long.parseLong(roomID));
//            room.setMicrophone(TRoom.MICPHONE_QUEUE);
//
//            roomService.updateBySelective(room);
//            Map<String, String> map = new HashMap<String, String>();
//
//            if (!roomCacheController.removeFromMicrophoneQueue(roomID, userId, cache, map)) {
//                throw new InfServerException();
//            }
//
//            if (!roomCacheController.setMicphone(roomID, TRoom.MICPHONE_QUEUE, cache, map)) {
//                throw new InfServerException();
//            }
////            easeMobService.releaseMicMessage(Long.parseLong(userId), map.get("nickname"), map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void exitFm(String roomID, String userId, String position) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//
//            Map<String, String> map = new HashMap<String, String>();
//
//            if (!roomCacheController.removeFm(roomID, userId, position, cache, map)) {
//                throw new InfServerException();
//            }
//
////            easeMobService.exitFmMessage(Long.parseLong(userId), map.get("nickname"), position, map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void takebackMicrophone(String roomID) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TRoom room = new TRoom();
//            room.setRoomId(Long.parseLong(roomID));
//            room.setMicrophone(TRoom.MICPHONE_COMPERE);
//
//            roomService.updateBySelective(room);
//            Map<String, String> map = new HashMap<String, String>();
//            if (!roomCacheController.setMicphone(roomID, TRoom.MICPHONE_COMPERE, cache, map)) {
//                throw new InfServerException();
//            }
////            easeMobService.takebackMicMessage(map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//
//        }
//    }
//
//    public void queueMicrophone(String roomId, String playerId) throws Exception {
//
//        ICache cache = CacheManager.getCache();
//        try {
//            Map<String, String> map = new HashMap<String, String>();
//            if (!roomCacheController.queueMicphone(roomId, playerId, cache, map)) {
//                throw new InfServerException("3", "test use");
//            }
////            easeMobService.applyMicMessage(Long.parseLong(playerId), map.get("photoUrl"), map.get("nickname"),
////                    map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public void joinFm(String roomId, String playerId, String position) throws Exception {
//
//        ICache cache = CacheManager.getCache();
//        try {
//            Map<String, String> map = new HashMap<String, String>();
//            if (roomCacheController.joinFm(roomId, playerId, position, cache, map) == null) {
//                throw new InfServerException("3", "test use");
//            }
////            easeMobService.joinFmMessage(Long.parseLong(playerId), map.get("photoUrl"), map.get("nickname"), position,
////                    map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public void changeWaitingMicrophoneOrder(String roomId, String playerId, String position) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            Map<String, Object> map = new HashMap<String, Object>();
//            if (!roomCacheController.changeMicphoneQueue(roomId, playerId, position, cache, map)) {
//                throw new InfServerException();
//            }
////            easeMobService.changeMicMessage((List) map.get("micList"), (String) map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public void removeFromWaitingMicrophone(String roomId, String playerId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            RoomCacheController rcc = new RoomCacheController();
//
//            Map<String, String> map = new HashMap<String, String>();
//            if (!rcc.removeFromMicrophoneQueue(roomId, playerId, cache, map)) {
//                throw new InfServerException();
//            }
////            easeMobService.removeFromMicMessage(Long.parseLong(playerId), map.get("chatRoomId"));
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheUserListProfile> viewRoomPlayers(String roomId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheUserListProfile> userList = roomCacheController.viewRoomPlayers(roomId, cache);
//
//            if (userList == null) {
//                throw new InfServerException();
//            } else {
//                return userList;
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheUserListProfile> viewMicphonePlayers(String roomId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheUserListProfile> userList = roomCacheController.viewMicphonePlayers(roomId, cache);
//
//            if (userList == null) {
//                throw new InfServerException();
//            } else {
//                return userList;
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheUserListProfile> viewFmPlayers(String roomId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheUserListProfile> userList = roomCacheController.viewFmPlayers(roomId, cache);
//
//            if (userList == null) {
//                throw new InfServerException();
//            } else {
//                return userList;
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public CacheRoomProfile isEnterRoomSuccess(String roomId, String userId, String password, String excRoomId, boolean isRobot)
//            throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//
//            CacheRoomProfile roomProfile = roomCacheController.queryRoomDetail(Long.parseLong(roomId), cache);
//
//            if (roomProfile == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "房间对象为空");
//            }
//            CacheCompereProfile compere = roomProfile.getCompere();
//            if (compere != null) {
//                compere.setIsFan(compereCacheController.isFanPlayerByCompereId(compere.getUserId(), userId, cache));
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "主播对象为空");
//            }
//
//            if (!StringUtils.isEmpty(excRoomId)) {
//                roomService.exitRoom(roomProfile.getCompere().getCityId(), userId, excRoomId);
//            }
//
//            CachePlayerProfile player = playerCacheController.queryPlayerDetail(Long.parseLong(userId), cache, false, false);
//
//            if (player == null) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "玩家对象为空");
//            }
//
//            if (StringUtils.isNotBlank(roomProfile.getRoomPassword())) {
//                if (!roomProfile.getRoomPassword().equals(password)) {
//                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "房间密码错误");
//                }
//            }
//
//            boolean result = roomCacheController.enterRoom(userId, roomProfile, cache);
//            if (result) {
////                easeMobService.enterRoomMessage(Long.parseLong(userId), player.getNickName(), player.getPhotoUrl(),
////                        player.getPhone(), isRobot, roomProfile.getChatRoomId());
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "加入房间失败");
//            }
//            roomProfile = roomCacheController.queryRoomDetail(Long.parseLong(roomId), cache);
//            roomProfile.setCompere(compere);
//
//            if (StringUtils.isEmpty(password) && !isRobot && roomProfile.getActivityPhotoUrl() == null) {
//            	final String fRoomId = roomId;
//                Thread t = new Thread(new Runnable() {
//
//    				@Override
//    				public void run() {
//    					// TODO Auto-generated method stub
//    					joinRobots(fRoomId);
//    				}
//    			});
//                t.start();
//            }
//
//            return roomProfile;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    private void joinRobots(String roomId) {
//    	ICache cache = null;
//    	try {
//    		cache = CacheManager.getCache();
//
//    		int batNo = robotsCacheController.getAvaibleBatNo(roomId, cache);
//
//    		if (batNo > 0) {
//    			List<String> ids = robotsCacheController.getRobotsByBatNo(batNo, cache);
//    			Thread.sleep(3000);
//    			for (String id : ids) {
//    				Thread.sleep(2000);
//    				isEnterRoomSuccess(roomId, id, null, null, true);
//    			}
//    		}
//
//    	} catch (Exception e) {
//
//    	} finally {
//    		if (cache != null) {
//    			CacheManager.releaseCache(cache);
//    		}
//    	}
//    }
//
//    public List<CacheRoomListProfile> getRoomList(Long cityId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheRoomListProfile> profiles = roomCacheController.queryRoomList(cityId, cache);
//            for(CacheRoomListProfile profile : profiles) {
//                CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(profile.getCompereId().toString(), cache, false, false);
//                profile.setCaptureStatus(compereProfile.getCaptureStatus());
//                profile.setProtectTime(compereProfile.getProtectTime());
//                profile.setPriority(compereProfile.getPriority());
//            }
//            return profiles;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheRoomListProfile> getAllRoomList() throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheRoomListProfile> profiles = roomCacheController.queryAllRoomList(cache);
//            for(CacheRoomListProfile profile : profiles) {
//                CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(profile.getCompereId().toString(), cache, false, false);
//                profile.setCaptureStatus(compereProfile.getCaptureStatus());
//                profile.setProtectTime(compereProfile.getProtectTime());
//                profile.setPriority(compereProfile.getPriority());
//            }
//            return profiles;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public List<CacheRoomListProfile> getFollowedRoomList(String userId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            List<CacheRoomListProfile> profiles = roomCacheController.queryAllRoomList(cache);
//            List<CacheCompereListProfile> comperes = (List<CacheCompereListProfile>)playerService.queryMyAttentions(userId);
//            List<String> compereIds = new ArrayList<String>();
//            for (CacheCompereListProfile c : comperes) { //获取关注的主播ID列表
//                compereIds.add(c.getUserId());
//            }
//            Iterator<CacheRoomListProfile> iterator = profiles.iterator();
//            while (iterator.hasNext()) { //移除非关注的房间
//                CacheRoomListProfile profile = iterator.next();
//                if (!compereIds.contains(profile.getCompereId())) {
//                    iterator.remove();
//                }
//            }
//            for(CacheRoomListProfile profile : profiles) {
//                CacheCompereProfile compereProfile = compereCacheController.getCompereDetail(profile.getCompereId().toString(), cache, false, false);
//                profile.setCaptureStatus(compereProfile.getCaptureStatus());
//                profile.setProtectTime(compereProfile.getProtectTime());
//            }
//            return profiles;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    public void uploadLiveCut(String roomId, String photoUrl, String cityId) throws Exception {
//        ICache cache = CacheManager.getCache();
//        try {
//            if (!roomCacheController.uploadLiveCut(roomId, photoUrl, cityId, cache)) {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "房间不存在");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//    }
//
//    /**
//     * 根据城市获取随机直播账户
//     * @param compere
//     * @param liveLastTime
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    private TLiveRoomAccount getRandomLiveRoomAccount(CacheCompereProfile compere, Float liveLastTime, ICache cache) throws Exception {
//        try {
//            Long compereId = Long.parseLong(compere.getUserId());
//            Date nowDate = new Date();
//            TLiveRoomAccount liveRoomAccount = null;
//            if (compere != null) {
////                String cityIdSstr = compere.getCityId();
////                if (StringUtils.isNotBlank(cityIdSstr)) {
//                    List<TLiveRoomAccount> liveRoomAccounts = roomCacheController.queryLiveRoomAccounts(cache);
//                    if (CollectionUtils.isNotEmpty(liveRoomAccounts)) {
//                        Calendar calendar = Calendar.getInstance();
//                        //判断是否有账号是当前主播占用的
//                        for (TLiveRoomAccount lra : liveRoomAccounts) {
//                            if (Constants.LIVE_ROOM_USE_STATUS_USED.equals(lra.getUseStatus()) && compereId.equals(lra.getCurrentUserId())) {
//                                int seconds = (int) (lra.getLiveLastTime() * 3600);
//                                calendar.setTime(lra.getLiveStartTime());
//                                calendar.add(Calendar.SECOND, seconds);
//                                if (calendar.getTime().after(nowDate)) {
//                                    liveRoomAccount = lra;
//                                    break;
//                                }
//                            }
//                        }
//
//                        if (liveRoomAccount == null) {
//                            for (TLiveRoomAccount lra : liveRoomAccounts) {
//                                if (Constants.LIVE_ROOM_USE_STATUS_FREE.equals(lra.getUseStatus())) {
//                                    if (lra.getLiveLastTime() != null) {
//                                        int seconds = (int) (lra.getLiveLastTime() * 3600);
//                                        calendar.setTime(nowDate);
//                                        calendar.add(Calendar.SECOND, -seconds);
//                                    }
//
//                                    int count = liveRoomAccountMapper.updateLiveRoomAccountUseStatus(compereId, lra.getId(), nowDate, liveLastTime, calendar.getTime());
//                                    if (count == 1) {
//                                        lra.setCurrentUserId(compereId);
//                                        lra.setUseStatus(Constants.LIVE_ROOM_USE_STATUS_USED);
//                                        lra.setLiveStartTime(nowDate);
//                                        lra.setLiveLastTime(liveLastTime);
//                                        liveRoomAccount = lra;
//                                        roomCacheController.updateLiveRoomAccount(liveRoomAccount, cache);
//                                        break;
//                                    }
//                                }
//                            }
//                        }
//
//                    }
//
//                    if (liveRoomAccount == null) {
//                        throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有可用的直播账号");
//                    }
////                } else {
////                    throw new InfServerException(Constants.RETURN_CODE_FAIL, "主播的城市为空");
////                }
//
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关主播");
//            }
//
//            return liveRoomAccount;
//        } catch (Exception e) {
//            throw e;
//        }
//    }
//
//    public List<TLiveHotWords> hotWords() throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TLiveHotWords> list = roomCacheController.hotWords(cache);
//            return list;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void compereGetRedPacket(String roomId, Integer index) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            roomCacheController.compereGetRedPacket(roomId, index, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public void playerGetRedPacket(String roomId, Long playerId, Integer index) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            if (roomCacheController.lockRedPacket(roomId, index)) {
//                try {
//
//                } catch (Exception e) {
//                    throw e;
//                } finally {
//                    roomCacheController.unlockRedPacket(roomId, index);
//                }
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//}
