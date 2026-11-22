package com.j.joker.mapper;

import com.j.joker.model.TGame;
import com.j.joker.model.TGameTypeByGold;
import com.j.joker.vo.request.common.MapVo;
import com.j.joker.vo.request.common.TLevelFenChangVo;
import com.j.joker.vo.response.gold.pickUpGoldVo;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;

/**
 * Created by muzi on 16/11/2017.
 */

public interface GoldMapper {
    public Integer getPlayerCountByPlayerBind(@Param("playerId") Long playerId);

    public Integer isAgent(@Param("playerId") Long playerId);

    public void updateAuthIdCard(@Param("playerId") Long playerId,
                                 @Param("name") String name,
                                 @Param("idCardNo") String idCardNo,
                                 @Param("phone") String phone);

    public void complaint2Admin(@Param("playerId") Long playerId,
                                @Param("game") String game,
                                @Param("context") String context,
                                @Param("date") Date date);

    public List<Integer> selectByRoomType(@Param("roomType") String roomType);

    public List<MapVo> queryRoomTypeList();

    public List<TGameTypeByGold> queryByRoomTypeId(@Param("mapKey") String mapKey);

    public List<TGameTypeByGold> queryRoomTypeByParentId(@Param("id") Long id);

    public List<TGame> queryGames(@Param("id") Long id);

    public String getGameConfigByLevel(@Param("level") Integer level);

    public void updateMoneyRepository(@Param("l") long l,
                                          @Param("playerId") Long playerId,
                                          @Param("count") Long count,
                                          @Param("type") Long type);

    public void insertIntoReposity(@Param("playerId") Long playerId,
                                   @Param("count") Long count,
                                   @Param("type") Long type);

    public Long getRepositoryMoney(@Param("l") long l,
                                   @Param("playerId") Long playerId);

    Long queryRepositoryMney(@Param("l") Long l,
                             @Param("userId") Long userId);

    Long queryRoomOwnerIncome(@Param("userId") Long userId);

    public List<pickUpGoldVo> getPickUpGoldList(@Param("playerId") Long playerId,
                                                @Param("beginRowIndex") Integer beginRowIndex,
                                                @Param("pageSize") int pageSize);

    public List<Integer> selectAllPlayerId();

    Integer selectOwerIncomeToday(@Param("playerId") Long playerId);

    public List<pickUpGoldVo> getPlayerCommissionList(@Param("playerId") Long playerId,
                                                      @Param("date") String date);

    int selectPlayerTask(@Param("l") Long l,
                         @Param("playerId") Long playerId);

    public void insertPlayerTask(@Param("l") long l,
                                 @Param("playerId") Long playerI,
                                 @Param("recCount") Integer recCount,
                                 @Param("squence") Integer squence);

    int selectRecCount(@Param("playerId") Long playerId);

    void insertPlayerTask4(@Param("l") long l,
                           @Param("playerId") Long playerId,
                           @Param("i") int i);

    public  List<TLevelFenChangVo> queryFenChangByGameId(@Param("level")Integer level);
}
