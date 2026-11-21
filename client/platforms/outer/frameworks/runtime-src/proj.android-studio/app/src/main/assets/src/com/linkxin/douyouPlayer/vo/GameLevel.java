package com.linkxin.douyouPlayer.vo;

import java.util.Comparator;

/**
 * 游戏段位
 * Created by lxy on 2016/4/8.
 */
public class GameLevel implements Comparator<GameLevel>{

    /**
     * gameId : 5
     * gameName : 斗牛
     * gamePhoto : niuniu
     * level : 1
     * levelName : 无分
     * levelTotalCount : 0
     * levelWinCount : 0
     * loseCount : 0
     * rankingPoints : 0
     * rankingPointsTotal : 30
     * tieCount : 0
     * userid : 207
     * winCount : 0
     */

    private long gameId;
    private String gameName;
    private String gamePhoto;
    private int level;
    private String levelName;
    private int levelTotalCount;
    private int levelWinCount;
    private int loseCount;
    private int rankingPoints;
    private int rankingPointsTotal;
    private int tieCount;
    private String userid;
    private int winCount;

    public long getGameId() {
        return gameId;
    }

    public void setGameId(long gameId) {
        this.gameId = gameId;
    }

    public String getGameName() {
        return gameName;
    }

    public void setGameName(String gameName) {
        this.gameName = gameName;
    }

    public String getGamePhoto() {
        return gamePhoto;
    }

    public void setGamePhoto(String gamePhoto) {
        this.gamePhoto = gamePhoto;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getLevelName() {
        return levelName;
    }

    public void setLevelName(String levelName) {
        this.levelName = levelName;
    }

    public int getLevelTotalCount() {
        return levelTotalCount;
    }

    public void setLevelTotalCount(int levelTotalCount) {
        this.levelTotalCount = levelTotalCount;
    }

    public int getLevelWinCount() {
        return levelWinCount;
    }

    public void setLevelWinCount(int levelWinCount) {
        this.levelWinCount = levelWinCount;
    }

    public int getLoseCount() {
        return loseCount;
    }

    public void setLoseCount(int loseCount) {
        this.loseCount = loseCount;
    }

    public int getRankingPoints() {
        return rankingPoints;
    }

    public void setRankingPoints(int rankingPoints) {
        this.rankingPoints = rankingPoints;
    }

    public int getRankingPointsTotal() {
        return rankingPointsTotal;
    }

    public void setRankingPointsTotal(int rankingPointsTotal) {
        this.rankingPointsTotal = rankingPointsTotal;
    }

    public int getTieCount() {
        return tieCount;
    }

    public void setTieCount(int tieCount) {
        this.tieCount = tieCount;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public int getWinCount() {
        return winCount;
    }

    public void setWinCount(int winCount) {
        this.winCount = winCount;
    }

    /**
     * 根据游戏级别排序
     *
     * 升序排序
     *
     * @param lhs
     * @param rhs
     * @return
     */
    @Override
    public int compare(GameLevel lhs, GameLevel rhs) {
        int lLevel = lhs.level;
        int rLevel = rhs.level;

        if (lLevel > rLevel){
            return -1;
        }else if (lLevel < rLevel){
            return 1;
        }
        return 0;
    }
}
