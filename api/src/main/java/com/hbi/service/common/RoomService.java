//package com.hbi.service.common;
//
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//import java.util.Timer;
//import java.util.TimerTask;
//
//import org.apache.commons.collections.CollectionUtils;
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.alibaba.fastjson.JSONObject;
//import com.core.service.BaseService;
//import com.hbi.cache.CacheDatabaseObject;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.cache.controller.CompereCacheController;
//import com.hbi.cache.controller.DatabaseQueueCacheController;
//import com.hbi.cache.controller.PlayerCacheController;
//import com.hbi.cache.controller.RoomCacheController;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CachePlayerProfile;
//import com.hbi.cache.model.CacheRoomListProfile;
//import com.hbi.cache.model.CacheUserListProfile;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TLiveRoomAccountMapper;
//import com.hbi.mapper.TRoomMapper;
//import com.hbi.model.TGame;
//import com.hbi.model.TGoods;
//import com.hbi.model.TLiveRoomAccount;
//import com.hbi.model.TRadioStationContent;
//import com.hbi.model.TRadioStationType;
//import com.hbi.model.TRoom;
//import com.hbi.model.TUserGoods;
//import com.hbi.model.TUserGoodsBuyRecord;
//import com.hbi.model.TUserGoodsPresentRecord;
//import com.hbi.model.TVipLevel;
//import com.hbi.service.compere.CompereService;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.GameServerUtil;
//import com.hbi.utils.InfServerException;
//
//@Service
//public class RoomService extends BaseService<TRoom> {
//
//	@Autowired
//	private RoomCacheController roomCacheController;
//
//	@Autowired
//	private UserGoodsService userGoodsService;
//
//	@Autowired
//	private UserGoodsBuyRecordService userGoodsBuyRecordService;
//
//
//	@Autowired
//	private UserTaskService userTaskService;
//	@Autowired
//	private LiveService liveService;
//	@Autowired
//	private CompereService compereService;
//	@Autowired
//	private GenerateIdService generateIdService;
//
//	@Autowired
//	private TRoomMapper roomMapper;
//	@Autowired
//	private TLiveRoomAccountMapper liveRoomAccountMapper;
//	@Autowired
//	private BaseCacheController baseCacheController;
//	@Autowired
//	private CommonCacheController commonCacheController;
//	@Autowired
//	private PlayerCacheController playerCacheController;
//	@Autowired
//    private CompereCacheController compereCacheController;
//	@Autowired
//    private DatabaseQueueCacheController databaseQueueCacheController;
//
//	private static Map<String, Timer> ysigTimerMap = new HashMap<String, Timer>();
//
//	private static Map<String, TimerTask> ysigTimerTaskMap = new HashMap<String, TimerTask>();
//
//	public void removeMemberFromRoom(String cityId, String roomId, String userId)
//			throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.removeMember(cityId, roomId, userId, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.kickMessage(Long.parseLong(userId), map.get("nickname"), map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void endLive(String cityId, String roomId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.endLive(cityId, roomId, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.stopLiveMessage(map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public String closeRoom(String cityId, String roomId, String compereId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			TRoom r = new TRoom();
//			r.setRoomId(Long.parseLong(roomId));
//			r.setStatus(3);
//			r.setEndDate(new Date());
//			roomMapper.updateByPrimaryKeySelective(r);
//
//			Map<String, String> map = new HashMap<String, String>();
//
//			int count = liveRoomAccountMapper.releaseLiveRoomAccount(Long.parseLong(compereId));
//			TLiveRoomAccount liveRoomAccount = null;
//			CacheCompereProfile compere = compereCacheController.getCompereDetail(compereId, cache, false, false);
//			if (count > 0) {
//			    List<TLiveRoomAccount> liveRoomAccounts = roomCacheController.queryLiveRoomAccounts(cache);
//			    if (CollectionUtils.isNotEmpty(liveRoomAccounts)) {
//			        for (TLiveRoomAccount lra : liveRoomAccounts) {
//			            if (lra.getCurrentUserId() != null) {
//			                if (lra.getCurrentUserId().toString().equals(compereId)) {
//	                            lra.setUseStatus(Constants.LIVE_ROOM_USE_STATUS_FREE);
//	                            lra.setCurrentUserId(null);
//	                            lra.setLiveStartTime(null);
//	                            lra.setLiveLastTime(null);
//	                            liveRoomAccount = lra;
//	                            break;
//	                        }
//			            }
//
//                    }
//			    }
//			}/* else {
//			    throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新直播账户数据失败");
//			}*/
//
//			if (!roomCacheController.closeRoom(cityId, roomId, compereId, cache, map)) {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "关闭房间修改缓存失败");
//            }
//
////			easeMobService.closeRoomMessage(map.get("chatRoomId"));
//			String chatroomId = compere.getChatroomId();
//			if (liveRoomAccount != null) {
//			    roomCacheController.updateLiveRoomAccount(liveRoomAccount, cache);
//			}
//			return chatroomId;
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void startGame(String cityId, String roomId, String gameId, String game)
//			throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			TGame g = baseCacheController.queryLiveGameByGameId(gameId, cache);
//
//			if (g == null) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "游戏不存在");
//			}
//
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.startGame(cityId, roomId, gameId, g.getCode(), game, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.openGameMessage(Long.parseLong(gameId), g.getCode(), map.get("gameName"), map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void startFm(String cityId, String roomId, String topicId, String topic)
//			throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.startFm(cityId, roomId, topicId, topic, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.openFmMessage(topic, map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void closeGame(String cityId, String roomId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.closeGame(cityId, roomId, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.closeGameMessage(Long.parseLong(map.get("gameId")), map.get("gameName"), map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void closeFm(String cityId, String roomId) throws Exception {
//		Timer t = ysigTimerMap.get(roomId);
//		if (t != null) {
//			t.cancel();
//			ysigTimerMap.remove(roomId);
//		}
//
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.closeFm(cityId, roomId, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.closeFmMessage(map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public List<Object> queryGiftForRoom(String roomId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			return roomCacheController.queryGiftForRoom(roomId,
//					cache);
//
//
////			if (result != null) {
////				return result;
////			} else {
////				TUserGoods e = new TUserGoods();
////				e.setRoomId(Long.parseLong(roomId));
////
////				List<TUserGoods> goods = userGoodsMapper.select(e);
////
////				result = new ArrayList<Object>();
////				if (!CollectionUtils.isEmpty(goods)) {
////					// 写redis
////
////
////					result.addAll(goods);
////
////					return result;
////				}
////				return result;
////			}
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	/**
//	 * 赠送礼物
//	 * @param giverId
//	 * @param goodsId
//	 * @param amount
//	 * @param receiverId
//	 * @param roomId
//	 * @throws Exception
//	 */
//	public void givePresents(Long giverId, Long goodsId, int amount, Long receiverId, Long roomId, int currentCount) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//
//			TGoods goods = baseCacheController.queryGiftGoodsByGoodsId(goodsId, cache);
//
//			//VIP等级折扣
//			CachePlayerProfile playerProfile = playerCacheController.queryPlayerDetail(giverId, cache, false, false);
//			TVipLevel vipLevel = playerCacheController.queryVipLevel(playerProfile.getVipLevel(), cache);
//			Float presentDiscount = vipLevel.getPresentDiscount();
//
//			Integer cost = (int)(goods.getPrice() * amount * presentDiscount);
//			String json = GameServerUtil.invokeQuery(giverId);
//
//			if (StringUtils.isEmpty(json)) {
//				throw new InfServerException();
//			}
//
//			JSONObject obj = JSONObject.parseObject(json);
//
//			if (obj == null || !obj.containsKey("coinAmount")) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "赠送人宝贝币账户不存在");
//			}
//
//			int remain = Integer.parseInt(obj.getString("coinAmount"));
//
//			if (cost > remain) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "余额不足");
//			}
//
//			json = GameServerUtil.invokeQuery(receiverId);
//
//			if (StringUtils.isEmpty(json)) {
//				throw new InfServerException();
//			}
//
//			obj = JSONObject.parseObject(json);
//
//			if (obj == null || !obj.containsKey("coinAmount")) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "接收人宝贝币账户不存在");
//			}
//
//			List<CacheDatabaseObject> insertList = new ArrayList<CacheDatabaseObject>();
//			List<CacheDatabaseObject> updateList = new ArrayList<CacheDatabaseObject>();
//
//			//个人背包
//			TUserGoods ug = new TUserGoods();
//			ug.setUserId(receiverId);
//	   		ug.setAmount(goods.getAmount() * amount);
//   			ug.setTotalPrice(cost);
//			ug.setUnitPrice(ug.getTotalPrice() / ug.getAmount());
//			CacheDatabaseObject ugObj = new CacheDatabaseObject();
//			ugObj.setControlType("insert:T_USER_GOODS");
//			ugObj.setData(ug);
//			insertList.add(ugObj);
//
//			Date nowDate = new Date();
//			//购买历史
//	   	   	TUserGoodsBuyRecord goodsBuyRecord = new TUserGoodsBuyRecord();
////	   	   	goodsBuyRecord.setId(generateIdService.generateId(TUserGoodsBuyRecord.class.getName()));
//			goodsBuyRecord.setUserId(giverId);
//			goodsBuyRecord.setGoodsId(goodsId);
//			goodsBuyRecord.setTotalPrice(ug.getTotalPrice());
//			goodsBuyRecord.setAmount(ug.getAmount());
//			goodsBuyRecord.setBuyDate(nowDate);
//			if (goods != null) {
//  				goodsBuyRecord.setGoodsName(goods.getName());
//  				goodsBuyRecord.setGoodsPhoto(goods.getPhoto());
//			}
////			userGoodsBuyRecordService.save(goodsBuyRecord);
//			CacheDatabaseObject goodsBuyRecordObj = new CacheDatabaseObject();
//			goodsBuyRecordObj.setControlType("insert:T_USER_GOODS_BUY_RECORD");
//			goodsBuyRecordObj.setData(goodsBuyRecord);
//			insertList.add(goodsBuyRecordObj);
//
//			//赠送历史
//			TUserGoodsPresentRecord goodsPresentRecord = new TUserGoodsPresentRecord();
//			goodsPresentRecord.setId(generateIdService.generateId());
//			goodsPresentRecord.setUserId(receiverId);
//			goodsPresentRecord.setGoodsId(goodsId);
//			goodsPresentRecord.setGoodsName(goods.getName());
//			goodsPresentRecord.setGoodsPhoto(goods.getPhoto());
//			goodsPresentRecord.setTotalPrice(cost);
//			goodsPresentRecord.setAmount(amount);
//			goodsPresentRecord.setRoomId(roomId);
//			goodsPresentRecord.setGiverId(giverId);
//			goodsPresentRecord.setGiveDate(nowDate);
//
////			userGoodsPresentRecordService.save(goodsPresentRecord);
//			CacheDatabaseObject goodsPresentRecordObj = new CacheDatabaseObject();
//			goodsPresentRecordObj.setControlType("insert:T_USER_GOODS_PRESENT_RECORD");
//			goodsPresentRecordObj.setData(goodsPresentRecord);
//			insertList.add(goodsPresentRecordObj);
//
//			compereService.updateCompereExp(receiverId, cost, cache);
//
//			//更新任务进度
//			userTaskService.updateUserDailyTaskAsync(receiverId, Constants.USER_TYPE_C, Constants.TASK_RECEIVE_GIFT, 1, cache, insertList, updateList);
//
//			Map<String, String> map = new HashMap<String, String>();
//
//			roomCacheController.givePresents(goodsPresentRecord, cache, map);
//
//			//发红包
//			roomCacheController.increaseRoomRedPacketAmountAndSendPacket(roomId, map.get("chatRoomId"), goodsPresentRecord.getTotalPrice(), cache);
//
//
//			if (!GameServerUtil.invokeUpdateCoin(giverId, 0 - cost)) {
//				throw new InfServerException(Constants.RETURN_CODE_ACCOUNT_ERROR, "更新玩家账户失败");
//			}
//
//			if (!databaseQueueCacheController.queueObject(giverId + "", insertList, updateList, cache)) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "数据更新失败");
//			}
//
//
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void exitRoom(String cityId, String userId, String roomId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.exitRoom(cityId, userId, roomId, cache, map)) {
//				throw new InfServerException();
//			}
//			if (map.get("chatRoomId") != null) {
////				easeMobService.exitRoomMessage(Long.parseLong(userId), map.get("nickname"), map.get("chatRoomId"));
//			}
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public List<TRadioStationType> queryRadioStationTypes() throws Exception {
//	    ICache cache = CacheManager.getCache();
//        try {
//            return commonCacheController.queryRadioStationTypes(cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//	}
//
//	/**
//	 * 根据电台主题，随机查询提示
//	 * @param topicId
//	 * @param count
//	 * @return
//	 * @throws Exception
//	 */
//	public List<TRadioStationContent> queryFmHintContent(Long topicId, int count) throws Exception {
//	    ICache cache = CacheManager.getCache();
//        try {
//            List<TRadioStationContent> radioStationContents = commonCacheController.queryRandomRadioStationContentByType(topicId, count, cache);
//            if (CollectionUtils.isNotEmpty(radioStationContents)) {
//                return radioStationContents;
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有查询到相关电台主题内容");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            CacheManager.releaseCache(cache);
//        }
//	}
//
//	public void openYouSayIGuess(String cityId, String roomId, String topicId, String topic, String goodsId)
//			throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			TGoods goods = baseCacheController.queryGiftGoodsByGoodsId(Long.parseLong(goodsId), cache);
//
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.openYouSayIGuess(cityId, roomId, topicId, topic, goods, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.openYouSayIGuessMessage(topic, goods, map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void joinYouSayIGuess(String roomId, String compereId, String playerId, String goodsId, String position, int currentCount)
//			throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			if (roomCacheController.getFmStartStatus(roomId, cache) != null) {
//				throw new InfServerException("3", "游戏已开始");
//			}
//
//			givePresents(Long.parseLong(playerId), Long.parseLong(goodsId), 1, Long.parseLong(compereId), Long.parseLong(roomId), currentCount);
//			Map<String, String> map = new HashMap<String, String>();
//
//			CacheUserListProfile m = roomCacheController.joinFm(roomId, playerId, position, cache, map);
//			if (m == null) {
//				throw new InfServerException("3", "test use");
//			}
////			easeMobService.joinYouSayIGuessMessage(m, map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void startYouSayIGuess(String roomId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			Map<String, CacheUserListProfile> result = roomCacheController.startYouSayIGuess(roomId, cache, map);
//			if (result == null) {
//				throw new InfServerException();
//			}
//			Timer t = new Timer();
//			ysigTimerMap.put(roomId, t);
////			easeMobService.startYouSayIGuessMessage(result, map.get("chatRoomId"));
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void selectWordForYouSayIGuess(String roomId, String word) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Map<String, String> map = new HashMap<String, String>();
//			if (!roomCacheController.selectWordForYouSayIGuess(roomId, word, cache, map)) {
//				throw new InfServerException();
//			}
////			easeMobService.selectWordForYouSayIGuessMessage(word, map.get("chatRoomId"));
//
//			Timer t = ysigTimerMap.get(roomId);
//			if (t != null) {
//				final String finalRoomId = roomId;
//				TimerTask tt = new TimerTask() {
//					String mRoomId = finalRoomId;
//					int seconds = 60;
//
//					@Override
//					public void run() {
//						// TODO Auto-generated method stub
//						if (seconds == 0) {
//							try {
//								endYouSayIGuess(mRoomId);
//							} catch (Exception e) {
//								// TODO Auto-generated catch block
//								e.printStackTrace();
//							}
//						}
//						seconds--;
//					}
//				};
//				ysigTimerTaskMap.put(roomId, tt);
//				t.schedule(tt, 0, 1000);
//			}
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void endYouSayIGuess(String roomId) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			Timer t = ysigTimerMap.get(roomId);
//			if (t != null) {
//				TimerTask tt = ysigTimerTaskMap.get(roomId);
//				if (tt != null) {
//					tt.cancel();
//					ysigTimerTaskMap.remove(roomId);
//				}
//				t.purge();
//			}
//
//			String chatRoomId = roomCacheController.getChatRoomId(Long.parseLong(roomId), cache);
//
//			int rounds = roomCacheController.queryYouSayIGuessRounds(roomId, cache);
//
//			if (rounds > 5) {
//				List<CacheUserListProfile> sortedPlayers = roomCacheController.endYouSayIGuessMatch(roomId, cache);
//
//				for (int i = 1; i < sortedPlayers.size(); i++) {
//					CacheUserListProfile m = sortedPlayers.get(i);
//					liveService.exitFm(roomId, m.getUserId(), m.getPosition());
//				}
//
//				CacheUserListProfile winner = sortedPlayers.get(0);
//				//发个轮结束的消息
////				easeMobService.endYouSayIGuessMatchMessage(winner, chatRoomId);
//			} else {
//				roomCacheController.endYouSayIGuess(roomId, cache);
//
//				Map<String, CacheUserListProfile> players = roomCacheController.queryYouSayIGuess(roomId, cache);
//
////				easeMobService.endYouSayIGuessMessage(players, chatRoomId);
//			}
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public void answerYouSayIGuess(String roomId, String position) throws Exception {
//		ICache cache = CacheManager.getCache();
//		try {
//			String chatRoomId = roomCacheController.getChatRoomId(Long.parseLong(roomId), cache);
//
//			Map<String, Object> map = roomCacheController.answerYouSayIGuess(roomId, position, cache);
//
//			boolean isEnded = Boolean.parseBoolean(map.get("isEnded").toString());
//			if (isEnded) {
//				endYouSayIGuess(roomId);
//			} else {
////				easeMobService.updatePlayerForYouSayIGuessMessage((CacheUserListProfile)map.get("player"), chatRoomId);
//			}
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			CacheManager.releaseCache(cache);
//		}
//	}
//
//	public List<CacheRoomListProfile> queryAllNotClosedRooms() {
//	    return roomMapper.queryAllNotClosedRooms();
//	}
//}
