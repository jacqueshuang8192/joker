package com.hbi.mapper;

import com.hbi.model.TGame;
import com.hbi.model.TGameConfig;
import com.hbi.model.TGameProvince;
import com.hbi.model.TGameType;
import com.hbi.model.TGameTypeGame;
import com.hbi.model.TGameTypeGold;
import com.hbi.vo.response.user.GameTypeGameVo;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

public interface TGameTypeGameMapper extends EntityMapper<TGameTypeGame> {
    
    List<GameTypeGameVo> selectByAgentId(@Param("agentId") Long agentId);
    List<GameTypeGameVo> selectByAgent(@Param("agentId") Long agentId);
    List<TGameType> selectGameTypeByAgentId(@Param("agentId") Long agentId);
    List<TGameTypeGold> selectGameTypeByAgentIdByGold(@Param("agentId") Long agentId);
    List<TGameType> selectGameTypeByAgent(@Param("agentId") Long agentId);
    List<TGameTypeGold> selectGameTypeByAgentByGold(@Param("agentId") Long agentId);
    List<TGameType> selectGameTypeByParentId(@Param("agentId") Long agentId);
    List<TGameTypeGold> selectGameTypeByParentIdByGold(@Param("agentId") Long agentId);


    public List<TGameType> selectGameTypeByRoomTyper(@Param("roomType") Integer roomType);
}