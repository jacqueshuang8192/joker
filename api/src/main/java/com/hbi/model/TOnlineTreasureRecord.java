//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import java.util.Date;
//
///**
// * one yuan treasure
// * Created by yrou on 4/20/2016.
// */
//@Table(name="t_online_treasure_record")
//public class TOnlineTreasureRecord {
//    @Id
//    private Long id;
//
//    @Column(name = "activity_id")
//    private Long activityId;
//
//    @Column(name = "user_id")
//    private Long userId;
//
//    @Column(name = "user_name")
//    private String userName;
//
//    private String photo;
//
//    @Column(name = "user_type")
//    private String userType;
//
//    @Column(name = "jewel_amount")
//    private Integer jewelAmount;
//
//    private String code;
//
//    private Date date;
//
//    public Long getActivityId() {
//        return activityId;
//    }
//
//    public void setActivityId(Long activityId) {
//        this.activityId = activityId;
//    }
//
//    public Date getDate() {
//        return date;
//    }
//
//    public void setDate(Date date) {
//        this.date = date;
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
//    public Integer getJewelAmount() {
//        return jewelAmount;
//    }
//
//    public void setJewelAmount(Integer jewelAmount) {
//        this.jewelAmount = jewelAmount;
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
//    public String getCode() {
//        return code;
//    }
//
//    public void setCode(String code) {
//        this.code = code;
//    }
//
//    public String getUserType() {
//        return userType;
//    }
//
//    public void setUserType(String userType) {
//        this.userType = userType;
//    }
//
//    public String getUserName() {
//        return userName;
//    }
//
//    public void setUserName(String userName) {
//        this.userName = userName;
//    }
//
//    public String getPhoto() {
//        return photo;
//    }
//
//    public void setPhoto(String photo) {
//        this.photo = photo;
//    }
//}
