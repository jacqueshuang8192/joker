package com.hbi.mapper;

import com.hbi.model.TGroupPlayer;
import com.hbi.model.TPlayerGroup;
import com.hbi.vo.request.common.GameResultVo;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

/**
 * Created by muzi on 2017/12/7.
 */
public interface TGroupPlayerMapper extends EntityMapper<TGroupPlayer> {
    public int insertGroup(TGroupPlayer tgp);

    Long queryGroupOwerId(@Param("groupId")Integer groupId);

    void updateComConfig(@Param("groupId") Integer groupId,
                         @Param("cost_pattern") Integer cost_pattern,
                         @Param("commission") Double commission,
                         @Param("cost_user_type") Integer cost_user_type,
                         @Param("costLimit") Double costLimit,
                         @Param("strengthLimit") Integer strengthLimit);

    void updatePlayCoins(@Param("groupId") Integer groupId,
                         @Param("coins") Integer coins);

    void updatCostUserType(@Param("groupId") Integer groupId,
                           @Param("costUserType") Integer costUserType);

    /**
     * 设置抽水
     */
    void setCost(
            @Param("groupId") Integer groupId,
            @Param("playerId") Integer playerId,
            @Param("costPattern") Integer costPattern,
            @Param("commission") Double commission,
            @Param("costUserType") Integer costUserType);

    void updateChoushuiCount(@Param("groupId") Integer groupId, @Param("choushuiCount") int choushuiCount,
                             @Param("shengyuCount")Integer shengyuCount);

    List<GameResultVo> selectGameResultVos(@Param("l")Integer l,
                                           @Param("groupId") Integer groupId,
                                           @Param("playerId") Integer playerId,
                                           @Param("dateStr") String dateStr,
                                           @Param("pageIndex") Integer pageIndex,
                                           @Param("pageSize") Integer pageSize);

    TPlayerGroup selectByInviteCode(@Param("inviteCode") String inviteCode);

    Integer updateCluPointPool(@Param("groupId") Integer groupId, @Param("coins") Integer coins);

    Integer updateCluProfitCount(@Param("groupId") Integer groupId, @Param("profitCount") Integer profitCount, @Param("profitClubCount") Integer profitClubCount,
                                 @Param("pointPool") Integer pointPool);

    void updateClubOwnerId(@Param("groupId") Integer groupId, @Param("assignor") Integer assignor);

    List<TGroupPlayer> selectAllClub();
}
