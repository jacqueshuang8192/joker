package com.hbi.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;

@Table("t_group_xiaohao_history")
public class TGroupXiaohaoHistory {
    @Id(keyType = KeyType.Auto)
    private Integer id;

    @Column("group_id")
    private Integer groupId;

    @Column("hehuoren_id")
    private Integer hehuorenId;

    @Column("player_id")
    private Integer playerId;

    private Integer profit;

    @Column("profit_time")
    private Date profitTime;

    @Column("profit_count")
    private Integer profitCount;

    @Column("game_level")
    private Integer gameLevel;

    @Column("activity_id")
    private Long activityId;

    public void setGameLevel(Integer gameLevel) {
        this.gameLevel = gameLevel;
    }

    public Integer getGameLevel() {
        return gameLevel;
    }

    public Long getActivityId() {
        return activityId;
    }

    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

    @Column(ignore = true)
    private String smallPhoto;

    @Column(ignore = true)
    private String nickName;

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public TGroupXiaohaoHistory() {
    }

    public Integer getProfitCount() {
        return profitCount;
    }

    public void setProfitCount(Integer profitCount) {
        this.profitCount = profitCount;
    }

    public String getSmallPhoto() {
        return smallPhoto;
    }

    public void setSmallPhoto(String smallPhoto) {
        this.smallPhoto = smallPhoto;
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
     * @return hehuoren_id
     */
    public Integer getHehuorenId() {
        return hehuorenId;
    }

    /**
     * @param hehuorenId
     */
    public void setHehuorenId(Integer hehuorenId) {
        this.hehuorenId = hehuorenId;
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
     * @return profit
     */
    public Integer getProfit() {
        return profit;
    }

    /**
     * @param profit
     */
    public void setProfit(Integer profit) {
        this.profit = profit;
    }

    /**
     * @return profit_time
     */
    public Date getProfitTime() {
        return profitTime;
    }

    /**
     * @param profitTime
     */
    public void setProfitTime(Date profitTime) {
        this.profitTime = profitTime;
    }
}