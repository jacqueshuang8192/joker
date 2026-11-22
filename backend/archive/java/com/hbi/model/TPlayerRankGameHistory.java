//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_player_rank_game_history")
//public class TPlayerRankGameHistory {
//    @Column(name = "game_id")
//    private Long gameId;
//
//    @Column(name = "player_id")
//    private Long playerId;
//
//    @Column(name = "activity_id")
//    private Long activityId;
//
//    private Short status;
//
//    private Integer points;
//
//    private Integer minutes;
//
//    private Integer level;
//
//    /**
//     * @return game_id
//     */
//    public Long getGameId() {
//        return gameId;
//    }
//
//    /**
//     * @param gameId
//     */
//    public void setGameId(Long gameId) {
//        this.gameId = gameId;
//    }
//
//    /**
//     * @return player_id
//     */
//    public Long getPlayerId() {
//        return playerId;
//    }
//
//    /**
//     * @param playerId
//     */
//    public void setPlayerId(Long playerId) {
//        this.playerId = playerId;
//    }
//
//    /**
//     * @return activity_id
//     */
//    public Long getActivityId() {
//        return activityId;
//    }
//
//    /**
//     * @param activityId
//     */
//    public void setActivityId(Long activityId) {
//        this.activityId = activityId;
//    }
//
//    /**
//     * @return status
//     */
//    public Short getStatus() {
//        return status;
//    }
//
//    /**
//     * @param status
//     */
//    public void setStatus(Short status) {
//        this.status = status;
//    }
//
//    /**
//     * @return points
//     */
//    public Integer getPoints() {
//        return points;
//    }
//
//    /**
//     * @param points
//     */
//    public void setPoints(Integer points) {
//        this.points = points;
//    }
//
//    /**
//     * @return minutes
//     */
//    public Integer getMinutes() {
//        return minutes;
//    }
//
//    /**
//     * @param minutes
//     */
//    public void setMinutes(Integer minutes) {
//        this.minutes = minutes;
//    }
//
//    public Integer getLevel() {
//        return level;
//    }
//
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//}