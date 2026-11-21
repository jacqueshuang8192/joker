//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_jewel_gives")
//public class TJewelGives {
//    @Id
//    @Column(name = "give_flow_id")
//    private Long giveFlowId;
//
//    @Column(name = "compere_id")
//    private Long compereId;
//
//    @Column(name = "jewel_amount")
//    private Long jewelAmount;
//
//    @Column(name = "give_date")
//    private Date giveDate;
//
//    @Column(name = "agent_id")
//    private Long agentId;
//
//    @Column(name = "pay_status")
//    private String payStatus;
//
//    @Column(name = "pay_amount")
//    private Long payAmount;
//
//    @Column(name = "pay_date")
//    private Date payDate;
//
//    @Column(name = "bank_flow_id")
//    private String bankFlowId;
//
//    /**
//     * @return give_flow_id
//     */
//    public Long getGiveFlowId() {
//        return giveFlowId;
//    }
//
//    /**
//     * @param giveFlowId
//     */
//    public void setGiveFlowId(Long giveFlowId) {
//        this.giveFlowId = giveFlowId;
//    }
//
//    /**
//     * @return compere_id
//     */
//    public Long getCompereId() {
//        return compereId;
//    }
//
//    /**
//     * @param compereId
//     */
//    public void setCompereId(Long compereId) {
//        this.compereId = compereId;
//    }
//
//    /**
//     * @return jewel_amount
//     */
//    public Long getJewelAmount() {
//        return jewelAmount;
//    }
//
//    /**
//     * @param jewelAmount
//     */
//    public void setJewelAmount(Long jewelAmount) {
//        this.jewelAmount = jewelAmount;
//    }
//
//    /**
//     * @return give_date
//     */
//    public Date getGiveDate() {
//        return giveDate;
//    }
//
//    /**
//     * @param giveDate
//     */
//    public void setGiveDate(Date giveDate) {
//        this.giveDate = giveDate;
//    }
//
//    /**
//     * @return agent_id
//     */
//    public Long getAgentId() {
//        return agentId;
//    }
//
//    /**
//     * @param agentId
//     */
//    public void setAgentId(Long agentId) {
//        this.agentId = agentId;
//    }
//
//    /**
//     * @return pay_status
//     */
//    public String getPayStatus() {
//        return payStatus;
//    }
//
//    /**
//     * @param payStatus
//     */
//    public void setPayStatus(String payStatus) {
//        this.payStatus = payStatus;
//    }
//
//    /**
//     * @return pay_amount
//     */
//    public Long getPayAmount() {
//        return payAmount;
//    }
//
//    /**
//     * @param payAmount
//     */
//    public void setPayAmount(Long payAmount) {
//        this.payAmount = payAmount;
//    }
//
//    /**
//     * @return pay_date
//     */
//    public Date getPayDate() {
//        return payDate;
//    }
//
//    /**
//     * @param payDate
//     */
//    public void setPayDate(Date payDate) {
//        this.payDate = payDate;
//    }
//
//    /**
//     * @return bank_flow_id
//     */
//    public String getBankFlowId() {
//        return bankFlowId;
//    }
//
//    /**
//     * @param bankFlowId
//     */
//    public void setBankFlowId(String bankFlowId) {
//        this.bankFlowId = bankFlowId;
//    }
//}