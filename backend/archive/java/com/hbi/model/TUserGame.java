//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_user_game")
//public class TUserGame {
//    @Id
//    private Long userid;
//
//    /**
//     * 游戏ID
//     */
//    @Id
//    @Column(name = "game_id")
//    private Long gameId;
//
//    /**
//     * 胜利总局数
//     */
//    @Column(name = "win_count")
//    private Integer winCount;
//
//    /**
//     * 平总局数
//     */
//    @Column(name = "tie_count")
//    private Integer tieCount;
//
//    /**
//     * 失败总局数
//     */
//    @Column(name = "lose_count")
//    private Integer loseCount;
//
//    /**
//     * 当前级所需总局数
//     */
//    @Column(name = "level_total_count")
//    private Integer levelTotalCount;
//
//    /**
//     * 当前级胜利局数
//     */
//    @Column(name = "level_win_count")
//    private Integer levelWinCount;
//
//    private Integer level;
//
//    @Column(name= "level_name")
//    private String levelName;
//
//    private Integer ranking;
//
//    private String status;
//
//    /**
//     * 段位赛点数
//     */
//    @Column(name = "ranking_points")
//    private Integer rankingPoints;
//
//    /**
//     * 段位赛总点数
//     */
//    @Column(name = "ranking_points_total")
//    private Long rankingPointsTotal;
//
//    /**
//     * 最近参加游戏时间
//     */
//    @Column(name = "last_play_date")
//    private Date lastPlayDate;
//
//    @Transient
//    private String gameName;
//
//    @Transient
//    private String gamePhoto;
//
//    /**
//     * @return userid
//     */
//    public Long getUserid() {
//        return userid;
//    }
//
//    /**
//     * @param userid
//     */
//    public void setUserid(Long userid) {
//        this.userid = userid;
//    }
//
//    /**
//     * @return win_count
//     */
//    public Integer getWinCount() {
//        return winCount;
//    }
//
//    /**
//     * @param winCount
//     */
//    public void setWinCount(Integer winCount) {
//        this.winCount = winCount;
//    }
//
//    /**
//     * @return tie_count
//     */
//    public Integer getTieCount() {
//        return tieCount;
//    }
//
//    /**
//     * @param tieCount
//     */
//    public void setTieCount(Integer tieCount) {
//        this.tieCount = tieCount;
//    }
//
//    /**
//     * @return lose_count
//     */
//    public Integer getLoseCount() {
//        return loseCount;
//    }
//
//    /**
//     * @param loseCount
//     */
//    public void setLoseCount(Integer loseCount) {
//        this.loseCount = loseCount;
//    }
//
//    /**
//     * @return level
//     */
//    public Integer getLevel() {
//        return level;
//    }
//
//    /**
//     * @param level
//     */
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    public String getLevelName() {
//		return levelName;
//	}
//
//	public void setLevelName(String levelName) {
//		this.levelName = levelName;
//	}
//
//	/**
//     * @return ranking
//     */
//    public Integer getRanking() {
//        return ranking;
//    }
//
//    /**
//     * @param ranking
//     */
//    public void setRanking(Integer ranking) {
//        this.ranking = ranking;
//    }
//
//    /**
//     * @return status
//     */
//    public String getStatus() {
//        return status;
//    }
//
//    /**
//     * @param status
//     */
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    /**
//     * @return ranking_points
//     */
//    public Integer getRankingPoints() {
//        return rankingPoints;
//    }
//
//    /**
//     * @param rankingPoints
//     */
//    public void setRankingPoints(Integer rankingPoints) {
//        this.rankingPoints = rankingPoints;
//    }
//
//    /**
//     * @return ranking_points_total
//     */
//    public Long getRankingPointsTotal() {
//        return rankingPointsTotal;
//    }
//
//    /**
//     * @param rankingPointsTotal
//     */
//    public void setRankingPointsTotal(Long rankingPointsTotal) {
//        this.rankingPointsTotal = rankingPointsTotal;
//    }
//
//    /**
//     * @return last_play_date
//     */
//    public Date getLastPlayDate() {
//        return lastPlayDate;
//    }
//
//    /**
//     * @param lastPlayDate
//     */
//    public void setLastPlayDate(Date lastPlayDate) {
//        this.lastPlayDate = lastPlayDate;
//    }
//
//    public Integer getLevelTotalCount() {
//        return levelTotalCount;
//    }
//
//    public void setLevelTotalCount(Integer levelTotalCount) {
//        this.levelTotalCount = levelTotalCount;
//    }
//
//    public Integer getLevelWinCount() {
//        return levelWinCount;
//    }
//
//    public void setLevelWinCount(Integer levelWinCount) {
//        this.levelWinCount = levelWinCount;
//    }
//
//    public Long getGameId() {
//        return gameId;
//    }
//
//    public void setGameId(Long gameId) {
//        this.gameId = gameId;
//    }
//
//    public String getGameName() {
//        return gameName;
//    }
//
//    public void setGameName(String gameName) {
//        this.gameName = gameName;
//    }
//
//    public String getGamePhoto() {
//        return gamePhoto;
//    }
//
//    public void setGamePhoto(String gamePhoto) {
//        this.gamePhoto = gamePhoto;
//    }
//
//}