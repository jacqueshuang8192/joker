package com.j.joker.vo.response.society;

public class UserGameDetail {
    private Long userId;
    
    private Long gameId;
    
    private String gameName;
    
    private Integer level;
    
    private Integer levelWinCount;
    
    private Integer levelTotalCount;
    
    /**
     * 职业属性
     */
    private String property;

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getGameId() {
        return gameId;
    }

    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    public String getGameName() {
        return gameName;
    }

    public void setGameName(String gameName) {
        this.gameName = gameName;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getLevelWinCount() {
        return levelWinCount;
    }

    public void setLevelWinCount(Integer levelWinCount) {
        this.levelWinCount = levelWinCount;
    }

    public Integer getLevelTotalCount() {
        return levelTotalCount;
    }

    public void setLevelTotalCount(Integer levelTotalCount) {
        this.levelTotalCount = levelTotalCount;
    }

    public String getProperty() {
        return property;
    }

    public void setProperty(String property) {
        this.property = property;
    }
}
