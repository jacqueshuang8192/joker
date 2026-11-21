package com.hbi.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;

@Table("t_activity_history")
public class TActivityHistory {
    @Id(keyType = KeyType.Auto)
    private Long id;

    @Column("activity_id")
    private Long activityId;

    @Column("user_id")
    private Long userId;

    @Column("game_id")
    private Long gameId;

    private Integer level;

    private Integer round;

    @Column("card_count")
    private Integer cardCount;

    @Column("user_names")
    private String userNames;

    @Column("start_date")
    private Date startDate;

    @Column("remaining_time")
    private Integer remainingTime;

    /**
     * @return id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param id
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * @return activity_id
     */
    public Long getActivityId() {
        return activityId;
    }

    /**
     * @param activityId
     */
    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

    /**
     * @return user_id
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * @param userId
     */
    public void setUserId(Long userId) {
        this.userId = userId;
    }

    /**
     * @return game_id
     */
    public Long getGameId() {
        return gameId;
    }

    /**
     * @param gameId
     */
    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    /**
     * @return level
     */
    public Integer getLevel() {
        return level;
    }

    /**
     * @param level
     */
    public void setLevel(Integer level) {
        this.level = level;
    }

    /**
     * @return round
     */
    public Integer getRound() {
        return round;
    }

    /**
     * @param round
     */
    public void setRound(Integer round) {
        this.round = round;
    }

    /**
     * @return card_count
     */
    public Integer getCardCount() {
        return cardCount;
    }

    /**
     * @param cardCount
     */
    public void setCardCount(Integer cardCount) {
        this.cardCount = cardCount;
    }

    /**
     * @return user_names
     */
    public String getUserNames() {
        return userNames;
    }

    /**
     * @param userNames
     */
    public void setUserNames(String userNames) {
        this.userNames = userNames;
    }

    /**
     * @return start_date
     */
    public Date getStartDate() {
        return startDate;
    }

    /**
     * @param startDate
     */
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    /**
     * @return remaining_time
     */
    public Integer getRemainingTime() {
        return remainingTime;
    }

    /**
     * @param remainingTime
     */
    public void setRemainingTime(Integer remainingTime) {
        this.remainingTime = remainingTime;
    }
}