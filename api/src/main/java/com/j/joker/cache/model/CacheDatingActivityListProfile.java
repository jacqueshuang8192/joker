package com.j.joker.cache.model;

import java.util.Date;

import com.j.joker.cache.CacheModel;

public class CacheDatingActivityListProfile extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Long activityId;
    private Long initiatorId;
    private String userType;
    private CacheUserProfile initiator;
    private Date time;
    private String period;
    private Long cityId;
    private Long categoryId;
    private String categoryName;
    private Integer auctionCount;
    private Long highestAuctionUserId;
    private CacheUserProfile highestAuctionUser;
    private Integer highestAuctionCount;
    private Date lastAuctionDate;
    private Integer totalAuctionNum;
    private Integer isEvaluation;
    private String status;
    private String endType;
    private Date endDate;
    private Date createDate;
    private String chatroomId;

    public Long getActivityId() {
        return activityId;
    }

    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

    public Long getInitiatorId() {
        return initiatorId;
    }

    public void setInitiatorId(Long initiatorId) {
        this.initiatorId = initiatorId;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public CacheUserProfile getInitiator() {
        return initiator;
    }

    public void setInitiator(CacheUserProfile initiator) {
        this.initiator = initiator;
    }

    public Date getTime() {
        return time;
    }

    public void setTime(Date time) {
        this.time = time;
    }

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
    }

    public Long getCityId() {
        return cityId;
    }

    public void setCityId(Long cityId) {
        this.cityId = cityId;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public Integer getAuctionCount() {
        return auctionCount;
    }

    public void setAuctionCount(Integer auctionCount) {
        this.auctionCount = auctionCount;
    }

    public Long getHighestAuctionUserId() {
        return highestAuctionUserId;
    }

    public void setHighestAuctionUserId(Long highestAuctionUserId) {
        this.highestAuctionUserId = highestAuctionUserId;
    }

    public CacheUserProfile getHighestAuctionUser() {
        return highestAuctionUser;
    }

    public void setHighestAuctionUser(CacheUserProfile highestAuctionUser) {
        this.highestAuctionUser = highestAuctionUser;
    }

    public Integer getHighestAuctionCount() {
        return highestAuctionCount;
    }

    public void setHighestAuctionCount(Integer highestAuctionCount) {
        this.highestAuctionCount = highestAuctionCount;
    }

    public Date getLastAuctionDate() {
        return lastAuctionDate;
    }

    public void setLastAuctionDate(Date lastAuctionDate) {
        this.lastAuctionDate = lastAuctionDate;
    }

    public Integer getTotalAuctionNum() {
        return totalAuctionNum;
    }

    public void setTotalAuctionNum(Integer totalAuctionNum) {
        this.totalAuctionNum = totalAuctionNum;
    }

    public Integer getIsEvaluation() {
        return isEvaluation;
    }

    public void setIsEvaluation(Integer isEvaluation) {
        this.isEvaluation = isEvaluation;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getEndType() {
        return endType;
    }

    public void setEndType(String endType) {
        this.endType = endType;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public String getChatroomId() {
        return chatroomId;
    }

    public void setChatroomId(String chatroomId) {
        this.chatroomId = chatroomId;
    }

}
