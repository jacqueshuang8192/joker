package com.hbi.model;

import java.util.Date;
import javax.persistence.*;

@Table(name = "t_group_zhanji")
public class TGroupZhanji {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "group_id")
    private Integer groupId;

    @Column(name = "player_id")
    private Integer playerId;

    @Column(name = "activity_id")
    private Integer activityId;

    @Column(name = "invite_code")
    private Integer inviteCode;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "is_dayingjia")
    private Integer isDayingjia;

    @Column(name = "dayingjia_points")
    private Integer dayingjiaPoints;

    @Column(name = "play_point_count")
    private Integer playPointCount;

    @Column(name = "round")
    private Integer round;

    @Column(name = "level")
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