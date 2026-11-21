package com.hbi.mapper;

import com.hbi.model.TGame;
import com.hbi.vo.request.common.TLevelFenChangVo;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

public interface TGameMapper extends EntityMapper<TGame> {
    TGame selectGameByLevel(@Param("level") Integer level);
    Integer selectIsGold(@Param("gameId") String gameId);
    Integer selectMinGlods(@Param("gameId") String gameId);
    Integer selectMaxGlods(@Param("gameId") String gameId);

    Long getActivityIdByRoomId(@Param("roomId") Long roomId);

    public List<Integer> getLevelByGameId(@Param("gameId") Long gameId);

}