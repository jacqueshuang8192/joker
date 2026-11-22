//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_account")
//public class TAccount {
//    @Id
//    @Column(name = "account_id")
//    private Long accountId;
//
//    private Long userid;
//
//    private String state;
//
//    @Column(name = "coin_amount")
//    private Integer coinAmount;
//
//    @Column(name = "jewel_amount")
//    private Integer jewelAmount;
//
//    private Date ts;
//
//    @Column(name = "update_date")
//    private Date updateDate;
//
//    @Column(name = "coin_total")
//    private Long coinTotal;
//
//    @Column(name = "jewel_total")
//    private Long jewelTotal;
//
//    @Column(name = "rmb_total")
//    private Long rmbTotal;
//
//    /**
//     * @return account_id
//     */
//    public Long getAccountId() {
//        return accountId;
//    }
//
//    /**
//     * @param accountId
//     */
//    public void setAccountId(Long accountId) {
//        this.accountId = accountId;
//    }
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
//     * @return state
//     */
//    public String getState() {
//        return state;
//    }
//
//    /**
//     * @param state
//     */
//    public void setState(String state) {
//        this.state = state;
//    }
//
//    /**
//     * @return coin_amount
//     */
//    public Integer getCoinAmount() {
//        return coinAmount;
//    }
//
//    /**
//     * @param coinAmount
//     */
//    public void setCoinAmount(Integer coinAmount) {
//        this.coinAmount = coinAmount;
//    }
//
//    /**
//     * @return jewel_amount
//     */
//    public Integer getJewelAmount() {
//        return jewelAmount;
//    }
//
//    /**
//     * @param jewelAmount
//     */
//    public void setJewelAmount(Integer jewelAmount) {
//        this.jewelAmount = jewelAmount;
//    }
//
//    /**
//     * @return ts
//     */
//    public Date getTs() {
//        return ts;
//    }
//
//    /**
//     * @param ts
//     */
//    public void setTs(Date ts) {
//        this.ts = ts;
//    }
//
//    /**
//     * @return update_date
//     */
//    public Date getUpdateDate() {
//        return updateDate;
//    }
//
//    /**
//     * @param updateDate
//     */
//    public void setUpdateDate(Date updateDate) {
//        this.updateDate = updateDate;
//    }
//
//    /**
//     * @return coin_total
//     */
//    public Long getCoinTotal() {
//        return coinTotal;
//    }
//
//    /**
//     * @param coinTotal
//     */
//    public void setCoinTotal(Long coinTotal) {
//        this.coinTotal = coinTotal;
//    }
//
//    /**
//     * @return jewel_total
//     */
//    public Long getJewelTotal() {
//        return jewelTotal;
//    }
//
//    /**
//     * @param jewelTotal
//     */
//    public void setJewelTotal(Long jewelTotal) {
//        this.jewelTotal = jewelTotal;
//    }
//
//    /**
//     * @return rmb_total
//     */
//    public Long getRmbTotal() {
//        return rmbTotal;
//    }
//
//    /**
//     * @param rmbTotal
//     */
//    public void setRmbTotal(Long rmbTotal) {
//        this.rmbTotal = rmbTotal;
//    }
//}