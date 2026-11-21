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
//@Table(name="t_online_treasure_history")
//public class TOnlineTreasureHistory {
//    @Id
//    private Long id;
//
//    @Column(name = "activity_id")
//    private Long activityId;
//
//    @Column(name = "user_id")
//    private Long userId;
//
//    @Column(name = "nick_name")
//    private String nickName;
//
//    private String sex;
//
//    private Date birthday;
//
//    @Column(name = "photo_url")
//    private String photoUrl;
//
//    private String phone;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    public Date getBirthday() {
//        return birthday;
//    }
//
//    public void setBirthday(Date birthday) {
//        this.birthday = birthday;
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
//    public String getNickName() {
//        return nickName;
//    }
//
//    public void setNickName(String nickName) {
//        this.nickName = nickName;
//    }
//
//    public String getPhone() {
//        return phone;
//    }
//
//    public void setPhone(String phone) {
//        this.phone = phone;
//    }
//
//    public String getPhotoUrl() {
//        return photoUrl;
//    }
//
//    public void setPhotoUrl(String photoUrl) {
//        this.photoUrl = photoUrl;
//    }
//
//    public String getSex() {
//        return sex;
//    }
//
//    public void setSex(String sex) {
//        this.sex = sex;
//    }
//
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
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
//    public Long getActivityId() {
//        return activityId;
//    }
//
//    public void setActivityId(Long activityId) {
//        this.activityId = activityId;
//    }
//}
