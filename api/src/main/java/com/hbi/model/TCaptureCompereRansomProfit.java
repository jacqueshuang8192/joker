//package com.hbi.model;
//
//import java.math.BigDecimal;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_capture_compere_ransom_profit")
//public class TCaptureCompereRansomProfit {
//    @Id
//    @Column(name = "id")
//    private Long id;
//
//    @Column(name = "ransom_extract_id")
//    private Long ransomExtractId;
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
//    public Long getRansomExtractId() {
//        return ransomExtractId;
//    }
//
//    public void setRansomExtractId(Long ransomExtractId) {
//        this.ransomExtractId = ransomExtractId;
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