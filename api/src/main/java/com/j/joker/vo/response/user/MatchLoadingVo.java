package com.j.joker.vo.response.user;


public class MatchLoadingVo {
    /**
     * 自由场人数
     */
    private Integer freeCount;
    
    /**
     * 比赛场人数
     */
    private Integer matchCount;
    
    /**
     * 比赛奖池
     */
    private Integer matchAwardCount;
    
    /**
     * 段位赛人数
     */
    private Integer rankCount;
    
    /**
     * 当前分数
     */
    private Integer rankingPoints;
    
    /**
     * 资格分数
     */
    private Long rankingPointsTotal;
    
    /**
     * 当前段位
     */
    private Integer level;
    
    /**
     * 段位赛当前场数
     */
    private Integer presentGrounds;
    
    /**
     * 段位赛当前胜场数
     */
    private Integer presentWinGrounds;
    
    /**
     * 段位赛要求场数
     */
    private Integer minGrounds;
    
    /**
     * 段位赛当前胜率
     */
    private Float presentRate;
    
    /**
     * 段位赛要求胜率
     */
    private Float winRate;

    public Integer getFreeCount() {
        return freeCount;
    }

    public void setFreeCount(Integer freeCount) {
        this.freeCount = freeCount;
    }

    public Integer getMatchCount() {
        return matchCount;
    }

    public void setMatchCount(Integer matchCount) {
        this.matchCount = matchCount;
    }

    public Integer getMatchAwardCount() {
        return matchAwardCount;
    }

    public void setMatchAwardCount(Integer matchAwardCount) {
        this.matchAwardCount = matchAwardCount;
    }

    public Integer getRankCount() {
        return rankCount;
    }

    public void setRankCount(Integer rankCount) {
        this.rankCount = rankCount;
    }

    public Long getRankingPointsTotal() {
        return rankingPointsTotal;
    }

    public void setRankingPointsTotal(Long rankingPointsTotal) {
        this.rankingPointsTotal = rankingPointsTotal;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getRankingPoints() {
        return rankingPoints;
    }

    public void setRankingPoints(Integer rankingPoints) {
        this.rankingPoints = rankingPoints;
    }

    public Integer getPresentGrounds() {
        return presentGrounds;
    }

    public void setPresentGrounds(Integer presentGrounds) {
        this.presentGrounds = presentGrounds;
    }

    public Integer getMinGrounds() {
        return minGrounds;
    }

    public void setMinGrounds(Integer minGrounds) {
        this.minGrounds = minGrounds;
    }

    public Float getPresentRate() {
        return presentRate;
    }

    public void setPresentRate(Float presentRate) {
        this.presentRate = presentRate;
    }

    public Float getWinRate() {
        return winRate;
    }

    public void setWinRate(Float winRate) {
        this.winRate = winRate;
    }

    public Integer getPresentWinGrounds() {
        return presentWinGrounds;
    }

    public void setPresentWinGrounds(Integer presentWinGrounds) {
        this.presentWinGrounds = presentWinGrounds;
    }
}
