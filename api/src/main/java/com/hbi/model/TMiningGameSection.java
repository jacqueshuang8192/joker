//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.*;
//
//@Table(name = "t_mining_game_section")
//public class TMiningGameSection {
//    @Column(name = "minesection_id")
//    private Long mineSectionId;
//
//    @Column(name = "activity_id")
//    private Long activityId;
//
//    @Column(name = "minesectionPosition")
//    private Integer mineSectionPosition;
//
//    private String status;
//
//    @Column(name = "minesectionAmount")
//    private Long mineSectionAmount;
//
//    @Column(name = "minedAmount")
//    private Long minedAmount;
//
//    @Column(name = "availableAmount")
//    private Long availableAmount;
//
//    @Column(name = "defender_id")
//    private Long defenderId;
//
//    @Column(name = "attacker_id")
//    private Long attackerId;
//
//    /**
//     * 最后更新时间戳，用来决定矿坑是否需要被清理
//     */
//    @Transient
//    private Date timestamp;
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
//     * @return status
//     */
//    public String getStatus() {
//        return status;
//    }
//
//    /**
//     * @param status
//     */
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    /**
//     * @return defender_id
//     */
//    public Long getDefenderId() {
//        return defenderId;
//    }
//
//    /**
//     * @param defenderId
//     */
//    public void setDefenderId(Long defenderId) {
//        this.defenderId = defenderId;
//    }
//
//    /**
//     * @return attacker_id
//     */
//    public Long getAttackerId() {
//        return attackerId;
//    }
//
//    /**
//     * @param attackerId
//     */
//    public void setAttackerId(Long attackerId) {
//        this.attackerId = attackerId;
//    }
//
//    public Date getTimestamp() {
//        return timestamp;
//    }
//
//    public void setTimestamp(Date timestamp) {
//        this.timestamp = timestamp;
//    }
//
//    public Long getMineSectionId() {
//        return mineSectionId;
//    }
//
//    public void setMineSectionId(Long mineSectionId) {
//        this.mineSectionId = mineSectionId;
//    }
//
//    public Integer getMineSectionPosition() {
//        return mineSectionPosition;
//    }
//
//    public void setMineSectionPosition(Integer mineSectionPosition) {
//        this.mineSectionPosition = mineSectionPosition;
//    }
//
//    public Long getAvailableAmount() {
//        return availableAmount;
//    }
//
//    public void setAvailableAmount(Long availableAmount) {
//        this.availableAmount = availableAmount;
//    }
//
//    public Long getMineSectionAmount() {
//        return mineSectionAmount;
//    }
//
//    public void setMineSectionAmount(Long mineSectionAmount) {
//        this.mineSectionAmount = mineSectionAmount;
//    }
//
//    public Long getMinedAmount() {
//        return minedAmount;
//    }
//
//    public void setMinedAmount(Long minedAmount) {
//        this.minedAmount = minedAmount;
//    }
//}