package com.j.joker.service.playerGroup;

import com.j.joker.core.util.StringUtil;
import com.j.joker.mapper.TGroupGameconfigMapper;
import com.j.joker.model.TGroupGameconfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.mybatisflex.core.query.QueryWrapper;
import static com.mybatisflex.core.query.QueryMethods.column;

import java.util.List;

@Service
public class TGroupGameconfigService {

    @Autowired
    private TGroupGameconfigMapper gameconfigMapper;

    public TGroupGameconfig addOne(Integer groupId,Integer level,Integer gameType, String name , String config) {

        TGroupGameconfig gameConfig = new TGroupGameconfig();
        gameConfig.setGroupId(groupId);
        gameConfig.setLevel(level);
        gameConfig.setName(name);
        gameConfig.setConfig(config);
        gameConfig.setGameType(gameType);
        gameConfig.setStatus(1);

        int insert = gameconfigMapper.insertSelective(gameConfig);

        return gameConfig;
    }

    public Integer delOne(Integer configId ) {

        int i = gameconfigMapper.removeById(configId);

        return i;

    }

    public Integer updateOne(Integer configId, String name , String config,Integer status) {

        if (!StringUtil.isEmpty(configId)) {

            TGroupGameconfig gameConfig = new TGroupGameconfig();
            gameConfig.setId(configId);
            if (!StringUtil.isEmpty(name) ) {
                gameConfig.setName(name);
            }
            if (!StringUtil.isEmpty(config) ) {
                gameConfig.setConfig(config);
            }
            if (!StringUtil.isEmpty(status) ) {
                gameConfig.setStatus(status);
            }

            return gameconfigMapper.updateSelective(gameConfig);

        }

        return 0;

    }

    public List<TGroupGameconfig> selectAll(Integer groupId,Integer level,Integer gameType ) {

        QueryWrapper query = QueryWrapper.create();
        if (!StringUtil.isEmpty(groupId)) {
            query.and(column(TGroupGameconfig::getGroupId).eq(groupId));
        }
        if (!StringUtil.isEmpty(level)) {
            query.and(column(TGroupGameconfig::getLevel).eq(level));
        }
        if (!StringUtil.isEmpty(gameType) ) {
            query.and(column(TGroupGameconfig::getGameType).eq(gameType));
        }

        List<TGroupGameconfig> tGroupGameconfigs = gameconfigMapper.selectListByQuery(query);

        return tGroupGameconfigs;

    }

    public TGroupGameconfig selectOne(Integer configId) {

       return  gameconfigMapper.findById(configId);

    }


    public Integer selectConfigCountByGameType(String gameType, Integer groupId) {

        return gameconfigMapper.selectConfigCountByGameType(gameType,groupId);

    }
}
