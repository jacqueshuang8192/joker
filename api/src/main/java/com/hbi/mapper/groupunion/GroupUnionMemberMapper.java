package com.hbi.mapper.groupunion;

import com.hbi.model.TGroupUnionMember;
import org.apache.ibatis.annotations.Param;

import java.util.Date;

/**
 * Create by Mars on 2019/5/27 15:55
 */
public interface GroupUnionMemberMapper {

    /**
     * 添加联盟联盟成员
     * Create by Mars on 16:23 2019/5/27
     **/
    void add(@Param("vo") TGroupUnionMember vo);

    /**
     * 根据玩家ID、联盟ID查询玩家类型（0=>盟主 1=>管理员 2=>合伙人 3=>普通成员）
     * Create by Mars on 17:11 2019/5/27
     **/
    Integer getPlayerTypeByPlayerIdAndUnionId(
            @Param("playerId") Integer playerId,
            @Param("unionId") Integer unionId);

    /**
     * 设置成员类型
     * Create by Mars on 15:30 2019/5/28
     **/
    void setPlayerType(
            @Param("unionId") Integer unionId,
            @Param("playerId") Integer playerId,
            @Param("playerType") Integer playerType);

    /**
     * 添加群组成员都联盟
     * Create by Mars on 15:38 2019/5/28
     **/
    void addUnoinMember4Group(
            @Param("unionId") Integer unionId,
            @Param("playerId") Integer playerId,
            @Param("groupId") Integer groupId,
            @Param("bonus") Double bonus,
            @Param("now") Date now);
}
