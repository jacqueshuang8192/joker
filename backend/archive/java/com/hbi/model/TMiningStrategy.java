//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_mining_strategy")
//public class TMiningStrategy {
//    @Id
//    @Column(name = "strategy_id")
//    private Long strategyId;
//
//    @Column(name = "society_id")
//    private Long societyId;
//
//    @Column(name = "effective_start")
//    private Date effectiveStart;
//
//    @Column(name = "effective_end")
//    private Date effectiveEnd;
//
//    @Column(name = "full_amount")
//    private Long fullAmount;
//
//    @Column(name = "award_percentage")
//    private Float awardPercentage;
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
//     * @return society_id
//     */
//    public Long getSocietyId() {
//        return societyId;
//    }
//
//    /**
//     * @param societyId
//     */
//    public void setSocietyId(Long societyId) {
//        this.societyId = societyId;
//    }
//
//    /**
//     * @return effective_start
//     */
//    public Date getEffectiveStart() {
//        return effectiveStart;
//    }
//
//    /**
//     * @param effectiveStart
//     */
//    public void setEffectiveStart(Date effectiveStart) {
//        this.effectiveStart = effectiveStart;
//    }
//
//    /**
//     * @return effective_end
//     */
//    public Date getEffectiveEnd() {
//        return effectiveEnd;
//    }
//
//    /**
//     * @param effectiveEnd
//     */
//    public void setEffectiveEnd(Date effectiveEnd) {
//        this.effectiveEnd = effectiveEnd;
//    }
//
//    /**
//     * @return full_amount
//     */
//    public Long getFullAmount() {
//        return fullAmount;
//    }
//
//    /**
//     * @param fullAmount
//     */
//    public void setFullAmount(Long fullAmount) {
//        this.fullAmount = fullAmount;
//    }
//
//    /**
//     * @return award_percentage
//     */
//    public Float getAwardPercentage() {
//        return awardPercentage;
//    }
//
//    /**
//     * @param awardPercentage
//     */
//    public void setAwardPercentage(Float awardPercentage) {
//        this.awardPercentage = awardPercentage;
//    }
//}