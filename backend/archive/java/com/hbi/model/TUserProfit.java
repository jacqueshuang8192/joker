//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_user_profit")
//public class TUserProfit {
//    @Id
//    private Long tid;
//
//    @Column(name = "strategy_id")
//    private Long strategyId;
//
//    private Long userid;
//
//    @Column(name = "activity_id")
//    private Long activityId;
//
//    @Column(name = "room_id")
//    private Long roomId;
//
//    @Column(name = "coin_total")
//    private Long coinTotal;
//
//    private Float percentage;
//
//    @Column(name = "coin_amount")
//    private Long coinAmount;
//
//    @Column(name = "activity_date")
//    private Date activityDate;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    /**
//     * @return tid
//     */
//    public Long getTid() {
//        return tid;
//    }
//
//    /**
//     * @param tid
//     */
//    public void setTid(Long tid) {
//        this.tid = tid;
//    }
//
//    /**
//     * @return strategy_id
//     */
//    public Long getStrategyId() {
//        return strategyId;
//    }
//
//    /**
//     * @param strategyId
//     */
//    public void setStrategyId(Long strategyId) {
//        this.strategyId = strategyId;
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
//     * @return activity_id
//     */
//    public Long getActivityId() {
//        return activityId;
//    }
//
//    /**
//     * @param activityId
//     */
//    public void setActivityId(Long activityId) {
//        this.activityId = activityId;
//    }
//
//    /**
//     * @return room_id
//     */
//    public Long getRoomId() {
//        return roomId;
//    }
//
//    /**
//     * @param roomId
//     */
//    public void setRoomId(Long roomId) {
//        this.roomId = roomId;
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
//     * @return percentage
//     */
//    public Float getPercentage() {
//        return percentage;
//    }
//
//    /**
//     * @param percentage
//     */
//    public void setPercentage(Float percentage) {
//        this.percentage = percentage;
//    }
//
//    /**
//     * @return coin_amount
//     */
//    public Long getCoinAmount() {
//        return coinAmount;
//    }
//
//    /**
//     * @param coinAmount
//     */
//    public void setCoinAmount(Long coinAmount) {
//        this.coinAmount = coinAmount;
//    }
//
//    /**
//     * @return activity_date
//     */
//    public Date getActivityDate() {
//        return activityDate;
//    }
//
//    /**
//     * @param activityDate
//     */
//    public void setActivityDate(Date activityDate) {
//        this.activityDate = activityDate;
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
//}