//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_game_match")
//public class TGameMatch {
//    @Id
//    @Column(name = "match_id")
//    private Long matchId;
//
//    private String name;
//
//    private Integer level;
//
//    /**
//     * 说明
//     */
//    private String remark;
//
//    @Column(name = "game_id")
//    private Long gameId;
//
//    /**
//     * 报名费
//     */
//    @Column(name = "entry_fee")
//    private Integer entryFee;
//
//    /**
//     * 底注
//     */
//    private Integer coins;
//
//    /**
//     * 连线抽成
//     */
//    private Float lineExtract;
//
//    /**
//     * 大奖赛抽成
//     */
//    private Float grandPrixExtract;
//
//    /**
//     * 公会矿抽成
//     */
//    private Float societyMineExtract;
//
//    /**
//     * 分成抽成
//     */
//    private Float shareExtract;
//
//    private String status;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    /**
//     * @return match_id
//     */
//    public Long getMatchId() {
//        return matchId;
//    }
//
//    /**
//     * @param matchId
//     */
//    public void setMatchId(Long matchId) {
//        this.matchId = matchId;
//    }
//
//    /**
//     * @return name
//     */
//    public String getName() {
//        return name;
//    }
//
//    /**
//     * @param name
//     */
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    /**
//     * @return entry_fee
//     */
//    public Integer getEntryFee() {
//        return entryFee;
//    }
//
//    /**
//     * @param entryFee
//     */
//    public void setEntryFee(Integer entryFee) {
//        this.entryFee = entryFee;
//    }
//
//    /**
//     * @return coins
//     */
//    public Integer getCoins() {
//        return coins;
//    }
//
//    /**
//     * @param coins
//     */
//    public void setCoins(Integer coins) {
//        this.coins = coins;
//    }
//
//    /**
//     * @return create_date
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
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
//    public Float getLineExtract() {
//        return lineExtract;
//    }
//
//    public void setLineExtract(Float lineExtract) {
//        this.lineExtract = lineExtract;
//    }
//
//    public Float getGrandPrixExtract() {
//        return grandPrixExtract;
//    }
//
//    public void setGrandPrixExtract(Float grandPrixExtract) {
//        this.grandPrixExtract = grandPrixExtract;
//    }
//
//    public Float getSocietyMineExtract() {
//        return societyMineExtract;
//    }
//
//    public void setSocietyMineExtract(Float societyMineExtract) {
//        this.societyMineExtract = societyMineExtract;
//    }
//
//    public Float getShareExtract() {
//        return shareExtract;
//    }
//
//    public void setShareExtract(Float shareExtract) {
//        this.shareExtract = shareExtract;
//    }
//
//    public String getRemark() {
//        return remark;
//    }
//
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    public Integer getLevel() {
//        return level;
//    }
//
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//}