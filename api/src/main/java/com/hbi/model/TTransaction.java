//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_transaction")
//public class TTransaction {
//    @Id
//    @Column(name = "transaction_id")
//    private Long transactionId;
//
//    @Column(name = "account_id")
//    private Long accountId;
//
//    private Long userid;
//
//    @Column(name = "coin_amount")
//    private Integer coinAmount;
//
//    private String reason;
//
//    @Column(name = "trade_date")
//    private Date tradeDate;
//
//    @Column(name = "activity_id")
//    private String activityId;
//
//    private String type;
//
//    /**
//     * @return transaction_id
//     */
//    public Long getTransactionId() {
//        return transactionId;
//    }
//
//    /**
//     * @param transactionId
//     */
//    public void setTransactionId(Long transactionId) {
//        this.transactionId = transactionId;
//    }
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
//     * @return reason
//     */
//    public String getReason() {
//        return reason;
//    }
//
//    /**
//     * @param reason
//     */
//    public void setReason(String reason) {
//        this.reason = reason;
//    }
//
//    /**
//     * @return trade_date
//     */
//    public Date getTradeDate() {
//        return tradeDate;
//    }
//
//    /**
//     * @param tradeDate
//     */
//    public void setTradeDate(Date tradeDate) {
//        this.tradeDate = tradeDate;
//    }
//
//    /**
//     * @return activity_id
//     */
//    public String getActivityId() {
//        return activityId;
//    }
//
//    /**
//     * @param activityId
//     */
//    public void setActivityId(String activityId) {
//        this.activityId = activityId;
//    }
//
//    /**
//     * @return type
//     */
//    public String getType() {
//        return type;
//    }
//
//    /**
//     * @param type
//     */
//    public void setType(String type) {
//        this.type = type;
//    }
//}