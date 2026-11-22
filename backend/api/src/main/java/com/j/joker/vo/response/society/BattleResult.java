package com.j.joker.vo.response.society;

public class BattleResult {
    /**
     * 是否赢得比赛
     */
    private boolean isWin;

    /**
     * 本次抢矿收益
     */
    private Long profit;
    
    /**
     * 是否有防守玩家
     */
    private boolean hasDefender;

    /**
     * 剩余血量
     */
    private Long life;

    public boolean isWin() {
        return isWin;
    }

    public void setWin(boolean isWin) {
        this.isWin = isWin;
    }

    public Long getProfit() {
        return profit;
    }

    public void setProfit(Long profit) {
        this.profit = profit;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

    public boolean isHasDefender() {
        return hasDefender;
    }

    public void setHasDefender(boolean hasDefender) {
        this.hasDefender = hasDefender;
    }
}
