package com.j.joker.cache.cacheWritter;

import com.j.joker.constants.Constants;
import com.j.joker.mapper.TGameConfigMapper;
import com.j.joker.mapper.TGameServerMapper;
import com.j.joker.mapper.TGroupGameMapper;
import com.j.joker.mapper.TMemdataServerMapper;
import com.j.joker.model.TGameConfig;
import com.j.joker.model.TGameServer;
import com.j.joker.model.TGroupGame;
import com.j.joker.model.TMemdataServer;
import com.j.joker.utils.InfServerException;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GameCacheLoader {
//    @Autowired
//    private TGameRiseStrategyMapper strategyMapper;
//    @Autowired
//    private TLevelLifeforceMapper levelLifeforceMapper;
//    @Autowired
//    private TQuickGameMapper quickGameMapper;
//    @Autowired
//    private TGameMatchMapper gameMatchMapper;
//    @Autowired
//    private TCompereGameMapper compereGameMapper;
    @Autowired
    private TGroupGameMapper groupGameMapper;
    @Autowired
    private TGameServerMapper gameServerMapper;
//    @Autowired
//    private TGameMatchAwardMapper gameMatchAwardMapper;
    @Autowired
    private TMemdataServerMapper memdataServerMapper;
    @Autowired
    private TGameConfigMapper gameConfigMapper;

//    public List<TGameRiseStrategy> queryStrategiesByGameId(Long gameId) {
//        TGameRiseStrategy strategy = new TGameRiseStrategy();
//        strategy.setGameId(gameId);
//        return strategyMapper.select(strategy);
//    }
//
//    public List<TLevelLifeforce> queryLifeforces() {
//        return levelLifeforceMapper.select(new TLevelLifeforce());
//    }
//
//    public List<TQuickGame> loadAllQuickGames() {
//        return quickGameMapper.queryAllValidQuickGames();
//    }
    
    public List<TGroupGame> loadAllFreeGames() {
        return groupGameMapper.queryAllValidGroupGames();
    }
    
//    public List<TGameMatch> loadAllGameMatchs() {
//        return gameMatchMapper.queryAllValidGameMatchs();
//    }
//
//    public List<TCompereGame> loadAllCompereGames() {
//        return compereGameMapper.queryAllValidCompereGames();
//    }

    public List<TGameServer> loadGameServerList() {
        return gameServerMapper.select(new TGameServer());
    }

//    public List<TGameMatchAward> loadGameMatchAward(Long gameId, Integer level) {
//        TGameMatchAward award = new TGameMatchAward();
//        award.setGameId(gameId);
//        award.setLevel(level);
//        return gameMatchAwardMapper.select(award);
//    }

    public TMemdataServer loadMemdataServer() {
        return memdataServerMapper.select(new TMemdataServer()).get(0);
    }

    public List<TGameConfig> queryGameConfig() throws Exception {
        List<TGameConfig> list = gameConfigMapper.select(new TGameConfig());
        if (CollectionUtils.isNotEmpty(list)) {
            return list;
        }
        throw new InfServerException(Constants.RETURN_CODE_FAIL, "找不到组局配置");
    }

    public String queryGameConfigByLevel(Integer level) {
        return gameConfigMapper.qureyCountlByLevel(Long.parseLong(level.toString()));
    }
}
