package com.hbi.service.roomcard;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.util.DateUtils;
import com.core.util.RedisUtil3;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.RoomCardCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.charge.BaseChargeService;
import com.hbi.service.schedule.ScheduleConstants;
import com.hbi.utils.InfServerException;
import com.hbi.vo.request.common.MapVo;
import com.hbi.vo.response.Response;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by ceeuoo on 8/27/2016.
 */
@Service
public class RoomCardService {

	@Autowired
	private TUserMapper userMapper;
	@Autowired
	private RoomCardCacheController roomCardCacheController;
	@Autowired
	private BaseCacheController baseCacheController;
	@Autowired
	private TActivityHistoryMapper activityHistoryMapper;
	@Autowired
	private TGroupGameMapper groupGameMapper;
	@Autowired
	private TActivityMapper activityMapper;
	@Autowired
	private TActivityUserMapper tActivityUserMapper;
	@Autowired
	private BaseChargeService baseChargeService;

	private static final String PAY_TYPE = "pay_type";
	private static final String CARD_COUNT = "cardCount";
	private static final String GROUP_ID = "groupId";
	private static final String GAME_ROUND_KEY = "USERPLAY_ROUND_";
	private static final String GAME_TGDOUNIU_ROUND_KEY = "USERPLAY_TGDOUNIU_ROUND_";
	private static final String GAME_PEOPLE_NUM = "peopleNum";
	private static final String GAME_ACTIVITY_KEY_PREFIX = "GAME_ACTIVITY_";

		public void deductCard(Long userId, Integer level, Integer round,Long activityId ) throws Exception {
			ICache cache = null;
			try {
				cache = CacheManager.getCache();
//				TGameLevelCard card = roomCardCacheController.queryConfigByLevelAndRound(level, round, cache);
				String curGroupMasterRoomCard = baseCacheController.queryConfig(Constants.curGroupMasterRoomCard, cache);
				//更改是否扣卡的状态
				activityMapper.updateIsdeduct(activityId);


				// 获取房卡信息
				String paytype = cache.hget(GAME_ROUND_KEY + activityId, PAY_TYPE);
				String cardCountStr = cache.hget(GAME_ROUND_KEY + activityId, CARD_COUNT);
				String groupIdStr = cache.hget(GAME_ROUND_KEY + activityId, GROUP_ID);
				Integer cardCount = 0;
				if (!StringUtil.isEmpty(cardCountStr) ) {
					cardCount = Integer.parseInt(cardCountStr );
				}
				String groupOwerId = cache.hget(GAME_ROUND_KEY + activityId, "groupOwerId");
				TActivityHistory activityHistory = new TActivityHistory();
				activityHistory.setActivityId(activityId);
				activityHistory.setGameId(Long.parseLong(level.toString()));
				activityHistory.setLevel(level);
				activityHistory.setRound(round);
				activityHistory.setCardCount(cardCount);
				activityHistory.setStartDate(new Date());

				if (!StringUtil.isEmpty(groupIdStr) ) {
					RedisUtil3 ru = RedisUtil3.getRu();
					ru.hincrby(ScheduleConstants.STT_CLUB_CARD_COUNT_TODAY, groupIdStr, (long) cardCount);
				}

				//扣群主的卡
				if ("1".equals(curGroupMasterRoomCard) && StringUtil.isNotEmpty(groupOwerId)) {
					String nickName = cache.hget(Constants.PLAYER_+groupOwerId,"nickName");
					activityHistory.setUserId(Long.parseLong(groupOwerId));
					activityHistory.setUserNames(nickName);
					activityHistory.setStartDate(new Date());
					activityHistoryMapper.insert(activityHistory);
				}else {
					if (paytype != null && paytype.equals("fangka")) {

						String nickName = cache.hget(Constants.PLAYER_+userId,"nickName");
						activityHistory.setUserId(userId);
						activityHistory.setUserNames(nickName);
						activityHistory.setStartDate(new Date());
						activityHistoryMapper.insert(activityHistory);
					} else if (paytype != null && "AA".equals(paytype)) {

						//AA扣卡在小程序里面进行,这里做空实现
//						Map<String, String> players = RedisUtil3.getRu().hgetall("USER_GAME_AA_" + activityId);
//						String others = cache.hget("USERPLAY_ROUND_" + activityId, "others");
//
//						// 插入扣房卡历史记录
//						for (Map.Entry<String, String> entry : players.entrySet()) {
//							Long uid = Long.parseLong(entry.getKey());
//							//如果是代开就全部扣卡
//							if	("0".equals(others)) {
//								baseCacheController.updateRoomCard(uid,-Integer.parseInt(cardCount));
//							}else {
//								if (!userId.toString().equals(uid.toString())){
//									baseCacheController.updateRoomCard(uid,-Integer.parseInt(cardCount));
//								}
//							}
//
//							String nickName = cache.hget(Constants.PLAYER_+uid,"nickName");
//							activityHistory.setUserId(uid);
//							activityHistory.setUserNames(nickName);
//							activityHistoryMapper.insert(activityHistory);
//						}
					} else if (paytype == null) {
						String nickName = cache.hget(Constants.PLAYER_+userId,"nickName");
						// 插入扣房卡历史记录
						activityHistory.setUserId(userId);
						activityHistory.setCardCount(cardCount);
						activityHistory.setUserNames(nickName);
						activityHistoryMapper.insert(activityHistory);
					}
				}
			} catch (Exception e) {
				throw e;
			} finally {
				if (cache != null) {
					CacheManager.releaseCache(cache);
				}
			}
		}

		public void deductWinerCard(Long activeId, String winerList, Integer payCount) throws Exception {
			String[] winerListArray = winerList.split(",");
			for (int i = 0; i < winerListArray.length; i++) {
				Long userId = Long.valueOf(winerListArray[i]);
				TUser user = userMapper.selectByPrimaryKey(userId);
				// 获取房卡信息
				if (user.getCardCount() == null || user.getCardCount().equals(0)) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
				}
				if (user.getCardCount() < payCount) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
				}
				if (userMapper.increaseRoomCard(userId, -payCount) == 0) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新房卡失败");
				}

				String nickName = user.getNickName();
				TActivity activity = new TActivity();
				activity.setActivityId(activeId);
				activity = activityMapper.selectOne(activity);
				// 插入扣房卡历史记录
				TActivityHistory activityHistory = new TActivityHistory();
				activityHistory.setActivityId(activeId);
				activityHistory.setUserId(userId);
				activityHistory.setGameId(activity.getGameId());
				activityHistory.setLevel(activity.getLevel());
				activityHistory.setCardCount(payCount);
				activityHistory.setUserNames(nickName);
				activityHistory.setStartDate(new Date());
				activityHistoryMapper.insert(activityHistory);
			}

		}

		public String firstLoginSendCard(Long userId) throws Exception {
			Integer sendCardCount = queryFirstLoginSendCardCount();
			baseCacheController.updateRoomCard(userId,sendCardCount);
//			if (userMapper.increaseRoomCard(userId, sendCardCount) == 0) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "登陆赠送房卡失败");
//			}
			return sendCardCount+"";
		}
		public String firstLoginSendGold(Long userId) throws Exception {
			//初始赠送房卡
			ICache cache = null;
			try {
				cache = CacheManager.getCache();
				String giftOfPlayerFirstLogin2Gold = baseCacheController.queryConfig("giftOfPlayerFirstLogin2Gold", cache);
				if(StringUtil.isNotEmpty(giftOfPlayerFirstLogin2Gold)) {
					boolean b = baseChargeService.playerGoldRecharge(1, userId, Integer.parseInt(giftOfPlayerFirstLogin2Gold));
					return giftOfPlayerFirstLogin2Gold;
				}
				return "0";
			}catch (Exception e ) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "登陆赠送房卡失败");
			}finally {
				CacheManager.releaseCache(cache);
			}

		}

		public Integer everydayLoginSendCard(Long userId, Date lastLogin) throws Exception {
			Integer sendCardCount = queryEverydayLoginSendCardCount();
			Date now = new Date();
			if (lastLogin == null || !DateUtils.isSameDate(lastLogin, now)) {
				userMapper.increaseRoomCard(userId, sendCardCount);
			} else {
				sendCardCount = 0;
			}
			TUser user = new TUser();
			user.setUserid(userId);
			user.setLastLogin(now);
			userMapper.updateByPrimaryKeySelective(user);
			return sendCardCount;
		}

		public boolean isCardEnough(Long userId, Integer level, Integer round, Integer maxPlayerCount,Integer cardCount) throws Exception {
			ICache cache = null;
			try {
				cache = CacheManager.getCache();
				Integer cardsum = activityMapper.selectcardSumByuserId(userId);

//				TGameLevelCard card = roomCardCacheController.queryConfigByLevelAndRound(level, round, cache);
				// 获取房卡信息
//				TUser user = userMapper.selectByPrimaryKey(userId);
				Integer roomCard = baseCacheController.queryPlayerRoomCard(userId);

				if (roomCard == null || roomCard.equals(0)) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
				}
				if (cardsum==null) {
					if (roomCard <  cardCount) {
						return false;
					}
				}else {
					if (roomCard <  (cardCount+cardsum)) {
						return false;
					}
				}


				return true;
			} catch (Exception e) {
				throw e;
			} finally {
				if (cache != null) {
					CacheManager.releaseCache(cache);
				}
			}
		}

		public void setRoomCard(Long userId, Integer num) {
			TUser user = new TUser();
			user.setCardCount(num);
			user.setUserid(userId);
			userMapper.updateByPrimaryKeySelective(user);
		}

		public Integer queryRoomCardCount(Long userId) {
			Integer cardCount = baseCacheController.queryPlayerRoomCard(userId);
//			Integer cardCount = userMapper.selectRoomCardCount(userId);
//			if (cardCount == null || "".equals(cardCount) ) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "用户不存在");
//			}
			return cardCount;
		}

		public Integer queryFirstLoginSendCardCount() throws Exception {
			return querySendCardCount("giftOfPlayerFirstLogin");
		}

		public Integer queryEverydayLoginSendCardCount() throws Exception {
			return querySendCardCount("everydayLoginSendCard");
		}

		public Integer querySendCardCount(String key) throws Exception {
			ICache cache = null;
			try {
				cache = CacheManager.getCache();
				String value = baseCacheController.queryConfig(key, cache);
				if (StringUtils.isBlank(value)) {
					return 0;
				}
				return Integer.parseInt(value);
			} catch (Exception e) {
				throw e;
			} finally {
				if (cache != null) {
					CacheManager.releaseCache(cache);
				}
			}
		}

		public Response giftRoomCardEveryDay(Long userId) throws Exception {
			ICache cache = null;
			Response response = new Response();
			try {
				cache = CacheManager.getCache();


				TUser user = userMapper.selectByPrimaryKey(userId);
				//标志位,标志位是否有代理控制
				int i = 2;
				MapVo map = null;
				if (!StringUtil.isEmpty(user.getAgentId())) {
					 map = userMapper.selectImsTpUserByIsShare(user.getAgentId());
					if (StringUtil.isNotEmpty(map)) {
						i = Integer.parseInt(map.getMapValue());
					}
				}
				SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");//设置日期格式
				String format = df.format(new Date());
				String format1 = null;
				if (user.getBirthday() != null ) {
					format1 = df.format(user.getBirthday());
				}
				if (user.getBirthday() == null || !format.equals(format1) || i == 0) {
					//判断是属于哪个代理的&&代理有没有打开分享  由代理去承担

					String cardEveryDay = baseCacheController.queryConfig("sharSendCardEveryDay", cache);
					String goldEveryDay = baseCacheController.queryConfig("sharSendGoldEveryDay", cache);

					Long agentId = 1L;  //默认是平台的
					if (StringUtil.isEmpty(user.getAgentId())) {
						if (!StringUtil.isEmpty(cardEveryDay) && !"0".equals(cardEveryDay)) {
							cache.hincrby(Constants.PLAYER_ROOM_CARD,userId+"",Integer.parseInt(cardEveryDay));
							userMapper.giftRoomCardEveryDay1(userId,cardEveryDay);
						}
						if (!StringUtil.isEmpty(goldEveryDay) && !"0".equals(goldEveryDay)) {
							try {
								boolean b = baseChargeService.playerGoldRecharge(1, userId, Integer.parseInt(goldEveryDay));
								System.out.println("分享送金币 : " + agentId + b);
							}catch (Exception e ) {

							}
						}
						userMapper.insertTplayerShareGiftRecord2AgentId(userId,cardEveryDay,goldEveryDay,Constants.giftTypeEverydAY,agentId);
						JSONObject jo = new JSONObject();
						jo.put("goldCount",goldEveryDay);
						jo.put("cardCount",cardEveryDay);
						jo.put("msg","今日领取成功!!");
						response.setData(jo);
						response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
					}else {
						if (StringUtil.isNotEmpty(map) && "1".equals(map.getMapValue()) ) {
							agentId = user.getAgentId();
							cardEveryDay = baseCacheController.queryConfig("sharSendCardEveryDay4Agent", cache);
							goldEveryDay = baseCacheController.queryConfig("sharSendGoldEveryDay4Agent", cache);
							//记下代理的损耗
							if (!StringUtil.isEmpty(cardEveryDay) && !"0".equals(cardEveryDay)) {
								cache.hincrby(Constants.PLAYER_ROOM_CARD,userId+"",Integer.parseInt(cardEveryDay));
								userMapper.giftRoomCardEveryDay1(userId,cardEveryDay);
							}
							if (!StringUtil.isEmpty(goldEveryDay) && !"0".equals(goldEveryDay)) {
								try {
									boolean b = baseChargeService.playerGoldRecharge(1, userId, Integer.parseInt(goldEveryDay));
									System.out.println("分享送金币 : " + agentId + b);
								}catch (Exception e ) {

								}
							}
							userMapper.insertTplayerShareGiftRecord2AgentId(userId,cardEveryDay,goldEveryDay,Constants.giftTypeEverydAY,agentId);
							if (StringUtil.isNotEmpty(goldEveryDay) && !"0".equals(goldEveryDay)){
								userMapper.increaseUseGoldshare(agentId,goldEveryDay);
							}
							JSONObject jo = new JSONObject();
							jo.put("goldCount",goldEveryDay);
							jo.put("cardCount",cardEveryDay);
							jo.put("msg","今日领取成功!!");
							response.setData(jo);
							response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
						}else {
							response.setReturnCode(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
						}
					}
					
					return response;
				}else {
					response.setReturnCode(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
					response.setData("今日已经领取过了,请明日再来,谢谢您的参与!!");
					return response;
				}
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
    }

	public Map cutRoomCardByUsersAndNum(String json) {
		JSONObject jsonObject = JSON.parseObject(json);
		String users = jsonObject.getString("users");
		users = users.replace("[","(").replace("]",")");
		Integer cardNum = jsonObject.getInteger("CardNum");
		List<MapVo> list = userMapper.isCardCountEnough(users,cardNum);
		Map<String ,String> map = new HashMap<String, String>();
		StringBuffer str = new StringBuffer();
		str.append("(");
		for (int i = 0; i < list.size(); i ++) {
			MapVo mapVo = list.get(i);
			if (Integer.parseInt(mapVo.getMapValue()) > 0 ) {
				map.put(mapVo.getMapKey().toString(),"1");
				str.append(mapVo.getMapKey()+",");
			}
			//if (Integer.parseInt(mapVo.getMapValue()) <= 0 ) {
			//	map.put(mapVo.getMapKey().toString(),"0");
			//}
		}

		if (map == null || map.size()==0) {
			return null;
		}

		String s = str.toString();
		String s1 = s.substring(0, s.length() - 1) + ")";

		System.out.println(str.toString());
		userMapper.cutRoomCardByUsersAndNum(s1,cardNum);
		return map;
	}
}
