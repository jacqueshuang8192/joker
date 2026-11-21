//package com.hbi.model;
//
//import javax.persistence.Column;
//import java.util.Date;
//
//public class ZJewelStatement {
//    private Long id;
//
//    private Date time;
//
//    private Integer balance;
//
//    private String name;
//
//    private Integer remark; //1：赠送；2：收入
//
//    private Integer status; //0：未到账；1：已到账
//
//    private Integer type; //1：运营商；2：省代理；3：市代理；4：区县代理；5：经理；6：主播
//
//    @Column(name="giver_id")
//    private Long receiverId;
//
//    @Column(name="receiver_id")
//    private Long giverId;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Date getTime() {
//        return time;
//    }
//
//    public void setTime(Date time) {
//        this.time = time;
//    }
//
//    public Integer getBalance() {
//        return balance;
//    }
//
//    public void setBalance(Integer balance) {
//        this.balance = balance;
//    }
//
//    public String getName() {
//        return name;
//    }
//
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    public Integer getRemark() {
//        return remark;
//    }
//
//    public void setRemark(Integer remark) {
//        this.remark = remark;
//    }
//
//    public Integer getStatus() {
//        return status;
//    }
//
//    public void setStatus(Integer status) {
//        this.status = status;
//    }
//
//    public Integer getType() {
//        return type;
//    }
//
//    public void setType(Integer type) {
//        this.type = type;
//    }
//
//    public Long getGiverId() {
//        return giverId;
//    }
//
//    public void setGiverId(Long giverId) {
//        this.giverId = giverId;
//    }
//
//    public Long getReceiverId() {
//        return receiverId;
//    }
//
//    public void setReceiverId(Long receiverId) {
//        this.receiverId = receiverId;
//    }
//}
