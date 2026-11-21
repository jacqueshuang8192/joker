package com.hbi.vo.response.gold;

/**
 * Created by muzi on 30/11/2017.
 */
public class pickUpGoldVo {

    private Integer playerId;

    private Integer goldCount;

    private String date;

    public Integer getPlayerId() {
        return playerId;
    }

    public void setPlayerId(Integer playerId) {
        this.playerId = playerId;
    }

    public Integer getGoldCount() {
        return goldCount;
    }

    public void setGoldCount(Integer goldCount) {
        this.goldCount = goldCount;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }
}
