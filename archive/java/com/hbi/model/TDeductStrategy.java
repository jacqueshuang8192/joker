//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_deduct_strategy")
//public class TDeductStrategy {
//    @Id
//    @Column(name = "strategy_id")
//    private Long strategyId;
//
//    @Column(name = "chip_id")
//    private Long chipId;
//
//    private String name;
//
//    private String remark;
//
//    @Column(name = "effect_start")
//    private Date effectStart;
//
//    @Column(name = "effect_end")
//    private Date effectEnd;
//
//    @Column(name = "target_type")
//    private String targetType;
//
//    private Float percentage;
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
//     * @return chip_id
//     */
//    public Long getChipId() {
//        return chipId;
//    }
//
//    /**
//     * @param chipId
//     */
//    public void setChipId(Long chipId) {
//        this.chipId = chipId;
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
//     * @return remark
//     */
//    public String getRemark() {
//        return remark;
//    }
//
//    /**
//     * @param remark
//     */
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//
//    /**
//     * @return effect_start
//     */
//    public Date getEffectStart() {
//        return effectStart;
//    }
//
//    /**
//     * @param effectStart
//     */
//    public void setEffectStart(Date effectStart) {
//        this.effectStart = effectStart;
//    }
//
//    /**
//     * @return effect_end
//     */
//    public Date getEffectEnd() {
//        return effectEnd;
//    }
//
//    /**
//     * @param effectEnd
//     */
//    public void setEffectEnd(Date effectEnd) {
//        this.effectEnd = effectEnd;
//    }
//
//    /**
//     * @return target_type
//     */
//    public String getTargetType() {
//        return targetType;
//    }
//
//    /**
//     * @param targetType
//     */
//    public void setTargetType(String targetType) {
//        this.targetType = targetType;
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
//}