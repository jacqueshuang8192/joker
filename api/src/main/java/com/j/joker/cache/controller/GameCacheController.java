package com.j.joker.cache.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.core.util.RedisUtil;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.ICache;
import com.j.joker.cache.cacheWritter.GameCacheLoader;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TGroupGameMapper;
import com.j.joker.model.TGameConfig;
import com.j.joker.model.TGameServer;
import com.j.joker.model.TGroupGame;
import com.j.joker.model.TMemdataServer;
import com.j.joker.vo.response.game.UserOnlineGame;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class GameCacheController {
    private static final String USER_GAME_KEY = "USER_GAME_";
    private static final String USER_RANK_HISTORY_KEY = "USER_RANK_HISTORY_";
    private static final String RISE_STRATEGY_KEY = "RISE_STRATEGY_";
    private static final String GAME_MATCH_KEY = "GAME_MATCH_";
    private static final String GAME_ELIMINATION_RULE_KEY = "GAME_ELIMINATION_RULE";
    private static final String LIVE_ROOM_GAME_KEY = "LIVE_ROOM_GAME_";
    private static final String GAME_AWARD_POOL_DEFINITION_KEY = "GAME_AWARD_POOL_DEFINITION";
    private static final String LEVEL_LIFEFORCE_KEY = "LEVEL_LIFEFORCE";

    private static final String FREE_GAME_KEY_PREFIX = "FREE_GAME_";
    private static final String GAME_AWARD_POOL_DEFINITION_FIELD_PONDS = "gameAwardPoolDeductPonds";
    private static final String GAME_AWARD_POOL_KEY = "GAME_AWARD_POOL";
    private static final String GAME_AWARD_POOL_FIELD_COIN_AMOUNT = "coinAmount";

    private static final String GAME_AWARD_POOL_APPLY_USER_KEY = "GAME_AWARD_POOL_APPLY_USER";

    private static final String USER_ONLINE_GAME_KEY = "USER_ONLINE_GAME";
    private static final String GAME_LEVEL_KEY = "GAME_LEVEL";
    private static final String GAME_SERVER_KEY = "GAME_SERVER";
    private static final String GAME_SERVER_ROUND_KEY = "GAME_SERVER_ROUND";
    private static final String GAME_LEVEL_PLAYER_COUNT_KEY = "GAME_LEVEL_PLAYER_COUNT";

    private static final String GAME_MATCH_AWARD_KEY = "GAME_MATCH_AWARD_KEY_";
    
    private static final String FREEGAME_USER_TABLE_STATE_PREFIX = "GROUP_USER_TABLE_STATE_";
    private static final String FREEGAME_USER_TABLE_STATE = "STATE";

    private static final String MEMDATA_SERVER_KEY = "MEMDATA_SERVER";

    private static final String GAME_CONFIG_KEY = "GAME_CONFIG";

//    @Autowired
//    private TUserGameMapper userGameMapper;
//    @Autowired
//    private TPlayerRankGameHistoryMapper rankGameHistoryMapper;
//    @Autowired
//    private TGameMatchMapper gameMatchMapper;
    @Autowired
    private TGroupGameMapper groupGameMapper;
//    @Autowired
//    private TMatchPlayerGoonMapper matchPlayerGoonMapper;
//    @Autowired
//    private TCompereGameMapper compereGameMapper;
//    @Autowired
//    private TGameAwardPoolDefinitionMapper gameAwardPoolDefinitionMapper;
//    @Autowired
//    private TGameAwardPoolMapper gameAwardPoolMapper;
//    @Autowired
//    private TGameAwardPoolApplyRecordMapper gameAwardPoolApplyRecordMapper;
//    @Autowired
//    private TGameAwardPoolDeductPondMapper gameAwardPoolDeductPondMapper;
    @Autowired
    private GameCacheLoader gameCacheLoader;

    public boolean isExistFreeGameCreatedByUserId(String userId, ICache cache) {
    	String key = FREEGAME_USER_TABLE_STATE_PREFIX + userId;

    	Map<String, String> keyValue = RedisUtil.getRu().hgetall(key);
    	
    	for (String s : keyValue.keySet()) {
    		String state = keyValue.get(s);
    		
    		if (state != null && "1".equals(state)) {
        		return true;
        	}
    	}
    	
    	return false;
    }
    
//    public TUserGame queryUserGame(Long gameId, Long userId, ICache cache) {
//        String key = USER_GAME_KEY + gameId;
//        String userGame = cache.hget(key, userId.toString());
//        if (StringUtils.isEmpty(userGame)) {
//            TUserGame game = new TUserGame();
//            game.setGameId(gameId);
//            game.setUserid(userId);
//            game = userGameMapper.findById(game);
//            if (game != null) {
//                cache.hset(key, userId.toString(), JSONObject.toJSONString(game));
//            }
//            return game;
//        } else {
//            TUserGame game = JSONObject.parseObject(userGame, TUserGame.class);
//            return game;
//        }
//    }
//
//    public List<TPlayerRankGameHistory> queryRankGameHistory(Long playerId,
//            ICache cache) {
//        String key = USER_RANK_HISTORY_KEY + playerId;
//        List<String> history = cache.lgetAll(key);
//        if (history == null || history.size() == 0) {
//            TPlayerRankGameHistory temp = new TPlayerRankGameHistory();
//            temp.setPlayerId(playerId);
//            List<TPlayerRankGameHistory> list = rankGameHistoryMapper
//                    .select(temp);
//            for (TPlayerRankGameHistory h : list) {
//                cache.rpush(key, JSONObject.toJSONString(h));
//            }
//            return list;
//        } else {
//            List<TPlayerRankGameHistory> result = new ArrayList<TPlayerRankGameHistory>();
//            for (String json : history) {
//                result.add(
//                        JSON.parseObject(json, TPlayerRankGameHistory.class));
//            }
//            return result;
//        }
//    }
//
//    /**
//     * 根据游戏ID查询游戏段位策略列表
//     *
//     * @param gameId
//     * @param cache
//     * @return
//     */
//    public List<TGameRiseStrategy> queryStrategies(Long gameId, ICache cache) {
//        String key = RISE_STRATEGY_KEY + gameId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TGameRiseStrategy> list = gameCacheLoader
//                    .queryStrategiesByGameId(gameId);
//            for (TGameRiseStrategy tGameRiseStrategy : list) {
//                cache.hset(key, tGameRiseStrategy.getLevel().toString(),
//                        JSONObject.toJSONString(tGameRiseStrategy));
//            }
//            return list;
//        } else {
//            List<TGameRiseStrategy> result = new ArrayList<TGameRiseStrategy>();
//            Set<String> keys = map.keySet();
//            for (String k : keys) {
//                result.add(JSONObject.parseObject(map.get(k),
//                        TGameRiseStrategy.class));
//            }
//            return result;
//        }
//    }
//
//    /**
//     * 根据段位等级和游戏ID查询游戏段位策略
//     *
//     * @param gameId
//     * @param level
//     * @param cache
//     * @return
//     */
//    public TGameRiseStrategy queryStrategy(Long gameId, Integer level,
//            ICache cache) {
//        List<TGameRiseStrategy> list = queryStrategies(gameId, cache);
//        for (TGameRiseStrategy tGameRiseStrategy : list) {
//            if (tGameRiseStrategy.getLevel().equals(level)) {
//                return tGameRiseStrategy;
//            }
//        }
//        return null;
//    }
//
//    /**
//     * 查询等级属性（生命攻击防御）定义列表
//     *
//     * @param cache
//     * @return
//     */
//    public List<TLevelLifeforce> queryLifeforces(ICache cache) {
//        String key = LEVEL_LIFEFORCE_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TLevelLifeforce> list = gameCacheLoader.queryLifeforces();
//            for (TLevelLifeforce tLevelLifeforce : list) {
//                cache.hset(key, tLevelLifeforce.getLevel().toString(),
//                        JSONObject.toJSONString(tLevelLifeforce));
//            }
//            return list;
//        } else {
//            List<TLevelLifeforce> list = new ArrayList<TLevelLifeforce>();
//            Set<String> keyValues = map.keySet();
//            for (String string : keyValues) {
//                list.add(JSONObject.parseObject(map.get(string), TLevelLifeforce.class));
//            }
//            return list;
//        }
//    }
//
//    /**
//     * 根据等级查询属性（生命攻击防御）定义
//     * @param level
//     * @param cache
//     * @return
//     */
//    public TLevelLifeforce queryLifeforce(Integer level, ICache cache) {
//        List<TLevelLifeforce> list = queryLifeforces(cache);
//        for (TLevelLifeforce tLevelLifeforce : list) {
//            if(tLevelLifeforce.getLevel().equals(level)) {
//                return tLevelLifeforce;
//            }
//        }
//        return null;
//    }
//
//    /**
//     * 查询游戏比赛
//     *
//     * @param gameId
//     * @param cache
//     * @return
//     */
//    public List<TGameMatch> queryGameMatches(Long gameId, ICache cache) {
//        String key = GAME_MATCH_KEY + gameId;
//        List<String> list = cache.lgetAll(key);
//        if (list == null || list.size() == 0) {
//            TGameMatch tMatch = new TGameMatch();
//            tMatch.setGameId(gameId);
//            tMatch.setStatus(Constants.VALID);
//            List<TGameMatch> matches = gameMatchMapper.select(tMatch);
//            for (TGameMatch match : matches) {
//                cache.rpush(key, JSONObject.toJSONString(match));
//            }
//            return matches;
//        } else {
//            List<TGameMatch> matches = new ArrayList<TGameMatch>();
//            for (String str : list) {
//                matches.add(JSONObject.parseObject(str, TGameMatch.class));
//            }
//            return matches;
//        }
//    }
//
//    /**
//     * 查询比赛淘汰规则
//     *
//     * @param matchId
//     * @param cache
//     * @return
//     */
//    public List<TMatchPlayerGoon> queryEliminationGameRule(Long matchId,
//            ICache cache) {
//        String key = GAME_ELIMINATION_RULE_KEY + matchId;
//        List<String> strList = cache.lgetAll(key);
//        if (strList == null || strList.size() == 0) {
//            List<TMatchPlayerGoon> ruleList = new ArrayList<TMatchPlayerGoon>();
//            TMatchPlayerGoon rule = new TMatchPlayerGoon();
//            rule.setMatchId(matchId);
//            ruleList = matchPlayerGoonMapper.select(rule);
//            for (TMatchPlayerGoon tMatchPlayerGoon : ruleList) {
//                cache.rpush(key, JSONObject.toJSONString(tMatchPlayerGoon));
//            }
//            return ruleList;
//        } else {
//            List<TMatchPlayerGoon> ruleList = new ArrayList<TMatchPlayerGoon>();
//            for (String str : strList) {
//                ruleList.add(
//                        JSONObject.parseObject(str, TMatchPlayerGoon.class));
//            }
//            return ruleList;
//        }
//    }
//
//    /**
//     * 查询游戏比赛
//     *
//     * @param gameId
//     * @param cache
//     * @return
//     */
//    public TCompereGame queryCompereGame(Long gameId, ICache cache) {
//        TCompereGame compereGame = null;
//        String key = LIVE_ROOM_GAME_KEY + gameId;
//        String str = cache.get(key);
//        if (StringUtils.isNotBlank(str)) {
//            compereGame = JSONObject.parseObject(str, TCompereGame.class);
//        } else {
//            TCompereGame temp = new TCompereGame();
//            temp.setGameId(gameId);
//            List<TCompereGame> compereGames = compereGameMapper.select(temp);
//            if (CollectionUtils.isNotEmpty(compereGames)) {
//                compereGame = compereGames.get(0);
//                cache.set(key, JSONObject.toJSONString(compereGame));
//            }
//        }
//        return compereGame;
//    }
//
//    /**
//     * 获取连线奖池规则
//     *
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public TGameAwardPoolDefinition queryGameAwardPoolDefinition(ICache cache)
//            throws Exception {
//        TGameAwardPoolDefinition gameAwardPoolDefinition = null;
//        String key = GAME_AWARD_POOL_DEFINITION_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            gameAwardPoolDefinition = (TGameAwardPoolDefinition) BeanMapUtils
//                    .toBeanBySelective(TGameAwardPoolDefinition.class, map);
//            gameAwardPoolDefinition
//                    .setGameAwardPoolDeductPonds(JSONArray.parseArray(
//                            cache.hget(key,
//                                    GAME_AWARD_POOL_DEFINITION_FIELD_PONDS),
//                            TGameAwardPoolDeductPond.class));
//        } else {
//            TGameAwardPoolDefinition temp = new TGameAwardPoolDefinition();
//            temp.setStatus(Constants.VALID);
//            List<TGameAwardPoolDefinition> gapds = gameAwardPoolDefinitionMapper
//                    .select(temp);
//            if (CollectionUtils.isNotEmpty(gapds)) {
//                gameAwardPoolDefinition = gapds.get(0);
//                List<TGameAwardPoolDeductPond> gameAwardPoolDeductPonds = gameAwardPoolDeductPondMapper
//                        .select(new TGameAwardPoolDeductPond());
//                cache.hsetObj(key, GAME_AWARD_POOL_DEFINITION_FIELD_PONDS,
//                        gameAwardPoolDeductPonds);
//                cache.hmset(key,
//                        BeanMapUtils.toMapBySelective(gameAwardPoolDefinition));
//                gameAwardPoolDefinition
//                        .setGameAwardPoolDeductPonds(gameAwardPoolDeductPonds);
//            }
//        }
//        return gameAwardPoolDefinition;
//    }
//
//    /**
//     * 获取连线奖池
//     *
//     * @param cache
//     * @return
//     * @throws Exception
//     */
//    public TGameAwardPool queryGameAwardPool(ICache cache) throws Exception {
//        TGameAwardPool gameAwardPool = null;
//        String key = GAME_AWARD_POOL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            gameAwardPool = (TGameAwardPool) BeanMapUtils
//                    .toBeanBySelective(TGameAwardPool.class, map);
//        } else {
//            List<TGameAwardPool> gaps = gameAwardPoolMapper
//                    .queryAvailGameAwardPool();
//            if (CollectionUtils.isNotEmpty(gaps)) {
//                gameAwardPool = gaps.get(0);
//                cache.hmset(key, BeanMapUtils.toMapBySelective(gameAwardPool));
//            }
//        }
//        return gameAwardPool;
//    }
//
//    /**
//     * 更新连线奖池
//     *
//     * @param cache
//     * @throws Exception
//     */
//    public void updateGameAwardPoolCoinAmount(int addCoinAmount, ICache cache)
//            throws Exception {
//        String key = GAME_AWARD_POOL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            cache.hincrby(key, GAME_AWARD_POOL_FIELD_COIN_AMOUNT,
//                    addCoinAmount);
//        } else {
//            List<TGameAwardPool> gaps = gameAwardPoolMapper
//                    .queryAvailGameAwardPool();
//            if (CollectionUtils.isNotEmpty(gaps)) {
//                TGameAwardPool gameAwardPool = gaps.get(0);
//                cache.hmset(key, BeanMapUtils.toMapBySelective(gameAwardPool));
//            }
//        }
//    }
//
//    /**
//     * 更新连线奖池
//     *
//     * @param gameAwardPool
//     * @param cache
//     * @throws Exception
//     */
//    public void updateGameAwardPool(TGameAwardPool gameAwardPool, ICache cache)
//            throws Exception {
//        String key = GAME_AWARD_POOL_KEY;
//        if (gameAwardPool != null) {
//            cache.hmset(key, BeanMapUtils.toMapBySelective(gameAwardPool));
//        }
//    }
//
//    /**
//     * 获取连线奖池报名用户
//     *
//     * @param cache
//     * @return
//     */
//    public List<TGameAwardPoolApplyRecord> queryGameAwardPoolApplyRecords(
//            Long gameAwardPoolId, ICache cache) {
//        List<TGameAwardPoolApplyRecord> applyRecords = null;
//        String key = GAME_AWARD_POOL_APPLY_USER_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            applyRecords = new ArrayList<TGameAwardPoolApplyRecord>();
//            for (String k : map.keySet()) {
//                applyRecords.add(JSONObject.parseObject(map.get(k),
//                        TGameAwardPoolApplyRecord.class));
//            }
//        } else {
//            applyRecords = gameAwardPoolApplyRecordMapper.queryApplyRecordByPoolIdDistinctUserId(gameAwardPoolId);
//            if (CollectionUtils.isNotEmpty(applyRecords)) {
//                for (TGameAwardPoolApplyRecord ar : applyRecords) {
//                    cache.hset(key, ar.getUserId().toString(), JSON.toJSONString(ar));
//                }
//            }
//        }
//        return applyRecords;
//    }
//
//    /**
//     * 清空连线报名记录
//     *
//     * @param cache
//     */
//    public void clearGameAwardPoolApplyRecords(ICache cache) {
//        cache.del(GAME_AWARD_POOL_APPLY_USER_KEY);
//    }
//
//    /**
//     * 连线奖池报名
//     * @param awardPoolApplyRecord
//     * @param cache
//     */
//    public void applyGameAwardPool(
//            TGameAwardPoolApplyRecord awardPoolApplyRecord, ICache cache) {
//        String key = GAME_AWARD_POOL_APPLY_USER_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            cache.hset(key, awardPoolApplyRecord.getUserId().toString(), JSON.toJSONString(awardPoolApplyRecord));
//        } else {
//            List<TGameAwardPoolApplyRecord> applyRecords = gameAwardPoolApplyRecordMapper.queryApplyRecordByPoolIdDistinctUserId(awardPoolApplyRecord.getGameAwardPoolId());
//            if (CollectionUtils.isNotEmpty(applyRecords)) {
//                for (TGameAwardPoolApplyRecord ar : applyRecords) {
//                    cache.hset(key, ar.getUserId().toString(), JSON.toJSONString(ar));
//                }
//            }
//        }
//    }

    
//    public List<TFreeGame> queryFreeGames(Long gameId, ICache cache) {
//        String key = FREE_GAME_KEY_PREFIX + gameId;
//        List<String> list = cache.lgetAll(key);
//        if (CollectionUtils.isEmpty(list)) {
//            TFreeGame freeGame = new TFreeGame();
//            freeGame.setGameId(gameId);
//            freeGame.setStatus(Constants.VALID);
//            List<TFreeGame> freeGames = freeGameMapper.select(freeGame);
//            for (TFreeGame fg : freeGames) {
//                cache.rpush(key, JSONObject.toJSONString(fg));
//            }
//            return freeGames;
//        } else {
//            List<TFreeGame> freeGames = new ArrayList<TFreeGame>();
//            for (String str : list) {
//                freeGames.add(JSONObject.parseObject(str, TFreeGame.class));
//            }
//            return freeGames;
//        }
//    }
    
//    public TFreeGame queryFreeGameByLevel(String level, ICache cache) {
//        TFreeGame freeGame = null;
//        String gameIdAndTypeStr = queryGameIdAndTypeByGameLevel(level, cache);
//        if (StringUtils.isNotBlank(gameIdAndTypeStr)) {
//            if (gameIdAndTypeStr.contains(",")) {
//                String gameIdStr = gameIdAndTypeStr.substring(0, gameIdAndTypeStr.indexOf(","));
//
//                List<TFreeGame> freeGames = queryFreeGames(Long.parseLong(gameIdStr), cache);
//                if (CollectionUtils.isNotEmpty(freeGames)) {
//                    for (TFreeGame fg : freeGames) {
//                        if (level.equals(fg.getLevel().toString())) {
//                            freeGame = fg;
//                            break;
//                        }
//                    }
//                }
//            }
//        }
//        return freeGame;
//    }
    
    /**
     * 查询玩家游戏状态
     * @param userId
     * @param cache
     * @return
     */
    public UserOnlineGame queryUserOnlineGame(String userId, ICache cache) {
        UserOnlineGame userOnlineGame = new UserOnlineGame();
        String key = USER_ONLINE_GAME_KEY;
        String gameLevel = cache.hget(key, userId);
        if (StringUtils.isNotBlank(gameLevel)) {
            String gameIdAndType = queryGameIdAndTypeByGameLevel(gameLevel, cache);
            if (StringUtils.isNotBlank(gameIdAndType)) {
                String[] temps = gameIdAndType.split(",");
                if (temps.length == 2) {
                    userOnlineGame.setGameId(Long.parseLong(temps[0]));
                    userOnlineGame.setType(temps[1]);
                    userOnlineGame.setGameStatus(Constants.USER_ONLINE_GAME_STATUS_GAMING);
                }
            }
        } else {
            userOnlineGame.setGameStatus(Constants.USER_ONLINE_GAME_STATUS_FREE);
        }
        return userOnlineGame;
    }
    
    /**
     * 根据游戏level获取游戏ID和游戏类型
     * @param level
     * @return
     */
    public String queryGameIdAndTypeByGameLevel(String level, ICache cache) {
        String gameIdAndType = null;
        String key = GAME_LEVEL_KEY;
        if (cache.hlen(key) > 0 && !StringUtils.isEmpty(cache.hget(key,level))) {
            gameIdAndType = cache.hget(key, level);
        } else {
//            List<TQuickGame> quickGames = gameCacheLoader.loadAllQuickGames();
//            if (CollectionUtils.isNotEmpty(quickGames)) {
//                for (TQuickGame qg : quickGames) {
//                    cache.hset(key, qg.getLevel().toString(), qg.getGameId().toString() + "," + Constants.QUICK_GAME);
//                }
//            }
//
//            List<TGameMatch> gameMatchs = gameCacheLoader.loadAllGameMatchs();
//            if (CollectionUtils.isNotEmpty(gameMatchs)) {
//                for (TGameMatch gm : gameMatchs) {
//                    cache.hset(key, gm.getLevel().toString(), gm.getGameId().toString() + "," + Constants.GAME_MATCH);
//                }
//            }
//
//            List<TCompereGame> compereGames = gameCacheLoader.loadAllCompereGames();
//            if (CollectionUtils.isNotEmpty(compereGames)) {
//                for (TCompereGame cg : compereGames) {
//                    cache.hset(key, cg.getLevel().toString(), cg.getGameId().toString() + "," + Constants.COMPERE_GAME);
//                }
//            }

            List<TGroupGame> freeGames = gameCacheLoader.loadAllFreeGames();
            if (CollectionUtils.isNotEmpty(freeGames)) {
                for (TGroupGame fg : freeGames) {
                    cache.hset(key, fg.getLevel().toString(), fg.getGameId().toString() + "," + Constants.FREE_GAME);
                }
            }
            gameIdAndType = cache.hget(key, level);
        }
        return gameIdAndType;
    }
    
    /**
     * 查询每个游戏的在线人数
     * @param cache
     * @return
     */
//    public Map<String, Integer> queryGamesCurrentPlayerCount(ICache cache) {
//        Map<String, Integer> playerCountMap = new HashMap<String, Integer>();
//        String key = USER_ONLINE_GAME_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            Collection<String> levels = map.values();
//            for (String level : levels) {
//                String gameIdAndTypeStr = this.queryGameIdAndTypeByGameLevel(level, cache);
//                if (StringUtils.isNotBlank(gameIdAndTypeStr)) {
//                    if (gameIdAndTypeStr.contains(",")) {
//                        String gameId = gameIdAndTypeStr.substring(0, gameIdAndTypeStr.indexOf(","));
//                        if (playerCountMap.containsKey(gameId)) {
//                            playerCountMap.put(gameId, playerCountMap.get(gameId) + 1);
//                        } else {
//                            playerCountMap.put(gameId, 1);
//                        }
//                    }
//                }
//            }
//        }
//        return playerCountMap;
//    }
    
    /**
     * 查询游戏自由场和比赛场的在线人数
     * @param gameId
     * @param cache
     * @return
     */
//    public Map<String, Integer> queryGameSceneCurrentPlayerCountByGame(Long gameId, ICache cache) {
//        Map<String, Integer> playerCountMap = new HashMap<String, Integer>();
//        playerCountMap.put("qg", 0);
//        playerCountMap.put("gm", 0);
//        String key = USER_ONLINE_GAME_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            List<TQuickGame> quickGames = baseCacheController.queryQuickGame(gameId, cache);
//            List<TGameMatch> gameMatchs = queryGameMatches(gameId, cache);
//
//            Collection<String> levels = map.values();
//            for (String level : levels) {
//                boolean isQuickGame = false;
//                if (CollectionUtils.isNotEmpty(quickGames)) {
//                    for (TQuickGame qg : quickGames) {
//                        if (qg.getLevel().toString().equals(level)) {
//                            playerCountMap.put("qg", playerCountMap.get("qg") + 1);
//                            isQuickGame = true;
//                            break;
//                        }
//                    }
//                }
//
//                if (CollectionUtils.isNotEmpty(gameMatchs)) {
//                    if (!isQuickGame) {
//                        for (TGameMatch gm : gameMatchs) {
//                            if (gm.getLevel().toString().equals(level)) {
//                                playerCountMap.put("gm", playerCountMap.get("gm") + 1);
//                                break;
//                            }
//                        }
//                    }
//                }
//
//            }
//        }
//        return playerCountMap;
//    }
    
    /**
     * 查询自由场分场的在线人数
     * @param gameId
     * @param cache
     * @return
     */
//    public Map<String, Integer> queryQuickGameCurrentPlayerCount(Long gameId, ICache cache) {
//        Map<String, Integer> playerCountMap = new HashMap<String, Integer>();
//        String key = USER_ONLINE_GAME_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            List<TQuickGame> quickGames = baseCacheController.queryQuickGame(gameId, cache);
//            if (CollectionUtils.isNotEmpty(quickGames)) {
//                Collection<String> levels = map.values();
//                for (String level : levels) {
//                    for (TQuickGame qg : quickGames) {
//                        if (qg.getLevel().toString().equals(level)) {
//                            if (playerCountMap.containsKey(level)) {
//                                playerCountMap.put(level, playerCountMap.get(level) + 1);
//                            } else {
//                                playerCountMap.put(level, 1);
//                            }
//                            break;
//                        }
//                    }
//                }
//            }
//
//        }
//        return playerCountMap;
//    }
    
    /**
     * 查询比赛场分场在线人数
     * @param gameId
     * @param cache
     * @return
     */
//    public Map<String, Integer> queryGameMatchCurrentPlayerCount(Long gameId, ICache cache) {
//        Map<String, Integer> playerCountMap = new HashMap<String, Integer>();
//        String key = USER_ONLINE_GAME_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            List<TGameMatch> gameMatchs = queryGameMatches(gameId, cache);
//            if (CollectionUtils.isNotEmpty(gameMatchs)) {
//                Collection<String> levels = map.values();
//                for (String level : levels) {
//                    for (TGameMatch gm : gameMatchs) {
//                        if (gm.getLevel().toString().equals(level)) {
//                            if (playerCountMap.containsKey(level)) {
//                                playerCountMap.put(level, playerCountMap.get(level) + 1);
//                            } else {
//                                playerCountMap.put(level, 1);
//                            }
//                            break;
//                        }
//                    }
//                }
//            }
//
//        }
//        return playerCountMap;
//    }
//
//    public TGameAwardPool queryOnlineTreasures(ICache cache) {
//        // TODO Auto-generated method stub
//        return null;
//    }

    /**
     * 查询游戏服务器列表
     * @param cache 缓存实例
     * @return
     */
    public List<TGameServer> queryGameServerList(ICache cache) {
        String key = GAME_SERVER_KEY;
        List<TGameServer> list = new ArrayList<TGameServer>();
        if (cache.exist(key)) {
            Map<String, String> map = cache.hgetAll(key);
            Set<String> keySet = map.keySet();
            for (String s : keySet) {
                String str = map.get(s);
                list.add(JSON.parseObject(str, TGameServer.class));
            }
        } else {
            list = gameCacheLoader.loadGameServerList();
            for (TGameServer s : list) {
                cache.hset(key, s.getId().toString(), JSON.toJSONString(s));
            }
        }
        return list;
    }

    /**
     * 查询轮询游戏服务器当前index，并且index指向下一台服务器
     * @param cache
     * @return
     */
    public int queryCurGameServerRound(ICache cache) {
        int index = 0;
        String key = GAME_SERVER_ROUND_KEY;
        if (!cache.exist(key)) {
            cache.set(key, String.valueOf(index));
        } else {
            String str = cache.get(key);
            Integer it = Integer.parseInt(str);
            index = it;
            String totalStr = ConfigUtil.get("game.round", "3");
            Integer total = Integer.parseInt(totalStr);
            if (it == total -1) { //index从0开始算，当前已轮询到最后一台，下一次从第一台开始
                cache.set(key, "0");
            } else {
                cache.set(key, String.valueOf(it + 1));
            }
        }
        return index;
    }

//    public List<TGameMatchAward> queryGameMatchAwardByCondition(Long gameId, Integer level, ICache cache) {
//        String key = GAME_MATCH_AWARD_KEY + gameId + "_" + level;
//        List<TGameMatchAward> list = new ArrayList<TGameMatchAward>();
//        if (cache.exist(key)) {
//            Map<String, String> map = cache.hgetAll(key);
//            Set<String> ks = map.keySet();
//            for (String rank : ks) {
//                String awardStr = map.get(rank);
//                TGameMatchAward award = JSON.parseObject(awardStr, TGameMatchAward.class);
//                list.add(award);
//            }
//            return list;
//        } else {
//            list = gameCacheLoader.loadGameMatchAward(gameId, level);
//            for (TGameMatchAward t : list) {
//                cache.hset(key, t.getRank(), JSON.toJSONString(t));
//            }
//            return  list;
//        }
//    }

    public TMemdataServer queryMemdataServer(ICache cache) {
        String key = MEMDATA_SERVER_KEY;
        if (cache.exist(key)) {
            String value = cache.get(key);
            return JSON.parseObject(value, TMemdataServer.class);
        } else {
            TMemdataServer server = gameCacheLoader.loadMemdataServer();
            cache.set(key, JSON.toJSONString(server));
            return server;
        }
    }

    public String queryGameConfig(Integer level,ICache cache) throws Exception {
        String hget = cache.hget(GAME_CONFIG_KEY, level.toString());
        if (StringUtil.isNotEmpty(hget)) {
            return hget;
        } else {
            String content = gameCacheLoader.queryGameConfigByLevel(level);
            cache.hset(GAME_CONFIG_KEY,level.toString(),content);
            return content;
        }
    }

    /**
     * 后台数据结构改成按level区分，对前端透明，此处转换
     * @param list
     * @return
     */
    private TGameConfig convert(List<TGameConfig> list) {
        TGameConfig config = new TGameConfig();

        JSONArray array = new JSONArray();
        for (TGameConfig g : list) {
            array.add(JSONObject.parseObject(g.getContent()));
        }
        String content = array.toJSONString().replaceAll("\\\\", "");

        config.setId(1L);
        config.setContent(content);
        return config;
    }
}
