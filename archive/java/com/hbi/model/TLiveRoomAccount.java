//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_live_room_account")
//public class TLiveRoomAccount {
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "account")
//    private String account;
//    @Column(name = "password")
//    private String password;
//    @Column(name = "live_id")
//    private Long liveId;
//    @Column(name = "city_id")
//    private Long cityId;
//    @Column(name = "owner_id")
//    private Long ownerId;
//    @Column(name = "status")
//    private String status;
//    @Column(name = "use_status")
//    private String useStatus;
//    @Column(name = "current_user_id")
//    private Long currentUserId;
//    @Column(name = "live_start_time")
//    private Date liveStartTime;
//    @Column(name = "live_last_time")
//    private Float liveLastTime;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getAccount() {
//        return account;
//    }
//
//    public void setAccount(String account) {
//        this.account = account;
//    }
//
//    public String getPassword() {
//        return password;
//    }
//
//    public void setPassword(String password) {
//        this.password = password;
//    }
//
//    public Long getLiveId() {
//        return liveId;
//    }
//
//    public void setLiveId(Long liveId) {
//        this.liveId = liveId;
//    }
//
//    public Long getCityId() {
//        return cityId;
//    }
//
//    public void setCityId(Long cityId) {
//        this.cityId = cityId;
//    }
//
//    public Long getOwnerId() {
//        return ownerId;
//    }
//
//    public void setOwnerId(Long ownerId) {
//        this.ownerId = ownerId;
//    }
//
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    public String getUseStatus() {
//        return useStatus;
//    }
//
//    public void setUseStatus(String useStatus) {
//        this.useStatus = useStatus;
//    }
//
//    public Long getCurrentUserId() {
//        return currentUserId;
//    }
//
//    public void setCurrentUserId(Long currentUserId) {
//        this.currentUserId = currentUserId;
//    }
//
//    public Date getLiveStartTime() {
//        return liveStartTime;
//    }
//
//    public void setLiveStartTime(Date liveStartTime) {
//        this.liveStartTime = liveStartTime;
//    }
//
//    public Float getLiveLastTime() {
//        return liveLastTime;
//    }
//
//    public void setLiveLastTime(Float liveLastTime) {
//        this.liveLastTime = liveLastTime;
//    }
//
//}