package com.j.joker.mapper;

import com.j.joker.model.TGame;
import com.j.joker.model.TGameConfig;
import com.j.joker.model.TGameProvince;
import com.j.joker.model.TGameType;
import com.j.joker.model.TGameTypeGame;
import com.j.joker.model.TGameTypeGold;
import com.j.joker.vo.response.user.GameTypeGameVo;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import com.j.joker.core.mapper.EntityMapper;

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