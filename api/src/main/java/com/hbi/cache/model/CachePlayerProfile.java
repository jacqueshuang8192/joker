package com.hbi.cache.model;

public class CachePlayerProfile extends CacheUserProfile {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    /**
     * 平台等级
     */
    private Integer level;

    /**
     * vip等级
     */
    private Integer vipLevel;

    /**
     * 绑定的主播ID
     */
    private String bindCompereId;

    /**
     * 财富
     */
    private int wealth;

    /**
     * 最高的段位等级
     */
    private String highestMasterLevel;

    /**
     * 玩家当日剩余抢矿次数
     */
    private Integer leftDigCount;

    /**
     * 玩家当日收益
     */
    private Long dayProfit;

    /**
     * 抢主播攻击
     */
    private Long captureAttack;

    /**
     * 抢主播防御
     */
    private Long captureDefense;

    /**
     * 抢主播生命
     */
    private Long captureLife;

    /**
     * 玩家总充值数
     */
    private Long chargeSum;

    /**
     * 推广玩家ID
     */
    private Long promoterId;
    
    private String promoCode;

    private String myIp;

    public String getMyIp() {
        return myIp;
    }

    public void setMyIp(String myIp) {
        this.myIp = myIp;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getVipLevel() {
        return vipLevel;
    }

    public void setVipLevel(Integer vipLevel) {
        this.vipLevel = vipLevel;
    }

    public String getBindCompereId() {
        return bindCompereId;
    }

    public void setBindCompereId(String bindCompereId) {
        this.bindCompereId = bindCompereId;
    }

    public int getWealth() {
        return wealth;
    }

    public void setWealth(int wealth) {
        this.wealth = wealth;
    }

    public String getHighestMasterLevel() {
        return highestMasterLevel;
    }

    public void setHighestMasterLevel(String highestMasterLevel) {
        this.highestMasterLevel = highestMasterLevel;
    }

    public Integer getLeftDigCount() {
        return leftDigCount;
    }

    public void setLeftDigCount(Integer leftDigCount) {
        this.leftDigCount = leftDigCount;
    }

    public Long getDayProfit() {
        return dayProfit;
    }

    public void setDayProfit(Long dayProfit) {
        this.dayProfit = dayProfit;
    }

    public Long getCaptureAttack() {
        return captureAttack;
    }

    public void setCaptureAttack(Long captureAttack) {
        this.captureAttack = captureAttack;
    }

    public Long getCaptureDefense() {
        return captureDefense;
    }

    public void setCaptureDefense(Long captureDefense) {
        this.captureDefense = captureDefense;
    }

    public Long getCaptureLife() {
        return captureLife;
    }

    public void setCaptureLife(Long captureLife) {
        this.captureLife = captureLife;
    }

    public Long getChargeSum() {
        return chargeSum;
    }

    public void setChargeSum(Long chargeSum) {
        this.chargeSum = chargeSum;
    }

    public Long getPromoterId() {
        return promoterId;
    }

    public void setPromoterId(Long promoterId) {
        this.promoterId = promoterId;
    }

    public String getPromoCode() {
        return promoCode;
    }

    public void setPromoCode(String promoCode) {
        this.promoCode = promoCode;
    }

}
