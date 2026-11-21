//package com.hbi.model;
//
//import java.math.BigDecimal;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_capture_compere_defend_profit")
//public class TCaptureCompereDefendProfit {
//    @Id
//    @Column(name = "id")
//    private Long id;
//
//    @Column(name = "defend_extract_id")
//    private Long defendExtractId;
//
//    @Column(name = "receiver_id")
//    private Long receiverId;
//
//    @Column(name = "receiver_type")
//    private String receiverType;
//
//    @Column(name = "income")
//    private BigDecimal income;
//
//    @Column(name = "contributory_id")
//    private Long contributoryId;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getDefendExtractId() {
//        return defendExtractId;
//    }
//
//    public void setDefendExtractId(Long defendExtractId) {
//        this.defendExtractId = defendExtractId;
//    }
//
//    public Long getReceiverId() {
//        return receiverId;
//    }
//
//    public void setReceiverId(Long receiverId) {
//        this.receiverId = receiverId;
//    }
//
//    public String getReceiverType() {
//        return receiverType;
//    }
//
//    public void setReceiverType(String receiverType) {
//        this.receiverType = receiverType;
//    }
//
//    public BigDecimal getIncome() {
//        return income;
//    }
//
//    public void setIncome(BigDecimal income) {
//        this.income = income;
//    }
//
//    public Long getContributoryId() {
//        return contributoryId;
//    }
//
//    public void setContributoryId(Long contributoryId) {
//        this.contributoryId = contributoryId;
//    }
//
//}