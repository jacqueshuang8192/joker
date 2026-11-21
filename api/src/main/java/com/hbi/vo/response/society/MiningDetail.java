package com.hbi.vo.response.society;

import java.util.List;

public class MiningDetail {
    private Long userId;
    
    /**
     * 抢矿活动开始时间
     */
    private String startDate;
    
    /**
     * 抢矿活动结束时间
     */
    private String endDate;
    
    /**
     * 攻击人数
     */
    private Integer attackNum;
    
    /**
     * 防守人数
     */
    private Integer defenseNum;
    
    /**
     * 该玩家攻击
     */
    private Long attack;
    
    /**
     * 该玩家生命
     */
    private Long life;
    
    /**
     * 该玩家防御
     */
    private Long defense;
    
    /**
     * 该玩家当日收益
     */
    private Long dayProfit;
    
    /**
     * 该公会总矿量
     */
    private Long fullAmount;
    
    /**
     * 该公会剩余矿量
     */
    private Long realAmount;
    
    /**
     * 矿位列表
     */
    private List mineSegList;
    
    /**
     * 最小抢矿时间
     */
    private Integer minDigSecond;
    
    /**
     * 复活时间
     */
    private Integer reviveTime;
    
    /**
     * 玩家单次收益
     */
    private Long profit;
    
    /**
     * 单次战斗结果
     */
    private boolean isWin;
    
    /**
     * 采矿最大战斗回合数
     */
    private Integer maxFightRound;

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public Integer getAttackNum() {
        return attackNum;
    }

    public void setAttackNum(Integer attackNum) {
        this.attackNum = attackNum;
    }

    public Integer getDefenseNum() {
        return defenseNum;
    }

    public void setDefenseNum(Integer defenseNum) {
        this.defenseNum = defenseNum;
    }

    public Long getAttack() {
        return attack;
    }

    public void setAttack(Long attack) {
        this.attack = attack;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

    public Long getDefense() {
        return defense;
    }

    public void setDefense(Long defense) {
        this.defense = defense;
    }

    public List getMineSegList() {
        return mineSegList;
    }

    public void setMineSegList(List mineSegList) {
        this.mineSegList = mineSegList;
    }

    public Long getDayProfit() {
        return dayProfit;
    }

    public void setDayProfit(Long dayProfit) {
        this.dayProfit = dayProfit;
    }

    public Integer getMinDigSecond() {
        return minDigSecond;
    }

    public void setMinDigSecond(Integer minDigSecond) {
        this.minDigSecond = minDigSecond;
    }

    public Long getFullAmount() {
        return fullAmount;
    }

    public void setFullAmount(Long fullAmount) {
        this.fullAmount = fullAmount;
    }

    public Long getRealAmount() {
        return realAmount;
    }

    public void setRealAmount(Long realAmount) {
        this.realAmount = realAmount;
    }

    public Integer getReviveTime() {
        return reviveTime;
    }

    public void setReviveTime(Integer reviveTime) {
        this.reviveTime = reviveTime;
    }

    public Long getProfit() {
        return profit;
    }

    public void setProfit(Long profit) {
        this.profit = profit;
    }

    public boolean isWin() {
        return isWin;
    }

    public void setWin(boolean isWin) {
        this.isWin = isWin;
    }

    public Integer getMaxFightRound() {
        return maxFightRound;
    }

    public void setMaxFightRound(Integer maxFightRound) {
        this.maxFightRound = maxFightRound;
    }
    
}
