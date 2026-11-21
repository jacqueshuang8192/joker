package com.hbi.service.common;

import com.alibaba.fastjson.JSONObject;
import com.core.service.BaseService;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.CommonCacheController;
import com.hbi.cache.controller.GameCacheController;
import com.hbi.cache.controller.PlayerCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.idGenerate.GenerateIdService;
import com.hbi.utils.InfServerException;
import com.hbi.vo.response.game.UserOnlineGame;
import com.hbi.vo.response.user.GameTypeGameVo;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class GameService extends BaseService<TGame> {

	@Autowired
	private BaseCacheController baseCacheController;
	@Autowired
	private GameCacheController gameCacheController;
	@Autowired
	private PlayerCacheController playerCacheController;
	@Autowired
	private CommonCacheController commonCacheController;
	@Autowired
	private TPlayerMapper playerMapper;
	@Autowired
	private TSecUserMapper secUserMapper;
	@Autowired
	private GenerateIdService generateIdService;
	@Autowired
	private TGameTypeMapper tGameTypeMapper;
	@Autowired
	private TGameProvinceMapper tGameProvinceMapper;
	@Autowired
	private TGameTypeGameMapper tGameTypeGameMapper;
	@Autowired
	private TProvinceAgentMapper tProvinceAgentMapper;
	@Autowired
	private TGameMapper gameMapper;

	

	/**
	 * 获取主播游戏
	 * 
	 * @return
	 * @throws Exception
	 */

	/**
	 * 大厅登陆页面所需数据
	 * 
	 * @return
	 * @throws Exception
	 */
	public List<TGame> getHallLoadingGames() throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<TGame> games = baseCacheController.queryGame(cache);
			for (TGame tGame : games) {
				TVersion version = baseCacheController.queryNewestGameVersionByGameId(tGame.getGameId(), cache);
				if (version != null) {
					tGame.setVersion(version.getVersion());
				}

				tGame.setPlayerCount(0);

			}
			return games;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TGameType> getGametype(Long provinceId, Long agentId,Integer roomType) throws Exception {
		ICache cache = null;
		if (StringUtil.isEmpty(roomType)) {
			roomType = 2;
		}
		try {
			cache = CacheManager.getCache();
			Long agent;
			List<TGameType>	tGameTypes =null;
			//如果代理ID为空,则直接通过省份获取这个省份的所有游戏
			if (roomType == 2) {
				if (agentId == null) {
					agent = tGameProvinceMapper.selectAgentByProvinceId(provinceId);
					tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentId(agent);
//				List<TGameTypeGame> gameTypeGames = tGameTypeGameMapper.selectByAgentId(agent);
				}else {
					agent=agentId;
					Integer agentlevel = secUserMapper.queryAgentLevelByAgentId(agent);
					Long agents = tGameProvinceMapper.selectAgentByProvinceId(provinceId);
					//如果代理的level是1,也就是运营商
					if (agentlevel!=null && agentlevel==1) {
						//如果t_province_agent里面没有记录,则还是默认获取省份的所有游戏
						TProvinceAgent provinceAgent = tProvinceAgentMapper.selectByAgentIdAndProvinceId(agentId,provinceId);
						if (provinceAgent!=null) {
							tGameTypes = tGameTypeGameMapper.selectGameTypeByAgent(agent);
						}else {
							tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentId(agents);
						}


					}else{
						Long agent2 = secUserMapper.queryParentIdByUserId(agent);
						Long provinces = secUserMapper.selectProvinceIdByAgentId(agent);
						//查看传入的代理id对应的省份是否对应,不对应按传入的省份查
						if (provinces!=null && provinces.equals(provinceId)) {
							tGameTypes = tGameTypeGameMapper.selectGameTypeByParentId(agent);
						}else{
							tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentId(agents);
						}

					}
				}

			}
			if (roomType == 1 ) {
				tGameTypes = tGameTypeGameMapper.selectGameTypeByRoomTyper(roomType);
			}
			
				
			return tGameTypes;
					
				

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TGameTypeGold> getGametypeByGold(Long provinceId, Long agentId) throws Exception {
		ICache cache = null;

		try {
			cache = CacheManager.getCache();
			Long agent;
			List<TGameTypeGold>	tGameTypes =null;
			//如果代理ID为空,则直接通过省份获取这个省份的所有游戏
			if (agentId == null) {
				agent = tGameProvinceMapper.selectAgentByProvinceId(provinceId);
				tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentIdByGold(agent);
//				List<TGameTypeGame> gameTypeGames = tGameTypeGameMapper.selectByAgentId(agent);
			}else {
				agent=agentId;
				Integer agentlevel = secUserMapper.queryAgentLevelByAgentId(agent);
				Long agents = tGameProvinceMapper.selectAgentByProvinceId(provinceId);
				//如果代理的level是1,也就是运营商
				if (agentlevel!=null && agentlevel==1) {
					//如果t_province_agent里面没有记录,则还是默认获取省份的所有游戏
					TProvinceAgent provinceAgent = tProvinceAgentMapper.selectByAgentIdAndProvinceId(agentId,provinceId);
					if (provinceAgent!=null) {
						tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentByGold(agent);
					}else {
						tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentIdByGold(agents);
					}
				}else{
					Long agent2 = secUserMapper.queryParentIdByUserId(agent);
					System.out.println(agent2);
					Long provinces = secUserMapper.selectProvinceIdByAgentId(agent);
					//查看传入的代理id对应的省份是否对应,不对应按传入的省份查
					if (provinces!=null && provinces.equals(provinceId)) {
						tGameTypes = tGameTypeGameMapper.selectGameTypeByParentIdByGold(agent);
					}else{
						tGameTypes = tGameTypeGameMapper.selectGameTypeByAgentIdByGold(agents);
					}
				}
			}
			return tGameTypes;

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TGameProvince> getGameProvince() throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			List<TGameProvince> gameProvinces = tGameProvinceMapper.queryGameProvince();

			return gameProvinces;

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	/**
	 * 获取组局游戏列表
	 * 
	 * @return
	 * @throws Exception
	 */
	public List<TGame> getFreeGameList() throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<TGame> games = baseCacheController.queryGame(cache);
			Iterator<TGame> iterator = games.iterator();
			while (iterator.hasNext()) {
				TGame game = iterator.next();
				if (game.getIsFreeGame() == null || !game.getIsFreeGame().equals(Constants.YES)) {
					iterator.remove();
				}
			}
			for (TGame tGame : games) {
				List<TGroupGame> chipList = getGroupGame(tGame.getGameId());
				tGame.setGroupGameList(chipList);
			}
			// 获取玩家人数
			for (TGame game : games) {
				game.setPlayerCount(123);
			}
			return games;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	/**
	 * 选择赛场页面所需数据
	 * 
	 * @param categoryId
	 * @param userId
	 * @return
	 */

	/**
	 * 自由场页面所需数据
	 * 
	 * @param gameId
	 * @return
	 */

	/**
	 * 组局所需数据
	 *
	 * @param gameId
	 * @return
	 */
	public List<TGroupGame> getGroupGame(Long gameId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<TGroupGame> chipSelects = baseCacheController.queryGroupGame(gameId, cache);

			return chipSelects;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}

	}

	/**
	 * 比赛场页面所需数据
	 * 
	 * @param gameId
	 * @return
	 */

	/**
	 * 快速游戏抽成
	 * 
	 * @param quickGameId
	 * @param totalIncome
	 * @param extractIncome
	 * @throws Exception
	 */

	/**
	 * 报名比赛
	 * 
	 * @param gameId
	 * @param gameMatchId
	 * @param userId
	 * @param userType
	 * @param totalIncome
	 * @throws Exception
	 */

	/**
	 * 连线奖池报名
	 * 
	 * @param gameId
	 * @param userId
	 * @param userType
	 * @throws Exception
	 */

	/**
	 * 领取连线奖池奖励
	 * 
	 * @param userId
	 * @param userType
	 * @param gameAwardPoolId
	 * @throws Exception
	 */

	/**
	 * 直播间游戏分成
	 * 
	 * @param gameId
	 * @param compereId
	 * @param userId
	 * @param extractIncome
	 * @throws Exception
	 */
	public void addLiveGameExtract(String roomId, Long gameId, Long compereId, Long userId, Integer extractIncome)
			throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			Long rId = null;
			if (StringUtils.isNotBlank(roomId)) {
				rId = Long.parseLong(roomId);
			}

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	/**
	 * 组局分成
	 * 
	 * @param activityId
	 * @param userId
	 * @param extractIncome
	 * @throws Exception
	 */
	public void addFreeGameExtract(Long activityId, String gameLevel, String userId, Integer totalIncome,
			Integer extractIncome) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			String userType = commonCacheController.queryUserTypeByUserId(userId, cache);
			if (StringUtils.isNotBlank(userType)) {
			} else {
				throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有对应的用户类型");
			}

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public void gameNumChanged(Long userId, String userType, Integer amount) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	/**
	 * 更新游戏段位积分
	 * 
	 * @param gameId
	 * @param userId
	 */

	/**
	 * 玩家段位升级或降级之后重新计算攻击防御生命信息
	 * 
	 * @param playerId
	 */

	/**
	 * 主播段位升级或降级之后重新计算攻击防御生命信息
	 * 
	 * @param compereId
	 * @throws Exception
	 */

	/**
	 * 获取当前连线彩池房卡数量
	 * 
	 * @return
	 * @throws Exception
	 */

	/**
	 * 查询用户游戏在线情况
	 * 
	 * @param userId
	 * @return
	 */
	public UserOnlineGame queryUserOnlineGame(String userId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return gameCacheController.queryUserOnlineGame(userId, cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public TGameServer queryGameServer() throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<TGameServer> serverList = gameCacheController.queryGameServerList(cache);
			int index = gameCacheController.queryCurGameServerRound(cache);
			return serverList.get(index);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public TGameServer queryGameServer(String userId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<TGameServer> serverList = gameCacheController.queryGameServerList(cache);
			//int index = gameCacheController.queryCurGameServerRound(cache);
			//每个userId取固定的大厅
			int i = Integer.parseInt(userId);
			int i1 = i % (serverList.size());
			return serverList.get(i1);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}
	
//	public List<TGameType> getGametype() throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TGameType> gametypes = tGameTypeMapper.queryGameType();
//            
//            return gametypes;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
	
	
	
	public JSONObject queryScoreSection() throws Exception {
		ICache cache = null;
		JSONObject json = new JSONObject();
		try {
			cache = CacheManager.getCache();
			String info = baseCacheController.queryScoreSection(cache);
			json.put("sectionInfo", info);
			return json;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<JSONObject> queryGameConfig(Long provinceId, Long agentId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			Long agent;
			List<GameTypeGameVo> gameTypeGames =null;
			if (agentId == null) {
				agent = tGameProvinceMapper.selectAgentByProvinceId(provinceId);
				gameTypeGames = tGameTypeGameMapper.selectByAgentId(agent);
//				List<TGameTypeGame> gameTypeGames = tGameTypeGameMapper.selectByAgentId(agent);
			}else {
				agent=agentId;
				Integer agentlevel = secUserMapper.queryAgentLevelByAgentId(agent);
				Long agents = tGameProvinceMapper.selectAgentByProvinceId(provinceId);
				
				if (agentlevel!=null && agentlevel==1) {
					TProvinceAgent provinceAgent = tProvinceAgentMapper.selectByAgentIdAndProvinceId(agentId,provinceId);
					if (provinceAgent!=null) {
						gameTypeGames = tGameTypeGameMapper.selectByAgent(agent);
					}else {
						gameTypeGames = tGameTypeGameMapper.selectByAgentId(agents);
					}
					
					
				}else{
					Long agent2 = secUserMapper.queryParentIdByUserId(agent);
					Long provinces = secUserMapper.selectProvinceIdByAgentId(agent);
					if (provinces!=null && provinces.equals(provinceId)) {
						gameTypeGames = tGameTypeGameMapper.selectByAgentId(agent2);
					}else{
						gameTypeGames = tGameTypeGameMapper.selectByAgentId(agents);
					}
					
				}
			}
			
			
			Map<Integer, List<GameTypeGameVo>> map = new HashMap<Integer, List<GameTypeGameVo>>();
			Map<Integer, String> maps = new HashMap<Integer, String>();
			for (GameTypeGameVo gameTypeGameVo : gameTypeGames) {
				Integer gameTypeId = gameTypeGameVo.getGameTypeId();
				
				List<GameTypeGameVo> list = map.get(gameTypeId);
				if (list == null) {
					list = new ArrayList<GameTypeGameVo>();
					map.put(gameTypeId, list);
					maps.put(gameTypeId, gameTypeGameVo.getGameType());
					maps.put(gameTypeId, gameTypeGameVo.getName());
				}
				list.add(gameTypeGameVo);
			}
			
			
			List<JSONObject> gameTypeGameList = new ArrayList<JSONObject>();
			
	
			for (Integer key : map.keySet()) {
				JSONObject jo = new JSONObject();
				jo.put("gameTypeId",key);
				jo.put("gameList", map.get(key));
				gameTypeGameList.add(jo);
			}
			
			return gameTypeGameList;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public Long getActivityIdByRoomId(Long roomId) {
		Long activityId =  gameMapper.getActivityIdByRoomId(roomId);
		if ( activityId == null || activityId.equals("")) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, "没有找到这个房间号!!");
		}else {
			return activityId;
		}
	}
	
//	public TGameConfig queryGameConfig() throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TGameConfig config = gameCacheController.queryGameConfig(cache);
//
//            return config;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
}
