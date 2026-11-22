//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_game_points")
//public class TGamePoints {
//    @Id
//    @Column(name = "game_id")
//    private Long gameId;
//
//    @Column(name = "win_points")
//    private Integer winPoints;
//
//    @Column(name = "tie_points")
//    private Integer tiePoints;
//
//    @Column(name = "lose_points")
//    private Integer losePoints;
//
//    private Integer minutes;
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
//     * @return win_points
//     */
//    public Integer getWinPoints() {
//        return winPoints;
//    }
//
//    /**
//     * @param winPoints
//     */
//    public void setWinPoints(Integer winPoints) {
//        this.winPoints = winPoints;
//    }
//
//    /**
//     * @return tie_points
//     */
//    public Integer getTiePoints() {
//        return tiePoints;
//    }
//
//    /**
//     * @param tiePoints
//     */
//    public void setTiePoints(Integer tiePoints) {
//        this.tiePoints = tiePoints;
//    }
//
//    /**
//     * @return lose_points
//     */
//    public Integer getLosePoints() {
//        return losePoints;
//    }
//
//    /**
//     * @param losePoints
//     */
//    public void setLosePoints(Integer losePoints) {
//        this.losePoints = losePoints;
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
//}