package com.hbi.model;

import java.util.Date;

/**
 * 联盟联盟成员
 * Create by Mars on 2019/5/27 15:17
 */
public class TGroupUnionMember {

    private Integer id;

    // 联盟ID
    private Integer unionId;

    // 玩家ID
    private Integer playerId;

    // 邀请人ID
    private Integer inviterId;

    // 玩家类型（0=>盟主 1=>管理员 2=>合伙人 3=>普通成员）
    private Integer playerType;

    // 原群组ID
    private Integer fromGroupId;

    // 分红比例
    private Double bonus;

    private Date createTime;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUnionId() {
        return unionId;
    }

    public void setUnionId(Integer unionId) {
        this.unionId = unionId;
    }

    public Integer getPlayerId() {
        return playerId;
    }

    public void setPlayerId(Integer playerId) {
        this.playerId = playerId;
    }

    public Integer getInviterId() {
        return inviterId;
    }

    public void setInviterId(Integer inviterId) {
        this.inviterId = inviterId;
    }

    public Integer getPlayerType() {
        return playerType;
    }

    public void setPlayerType(Integer playerType) {
        this.playerType = playerType;
    }

    public Integer getFromGroupId() {
        return fromGroupId;
    }

    public void setFromGroupId(Integer fromGroupId) {
        this.fromGroupId = fromGroupId;
    }

    public Double getBonus() {
        return bonus;
    }

    public void setBonus(Double bonus) {
        this.bonus = bonus;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}
