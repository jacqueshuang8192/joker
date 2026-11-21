//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_dating_activity")
//public class TDatingActivity {
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "user_id")
//    private Long userId;
//    @Column(name = "user_type")
//    private String userType;
//    @Column(name = "time")
//    private Date time;
//    @Column(name = "period")
//    private String period;
//    @Column(name = "city_id")
//    private Long cityId;
//    @Column(name = "auction_declaration")
//    private String auctionDeclaration;
//    @Column(name = "category_id")
//    private Long categoryId;
//    @Column(name = "category_name")
//    private String categoryName;
//    @Column(name = "auction_count")
//    private Integer auctionCount;
//    @Column(name = "highest_auction_user_id")
//    private Long highestAuctionUserId;
//    @Column(name = "highest_auction_count")
//    private Integer highestAuctionCount;
//    @Column(name = "last_auction_date")
//    private Date lastAuctionDate;
//    @Column(name = "total_auction_num")
//    private Integer totalAuctionNum;
//    @Column(name = "is_evaluation")
//    private Integer isEvaluation;
//    @Column(name = "on_time_grade")
//    private Float onTimeGrade;
//    @Column(name = "satisfaction")
//    private Float satisfaction;
//    @Column(name = "status")
//    private String status;
//    @Column(name = "end_type")
//    private String endType;
//    @Column(name = "end_date")
//    private Date endDate;
//    @Column(name = "cancel_reason")
//    private String cancelReason;
//    @Column(name = "chatroom_id")
//    private String chatroomId;
//    @Column(name = "create_date")
//    private Date createDate;
//    @Column(name = "reply_date")
//    private Date replyDate;
//    @Column(name = "grade_date")
//    private Date gradeDate;
//    @Column(name = "last_modify_date")
//    private Date lastModifyDate;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
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
//    public Date getTime() {
//        return time;
//    }
//
//    public void setTime(Date time) {
//        this.time = time;
//    }
//
//    public String getPeriod() {
//        return period;
//    }
//
//    public void setPeriod(String period) {
//        this.period = period;
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
//    public String getAuctionDeclaration() {
//        return auctionDeclaration;
//    }
//
//    public void setAuctionDeclaration(String auctionDeclaration) {
//        this.auctionDeclaration = auctionDeclaration;
//    }
//
//    public Long getCategoryId() {
//        return categoryId;
//    }
//
//    public void setCategoryId(Long categoryId) {
//        this.categoryId = categoryId;
//    }
//
//    public String getCategoryName() {
//        return categoryName;
//    }
//
//    public void setCategoryName(String categoryName) {
//        this.categoryName = categoryName;
//    }
//
//    public Integer getAuctionCount() {
//        return auctionCount;
//    }
//
//    public void setAuctionCount(Integer auctionCount) {
//        this.auctionCount = auctionCount;
//    }
//
//    public Long getHighestAuctionUserId() {
//        return highestAuctionUserId;
//    }
//
//    public void setHighestAuctionUserId(Long highestAuctionUserId) {
//        this.highestAuctionUserId = highestAuctionUserId;
//    }
//
//    public Integer getHighestAuctionCount() {
//        return highestAuctionCount;
//    }
//
//    public void setHighestAuctionCount(Integer highestAuctionCount) {
//        this.highestAuctionCount = highestAuctionCount;
//    }
//
//    public Date getLastAuctionDate() {
//        return lastAuctionDate;
//    }
//
//    public void setLastAuctionDate(Date lastAuctionDate) {
//        this.lastAuctionDate = lastAuctionDate;
//    }
//
//    public Integer getTotalAuctionNum() {
//        return totalAuctionNum;
//    }
//
//    public void setTotalAuctionNum(Integer totalAuctionNum) {
//        this.totalAuctionNum = totalAuctionNum;
//    }
//
//    public Integer getIsEvaluation() {
//        return isEvaluation;
//    }
//
//    public void setIsEvaluation(Integer isEvaluation) {
//        this.isEvaluation = isEvaluation;
//    }
//
//    public Float getOnTimeGrade() {
//        return onTimeGrade;
//    }
//
//    public void setOnTimeGrade(Float onTimeGrade) {
//        this.onTimeGrade = onTimeGrade;
//    }
//
//    public Float getSatisfaction() {
//        return satisfaction;
//    }
//
//    public void setSatisfaction(Float satisfaction) {
//        this.satisfaction = satisfaction;
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
//    public String getEndType() {
//        return endType;
//    }
//
//    public void setEndType(String endType) {
//        this.endType = endType;
//    }
//
//    public Date getEndDate() {
//        return endDate;
//    }
//
//    public void setEndDate(Date endDate) {
//        this.endDate = endDate;
//    }
//
//    public String getCancelReason() {
//        return cancelReason;
//    }
//
//    public void setCancelReason(String cancelReason) {
//        this.cancelReason = cancelReason;
//    }
//
//    public String getChatroomId() {
//        return chatroomId;
//    }
//
//    public void setChatroomId(String chatroomId) {
//        this.chatroomId = chatroomId;
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
//    public Date getReplyDate() {
//        return replyDate;
//    }
//
//    public void setReplyDate(Date replyDate) {
//        this.replyDate = replyDate;
//    }
//
//    public Date getGradeDate() {
//        return gradeDate;
//    }
//
//    public void setGradeDate(Date gradeDate) {
//        this.gradeDate = gradeDate;
//    }
//
//    public Date getLastModifyDate() {
//        return lastModifyDate;
//    }
//
//    public void setLastModifyDate(Date lastModifyDate) {
//        this.lastModifyDate = lastModifyDate;
//    }
//
//}