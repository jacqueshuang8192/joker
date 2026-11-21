package com.hbi.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;

@Table("t_group_zhanji")
public class TGroupZhanji {
    @Id(keyType = KeyType.Auto)
    private Integer id;

    @Column("group_id")
    private Integer groupId;

    @Column("player_id")
    private Integer playerId;

    @Column("activity_id")
    private Integer activityId;

    @Column("invite_code")
    private Integer inviteCode;

    @Column("create_time")
    private Date createTime;

    @Column("is_dayingjia")
    private Integer isDayingjia;

    @Column("dayingjia_points")
    private Integer dayingjiaPoints;

    @Column("play_point_count")
    private Integer playPointCount;

    @Column("round")
    private Integer round;

    @Column("level")
    private Integer level;

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getRound() {
        return round;
    }

    public void setRound(Integer round) {
        this.round = round;
    }

    /**
     * @return id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param id
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * @return group_id
     */
    public Integer getGroupId() {
        return groupId;
    }

    /**
     * @param groupId
     */
    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    /**
     * @return player_id
     */
    public Integer getPlayerId() {
        return playerId;
    }

    /**
     * @param playerId
     */
    public void setPlayerId(Integer playerId) {
        this.playerId = playerId;
    }

    /**
     * @return activity_id
     */
    public Integer getActivityId() {
        return activityId;
    }

    /**
     * @param activityId
     */
    public void setActivityId(Integer activityId) {
        this.activityId = activityId;
    }

    /**
     * @return invite_code
     */
    public Integer getInviteCode() {
        return inviteCode;
    }

    /**
     * @param inviteCode
     */
    public void setInviteCode(Integer inviteCode) {
        this.inviteCode = inviteCode;
    }

    /**
     * @return create_time
     */
    public Date getCreateTime() {
        return createTime;
    }

    /**
     * @param createTime
     */
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    /**
     * @return is_dayingjia
     */
    public Integer getIsDayingjia() {
        return isDayingjia;
    }

    /**
     * @param isDayingjia
     */
    public void setIsDayingjia(Integer isDayingjia) {
        this.isDayingjia = isDayingjia;
    }

    /**
     * @return dayingjia_points
     */
    public Integer getDayingjiaPoints() {
        return dayingjiaPoints;
    }

    /**
     * @param dayingjiaPoints
     */
    public void setDayingjiaPoints(Integer dayingjiaPoints) {
        this.dayingjiaPoints = dayingjiaPoints;
    }

    /**
     * @return play_point_count
     */
    public Integer getPlayPointCount() {
        return playPointCount;
    }

    /**
     * @param playPointCount
     */
    public void setPlayPointCount(Integer playPointCount) {
        this.playPointCount = playPointCount;
    }
}