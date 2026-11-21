//package com.hbi.model;
//
//import java.math.BigDecimal;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_free_game_profit")
//public class TFreeGameProfit {
//    @Id
//    @Column(name = "id")
//    private Long id;
//
//    @Column(name = "free_game_extract_id")
//    private Long freeGameExtractId;
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
//    public Long getFreeGameExtractId() {
//        return freeGameExtractId;
//    }
//
//    public void setFreeGameExtractId(Long freeGameExtractId) {
//        this.freeGameExtractId = freeGameExtractId;
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