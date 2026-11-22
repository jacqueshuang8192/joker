//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import java.util.Date;
//
//@Table(name = "t_agent_charge")
//public class TAgentCharge {
//    @Id
//    @Column(name = "charge_id")
//    private Long chargeId;
//
//    @Column(name = "agent_id")
//    private Long agentId;
//
//    @Column(name = "charge_date")
//    private Date chargeDate;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    @Column(name = "pay_type")
//    private String payType;
//
//    @Column(name="status")
//    private String status;
//
//    @Column(name="charge_order")
//    private String chargeOrder;
//
//    private String remark;
//
//    @Column(name="card_num")
//    private Integer cardNum;
//
//    @Column(name="rmb_amount")
//    private Integer rmbAmount;
//
//    /**
//     * @return charge_id
//     */
//    public Long getChargeId() {
//        return chargeId;
//    }
//
//    /**
//     * @param chargeId
//     */
//    public void setChargeId(Long chargeId) {
//        this.chargeId = chargeId;
//    }
//
//
//    /**
//     * @return charge_date
//     */
//    public Date getChargeDate() {
//        return chargeDate;
//    }
//
//    /**
//     * @param chargeDate
//     */
//    public void setChargeDate(Date chargeDate) {
//        this.chargeDate = chargeDate;
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
//    /**
//     * @return pay_type
//     */
//    public String getPayType() {
//        return payType;
//    }
//
//    /**
//     * @param payType
//     */
//    public void setPayType(String payType) {
//        this.payType = payType;
//    }
//
//	public String getStatus() {
//		return status;
//	}
//
//	public void setStatus(String status) {
//		this.status = status;
//	}
//
//	public String getChargeOrder() {
//		return chargeOrder;
//	}
//
//	public void setChargeOrder(String chargeOrder) {
//		this.chargeOrder = chargeOrder;
//	}
//
//    public String getRemark() {
//        return remark;
//    }
//
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//
//    public Long getAgentId() {
//        return agentId;
//    }
//
//    public void setAgentId(Long agentId) {
//        this.agentId = agentId;
//    }
//
//    public Integer getCardNum() {
//        return cardNum;
//    }
//
//    public void setCardNum(Integer cardNum) {
//        this.cardNum = cardNum;
//    }
//
//    public Integer getRmbAmount() {
//        return rmbAmount;
//    }
//
//    public void setRmbAmount(Integer rmbAmount) {
//        this.rmbAmount = rmbAmount;
//    }
//}