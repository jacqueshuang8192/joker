package com.hbi.cache.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.cacheWritter.BaseCacheLoader;
import com.hbi.cache.model.CacheCountry;
import com.hbi.constants.Constants;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.utils.InfServerException;
import com.hbi.vo.request.common.TLevelFenChangVo;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.beans.IntrospectionException;
import java.lang.reflect.InvocationTargetException;
import java.util.*;

@Service
public class BaseCacheController {
    
    @Autowired
    private BaseCacheLoader baseCacheLoader;
    @Autowired
    private TUserMapper userMapper;
    
//    @Autowired
//    private TBaseClassificationMapper baseClassificationMapper;
//
//    @Autowired
//    private TBaseDetailMapper baseDetailMapper;
    
    @Autowired 
    private TGoodsCategoryMapper goodsCategoryMapper;
    
    @Autowired
    private TGoodsMapper goodsMapper;
    
    @Autowired
    private TGameMapper gameMapper;

    @Autowired
    private GoldMapper goldMapper;
    
//    @Autowired
//    private TQuickGameMapper quickGameMapper;

    @Autowired
    private TGroupGameMapper groupGameMapper;
    
    private static final String LIVE_GAME_LIST_KEY = "LIVE_GAME_LIST";
    
    private static final String LIVE_VOICE_KEY = "LIVE_VOICE";
    
    private static final String LIVE_THEME_KEY = "LIVE_THEME";
    
    private static final String ITEM_KEY = "ITEM_GOODS";
    
    private static final String QUICK_GAME_LIST_KEY_PREFIX = "QUICK_GAME_LIST_";

    private static final String GROUP_GAME_LIST_KEY_PREFIX = "GROUP_GAME_LIST_";
    
    private static final String CATEGORY_LIST_KEY = "CATEGORY_LIST";
    
    private static final String GAME_CATEGORY_LIST_KEY = "GAME_CATEGORY_LIST";
    
    private static final String PRIVILEGES_KEY = "PRIVILEGES";
    
    private static final String COUNTRY_CODE_KEY = "COUNTRY_";
    
    private static final String BASE_CLASSIFICATION_KEY = "BASE_GROUP";
    
    private static final String BASE_DETAIL_KEY = "BASE_GROUP_";
    
    private static final String CONFIG_KEY = "CONFIG";

    private static final String ALLOWANCE_KEY = "ALLOWANCE";

    private static final String PLATFORM_LEVEL_KEY = "PLATFORM_LEVEL";
    
    private static final String COMPERE_LEVEL_KEY = "COMPERE_LEVEL";
    
    private static final String BASE_EXTRACT_STRATEGY_KEY = "BASE_EXTRACT_STRATEGY";
    
    private static final String INDIVIDUATION_EXTRACT_STRATEGY_KEY_PREFIX = "INDIVIDUATION_EXTRACT_STRATEGY";
    
    private static final String APPLICATION_VERSION_KEY = "APPLICATION_VERSION";
    private static final String GAME_HALL_VERSION_KEY = "GAME_HALL_VERSION";
    private static final String GAME_VERSION_KEY = "GAME_VERSION_";
    private static final String BASE_DATA_VERSION_KEY = "BASE_DATA_VERSION";
    
    private static final String ANNOUNCEMENT_KEY_PREFIX = "ANNOUNCEMENT_";
    
    private static final String FREE_GAME_INVITE_CODE_PREFIX = "FREE_GAME_INVITE_CODE_";

    private static final String RED_PACKET_KEY = "RED_PACKET";

    private static final String SCORE_SECTION_KEY = "SCORE_SECTION";
    private static final String FENG_CHANG = "FENG_CHANG_";

    public boolean insertFreeGameInviteCode(String code, ICache cache) {
    	String key = FREE_GAME_INVITE_CODE_PREFIX + code;
        Long result = cache.setnx(key, key);
        if (result == 0L) {
            return false;
        }
        return true;
//    	if (cache.get(key) != null) {
//    		return false;
//    	} else {
//    		cache.set(key, key);
//    		return true;
//    	}
    }
    
    public void releaseFreeGameInviteCode(String code, ICache cache) {
    	String key = FREE_GAME_INVITE_CODE_PREFIX + code;
    	cache.del(key);
    }
    
    public List<TGame> queryLiveGames(ICache cache) {
        String key = LIVE_GAME_LIST_KEY;
        Map<String, String> map = cache.hgetAll(key);
        
        if(map == null || map.isEmpty()) {
            TGame game = new TGame();
            game.setType(Constants.LIVE_GAME);
            List<TGame> games = gameMapper.select(game);
            for (TGame tg : games) {
                cache.hset(key, tg.getGameId().toString(), JSONObject.toJSONString(tg));
            }
            return games;
        } else {
            List<TGame> result = new ArrayList<TGame>();
            Set<String> keys = map.keySet();
            for (String k : keys) {
                result.add(JSONObject.parseObject(map.get(k), TGame.class));
            }
            return result;
        }
    }

//    public TGame queryLiveGameById(Long id, ICache cache) {
//
//    }
    
    public TGame queryLiveGameByGameId(String gameId, ICache cache) {
    	String key = LIVE_GAME_LIST_KEY;
    	
    	String json = cache.hget(key, gameId);
    	
    	if (StringUtils.isBlank(json)) {
    		queryLiveGames(cache);
    		
    		json = cache.hget(key, gameId);
    		
    		if (StringUtils.isBlank(json)) {
    			return null;
    		} else {
    			return JSON.parseObject(json, TGame.class);
    		}
    	} else {
    		return JSON.parseObject(json, TGame.class);
    	}
    }
    
//    public List<TBaseDetail> queryBackgroundSongs(ICache cache) {
//        List<String> jsonStrs = cache.lgetAll(LIVE_VOICE_KEY);
//        if (CollectionUtils.isEmpty(jsonStrs)) {
//        	List<TBaseDetail> result = baseCacheLoader.loadBaseDetailByType("BACKGROUND_SONG");
//        	return result;
//        } else {
//            List<TBaseDetail> result = new ArrayList<TBaseDetail>();
//            for (String json : jsonStrs) {
//                result.add(JSON.parseObject(json, TBaseDetail.class));
//            }
//            return result;
//        }
//    }
    
//    public List<TBaseDetail> queryTheme(ICache cache) {
//        List<String> jsonStrs = cache.lgetAll(LIVE_THEME_KEY);
//        if (CollectionUtils.isEmpty(jsonStrs)) {
//        	List<TBaseDetail> result = baseCacheLoader.loadBaseDetailByType("THEME");
//        	return result;
//        } else {
//            List<TBaseDetail> result = new ArrayList<TBaseDetail>();
//            for (String json : jsonStrs) {
//                result.add(JSON.parseObject(json, TBaseDetail.class));
//            }
//            return result;
//        }
//    }
    
//    public void updateBackgroundSongs(List<TBaseDetail> games, ICache cache) {
//        for (Object obj : games) {
//            cache.rpush(LIVE_VOICE_KEY, JSON.toJSONString(obj));
//        }
//    }
    
    /**
     * 查询国家的省市区
     * @param country
     * @param cache
     * @return
     */
    public CacheCountry queryCountry(String country, ICache cache) {
        String key = COUNTRY_CODE_KEY + country;
        String result = cache.get(key);
        if(StringUtils.isEmpty(result)) {
            List<TProvince> provinces = baseCacheLoader.loadCountry();
            CacheCountry cacheCountry = new CacheCountry();
            cacheCountry.setCountryCode(country);
            cacheCountry.setProvinces(provinces);
            result = JSONObject.toJSONString(cacheCountry);
            cache.set(key, result);
            return cacheCountry;
        } else {
            CacheCountry cacheCountry = JSONObject.parseObject(result, CacheCountry.class);
            return cacheCountry;
        }
    }
    
    /**
     * 通过code查询基础数据分类
     * @param code
     * @param cache
     * @return
     * @throws Exception
     */
//    public TBaseClassification queryBaseClassificationByCode(String code, ICache cache) throws Exception {
//        String key = BASE_CLASSIFICATION_KEY + code;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            TBaseClassification tc = new TBaseClassification();
//            tc.setCode(code);
//            tc = baseClassificationMapper.selectOne(tc);
//            if(tc != null) {
//                map = BeanMapUtils.toMapBySelective(tc);
//                cache.hmset(key, map);
//            }
//            return tc;
//        } else {
//            TBaseClassification tc = (TBaseClassification) BeanMapUtils.toBeanBySelective(TBaseClassification.class, map);
//            return tc;
//        }
//    }
    
    /**
     * 查询基础数据明细
     * @param detailCode
     * @param cache
     * @return
     */
//    public TBaseDetail queryBaseDetail(Long categoryId, String detailCode, ICache cache) {
//        String key = BASE_DETAIL_KEY + categoryId;
//        String detailString = cache.hget(key, detailCode);
//        if(StringUtils.isEmpty(detailString)) {
//            Map<String, String> map = new HashMap<String, String>();
//            TBaseDetail td = new TBaseDetail();
//            td.setCategoryId(categoryId);
//            List<TBaseDetail> details = baseDetailMapper.select(td);
//            for(TBaseDetail detail : details) {
//                if(detail.getCode().equalsIgnoreCase(detailCode)) {
//                    td = detail;
//                }
//                map.put(detail.getCode(), JSONObject.toJSONString(detail));
//            }
//            cache.hmset(key, map);
//            return td;
//        } else {
//            TBaseDetail td = JSONObject.parseObject(detailString, TBaseDetail.class);
//            return td;
//        }
//    }
    
    /**
     * 查询道具
     * @param cache
     * @return
     */
    public List<TGoods> queryGoodsByType(String type, ICache cache) {
    	String key = ITEM_KEY + type;
        Map<String, String> goodsMap = cache.hgetAll(key);
        if(MapUtils.isEmpty(goodsMap)) {
            List<TGoods> list = null;
            list = goodsMapper.findGoodsByCategoryType(type);
            if (CollectionUtils.isNotEmpty(list)) {
            	for (TGoods gs : list) {
            		cache.hset(key, gs.getGoodsId().toString(), JSONObject.toJSONString(gs));
				}
            }
            return list;
        } else {
            List<TGoods> list = new ArrayList<TGoods>();
            Set<String> keys = goodsMap.keySet();
            for (String k : keys) {
                list.add(JSONObject.parseObject(goodsMap.get(k), TGoods.class));
            }
            return list;
        }
    }

    /**
     * 查询道具
     * @param cache
     * @return
     */
    public List<ImsGoods> queryImsGoodsByType(String type,String status, ICache cache) {
        String key = ITEM_KEY+type;
        Map<String, String> goodsMap = cache.hgetAll(key);
        if(MapUtils.isEmpty(goodsMap)) {
            List<ImsGoods> list = null;
            list = goodsMapper.findImsGoodsByCategoryType(type,status);
            if (CollectionUtils.isNotEmpty(list)) {
                for (ImsGoods gs : list) {
                    cache.hset(key, gs.getGoodsId().toString(), JSONObject.toJSONString(gs));
                }
            }
            return list;
        } else {
            List<ImsGoods> list = new ArrayList<ImsGoods>();
            Set<String> keys = goodsMap.keySet();
            for (String k : keys) {
                list.add(JSONObject.parseObject(goodsMap.get(k), ImsGoods.class));
            }
            return list;
        }
    }
    
    /**
     * 查询游戏房间列表
     * @param cache
     * @return
     */
//    public List<TChipSelect> queryChip(ICache cache) {
//        String key = GAME_LIST_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if(map == null || map.isEmpty()) {
//            List<TChipSelect> games = chipSelectMapper.select(new TChipSelect());
//            for (TChipSelect tg : games) {
//                cache.hset(key, tg.getChipId().toString(), JSONObject.toJSONString(tg));
//            }
//            return games;
//        } else {
//            List<TChipSelect> result = new ArrayList<TChipSelect>();
//            Set<String> keys = map.keySet();
//            for (String k : keys) {
//                result.add(JSONObject.parseObject(map.get(k), TChipSelect.class));
//            }
//            return result;
//            
//        }
//    }
    
    /**
     * 查询快速比赛分场
     * @param cache
     * @return
     */
//    public List<TQuickGame> queryQuickGame(Long gameId, ICache cache) {
//        List<TQuickGame> quickGames = null;
//        String key = QUICK_GAME_LIST_KEY_PREFIX + gameId;
//        Map<String, String> map = cache.hgetAll(key);
//        if (MapUtils.isNotEmpty(map)) {
//            quickGames = new ArrayList<TQuickGame>();
//            for (String k : map.keySet()) {
//                quickGames.add(JSONObject.parseObject(map.get(k), TQuickGame.class));
//            }
//        } else {
//            quickGames = quickGameMapper.queryValidQuickGamesByGameId(gameId);
//            if (CollectionUtils.isNotEmpty(quickGames)) {
//                for (TQuickGame tg : quickGames) {
//                    cache.hset(key, tg.getId().toString(), JSONObject.toJSONString(tg));
//                }
//            }
//        }
//        return quickGames;
//    }
    
    public TGroupGame queryGroupGameByGameIdAndLevel(Long gameId, int level, ICache cache) {
    	String key = GROUP_GAME_LIST_KEY_PREFIX + gameId;
    	String json = cache.hget(key, level + "");
    	
    	if (json != null) {
    		return JSON.parseObject(json, TGroupGame.class);
    	} else {
    		queryGroupGame(gameId, cache);
    		
    		json = cache.hget(key, level + "");
    		
    		if (json != null) {
        		return JSON.parseObject(json, TGroupGame.class);
        	} else {
        		return null;
        	}
    	}
    }

    public List<TGroupGame> queryGroupGame(Long gameId, ICache cache) {
        List<TGroupGame> groupGames = null;
        String key = GROUP_GAME_LIST_KEY_PREFIX + gameId;
        Map<String, String> map = cache.hgetAll(key);
        if (MapUtils.isNotEmpty(map)) {
            groupGames = new ArrayList<TGroupGame>();
            for (String k : map.keySet()) {
                groupGames.add(JSONObject.parseObject(map.get(k), TGroupGame.class));
            }
        } else {
            groupGames = groupGameMapper.queryValidGroupGamesByGameId(gameId);
            if (CollectionUtils.isNotEmpty(groupGames)) {
                for (TGroupGame tg : groupGames) {
                    cache.hset(key, tg.getLevel().toString(), JSONObject.toJSONString(tg));
                }
            }
        }
        return groupGames;
    }
    
    /**
     * 查询玩家游戏
     * @param cache
     * @return
     */
    public List<TGame> queryGame(ICache cache) {
        List<TGame> games = null;
        String key = GAME_CATEGORY_LIST_KEY;
        Map<String, String> map = cache.hgetAll(key);
        if(MapUtils.isEmpty(map)) {
            TGame game = new TGame();
            game.setStatus(Constants.NORMAL_STATUS_PUBLISH);
            games = gameMapper.select(game);
            for (TGame tg : games) {
                cache.hset(key, tg.getGameId().toString(), JSONObject.toJSONString(tg));
            }
        } else {
            games = new ArrayList<TGame>();
            Set<String> keys = map.keySet();
            for (String k : keys) {
                games.add(JSONObject.parseObject(map.get(k), TGame.class));
            }
        }
        Iterator<TGame> iterator = games.iterator();
        while (iterator.hasNext()) {
            TGame g = iterator.next();
            if (g.getCode().equals("top11")) { //过滤一元夺宝
                iterator.remove();
            }
        }
        return games;
    }
    
    public TGame queryGameById(Long gameId, ICache cache) {
        String key = GAME_CATEGORY_LIST_KEY;
        String str = cache.hget(key, gameId.toString());
        if (StringUtils.isNotBlank(str)) {
            return JSON.parseObject(str, TGame.class);
        } else {
            queryGame(cache);
            str = cache.hget(key, gameId.toString());
            if (StringUtils.isNotBlank(str)) {
                return JSON.parseObject(str, TGame.class);
            }
        }
        return null;
    }

    public String queryGameNameById(Long gameId, ICache cache) {
        TGame game = queryGameById(gameId, cache);
        if (!StringUtil.isEmpty(game) ) {
            return game.getName();
        }
        return "";
    }
    
    public String queryConfig(String field, ICache cache) throws Exception {
        String key = CONFIG_KEY;
        Map<String, String> map = cache.hgetAll(key);
        if(map == null || map.isEmpty()) {
            List<TConfig> list = baseCacheLoader.queryConfig();
            String value = null;
            for(TConfig c : list) {
                if (c.getK() != null && c.getV() != null) {
                    cache.hset(key, c.getK(), c.getV());
                    if(c.getK().equalsIgnoreCase(field)) {
                        value = c.getV();
                    }
                }
            }
            return value;
        } else {
            return map.get(field);
        }
    }

    public Integer getIntegerConfig(String field, ICache cache) throws Exception{
        String value = queryConfig(field, cache);
        if (StringUtils.isBlank(value)) {
            return 0;
        }
        return Integer.parseInt(value);
    }

    public Double getDoubleConfig(String field, ICache cache) throws Exception{
        String value = queryConfig(field, cache);
        if (StringUtils.isBlank(value)) {
            return 0.0;
        }
        return Double.parseDouble(value);
    }
    
    public void updateConfig(String field, String value, ICache cache) throws Exception {
        String key = CONFIG_KEY;
        Map<String, String> map = cache.hgetAll(key);
        if(MapUtils.isNotEmpty(map)) {
            cache.hset(key, field, value);
        } else {
            List<TConfig> list = baseCacheLoader.queryConfig();
            for(TConfig c : list) {
                cache.hset(key, c.getK(), c.getV());
            }
        }
    }
    
    /**
     * 查询玩家平台等级
     * @param cache
     * @return
     */
//    public List<TPlatformLevel> queryPlatformLevel(ICache cache) {
//        String key = PLATFORM_LEVEL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TPlatformLevel> list = baseCacheLoader.loadPlatformLevel();
//            for (TPlatformLevel p : list) {
//                cache.hset(key, p.getLevel().toString(), JSONObject.toJSONString(p));
//            }
//            return list;
//        } else {
//            List<TPlatformLevel> result = new ArrayList<TPlatformLevel>();
//            Set<String> keys = map.keySet();
//            for (String k : keys) {
//                result.add(JSONObject.parseObject(map.get(k), TPlatformLevel.class));
//            }
//            return result;
//        }
//    }
    
    /**
     * 根据平台等级查询平台等级实体类
     * @param level
     * @param cache
     * @return
     */
//    public TPlatformLevel queryPlatformLevelByLevel(Integer level, ICache cache) {
//        List<TPlatformLevel> list = queryPlatformLevel(cache);
//        for (TPlatformLevel p : list) {
//            if(p.getLevel() == level) {
//                return p;
//            }
//        }
//        return null;
//    }
    
    /**
     * 查看主播等级
     * @return
     */
//    public List<TCompereLevel> queryCompereLevel(ICache cache) {
//        String key = COMPERE_LEVEL_KEY;
//        Map<String, String> map = cache.hgetAll(key);
//        if (map == null || map.isEmpty()) {
//            List<TCompereLevel> list = baseCacheLoader.loadCompereLevel();
//            for (TCompereLevel p : list) {
//                cache.hset(key, p.getLevel().toString(), JSONObject.toJSONString(p));
//            }
//            return list;
//        } else {
//            List<TCompereLevel> result = new ArrayList<TCompereLevel>();
//            Set<String> keys = map.keySet();
//            for (String k : keys) {
//                result.add(JSONObject.parseObject(map.get(k), TCompereLevel.class));
//            }
//            return result;
//        }
//    }
    
    /**
     * 根据平台等级查询平台等级实体类
     * @param level
     * @param cache
     * @return
     */
//    public TCompereLevel queryCompereLevelByLevel(Integer level, ICache cache) {
//        List<TCompereLevel> list = queryCompereLevel(cache);
//        for (TCompereLevel p : list) {
//            if(p.getLevel() == level) {
//                return p;
//            }
//        }
//        return null;
//    }
    
    /**
     * 根据分成获取普通分成策略
     * @param source
     * @param cache
     * @return
     */
//    public CacheExtractStrategyProfile queryBaseExtractStrategiesBySource(String source, ICache cache) {
//    	CacheExtractStrategyProfile extractStrategy = null;
//    	String key = BASE_EXTRACT_STRATEGY_KEY;
//    	Map<String, String> map = cache.hgetAll(key);
//    	if (MapUtils.isNotEmpty(map)) {
//    	    if (map.containsKey(source)) {
//    	        extractStrategy = JSONObject.parseObject(map.get(source), CacheExtractStrategyProfile.class);
//    	    }
//    	} else {
//    		List<CacheExtractStrategyProfile> extractStrategies = baseCacheLoader.loadBaseExtractStrategies();
//    		if (CollectionUtils.isNotEmpty(extractStrategies)) {
//    			for (CacheExtractStrategyProfile es : extractStrategies) {
//    			    if (es.getSource().equals(source)) {
//    			        extractStrategy = es;
//    			    }
//    				cache.hset(key, es.getSource(), JSON.toJSONString(es));
//    			}
//    		}
//    	}
//    	return extractStrategy;
//    }
    
    /**
     * 获取今天的个性化分成策略
     * @param source
     * @param managerId
     * @param cache
     * @return
     */
//    public CacheExtractStrategyProfile queryTodayIndividuationExtractStrategiesByManagerId(String source, Long managerId, Date nowDate, ICache cache) throws Exception {
//        CacheExtractStrategyProfile extractStrategy = null;
//        List<CacheExtractStrategyProfile> extractStrategies = queryIndividuationExtractStrategiesByManagerId(source, managerId, cache);
//        if (CollectionUtils.isNotEmpty(extractStrategies)) {
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            nowDate = sdf.parse(sdf.format(nowDate));
//            for (CacheExtractStrategyProfile cesp : extractStrategies) {
//                if(nowDate.compareTo(cesp.getStartDate()) >= 0 && nowDate.compareTo(cesp.getEndDate()) <= 0) {
//                    extractStrategy = cesp;
//                    break;
//                }
//            }
//        }
//        return extractStrategy;
//    }
    
    /**
     * 根据经理查询个性化分成策略
     * @param source
     * @param managerId
     * @param cache
     * @return
     * @throws Exception 
     */
//    public List<CacheExtractStrategyProfile> queryIndividuationExtractStrategiesByManagerId(String source, Long managerId, ICache cache) throws Exception {
//        List<CacheExtractStrategyProfile> extractStrategies = null;
//        String key = INDIVIDUATION_EXTRACT_STRATEGY_KEY_PREFIX + source + managerId;
//        List<String> list = cache.lgetAll(key);
//        if (CollectionUtils.isNotEmpty(list)) {
//            extractStrategies = new ArrayList<CacheExtractStrategyProfile>();
//            for (String l : list) {
//                extractStrategies.add(JSONObject.parseObject(l, CacheExtractStrategyProfile.class));
//            }
//        } else {
//            extractStrategies = baseCacheLoader.loadIndividuationExtractStrategiesByManagerId(source, managerId);
//            if (CollectionUtils.isNotEmpty(extractStrategies)) {
//                CacheExtractStrategyProfile baseExtractStrategy = queryBaseExtractStrategiesBySource(source, cache);
//                if (baseExtractStrategy != null) {
//                    String[] strs = new String[extractStrategies.size()];
//                    for (int i = 0; i < extractStrategies.size(); i++) {
//                        CacheExtractStrategyProfile temp = extractStrategies.get(i);
//                        temp.setPlatformPercentage(baseExtractStrategy.getPlatformPercentage());
//                        temp.setPlatformCurrency(baseExtractStrategy.getPlatformCurrency());
//                        temp.setOperatorPercentage(baseExtractStrategy.getOperatorPercentage());
//                        temp.setOperatorCurrency(baseExtractStrategy.getOperatorCurrency());
//                        temp.setPrimaryAgentCurrency(baseExtractStrategy.getPrimaryAgentCurrency());
//                        temp.setSecondaryAgentCurrency(baseExtractStrategy.getSecondaryAgentCurrency());
//                        temp.setThirdlyAgentCurrency(baseExtractStrategy.getThirdlyAgentCurrency());
//                        temp.setComperePercentage(baseExtractStrategy.getComperePercentage());
//                        temp.setCompereCurrency(baseExtractStrategy.getCompereCurrency());
//                        temp.setSupplierPercentage(baseExtractStrategy.getSupplierPercentage());
//                        temp.setSupplierCurrency(baseExtractStrategy.getSupplierCurrency());
//                        temp.setUserPercentage(baseExtractStrategy.getUserPercentage());
//                        temp.setUserCurrency(baseExtractStrategy.getUserCurrency());
//                        strs[i] = JSON.toJSONString(temp);
//                    }
//                    cache.rpush(key, strs);
//                } else {
//                    throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "没有相关的普通分成策略");
//                }
//            }
//        }
//        return extractStrategies;
//    }
    
    /**
     * 根据平台，获取最新版本号
     * @param applicationType
     * @param cache
     * @return
     */
    public TVersion queryNewestApplicationVersionByApplicationType(String applicationType, ICache cache) throws IllegalAccessException, IntrospectionException, InvocationTargetException {
        TVersion version = null;
        String key = APPLICATION_VERSION_KEY;
        Map<String, String> map = cache.hgetAll(key);
        if (MapUtils.isNotEmpty(map)) {
            if (map.containsKey(applicationType)) {
                version = JSONObject.parseObject(map.get(applicationType), TVersion.class);
            }
        } else {
            Map<String, TVersion> versionMaps = baseCacheLoader.loadNewestApplicationVersions();
            if (MapUtils.isNotEmpty(versionMaps)) {
                if (versionMaps.containsKey(applicationType)) {
                    version = versionMaps.get(applicationType);
                }
                Set<String> keys = versionMaps.keySet();
                for (String k : keys) {
                    cache.hset(key, k, JSON.toJSONString(versionMaps.get(k)));
                }
            }
        }
        //查询是否开启夺宝
        TGame treasure = queryGameById(6L, cache);
        boolean isTreasureEnabled = false;
        if (treasure != null && treasure.getStatus().equals(Constants.NORMAL_STATUS_PUBLISH) ) {
            isTreasureEnabled = true;
        }
        version.setIsTreasureEnabled(isTreasureEnabled);
        return version;
    }

//    public List<TDataVersion> queryDataVersions(ICache cache) {
//        String key = BASE_DATA_VERSION_KEY;
//        List<TDataVersion> versions = new ArrayList<TDataVersion>();
//        if (cache.exist(key)) {
//            Map<String, String> map = cache.hgetAll(key);
//            Set<String> keys = map.keySet();
//            for (String k : keys) {
//                String str = map.get(k);
//                versions.add(JSON.parseObject(str, TDataVersion.class));
//            }
//        } else {
//            versions = baseCacheLoader.queryDataVersions();
//            for (TDataVersion v : versions) {
//                cache.hset(key, v.getType(), JSON.toJSONString(v));
//            }
//        }
//        return versions;
//    }

//    public TDataVersion queryDataVersion(String type, ICache cache) {
//        String key = BASE_DATA_VERSION_KEY;
//        String str = cache.hget(key, type);
//        if (StringUtils.isNotBlank(str)) {
//            return JSON.parseObject(str, TDataVersion.class);
//        } else {
//            queryDataVersions(cache);
//            str = cache.hget(key, type);
//            if (StringUtils.isNotBlank(str)) {
//                return JSON.parseObject(str, TDataVersion.class);
//            }
//        }
//        return null;
//    }
    
    public TVersion queryNewestGameHallVersion(ICache cache) {
        TVersion version = null;
        String key = GAME_HALL_VERSION_KEY;
        String str = cache.get(key);
        if (StringUtils.isNotBlank(str)) {
            version = JSONObject.parseObject(str, TVersion.class);
        } else {
            version = baseCacheLoader.loadNewestGameHallVersions();
            cache.set(key, JSON.toJSONString(version));
        }
        return version;
    }
    
    public TVersion queryNewestGameVersionByGameId(Long gameId, ICache cache) {
        TVersion version = null;
        String key = GAME_VERSION_KEY + gameId;
        String str = cache.get(key);
        if (StringUtils.isNotEmpty(str)) {
            version = JSONObject.parseObject(str, TVersion.class);
        } else {
            version = baseCacheLoader.loadNewestGameVersionByGameId(gameId);
            cache.set(key, JSON.toJSONString(version));
        }
        return version;
    }
    
    public List<TAnnouncement> queryAnnouncementsByType(String type, ICache cache) {
        List<TAnnouncement> announcements = null;
        String key = ANNOUNCEMENT_KEY_PREFIX + type;
        List<String> list = cache.lgetAll(key);
        if (CollectionUtils.isNotEmpty(list)) {
            announcements = new ArrayList<TAnnouncement>();
            for (String l : list) {
                announcements.add(JSONObject.parseObject(l, TAnnouncement.class));
            }
        } else {
            announcements = baseCacheLoader.loadAnnouncementsByType(type);
            if (CollectionUtils.isNotEmpty(announcements)) {
                list = new ArrayList<String>();
                for (TAnnouncement announcement : announcements) {
                    list.add(JSON.toJSONString(announcement));
                }
                cache.rpush(key, list);
            }
        }
        return announcements;
    }

//    public List<TRoomRedPacket> queryRedPacketLevels(ICache cache) {
//        String key = RED_PACKET_KEY;
//        List<TRoomRedPacket> list = new ArrayList<TRoomRedPacket>();
//        if (cache.exist(key)) {
//            List<String> strs = cache.lgetAll(key);
//            for (String s : strs) {
//                TRoomRedPacket r = JSON.parseObject(s, TRoomRedPacket.class);
//                list.add(r);
//            }
//        } else {
//            list = baseCacheLoader.queryRedPacketLevels();
//            for (TRoomRedPacket r : list) {
//                cache.rpush(key, JSON.toJSONString(r));
//            }
//        }
//        return list;
//    }

//    public Integer queryRedPacketValueByLevel(Integer level, ICache cache) {
//        List<TRoomRedPacket> list = queryRedPacketLevels(cache);
//        for (TRoomRedPacket r : list) {
//            if (r.getLevel().equals(level)) {
//                return r.getValue();
//            }
//        }
//        return null;
//    }

//    public Integer queryRedPacketMaxLevel(ICache cache) {
//        List<TRoomRedPacket> list = queryRedPacketLevels(cache);
//        return list.get(list.size() - 1).getLevel();
//    }
//
//    public List<TAllowance> queryAllowanceList(Integer cardType, ICache cache) {
//        String key = ALLOWANCE_KEY + cardType;
//        List<TAllowance> result = new ArrayList<TAllowance>();
//        if (cache.exist(key)) {
//            List<String> strs = cache.lgetAll(key);
//            for (String s : strs) {
//                result.add(JSON.parseObject(s, TAllowance.class));
//            }
//        } else {
//            result = baseCacheLoader.queryAllowanceList(cardType);
//            for (TAllowance t : result) {
//                cache.rpush(key, JSON.toJSONString(t));
//            }
//        }
//        return result;
//    }
//
//    public TAllowance queryAllowanceByLevel(Integer level, Integer cardType, ICache cache) {
//        List<TAllowance> list = queryAllowanceList(cardType, cache);
//        for (TAllowance t : list) {
//            if (t.getLevel().equals(level)) {
//                return t;
//            }
//        }
//        return null;
//    }

    public String queryScoreSection(ICache cache) {
        String key = SCORE_SECTION_KEY;
        if (cache.exist(key)) {
            return cache.get(key);
        } else {
            LandlordScoreSection scoreSection = baseCacheLoader.queryScoreSectio();
            cache.set(key, scoreSection.getSectionInfo());
            return scoreSection.getSectionInfo();
        }
    }

    public Integer queryMinCoinsByFenChang(Long gameId, Integer fenChang, ICache cache) {

        String key = FENG_CHANG;
        String hget = cache.hget(key + gameId, fenChang.toString());
        if (StringUtil.isEmpty(hget)) {
            List<TLevelFenChangVo> list = goldMapper.queryFenChangByGameId(Integer.parseInt(gameId.toString()));
            for (TLevelFenChangVo vo : list ) {
                cache.hset(key + gameId, vo.getFenchang().toString(), vo.getMisCoinsGold().toString());
            }
            hget = cache.hget(key + gameId, fenChang.toString());
            if(StringUtil.isEmpty(hget)) {
                return null;
            }else {
                return Integer.parseInt(hget);
            }
        }else {
            return Integer.parseInt(hget);
        }
    }

    public Integer queryPlayerRoomCard(Long userId) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String hget = cache.hget(Constants.PLAYER_ROOM_CARD, userId.toString());
            if (StringUtil.isNotEmpty(hget)) {
                return Integer.parseInt(hget);
            }else {
                TUser tUser = userMapper.selectByPrimaryKey(userId);
                System.out.println(tUser.getCardCount());
                if (null == tUser) {
                    return 0;
                }else {
                    cache.hset(Constants.PLAYER_ROOM_CARD,userId.toString(),tUser.getCardCount().toString());
                }
                return tUser.getCardCount();
            }
        }catch (Exception e ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常!!");
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public void updateRoomCard(Long userId,Integer cardCount) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            int hget = queryPlayerRoomCard(userId);
            if (cardCount < 0 ) {
                if (hget < -cardCount ) {
                    throw new InfServerException(Constants.RETURN_CODE_FAIL,"您的房卡不足");
                }
            }
            cache.hincrby(Constants.PLAYER_ROOM_CARD,userId.toString(),cardCount);
//            userMapper.increaseRoomCard(userId,cardCount);

        }catch (Exception e ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常!!");
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public String queryMyAgent(Integer userId) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String agentId = cache.hget(Constants.PLAYER_ + userId, "agentId");
            if (StringUtil.isEmpty(agentId)) {
                Long agentId1 = userMapper.selectByPrimaryKey(Long.parseLong(userId + "")).getAgentId();
                if (StringUtil.isEmpty(agentId1)) {
                    return null;
                }else {
                    return agentId1+"";
                }
            }
            return agentId;
        }catch (Exception e ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常!!");
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public String queryAgentAdvice(String agentId) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String hget = cache.hget(Constants.MY_AGENT_ADVICE, agentId);
            if (StringUtil.isEmpty(hget)) {
                String advice = userMapper.selectAgentAdvice(agentId);
                if (StringUtil.isNotEmpty(advice)) {
                    cache.hset(Constants.MY_AGENT_ADVICE,agentId,advice);
                }
                return advice;
            }
            return hget;
        }catch (Exception e ) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常!!");
        }finally {
            CacheManager.releaseCache(cache);
        }
    }

    public String queryUserNickName(ICache cache,Integer playerId) {

        String nickName =  cache.hget(Constants.PLAYER_ + playerId ,"nickName");
        if (StringUtil.isEmpty(nickName)) {
            TUser user = userMapper.selectByPrimaryKey(Long.parseLong(playerId+""));
            if (StringUtil.isEmpty(user)) {
                return "";
            }
            return user.getNickName();
        }

        return nickName;
    }

    public String queryUserPhoto(ICache cache,Integer playerId) {

        String nickName =  cache.hget(Constants.PLAYER_ + playerId ,"photoUrl");
        if (StringUtil.isEmpty(nickName)) {
            TUser user = userMapper.selectByPrimaryKey(Long.parseLong(playerId+""));
            if (StringUtil.isEmpty(user)) {
                return "";
            }
            return user.getSmallIcon();
        }

        return nickName;

    }

    public boolean isInGame(Integer player, ICache cache) {

        String status = cache.hget(Constants.USER_GAME_STATUS, player + "");
        if (!StringUtil.isEmpty(status)) {

            String[] statusArr = status.split("_");
            if (statusArr.length >= 2 && Integer.parseInt(statusArr[1]) > 0 ) {
                return true;
//                return false;
            }

        }

        return false;
    }
}
