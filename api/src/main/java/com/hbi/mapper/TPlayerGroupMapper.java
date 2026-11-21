package com.hbi.mapper;

import com.hbi.model.TPlayerGroup;
import com.hbi.vo.response.hehuoren.PlayerGroupHhrListVo;
import org.apache.ibatis.annotations.Param;
import com.core.mapper.EntityMapper;

import java.util.List;

/**
 * Created by muzi on 2017/12/7.
 */
public interface TPlayerGroupMapper extends EntityMapper<TPlayerGroup> {
    TPlayerGroup selectByPlayerIdAndGroupId(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId);

    List<TPlayerGroup> selectByPlayerId(@Param("playerId") Integer playerId);

    List<TPlayerGroup> selectByGroupId(
            @Param("groupId") Integer groupId,
            @Param("startTime") String startTime,
            @Param("endTime") String endTime,
            @Param("playerType") Integer playerType,
            @Param("upPlayerId") Integer upPlayerId);

    void deleteByPlayerIdAndGroupId(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId);

    void deleteByGroupId(@Param("groupId") Integer groupId);

    Integer updatePoingCount(@Param("groupId")Integer groupId,
                          @Param("playerId") Integer playerId,
                          @Param("coins") Integer coins);

    /**
     * 根据群组ID、玩家ID获取玩家类型
     */
    Integer getPlayTypeByGroupIdAndPlayerId(
            @Param("groupId") Integer groupId,
            @Param("playerId") Integer playerId);

    /**
     * 根据群组ID、玩家ID判断玩家有没有在这个群组
     */
    Integer countByGroupIdAndPlayerId(
            @Param("groupId") Integer groupId,
            @Param("playerId") Integer playerId);

    /**
     * 添加玩家到群组
     */
    void add(@Param("vo") TPlayerGroup vo);

    /**
     * 设置玩家类型
     */
    void setPlayerType(
            @Param("groupId") Integer groupId,
            @Param("playerId") Integer playerId,
            @Param("playerType") Integer playerType,
            @Param("bonus") Double bonus,
            @Param("inviteCode") String inviteCode);

    /**
     * 获取合伙人列表信息
     */
    @Deprecated
    List<PlayerGroupHhrListVo> getPlayerGroupList(
            @Param("groupId") Integer groupId,
            @Param("playerType") Integer playerType,
            @Param("dateStr") String dateStr);

    /**
     * 设置分红
     */
    void setBonus(
            @Param("groupId") Integer groupId,
            @Param("playerId1") Integer playerId1,
            @Param("playerId2") Integer playerId2,
            @Param("bonus") Double bonus);

    /**
     * 根据群组ID、玩家ID获得群成员信息
     */
    TPlayerGroup getPlayerGroupByGroupIdAndPlayerId(
            @Param("groupId") Integer groupId,
            @Param("playerId") Integer playerId);

    void updateJifenInfo(@Param("xiaohaoCount") int xiaohaoCount, @Param("dayingjiaCount") int dayingjiaCount, @Param("groupId") Integer groupId, @Param("playerId") Integer playerId);

    List<TPlayerGroup> selectMySonList(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("roleType") Integer roleType,
                                       @Param("startIndex") Integer startIndex, @Param("pageSize") Integer pageSize);

    List<TPlayerGroup> selectMySonListByOne(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("roleType") Integer roleType,
                                       @Param("startIndex") Integer startIndex, @Param("pageSize") Integer pageSize,@Param("searchId") Integer searchId);

    Integer selectMySonListCount(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("roleType") Integer roleType,@Param("searchId") Integer searchId);

    int updateTixianCount(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("tixianCount") Integer tixianCount);

    void updateUpPlayerId(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("owerId") Integer owerId);

    void updateMyUpPlayerId(@Param("groupId") Integer groupId, @Param("myUid") Integer myUid, @Param("myUpUid") Integer myUpUid);

    int updatePoint2Repository(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("savePoint") Integer savePoint);

    void updateYesterday20();

    void updateToday2Yesterday();

    void updateToday20();

    List<TPlayerGroup> getClubPointRanking(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("startIndex") Integer startIndex, @Param("pageSize") Integer pageSize);

    Integer getClubPointRankingCount(@Param("groupId") Integer groupId,@Param("playerId") Integer playerId);

    Integer updateDayingjiaCount(@Param("dayingjiaCount") Integer dayingjiaCount, @Param("plaeyrId") Integer plaeyrId, @Param("groupId") Integer groupId);

    Integer updateplayCountToday(@Param("playCount") Integer playCount, @Param("plaeyrId") Integer plaeyrId, @Param("groupId") Integer groupId);

    List<TPlayerGroup> selectAll();

    void updateTeamPlayCount(@Param("groupId") Integer groupId, @Param("playerId") Integer playerId, @Param("teamPlayerCount") Integer teamPlayerCount);

    void updateIDCard(@Param("playerId") Integer playerId, @Param("groupId") Integer groupId, @Param("wechat") String wechat, @Param("qq") String qq, @Param("xianliao") String xianliao, @Param("inviteIcon") String inviteIcon);

    void updateClubPoingCount(@Param("clubId") String clubId, @Param("uid") String uid, @Param("point") String point);

    void updateRepositoryPoint(@Param("groupId") Integer groupId, @Param("ownerId") Integer ownerId, @Param("point") Integer point);

    List<TPlayerGroup> selctAllList(@Param("groupId") Integer groupId);

    List<TPlayerGroup> selectClubRepositoryPoint(@Param("groupId") Integer groupId);
}
