//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_game_award_pool_apply_record")
//public class TGameAwardPoolApplyRecord {
//
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "game_award_pool_id")
//    private Long gameAwardPoolId;
//    @Column(name = "user_id")
//    private Long userId;
//    @Column(name = "user_type")
//    private String userType;
//    @Column(name = "ranking")
//    private Integer ranking;
//    @Column(name = "award_amount")
//    private Integer awardAmount;
//    @Column(name = "award_status")
//    private String awardStatus;
//    @Column(name = "apply_date")
//    private Date applyDate;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getGameAwardPoolId() {
//        return gameAwardPoolId;
//    }
//
//    public void setGameAwardPoolId(Long gameAwardPoolId) {
//        this.gameAwardPoolId = gameAwardPoolId;
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
//    public String getUserType() {
//        return userType;
//    }
//
//    public void setUserType(String userType) {
//        this.userType = userType;
//    }
//
//    public Integer getRanking() {
//        return ranking;
//    }
//
//    public void setRanking(Integer ranking) {
//        this.ranking = ranking;
//    }
//
//    public Integer getAwardAmount() {
//        return awardAmount;
//    }
//
//    public void setAwardAmount(Integer awardAmount) {
//        this.awardAmount = awardAmount;
//    }
//
//    public String getAwardStatus() {
//        return awardStatus;
//    }
//
//    public void setAwardStatus(String awardStatus) {
//        this.awardStatus = awardStatus;
//    }
//
//    public Date getApplyDate() {
//        return applyDate;
//    }
//
//    public void setApplyDate(Date applyDate) {
//        this.applyDate = applyDate;
//    }
//
//}