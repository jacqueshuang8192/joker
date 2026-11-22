package com.j.joker.vo.response.onlineTreasure;

import com.j.joker.cache.model.CacheUserProfile;

/**
 * Created by ceeuoo on 6/8/2016.
 */
public class JoinTreasureActivityVo {

    private String code;

    private String status;

    private Long winnerId;

    private String winnerCode;

    private CacheUserProfile winner;

    private Integer leftJewel;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public CacheUserProfile getWinner() {
        return winner;
    }

    public void setWinner(CacheUserProfile winner) {
        this.winner = winner;
    }

    public String getWinnerCode() {
        return winnerCode;
    }

    public void setWinnerCode(String winnerCode) {
        this.winnerCode = winnerCode;
    }

    public Long getWinnerId() {
        return winnerId;
    }

    public void setWinnerId(Long winnerId) {
        this.winnerId = winnerId;
    }

    public Integer getLeftJewel() {
        return leftJewel;
    }

    public void setLeftJewel(Integer leftJewel) {
        this.leftJewel = leftJewel;
    }
}
