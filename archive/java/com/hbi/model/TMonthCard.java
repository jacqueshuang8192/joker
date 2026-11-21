//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import java.util.Date;
//
//
///**
// * 月卡
// * @author ceeuoo
// *
// */
//@Table(name="t_month_card")
//public class TMonthCard {
//    @Id
//    private Long id;
//
//    @Column(name="user_id")
//    private Long userId;
//
//
//    @Column(name="start_date")
//    private Date startDate;
//
//    @Column(name="end_date")
//    private Date endDate;
//
//    private Integer type;
//
//    public Date getEndDate() {
//        return endDate;
//    }
//
//    public void setEndDate(Date endDate) {
//        this.endDate = endDate;
//    }
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Date getStartDate() {
//        return startDate;
//    }
//
//    public void setStartDate(Date startDate) {
//        this.startDate = startDate;
//    }
//
//    public Long getUserId() {
//        return userId;
//    }
//
//    public void setUserId(Long userId) {
//        this.userId = userId;
//    }
//
//    public Integer getType() {
//        return type;
//    }
//
//    public void setType(Integer type) {
//        this.type = type;
//    }
//}
