package com.hbi.service.playerGroup;

import com.core.util.StringUtil;
import com.hbi.mapper.TGroupGameconfigMapper;
import com.hbi.model.TGroupGameconfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tk.mybatis.mapper.entity.Example;

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

        int i = gameconfigMapper.deleteByPrimaryKey(configId);

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

            return gameconfigMapper.updateByPrimaryKeySelective(gameConfig);

        }

        return 0;

    }

    public List<TGroupGameconfig> selectAll(Integer groupId,Integer level,Integer gameType ) {

        Example example = new Example(TGroupGameconfig.class);
        Example.Criteria criteria = example.createCriteria();
        if (!StringUtil.isEmpty(groupId)) {
            criteria.andEqualTo("groupId",groupId);
        }
        if (!StringUtil.isEmpty(level)) {
            criteria.andEqualTo("level",level);
        }
        if (!StringUtil.isEmpty(gameType) ) {
            criteria.andEqualTo("gameType",gameType);
        }

        List<TGroupGameconfig> tGroupGameconfigs = gameconfigMapper.selectByExample(example);

        return tGroupGameconfigs;

    }

    public TGroupGameconfig selectOne(Integer configId) {

       return  gameconfigMapper.selectByPrimaryKey(configId);

    }


    public Integer selectConfigCountByGameType(String gameType, Integer groupId) {

        return gameconfigMapper.selectConfigCountByGameType(gameType,groupId);

    }
}
