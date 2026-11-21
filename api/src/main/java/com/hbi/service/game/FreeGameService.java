package com.hbi.service.game;


import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.util.ConfigUtil;
import com.core.util.RedisUtil;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.CommonCacheController;
import com.hbi.cache.controller.FreeGameCacheController;
import com.hbi.cache.controller.GroupPlayerCacheController;
import com.hbi.cache.model.CacheGameActivity;
import com.hbi.cache.redis.CacheRedisImp;
import com.hbi.constants.Constants;
import com.hbi.controller.playerGroup.ClubConstant;
import com.hbi.impl.groupgame.GroupGameImpl;
import com.hbi.interfaces.IGroupGame;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.common.UserService;
import com.hbi.service.playerGroup.TGroupGameconfigService;
import com.hbi.service.playerGroup.TGroupPlayerService;
import com.hbi.service.playerGroup.TPlayerGroupService;
import com.hbi.utils.CommonUtil;
import com.hbi.utils.GameServerUtil;
import com.hbi.utils.InfServerException;
import com.hbi.utils.OSSUtil;
import com.hbi.vo.request.common.MapVo;
import com.hbi.vo.response.Response;
import com.hbi.vo.response.game.GameRankVo;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import tk.mybatis.mapper.entity.Example;
import tk.mybatis.mapper.entity.Example.Criteria;

import java.util.*;
/**
 * Created by ceeuoo on 8/19/2016.
 */
@Service
public class FreeGameService {
	private static Logger log = Logger.getLogger(FreeGameService.class);

	@Autowired
	private TFreeGameRoundMapper roundMapper;
	@Autowired
	private TGroupGameMapper groupGameMapper;
	@Autowired
	private TVersionMapper versionMapper;
	@Autowired
	private FreeGameCacheController freeGameCacheController;
	@Autowired
	private TFreeGameResultMapper freeGameResultMapper;
	@Autowired
	private CommonCacheController commonCacheController;
	@Autowired
	private TActivityMapper activityMapper;
	@Autowired
	private TFreeGameActivityMapper freeGameActivityMapper;
	@Autowired
	private BaseCacheController baseCacheController;
	@Autowired
	private TGameMapper gameMapper;
	@Autowired
	private TUserMapper userMapper;
	@Autowired
	private UserService userService;
	@Autowired
	private TGroupPlayerService groupPlayerService;
	@Autowired
	private TGroupPlayerMapper groupPlayerMapper;
	@Autowired
	private TGroupGameconfigService gameconfigService;
	@Autowired
	private GroupPlayerCacheController groupPlayerCacheController;
	@Autowired
	private TPlayerGroupService playerGroupService;

	@Autowired
	private TFreeGameTotalMapper freeGameTotalMapper;

	private static String createLock = "creatLock";
	private static String FREE_GAME_ROUND_ = "FREE_GAME_ROUND_";
	private static final String GAME_ROUND_KEY = "USERPLAY_ROUND_";
	public static final String GAME_EXTEND_ACTIVITY = "GAME_EXTEND_ACTIVITY";
	static final transient Object lock = new Object();

	/**
	 *  将游戏服json中的数据和录像脚本分离的处理过程，处理后content不包含录像脚本,录像脚本存储至oss
	 *  1.拆解出界面需要的json
	 *  2.将游戏服原始content存入oss，供前端脚本引擎使用，该url仅存储oss中的相对路径
	 *  3.存入数据库
	 */
	public void uploadFreeGameRound(Long activityId, String content, Integer level, Integer index,String replayUrl)
			throws Exception {
		ICache cache = null;
		try {
			cache                  = CacheManager.getCache();
			JSONObject origin      = JSONObject.parseObject(content);
			//换名字  这步可以跳过
			JSONArray array        = setNickname2Json(origin);
			JSONObject contentList = new JSONObject();
			contentList.put("userinfos", array);

			//这步也可以跳过
			for (int i = 0; i < array.size(); i++) {
				JSONObject jObj = array.getJSONObject(i);

				Integer changePoints = jObj.getInteger("changeGold");
				if (changePoints != null) {
					userMapper.increasePoint(jObj.getLongValue("uid"), changePoints);
				}
			}

			TFreeGameRound round = new TFreeGameRound();
			round.setActivityId(activityId);
			round.setContent(contentList.toJSONString());
			round.setReplayUrl(replayUrl);
			round.setLevel(level);
			round.setRoundIndex(index);
			round.setEndTime(new Date());
			if (roundMapper.insert(round) > 0) {
				freeGameCacheController.uploadFreeGameRound(round, cache);
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public void uploadConfigCard(String invitationCode, String content, Integer location)
			throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			String locations = location.toString();
			commonCacheController.uploadConfigCard(invitationCode,content,locations,cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public void uploadFreeGameResult(Long activityId, String content, Integer level) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			TGroupGame groupGames = new TGroupGame();
			groupGames.setLevel(level);
			groupGames = groupGameMapper.selectOne(groupGames);
			Long gameId = groupGames.getGameId();
			Integer oriCoin= groupGames.getOriCoins();
			System.out.println(gameId);
			TGame game = new TGame();
			game.setGameId(gameId);
			game = gameMapper.selectOne(game);
			String gameName = game.getName();
			System.out.println(gameName);
			JSONObject origin = JSONObject.parseObject(content);
			setNickname2Json(origin);
			TFreeGameResult result = new TFreeGameResult();
			result.setActivityId(activityId);
			result.setContent(origin.toJSONString());
			result.setLevel(level);
			result.setName(gameName);
			result.setOriCoins(oriCoin);
			result.setEndDate(new Date());

			Example exp = new Example(TFreeGameResult.class);
			Criteria criteria = exp.createCriteria();

			criteria.andEqualTo("activityId", activityId);
			// 加排行榜逻辑
			//JSONObject json = JSON.parseObject(content);
			//JSONArray userinfos = json.getJSONArray("userinfos");
			//JSONObject object = null;
			//int score = 0;
			//Long userId = 0L;
			//TGroupGame groupGame = new TGroupGame();
			if (freeGameResultMapper.updateByExampleSelective(result, exp) > 0) {
				freeGameCacheController.uploadFreeGameResult(result, cache);
			} else {

				if (freeGameResultMapper.insert(result) > 0) {
					freeGameCacheController.uploadFreeGameResult(result, cache);

					//加积分的代理  新项目没有用到积分  所以注释掉了
					//for (int i = 0; i < userinfos.size(); i++) {
					//	object = (JSONObject) userinfos.get(i);
					//Integer point = Integer.parseInt(configMapper.getVValues("giftPointOfGame"));
					//userId = object.getLong("uid");
					//userMapper.updatePoint(userId,point);
					//}

				}
			}




			//for (int i = 0; i < userinfos.size(); i++) {
			//	object = (JSONObject) userinfos.get(i);
			//	score = object.getInteger("score");
			//	userId = object.getLong("uid");
			//	groupGame.setLevel(level);
			//	groupGame = groupGameMapper.selectOne(groupGame);
			//	if (groupGame != null) {
			//		Integer oriCoins = groupGame.getOriCoins();
			//		score = score - oriCoins;
			//
			//	}
			//	Integer win = null;
			//	Integer draw = null;
			//	Integer lose = null;
			//	Integer total = null;
			//	if (score>0) {
			//		win =1;
			//		total =1;
			//		draw=0;
			//		lose =0;
			//	}else if (score==0) {
			//		win =0;
			//		total =1;
			//		draw=1;
			//		lose =0;
			//	}else {
			//		win =0;
			//		total =1;
			//		draw=0;
			//		lose =1;
			//	}



//				TFreeGameTotal freeGameTotal = new TFreeGameTotal();
//				freeGameTotal.setUserId(userId);
//
//				freeGameTotal.setWin(win);
//				freeGameTotal.setDraw(draw);
//				freeGameTotal.setTotal(total);
//				freeGameTotal.setLose(lose);
//				freeGameTotalMapper.insert(freeGameTotal);

//				TFreeGameTotalranking totalranking = new TFreeGameTotalranking();
//				totalranking.setLose(lose);
//				totalranking.setWin(win);
//				totalranking.setDraw(draw);
//				totalranking.setTotal(total);
//				totalranking.setGameId(groupGame.getGameId());
//				totalranking.setUserId(userId);
//				Example example = new Example(TFreeGameTotalranking.class);
//				Example.Criteria criteria = example.createCriteria();
//				criteria.andEqualTo("userId", userId);
//				criteria.andEqualTo("gameId", groupGame.getGameId());
//				int totalReult = freeGameTotalrankingMapper.updateByExample(totalranking, example);
//				if (totalReult == 0) {
//					totalranking.setGameId(groupGame.getGameId());
//					totalranking.setUserId(userId);
//					freeGameTotalrankingMapper.insert(totalranking);
//				}


			//	TFreeGameTotal total1 = new TFreeGameTotal();
			//	total1.setUserId(userId);
			//	total1.setWin(win);
			//	total1.setScore(score);
			//	total1.setDraw(draw);
			//	total1.setLose(lose);
			//	total1.setTotal(total);
			//
			//	Example exp1 = new Example(TFreeGameTotal.class);
			//	Criteria criteria1 = exp1.createCriteria();
			//
			//	criteria1.andEqualTo("userId", userId);
			//	if (freeGameTotalMapper.updateTotal(win, draw, lose, total, userId) == 0) {
			//		freeGameTotalMapper.insert(total1);
			//
			//	}
			//
			//}

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	private JSONArray setNickname2Json(JSONObject origin) {
		JSONArray array        = JSONArray.parseArray(origin.getString("userinfos"));
		for (Object o : array) {
			JSONObject json    = (JSONObject)o;
			Long userId        = json.getLong("uid");
			if (userId != null) {
				TUser user         = userMapper.selectByPrimaryKey(userId);
				if (user != null) {
					String nickname = user.getNickName();
					json.put("nickName", nickname);
				}
			}
		}
		origin.put("userinfos", array);
		return array;
	}

	private String uploadOss(Long activityId, Integer level, Integer index, String content) throws Exception {
		String replayUrl = CommonUtil.dateFormat(new Date(), "yyyyMM") + "/" + activityId + "_" + level + "_"
				+ index + "_" + CommonUtil.dateFormat(new Date(), "ddHHmmSSSS");
		OSSUtil.simpleUpload(content, replayUrl, ConfigUtil.get("oss.bucketName.replay"));
		return replayUrl;
	}

	public TFreeGameRound queryFreeGameRound(Long activityId, Integer roundIndex) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			TFreeGameRound round = freeGameCacheController.queryFreeGameRound(activityId, roundIndex, cache);
			// 前端需要传游戏名
			TFreeGameActivity freeGameActivity = new TFreeGameActivity();
			freeGameActivity.setActivityId(activityId);
			freeGameActivity = freeGameActivityMapper.selectOne(freeGameActivity);
			if (freeGameActivity == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局记录不存在");
			}
			Long gameId = freeGameActivity.getGameId();
			TGame game = baseCacheController.queryGameById(gameId, cache);
			round.setGameName(game.getName());
			return round;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public TFreeGameResult queryFreeGameResult(Long activityId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryFreeGameResult(activityId, cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public TVersion queryFreeGameVersion(Long gameId,String invitationCode) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			if (gameId==null && invitationCode ==null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "传入的数据为空");
			}
			if (gameId!=null) {
				TVersion version = versionMapper.queryVersionByGameIds(gameId);
				if (version==null) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "该游戏ID不存在");
				}
				return version;
			}

			if (invitationCode!=null) {
				Long gameid = freeGameActivityMapper.queryGameIdByInviteCode(invitationCode);
				if (gameid==null) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "该邀请码不存在");
				}
				TVersion versions = versionMapper.queryVersionByGameIds(gameid);
				if (versions==null) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "该游戏ID不存在");
				}
				return versions;
			}
			return versionMapper.queryVersionByGameIds(gameId);

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TFreeGameRound> querRoundsByActivityId(Long activityId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.querRoundsByActivityId(activityId, cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public TFreeGameTotal queryTotalGroupGeRenRank(Long userId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryTotalGroupGeRenRank(userId,  cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}
	public TFreeGameTotal queryTotalGroupGeRenRank2(Long userId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryTotalGroupGeRenRank2(userId,  cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TFreeGameTotal> queryTotalGroupRank(Long rankcount) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryTotalGroupRank(rankcount,cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}
	public TFreeGameSingleresult queryGeRenSingleResult(Long userId,String startTime,String endTime) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryGeRenSingleResult(userId, startTime,endTime,cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}
	public TFreeGameSingleresult queryGeRenSingleResult2(Long userId,String startTime,String endTime) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryGeRenSingleResult2(userId, startTime,endTime,cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}
	public List<TFreeGameSingleresult> querySingleResult(Long rankcount,String startTime,String endTime) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.querySingleResult(rankcount,startTime,endTime,cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}


	public List<TFreeGameResult> queryActivitiesByUserId(Long userId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			return freeGameCacheController.queryActivitiesByUserId(userId, cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}


	public List<TFreeGameRound> queryGoldActivitiesByUserId(Long userId,String currentPage,String pageSize) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			//默认分10页
			if (StringUtil.isEmpty(pageSize)) {
				pageSize = "10";
			}

			Integer beginRowIndex = (Integer.parseInt(currentPage)-1)*(Integer.parseInt(pageSize));
			if (beginRowIndex < 0) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL,"请输入正确的页数");
			}
			//从数据库查找出需要查询的activity记录
			long l = userId%10;
//			List<TFreeGameRound> result = new ArrayList<TFreeGameRound>();
			List<TFreeGameRound> result = freeGameActivityMapper.selectFreeActivityResultAll(l,userId,beginRowIndex,Integer.parseInt(pageSize));
//			List<MapVo> activityIds = freeGameActivityMapper.selectActivityIds2Gold(l,userId,beginRowIndex,Integer.parseInt(pageSize));
//			System.out.println(activityIds.size() + "----------");

			//从redis中找出数据
//			for (MapVo mv : activityIds) {

			//后期改进  从reids中获取
//				TFreeGameRound A = new TFreeGameRound();
//				String mapKey = mv.getMapKey();
//				String mapValue = mv.getMapValue();
			//String context = cache.hget(FREE_GAME_ROUND_ + mapKey, mapValue);
			//if (StringUtil.isEmpty(context)) {
			//	context = freeGameActivityMapper.selectFreeActivityRound(mapKey,mapValue);
			//}
			//A.setContent(context);
			//A.setActivityId(Long.parseLong(mapKey));
			//A.setRoundIndex(Integer.parseInt(mapValue));
			//result.add(A);
//				A = freeGameActivityMapper.selectFreeActivityRound(mapKey,mapValue);
//				if (A != null ) {
//					result.add(A);
//				}
//			}

			return result;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TFreeGameRound> queryGoldActivitiesByUserIdAndLevel(Long userId,String currentPage,String pageSize,Long level) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			//默认分10页
			if (StringUtil.isEmpty(pageSize)) {
				pageSize = "10";
			}

			Integer beginRowIndex = (Integer.parseInt(currentPage)-1)*(Integer.parseInt(pageSize));
			if (beginRowIndex < 0) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL,"请输入正确的页数");
			}
			//从数据库查找出需要查询的activity记录
			long l = userId%10;
			List<TFreeGameRound> result = freeGameActivityMapper.queryGoldActivitiesByUserIdAndLevel(l,userId,beginRowIndex,Integer.parseInt(pageSize),level);


			return result;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}


	public List<TFreeGameResult> queryCardActivitiesByUserId(Long userId,String currentPage,String pageSize) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			//默认分10页
			if (StringUtil.isEmpty(pageSize)) {
				pageSize = "10";
			}

			Integer beginRowIndex = (Integer.parseInt(currentPage)-1)*(Integer.parseInt(pageSize));
			if (beginRowIndex < 0) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL,"请输入正确的页数");
			}
			//从数据库查找出需要查询的activity记录

			List<TFreeGameResult> result = new ArrayList<TFreeGameResult>();
			long l = userId%10;
			List<MapVo> activityIds = freeGameActivityMapper.selectActivityIds2Card(l,userId,beginRowIndex,Integer.parseInt(pageSize));

			//从redis中找出数据
			for (MapVo mv : activityIds) {

				//后期改进  从reids中获取
				TFreeGameResult A = new TFreeGameResult();
				String mapKey = mv.getMapKey();
				String mapValue = mv.getMapValue();
				//String context = cache.hget(FREE_GAME_ROUND_ + mapKey, mapValue);
				//if (StringUtil.isEmpty(context)) {
				//	context = freeGameActivityMapper.selectFreeActivityRound(mapKey,mapValue);
				//}
				//A.setContent(context);
				//A.setActivityId(Long.parseLong(mapKey));
				//A.setRoundIndex(Integer.parseInt(mapValue));
				//result.add(A);
				A = freeGameActivityMapper.selectFreeActivityResult(mapKey);
				if (A!= null) {
					result.add(A);
				}
			}

			return result;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TFreeGameRound> queryCardActivities2RoundByUserI(Long userId, Long activityId, String inviteCode) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			if (!StringUtil.isEmpty(inviteCode) ) {
				Long ic2activityId = freeGameActivityMapper.queryActivityIdByInviteCode(inviteCode);
				if (!StringUtil.isEmpty(ic2activityId) ) {
					activityId = ic2activityId;
				}
			}

			if (StringUtil.isEmpty(activityId) ) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "该战绩不存在...");
			}

			List<TFreeGameRound> list = freeGameActivityMapper.queryCardActivities2RoundByUserI(userId, activityId);

			for (TFreeGameRound round :
					list) {
				round.setReplayUrl(OSSUtil.getFullyHttpUrl(round.getReplayUrl()));
			}

			return list;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<TFreeGameResult> queryActivitiesByOwner(Long userId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<TFreeGameResult> results = freeGameCacheController.queryActivitiesByOwner(userId, cache);
//			for (TFreeGameResult freeGameResult : results) {
//				Map<String, String> stringStringMap = cache.hgetAll(GAME_ROUND_KEY + freeGameResult.getActivityId());
//				String s = JSONObject.toJSONString(stringStringMap);
//				freeGameResult.setJson(s);
//			}
			return results;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public Integer queryGroupGameStatus(Long activityId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			TActivity t = activityMapper.selectByPrimaryKey(activityId);
			if (t == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局不存在");
			}
			return freeGameCacheController.queryGroupGameStatus(t.getOwnerId(), t.getActivityId(), cache);
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public List<FreeGameActivityInfo> queryGroupGameByOwner(Long userId,Integer roomType) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			List<FreeGameActivityInfoForPlayer> sources = freeGameActivityMapper.queryFreeGameByOwner(userId,roomType);

			List<FreeGameActivityInfo> result = new ArrayList<FreeGameActivityInfo>();

			Map<Long, FreeGameActivityInfo> map = new HashMap<Long, FreeGameActivityInfo>();
			for (FreeGameActivityInfoForPlayer s : sources) {
				FreeGameActivityInfo t = map.get(s.getActivityId());

				if (t == null) {
					t = new FreeGameActivityInfo();
					map.put(s.getActivityId(), t);

					t.setActivityId(s.getActivityId());
					t.setCoins(s.getCoins());
					t.setCreatorId(s.getCreatorId());
					t.setCreatorNickname(s.getCreatorNickname());
					t.setCreatorPhotoUrl(s.getCreatorPhotoUrl());
					t.setGameCode(s.getGameCode());
					t.setGameId(s.getGameId());
					t.setGameName(s.getGameName());
					t.setInviteCode(s.getInviteCode());
					t.setIsJoin(s.getIsJoin());
					t.setLevel(s.getLevel());
					t.setName(s.getName());
					t.setRounds(s.getRounds());
					t.setStartDate(s.getStartDate());
					t.setStatus(s.getStatus());
					t.setPlayers(new ArrayList<TActivityUser>());
					t.setCards(s.getCards());
					t.setDiscription(s.getDiscription());

					Map<String, String> stringStringMap = cache.hgetAll(GAME_ROUND_KEY + s.getActivityId());
					t.setJson(JSONObject.toJSONString(stringStringMap));

					result.add(t);
				}

				if (s.getUserId() != null) {
					TActivityUser user = new TActivityUser();
					user.setUserid(s.getUserId());
					user.setNickname(s.getNickname());
					user.setPhoto(s.getPhoto());

					t.getPlayers().add(user);
				}
			}

			return result;
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public void closeGroupGameByOwner(String inviteCode, Long activityId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			TActivity t = activityMapper.selectByPrimaryKey(activityId);
			if (t == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局不存在");
			}
			int status = freeGameCacheController.queryGroupGameStatus(t.getOwnerId(), t.getActivityId(), cache);
			if (status == 0) {
				userService.closeFreeGame(inviteCode, activityId + "", "8");
			} else if (status == 1) {
				//调用游戏服务器，解散组局
				TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(t.getGameId(), t.getLevel(), cache);
				CacheGameActivity gameActivity = commonCacheController.queryGameActivity(inviteCode, cache);

				if (gg == null) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
				}

				byte[] protocolNo = new byte[2];
				protocolNo[0] = (byte) 0x01;
				protocolNo[1] = (byte) 0x55;

				IGroupGame gameService = new GroupGameImpl(gg.getIp(), gg.getPort(), protocolNo);
				int result = gameService.dissolveRoom(activityId, gameActivity.getTableId());
				if (result != 0) {
					throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局该状态下不能解散，请检查");
				}

				userService.closeFreeGame(inviteCode, activityId + "", "8");
			} else {
				throw new Exception();
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public void cleanGroupGameStatus(String inviteCode, Long activityId) throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();
			TActivity t = new TActivity();
			t.setActivityId(activityId);
			t = activityMapper.selectOne(t);
			if (t == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局不存在");
			}
			if (t.getGameId() == null || t.getLevel() == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置错误");
			}
			TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(t.getGameId(), t.getLevel(), cache);

			if (gg == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
			}

			byte[] protocolNo = new byte[2];
			protocolNo[0] = (byte) 0x01;
			protocolNo[1] = (byte) 0x55;

			IGroupGame gameService = new GroupGameImpl(gg.getIp(), gg.getPort(), protocolNo);
			CacheGameActivity gameActivity = commonCacheController.queryGameActivity(inviteCode, cache);
			int result = gameService.dissolveRoom(activityId, gameActivity.getTableId());
			if (result != 0) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "清除组局状态失败");
			}

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}

	}

	public void cleanGroupGameByLevel(int level, String chain) throws Exception {
		if (!"MmeiSshiBbieXxiaJjiBbaDdiao".equals(chain)) {
			throw new Exception("请咨询相关技术人员");
		}

		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			List<CacheGameActivity> list = freeGameActivityMapper.queryNonCloseFreeGameByLevel(level);

			if (list != null) {
				for (CacheGameActivity a : list) {
					commonCacheController.closeFreeGame(a.getInviteCode(), cache);
					freeGameCacheController.delGroupGameStatus(Long.parseLong(a.getCreatorId()), Long.parseLong(a.getGameActivityId()), cache);

					userService.releaseSixCode(a.getInviteCode());
				}

				TActivity t = new TActivity();
				t.setStatus((short)2);
				Example exp = new Example(TActivity.class);
				Criteria criteria = exp.createCriteria();

				criteria.andEqualTo("status", 0);
				criteria.andEqualTo("level", level);

				activityMapper.updateByExampleSelective(t, exp);
			}

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}

	}

	public void cleanAllGroupGame(String chain) throws Exception {
		if (!"MmeiSshiBbieXxiaJjiBbaDdiao".equals(chain)) {
			throw new Exception("请咨询相关技术人员");
		}

		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			List<CacheGameActivity> list = freeGameActivityMapper.queryAllNonCloseFreeGame();

			if (list != null) {
				for (CacheGameActivity a : list) {
					commonCacheController.closeFreeGame(a.getInviteCode(), cache);
					freeGameCacheController.delGroupGameStatus(Long.parseLong(a.getCreatorId()), Long.parseLong(a.getGameActivityId()), cache);

					userService.releaseSixCode(a.getInviteCode());
				}

				TActivity t = new TActivity();
				t.setStatus((short)2);
				Example exp = new Example(TActivity.class);
				Criteria criteria = exp.createCriteria();

				criteria.andEqualTo("status", 0);

				activityMapper.updateByExampleSelective(t, exp);
			}

		} catch (Exception e) {
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}

	}

	public void cleanWaitCloseGroupGame() throws Exception {
		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			Map<String, String> datas = freeGameCacheController.queryWaitCloseGroup(cache);

			if (datas != null) {
				for (String key : datas.keySet()) {
					String value = datas.get(key);

					String[] strs = value.split("_");

					if (strs.length == 3) {
						userService.closeFreeGame(strs[0], strs[1], strs[2]);
					}
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
//	public Object createFreeGame(String userId, String gameId, Integer level, String name, Integer round, String json,
//			String discription) throws Exception {
//		ICache cache = CacheManager.getCache();
//
//		String inviteCode = null;
//		try {
//			Integer maxPlayerCount = freeGameCacheController.queryMaxPlayerCount(json);
//			if (!roomCardService.isCardEnough(Long.parseLong(userId), level, round,maxPlayerCount)) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
//			}
//			TGame g = baseCacheController.queryGameById(Long.parseLong(gameId), cache);
//
//			if (gameCacheController.isExistFreeGameCreatedByUserId(userId, cache)) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局资源还未释放，请稍后再试");
//			}
//			TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(Long.parseLong(gameId), level, cache);
//
//			if (gg == null) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
//			}
//
//			inviteCode = generateSixCode();
//
//			if ("-1".equals(inviteCode)) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局资源不足，请稍后再试");
//			}
//
//			int coins = gg.getCoins();
//			int oriCoins = gg.getOriCoins();
//
//			TActivity t = new TActivity();
//			t.setCreateDate(new Date());
//			t.setStartDate(t.getCreateDate());
//			t.setOwnerId(Long.parseLong(userId));
//			t.setType("1");
//			t.setGameId(Long.parseLong(gameId));
//			t.setLevel(level);
//			t.setActivityName(name);
//			t.setStatus((short) 0);
//
//			activityMapper.insertActivity(t);
//
//			TFreeGameActivity m = new TFreeGameActivity();
//			m.setActivityId(t.getActivityId());
//			m.setCoins(coins);
//			m.setGameId(Long.parseLong(gameId));
//			m.setInviteCode(inviteCode);
//			m.setLevel(level);
//
//			freeGameActivityMapper.insert(m);
//
//			TActivityUser u = new TActivityUser();
//			u.setActivityId(t.getActivityId());
//			u.setUserid(Long.parseLong(userId));
//			u.setStatus((short) 1);
//			activityUserMapper.insert(u);
//
//			byte[] protocolNo = new byte[2];
//			protocolNo[0] = (byte) 0x01;
//			protocolNo[1] = (byte) 0x60;
//
//			String ip = gg.getIp();
//			int port = gg.getPort();
//
//			IGroupGame gameService = new GroupGameImpl(ip, port, protocolNo);
//
//			int tid = gameService.createRoom(Long.parseLong(userId), level, coins, gg.getOriCoins(), inviteCode,
//					t.getActivityId(), round, json);
//
//			if (StringUtils.isNotBlank(discription)) {
//				freeGameCacheController.addFreeGameActivityDiscription(t.getActivityId(), discription, cache);
//			}
//
//			if (tid >= 0) {
//
//				freeGameCacheController.updateMaxPlayerCountByActivityId(t.getActivityId(), maxPlayerCount, cache);
//				freeGameCacheController.addFreeGamePlayerCount(t.getActivityId().toString(), cache);
//				JSONObject game = JSONObject.parseObject(json);
//		        Integer count = game.getInteger("winer_pay");
//		        String rounds = game.getString("round");
//		        String paytype = game.getString("pay_type");
//		        if (rounds != null && count != null && count ==1) {
//		        	commonCacheController.isWiner(t.getActivityId(),rounds,cache);
//				}
//		        String rs = round .toString();
//		        if (rs != null && paytype!=null) {
//		        	commonCacheController.playerRound(t.getActivityId(),rs,paytype,cache);
//				}
//		        if (level==13) {
//		        	String peopleNum = maxPlayerCount .toString();
//			        if (peopleNum != null ) {
//			        	commonCacheController.playerTgDouniuRound(t.getActivityId(),peopleNum,cache);
//					}
//				}
//
//				return commonCacheController.createFreeGameActivity(m, t, g.getCode(), tid, inviteCode, oriCoins,
//						Constants.USER_TYPE_P, "", cache);
//			} else if (tid == -1) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建组局的筹码与请求的不符");
//			} else if (tid == -2) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建桌子与此分配房间服务器level不同");
//			} else if (tid == -3) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "兑换筹码失败");
//			} else if (tid == -4) {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "此用户已经创建桌子");
//			} else {
//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建游戏桌失败");
//			}
//		} catch (Exception e) {
//			if (inviteCode != null) {
//				baseCacheController.releaseFreeGameInviteCode(inviteCode, cache);
//			}
//			throw e;
//		} finally {
//			if (cache != null) {
//				CacheManager.releaseCache(cache);
//			}
//		}
//	}

	//public Object createFreeGame(String userId, String gameId, Integer level, String name, Integer round, String json,
	//		String discription) throws Exception {
	//	synchronized (createLock) {
	//		List<FreeGameActivityInfo> histories = userService.viewReganizeGames(userId);
	//		Integer isGold = gameMapper.selectIsGold(gameId);
	//		Integer min_glods = gameMapper.selectMinGlods(gameId);
	//		Integer max_glods = gameMapper.selectMaxGlods(gameId);
	//		if (isGold != null && isGold == 1) {
	//			Long point = userMapper.selectPiontByUSerId(Long.parseLong(userId));
	//			if (point!=null && point< min_glods) {
	//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "积分不足，无法创建");
	//			}
	//			if (point!=null && point> max_glods) {
	//				throw new InfServerException(Constants.RETURN_CODE_FAIL, "你的积分已达到当前分场的上限，请前往更高分场");
	//			}
	//		}
	//		if (!CollectionUtils.isEmpty(histories)) {
	//			throw new InfServerException(Constants.RETURN_CODE_FAIL, "您已经加入了组局");
	//		}
	//
	//		CacheGameActivity obj = (CacheGameActivity)createFreeGameByOthers(userId, gameId, level, name, round, json, discription,null);
	//
	//		userService.joinFreeGame(userId, obj.getInviteCode(), obj.getGameActivityId(), level);
	//
	//		return obj;
	//	}
	//}

	/**
	 * 代开组局
	 * @param userId
	 * @param gameId
	 * @param level
	 * @param name
	 * @param round
	 * @param json
	 * @param discription
	 * @param discription2Server
	 * @param others
	 * @param baseChip
	 * @param groupId
	 * @param password
	 * @param configId
	 * @param extendActivityId
	 * @return
	 * @throws Exception
	 */
	public Object createFreeGameByOthers(String userId, String gameId, Integer level, String name, Integer round, String json,
										 String discription,String discription2Server,Integer others,Integer baseChip,Integer groupId,String password,Integer configId,Long extendActivityId) throws Exception {
		ICache cache = CacheManager.getCache();
		Long groupOwerId = 0L;
		String inviteCode = null;

		try {
			Integer gameType = 0;
			String groupName = "";

			//创建组局的配置,续房的时候使用
			JSONObject gameConfig = new JSONObject();
			gameConfig.put("userId",userId);
			gameConfig.put("gameId",gameId);
			gameConfig.put("level",level);
			gameConfig.put("name",name);
			gameConfig.put("round",round);
			gameConfig.put("discription",discription);
			gameConfig.put("discription2Server",discription2Server);
			gameConfig.put("others",others);
			gameConfig.put("baseChip",baseChip);
			gameConfig.put("groupId",groupId);
			gameConfig.put("password",password);
			gameConfig.put("configId",configId);

			if (!StringUtil.isEmpty(groupId) ) {
				boolean isNotOk = groupPlayerCacheController.isSurpassThresholdValue(cache, groupId, Integer.parseInt(userId));
				if (isNotOk ) {
					throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "请联系上级,池子不足...");
				}
			}

			TGame g = baseCacheController.queryGameById(Long.parseLong(gameId), cache);
			if (g == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局游戏配置异常...");
			}
			gameType = Integer.parseInt(g.getGameType());

			if (StringUtil.isNotEmpty(groupId)) {
				//初始化玩法配置
				TGroupPlayer tgp = groupPlayerMapper.selectByPrimaryKey(groupId);
				if (!StringUtil.isEmpty(tgp) ) {
					JSONObject clubConifg = JSONObject.parseObject(tgp.getConfig());
					String clubStatus = clubConifg.getString(ClubConstant.club_status);
					if ("0".equals(clubStatus)) {
						throw new InfServerException(Constants.RETURN_CODE_FAIL,"打烊中...");
					}
				}

				if (StringUtil.isEmpty(userId)) {
					userId = tgp.getOwerId() + "";
					gameConfig.put("userId",userId);
				}

				if (!StringUtil.isEmpty(configId)) {
					TGroupGameconfig gameconfig = gameconfigService.selectOne(configId);
					if (!StringUtil.isEmpty(gameconfig) ) {
						gameType = gameconfig.getGameType();
						groupName = gameconfig.getName();
					}
				}
				//玩家积分不足,不允许创建桌子
				JSONObject gameJ = JSONObject.parseObject(json);
				gameJ.put("master", tgp.getOwerId());
				if (!StringUtil.isEmpty(gameJ) && g.getIsGold() == Constants.CLUD_ROOM) {
					Integer joinGamePoint = gameJ.getInteger("joinGamePoint");
					if (!StringUtil.isEmpty(joinGamePoint)) {
						TPlayerGroup tPlayerGroup = groupPlayerCacheController.queryPlayerClubInfo(groupId, Long.parseLong(userId));
						Double userPoints = groupPlayerCacheController.queryClubPoint(groupId, Integer.parseInt(userId), null);
						if (StringUtil.isEmpty(tPlayerGroup)) {
							throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "未找到俱乐部信息");
						}
						if (joinGamePoint > userPoints && tPlayerGroup.getIsRobot() != 1) {
							throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "积分不足，无法创建房间");
						}
					}
				}
				json = gameJ.toJSONString();
			}
			gameConfig.put("json",json);

//			基本都是不用的,要的时候在打开,基本不用
//			if (StringUtil.isNotEmpty(groupId) && "1".equals(ConfigUtil.get("qunzhukaifang"))) {
//				JSONObject jsonObject = groupPlayerService.selectGroupPlayer(groupId);
//				String owerId = jsonObject.getString("owerId");
//				System.out.println(owerId + userId + "!!!!");
//				if (!userId.equals(owerId)) {
//					throw new InfServerException(Constants.RETURN_CODE_FAIL, "您不是群主,请邀请群主为您开房!!");
//				}
//			}
			//传入房间类型,如果是房卡场,则不用校验房卡,可以直接创建游戏
			Integer maxPlayerCount = freeGameCacheController.queryMaxPlayerCount(json);
			//解析json
			String pay_type = JSONObject.parseObject(json).getString("pay_type");
			if (StringUtil.isEmpty(pay_type)) {
				pay_type = "fangka";
			}

			Integer cardCount = JSONObject.parseObject(json).getInteger("cardCount");
			if (StringUtil.isEmpty(cardCount) ) {
				cardCount = 0;
			}

			String hget = cache.hget(Constants.GAME_CATEGORY_LIST, gameId);
			if (StringUtil.isEmpty(hget)) {
				//如果获取不到这个配置 就重新加载一遍
				cache.del(Constants.GAME_CATEGORY_LIST);
				baseCacheController.queryGame(cache);
				hget = cache.hget(Constants.GAME_CATEGORY_LIST, gameId);
			}
			JSONObject jsonObject1= JSONObject.parseObject(hget);
			int roomType = 1;
			if (jsonObject1.isEmpty()) {
				roomType = 1;
			}else {
				roomType = jsonObject1.getInteger("isGold");
			}


//			Long curUid = null;
//			Integer curCard = null;

			if(StringUtil.isEmpty(roomType) || roomType==1) {
				//房卡场不走接口创建房间
			}else {
				//采用同步
				synchronized (log) {
					//  1 : 自开   0 : 代开
					//扣卡机制在成功创建房间的时候才正式扣卡,预防redis不可回滚
					if (others == 1 ) {
						//检测房卡
						if (StringUtil.isEmpty(cardCount)) {
							throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR,"您好,游戏配置异常,请联系我们处理!!");
						}
						if ( baseCacheController.queryPlayerRoomCard(Long.parseLong(userId)) < cardCount) {
							throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
						}
						baseCacheController.updateRoomCard(Long.parseLong(userId),-cardCount);
//					curUid = Long.parseLong(userId);
//					curCard = -cardCount;
					}else {
						if("fangka".equals(pay_type)) {
							//开房扣群主的房间
							if (StringUtil.isNotEmpty(groupId) && "1".equals(baseCacheController.queryConfig(Constants.curGroupMasterRoomCard,cache)) ) {
								groupOwerId = groupPlayerService.queryGroupOwerId(groupId,cache);
								if ( baseCacheController.queryPlayerRoomCard(groupOwerId) < cardCount) {

									throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
								}
								baseCacheController.updateRoomCard(groupOwerId,-cardCount);
//							curUid = groupOwerId;
//							curCard = -cardCount;
							}else  {
								if ( baseCacheController.queryPlayerRoomCard(Long.parseLong(userId)) < cardCount) {
									throw new InfServerException(Constants.RETURN_CODE_FAIL, "房卡不足");
								}
								baseCacheController.updateRoomCard(Long.parseLong(userId),-cardCount);
//							curUid = Long.parseLong(userId);
//							curCard = -cardCount;
							}
						}
					}
				}
			}

			//将游戏的名字一起传输到大厅服中
			//String toServer = g.getName() + " " + discription2Server;
			String toServer = null;
			if (StringUtil.isEmpty(discription2Server)) {
				toServer = "";
			}else {
				toServer = discription2Server;
			}



			TGroupGame gg = baseCacheController.queryGroupGameByGameIdAndLevel(Long.parseLong(gameId), level, cache);

			if (gg == null) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
			}

			inviteCode = generateSixCode();

			if ("-1".equals(inviteCode)) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局资源不足，请稍后再试");
			}

			int coins = gg.getCoins();
			int oriCoins = gg.getOriCoins();

			TActivity t = new TActivity();
			t.setCreateDate(new Date());
			t.setStartDate(t.getCreateDate());
			t.setOwnerId(Long.parseLong(userId));
			t.setType("1");
			t.setGameId(Long.parseLong(gameId));
			t.setLevel(level);
			t.setActivityName(name);
			t.setStatus((short) 0);
			t.setGameJson(gameConfig.toJSONString());
			t.setExtendActivityId(extendActivityId);
			t.setInviteCode(inviteCode);
			Integer isGold = g.getIsGold();
			if (StringUtil.isNotEmpty(groupId)) {
				t.setRoomType(Constants.CLUD_ROOM);
				t.setGroupId(groupId);
			}else {
				if (isGold == 1) {
					t.setRoomType(Constants.GOLD_ROOM);
				}
				if (isGold == 2 ) {
					t.setRoomType(Constants.CARD_ROOM);
				}
			}

			//如果是房卡场就不用校验房卡了
			if (isGold == 1) {
				t.setCards(0);
			}else {
				t.setCards(cardCount);
			}

			t.setDiscription(discription);
			//如果是房主代开AA扣卡,就不用预扣卡了
			if (others == 0 && "AA".equals(pay_type)) {
				t.setIsDeduct(1);
			}else {
				t.setIsDeduct(0);
			}

			activityMapper.insertActivity(t);

			TFreeGameActivity m = new TFreeGameActivity();
			m.setActivityId(t.getActivityId());
			m.setCoins(coins);
			m.setGameId(Long.parseLong(gameId));
			m.setInviteCode(inviteCode);
			m.setLevel(level);

			freeGameActivityMapper.insert(m);

			byte[] protocolNo = new byte[2];
//			if (StringUtil.isNotEmpty(password)) {
//				if (password.length() != 6) {
//					throw new InfServerException(Constants.RETURN_CODE_FAIL, "组局配置异常");
//				}
//				protocolNo[0] = (byte) 0x02;
//				protocolNo[1] = (byte) 0x60;
//			}else {
			protocolNo[0] = (byte) 0x01;
			protocolNo[1] = (byte) 0x60;
//			}


			String ip = gg.getIp();
			int port = gg.getPort();

			IGroupGame gameService = new GroupGameImpl(ip, port, protocolNo);

			//将玩家的名字和头像直接传给服务器
			TUser tUser = userMapper.selectByPrimaryKey(Long.parseLong(userId));
			String creatorNickname = tUser.getNickName();
			String creatorPortrait = tUser.getSmallIcon();
			if (StringUtil.isEmpty(creatorNickname)) {
				creatorNickname = "";
			}
			if (StringUtil.isEmpty(creatorPortrait)) {
				creatorPortrait = "";
			}

			Integer maxCount = g.getMaxPlayerCount();
			JSONObject jsonObject = JSONObject.parseObject(json);
			//配置文件的配置游戏人数不允许超过数据库中设定的人数
			String maxSeatCount = jsonObject.getString("maxSeatCount");
			int SeatCount = maxCount;
			if (maxSeatCount != null && !"".equals(maxSeatCount)) {
				int i = Integer.parseInt(maxSeatCount);
				if (i >= 1 && i <= maxCount) {
					SeatCount = i;
				}
			}

			//最小入场的积分
			Integer minCoinsGold = 	baseCacheController.queryMinCoinsByFenChang(g.getGameId(),baseChip,cache);
			if (StringUtil.isEmpty(minCoinsGold)) {
				minCoinsGold = 0;
			}
			int tid;
			//密码房
//			if (StringUtil.isNotEmpty(password)) {
//				tid = gameService.createRoomByPassword(Long.parseLong(userId), level, baseChip, gg.getOriCoins(), inviteCode,
//						t.getActivityId(), round, json, discription,toServer,minCoinsGold,SeatCount,creatorNickname,creatorPortrait,password);
//			}else {

			if (StringUtil.isEmpty(password)) {
				password = "";
			}
			if (StringUtil.isEmpty(groupId)) {
				groupId = 0;
			}
			tid = gameService.createRoom(Long.parseLong(userId), level, baseChip, gg.getOriCoins(), inviteCode,
					t.getActivityId(), round, json, discription,toServer,minCoinsGold,SeatCount,creatorNickname,creatorPortrait,password,groupId,configId,gameType,groupName);
//			}


			if (StringUtils.isNotBlank(discription)) {
				freeGameCacheController.addFreeGameActivityDiscription(t.getActivityId(), discription, cache);
			}

			if (tid >= 0) {

				freeGameCacheController.updateMaxPlayerCountByActivityId(t.getActivityId(), maxPlayerCount, cache);

				if (StringUtil.isNotEmpty(json)) {
					commonCacheController.putJson(json,t.getActivityId(),round.toString(),cache,others,groupId,groupOwerId,password,inviteCode);
				}

				CacheGameActivity freeGameActivityByOthers = commonCacheController.createFreeGameActivityByOthers(m, t, g.getCode(), tid, inviteCode, oriCoins, Constants.USER_TYPE_P, "", cache, SeatCount);
//				freeGameActivityByOthers.setJson(json);
				//房卡的支付类型
//				freeGameActivityByOthers.setPayType(pay_type);
				//房间密码
//				freeGameActivityByOthers.setPassWord(password);


				if (StringUtil.isNotEmpty(groupId)) {
//					freeGameActivityByOthers.setJson(json);
//					freeGameActivityByOthers.setGroupId(groupId);
				}

				//如果是自己开房,就要把重连状态给设置进去
				if (others == 1 ) {
					//以后如果有代开列表的时候删除  房卡场的房卡场用
					if(StringUtil.isNotEmpty(roomType) && roomType==2) {
						String s = level + "_" + freeGameActivityByOthers.getTableId();
						cache.hset(Constants.USER_GAME_STATUS,userId,s);
					}
				}
				//成功创建房间后才正式扣卡
//				if (StringUtil.isNotEmpty(curUid) && StringUtil.isNotEmpty(curCard)) {
//					baseCacheController.updateRoomCard(curUid,curCard);
//				}

				return freeGameActivityByOthers;
			} else if (tid == -1) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建组局的筹码与请求的不符");
			} else if (tid == -2) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建桌子与此分配房间服务器level不同");
			} else if (tid == -3) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "兑换筹码失败");
			} else if (tid == -4) {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "此用户已经创建桌子");
			} else {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "创建游戏桌失败");
			}
		} catch (Exception e) {
			if (inviteCode != null) {
				baseCacheController.releaseFreeGameInviteCode(inviteCode, cache);
			}
			throw e;
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	public Object A2IcreateFreeGame(Integer clubId, String level) throws Exception {

		ICache cache = null;
		try {

			cache =CacheManager.getCache();
			String  createUid = null;
			//查找允许创建的机器人
			RedisUtil ru = RedisUtil.getRu();
			Map<String, String> robotStatus = ru.hgetall("ROBOT_STATUS");
			for (Map.Entry<String, String> entry : robotStatus.entrySet()) {
				String key = entry.getKey();
				String value = entry.getValue();
				if (!StringUtil.isEmpty(value) && value.split("_").length >= 3 ) {
					String[] status = value.split("_");
					String robotClubId = status[1];
					if (robotClubId.equals(clubId + "") ) {
						createUid = key;
						break;
					}
				}
			}

			//如果是百人场的游戏,则用默认的玩法去创建桌子
			String banRenGameStr = ConfigUtil.get("BanRenGames");
			if (!StringUtil.isEmpty(banRenGameStr) ) {
				String[] banRenGames = banRenGameStr.split(",");
				for (int i = 0; i < banRenGames.length; i++) {
					if (banRenGames[i].equals(level)) {
						String gameConfigStr = ConfigUtil.get("BanRenGamesConfig" + level);
						if (!StringUtil.isEmpty(gameConfigStr) ) {
							JSONObject gameConfigJson = JSONObject.parseObject(gameConfigStr);
							Integer round = gameConfigJson.getInteger("round");
							Integer baseChip = gameConfigJson.getInteger("baseChip");
							JSONObject json = gameConfigJson.getJSONObject("json");
							String discription = gameConfigJson.getString("discription");
							String discription2Server = gameConfigJson.getString("discription2Server");
							CacheGameActivity activity = (CacheGameActivity)createFreeGameByOthers(null, level, Integer.parseInt(level), "组局", round, json.toJSONString(), discription, discription2Server, 0,
									baseChip, clubId, null, -Integer.parseInt(level), null);
							return null;
						}
					}
				}
			}

			List<TGroupGameconfig> configs = playerGroupService.selectGameConfig(clubId, null, null, Integer.parseInt(level), null);
			if (StringUtil.isEmpty(configs) || configs.size() <= 0 ) {
				//如果没有获取到这个level的玩法的,从gameType里面随机获取一个
				TGame g = baseCacheController.queryGameById(Long.parseLong(level+""), cache);
				if (!StringUtil.isEmpty(g) && !StringUtil.isEmpty(g.getGameType()) ) {
					configs = playerGroupService.selectGameConfig(clubId, null, null, null, Integer.parseInt(g.getGameType()));
				}
			}

			log.info("createInfo" + createUid + " " + level + "----" + clubId);
			if (!StringUtil.isEmpty(configs) && configs.size() > 0 && !StringUtil.isEmpty(createUid) ) {
				Random random = new Random();
				int n = random.nextInt(configs.size());
				TGroupGameconfig config = configs.get(n);
				if (!StringUtil.isEmpty(config.getConfig())) {
					JSONObject jsonConfig = JSONObject.parseObject(config.getConfig());
					String uid = createUid;
					Integer baseChip = jsonConfig.getInteger("baseChip");
					Integer round = jsonConfig.getJSONObject("round").getInteger("optionValue");

					JSONObject json = new JSONObject();
					String discription = "";
					String discription2Server = "";
					for (String key : jsonConfig.keySet() ) {
						Object obj = jsonConfig.get(key);
						if (obj instanceof JSONObject) {
							JSONObject jo = (JSONObject)obj;
							if (jo.size() > 0 ) {
								String optionValue = jo.getString("optionValue");
								String optionName = jo.getString("optionName");
								String configName = jo.getString("configName");
								Integer isShow = jo.getInteger("isShow");
								if (!StringUtil.isEmpty(optionValue) ) {
									json.put(key, jo.get("optionValue"));
									if (!StringUtil.isEmpty(configName)) {
										discription += configName + ":" + optionName + " ";
										if (!StringUtil.isEmpty(isShow) && 1 == isShow ) {
											discription2Server += configName + ":" + optionName + " ";
										}
									}
								}
							}
						} else if (obj instanceof Integer) {
							json.put(key, obj);
						} else if ( obj instanceof String) {
							json.put(key, obj);
						}
					}

					CacheGameActivity activity = (CacheGameActivity)createFreeGameByOthers(uid, level, Integer.parseInt(level), "组局", round, json.toJSONString(), discription.trim(), discription2Server.trim(), 0,
							baseChip, clubId, null, config.getId(), null);
					log.info("createSuccess----" + activity.getGameActivityId());
				}
			}
		}catch (Exception e ) {
//			throw e;
			System.out.println("----------");
			System.out.println(e);
			TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
		}finally {
			CacheManager.releaseCache(cache);
		}

		return null;
	};

	/**
	 * 续房,如果有桌子了就返回activityId,如果没有就新建一个桌子
	 * @param userId
	 * @param activityId
	 * @return {"activityId":xxx,"inviteCode":xxx}
	 * @throws Exception
	 */
	public Map<String, String > extendFreeGameByOthers(String userId, Long activityId) throws Exception {


		ICache cache = null;
		Map<String, String > result = new HashMap<String, String>();
		try {
			cache = CacheManager.getCache();
			synchronized (lock) {
				String extendActivityId = cache.hget(GAME_EXTEND_ACTIVITY, activityId + "");
				if (StringUtil.isEmpty(extendActivityId) ) {
					TActivity tActivity = activityMapper.selectByPrimaryKey(activityId);
					if (StringUtil.isEmpty(tActivity) ) {
						throw new InfServerException(Constants.RETURN_CODE_FAIL,"组局数据异常,请返回大厅重新开始...");
					}
					String gameJson = tActivity.getGameJson();
					JSONObject gameJ = JSONObject.parseObject(gameJson);
					String userId1 = gameJ.getString("userId");
					String gameId = gameJ.getString("gameId");
					String level = gameJ.getString("level");
					String name = gameJ.getString("name");
					String round = gameJ.getString("round");
					String json = gameJ.getString("json");
					String discription = gameJ.getString("discription");
					String discription2Server = gameJ.getString("discription2Server");
					String others = gameJ.getString("others");
					String baseChip = gameJ.getString("baseChip");
					String password = gameJ.getString("password");
					String groupIdStr = gameJ.getString("groupId");
					String configIdStr = gameJ.getString("configId");
					Integer groupId = StringUtil.isEmpty(groupIdStr)? null: Integer.parseInt(groupIdStr);
					Integer configId = StringUtil.isEmpty(configIdStr)? null : Integer.parseInt(configIdStr);
					CacheGameActivity activity = (CacheGameActivity)createFreeGameByOthers(userId,gameId,Integer.parseInt(level),name,Integer.parseInt(round),json,discription,discription2Server, Integer.parseInt(others),Integer.parseInt(baseChip),
							groupId,password,configId,activityId);
					extendActivityId = activity.getGameActivityId();
					cache.hset(GAME_EXTEND_ACTIVITY,activityId+"", extendActivityId);
				}
				result.put("activityId",extendActivityId);
				String key = "USERPLAY_ROUND_" + extendActivityId;
				result.put("inviteCode",cache.hget(key,"inviteCode"));
				return result;
			}
		}catch (Exception e ) {
			throw e;
		}finally {
			CacheManager.releaseCache(cache);
		}
	};

	private String generateSixCode() {
		ICache cache = CacheManager.getCache();
		try {
			Random random = new Random();
			String result = String.format("%06d", random.nextInt(100000));

			int count = 0;
			while (!baseCacheController.insertFreeGameInviteCode(result, cache)) {
				if (count > 9) {
					return "-1";
				}
				result = String.format("%06d", random.nextInt(100000));
				count++;
			}

			return result;
		} catch (Exception e) {
			return "-1";
		} finally {
			if (cache != null) {
				CacheManager.releaseCache(cache);
			}
		}
	}

	/**查询redis中的数据
	 * @param userId
	 * @return
	 */
	public Response queryRedisTotalGroupBank(Long userId){
		Response response = new Response();
		String key="TOTALGROUPBANK-KEY";
		String GeRenRankKey="GERENRANK-KEY-"+userId;
		String GeRenRank2Key="GERENRANK2-KEY-"+userId;
		//过期时间为1天
		int expiretime=1*24*60*60;
		try {
			TUser user = userMapper.selectByPrimaryKey(userId);
			if (user != null) {
				Long self1 = freeGameTotalMapper.queryTotalByUserId(userId);
				List<TFreeGameTotal> result=null;
				@SuppressWarnings("unchecked")
				List<TFreeGameTotal> redisTgt=CacheRedisImp.getInstance().getObj(key, List.class);
				if(redisTgt==null){
					result = freeGameTotalMapper.queryTotalGroupRank(0L);
					CacheRedisImp.getInstance().setObj(key, result);
					//设置一天
					CacheRedisImp.getInstance().expire(key, expiretime);

				}else{
					result=redisTgt;
				}
				if (self1 != null) {

					if (self1 > 0) {
						TFreeGameTotal reidsSelf=CacheRedisImp.getInstance().getObj(GeRenRankKey, TFreeGameTotal.class);
						TFreeGameTotal self=null;
						if(reidsSelf==null){
							self = freeGameTotalMapper.queryTotalGroupGeRenRank(userId);
							CacheRedisImp.getInstance().setObj(GeRenRankKey, self);
							//设置一天
							CacheRedisImp.getInstance().expire(GeRenRankKey, expiretime);
						}else{
							self=reidsSelf;
						}
						GameRankVo vo = new GameRankVo();
						vo.setRankList(result);
						vo.setSelf(self);
						response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
						response.setData(vo);
					} else {

						TFreeGameTotal reidsSelf=CacheRedisImp.getInstance().getObj(GeRenRank2Key, TFreeGameTotal.class);
						TFreeGameTotal self=null;
						if(reidsSelf==null){
							self = freeGameTotalMapper.queryTotalGroupGeRenRank2(userId);
							CacheRedisImp.getInstance().setObj(GeRenRank2Key, self);
							//设置一天
							CacheRedisImp.getInstance().expire(GeRenRank2Key, expiretime);
						}else{
							self=reidsSelf;
						}

						GameRankVo vo = new GameRankVo();
						vo.setRankList(result);
						vo.setSelf(self);
						response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
						response.setData(vo);
					}
				}else{
					TFreeGameTotal total1 = new TFreeGameTotal();
					total1.setUserId(userId);
					total1.setWin(0);
					total1.setScore(0);
					total1.setDraw(0);
					total1.setLose(0);
					total1.setTotal(0);
					freeGameTotalMapper.insert(total1);
					TFreeGameTotal reidsSelf=CacheRedisImp.getInstance().getObj(GeRenRank2Key, TFreeGameTotal.class);
					TFreeGameTotal self=null;
					if(reidsSelf==null){
						self = freeGameTotalMapper.queryTotalGroupGeRenRank2(userId);
						CacheRedisImp.getInstance().setObj(GeRenRank2Key, self);
						//设置一天
						CacheRedisImp.getInstance().expire(GeRenRank2Key, expiretime);
					}else{
						self=reidsSelf;
					}
					GameRankVo vo = new GameRankVo();
					vo.setRankList(result);
					vo.setSelf(self);
					response.setReturnCode(Constants.RETURN_CODE_SUCCESS);
					response.setData(vo);
				}

			} else {
				throw new InfServerException(Constants.RETURN_CODE_FAIL, "该用户不存在");
			}

		} catch (InfServerException ie) {
			log.error("查询总排行榜：", ie);
			response.setReturnCode(ie.getErrorCode());
			response.setError(ie.getErrorMsg());
		} catch (Exception e) {
			log.error("查询总排行榜：", e);
			response.setReturnCode(Constants.RETURN_CODE_FAIL);
		}
		return response;
	}

	public Object queryGameNameByLevel(String level) {
		ICache cache = null;
		JSONObject json = null;
		try {
			cache = CacheManager.getCache();
			json = new JSONObject();

			Map<String, String> gameMap = cache.hgetAll(Constants.GAME_CATEGORY_LIST);
			if (!gameMap.containsKey(level)) {
				cache.del(Constants.GAME_CATEGORY_LIST);
				baseCacheController.queryGame(cache);
				gameMap = cache.hgetAll(Constants.GAME_CATEGORY_LIST);
			}
			if (StringUtil.isNotEmpty(level)) {
				String s = gameMap.get(level);
				if (StringUtil.isNotEmpty(s)) {
					String name = JSONObject.parseObject(s).getString("name");
					json.put(level,name);
				}
			}else {
				for (String key : gameMap.keySet()) {
					String name = JSONObject.parseObject(gameMap.get(key)).getString("name");
					json.put(key,name);
				}
			}

			return json;
		}catch (Exception e ) {

		}finally {
			CacheManager.releaseCache(cache);
		}
		return json;
	}

	public Map<String, Object> queryActivitiesResult(Integer userId, Integer groupId, Integer type, Integer currentPage, Integer pageSize, Integer level, Integer searchId) {


		if (!StringUtil.isEmpty(searchId) ) {
			userId = searchId;
		}

		int startPage = (currentPage-1) * pageSize;
		int l = userId%10;
		List<TFreeGameResult> list = freeGameResultMapper.queryActivitiesResult(l, userId, groupId, type, startPage, pageSize, level);
		Integer listCount = freeGameResultMapper.queryActivitiesResultCount(l, userId, groupId, type, level);

		HashMap<String, Object> result = new HashMap<String, Object>();
		result.put("list", list);
		result.put("listCount", listCount);

		return result;

	}
}
