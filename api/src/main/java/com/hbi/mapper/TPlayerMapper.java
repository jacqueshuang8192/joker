package com.hbi.mapper;

import java.util.List;

import com.hbi.model.TBiqiCardId;
import com.hbi.model.TGiftRoomCard;
import com.hbi.model.TWaiWriOrderHistory;
import org.apache.ibatis.annotations.Param;

import com.hbi.cache.model.CachePlayerProfile;
import com.hbi.cache.model.CachePlayerRelation;
import com.hbi.model.TPlayer;

import com.core.mapper.EntityMapper;

public interface TPlayerMapper extends EntityMapper<TPlayer> {
//    List<TaskVo> getTaksList(
//            @Param("playerId")String playerId);

    CachePlayerProfile queryPlayerDetails(@Param("playerId") Long playerId);

    CachePlayerRelation queryPlayerAllRelation(@Param("playerId") Long playerId);

    int updatePlayerExp(
            @Param("playerId")Long playerId,
            @Param("exp")Integer exp,
            @Param("level")Integer level);

    int updatePlayerAttributes(
            @Param("playerId")Long playerId,
            @Param("attack")Long attack,
            @Param("defense")Long defense,
            @Param("life")Long life);

    List<String> querySubPlayers(@Param("playerId") Long playerId);

    List<TBiqiCardId> queryUseBiqiHistory(@Param("playerId")Long playerId);

    List<TGiftRoomCard> queryPlayerShong(@Param("playerId")Integer playerId,
                                   @Param("beginRowIndex")Integer beginRowIndex,
                                   @Param("pageSize")int pageSize);

    List<TGiftRoomCard> queryPlayerShou(@Param("playerId")Integer playerId,
                                  @Param("beginRowIndex")Integer beginRowIndex,
                                  @Param("pageSize")int pageSize);

    List<TWaiWriOrderHistory> queryPlayerWaiWeiHistory(@Param("playerId")Integer playerId,
                                                       @Param("i")Integer i,
                                                       @Param("beginRowIndex")Integer beginRowIndex,
                                                       @Param("pageSize")int pageSize);

    Integer isAgent(@Param("userId") Integer userId);
}