//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_friends")
//public class TFriends {
//    @Id
//    @Column(name = "USERID")
//    private Long userid;
//
//    @Id
//    @Column(name = "FRIEND_ID")
//    private Long friendId;
//
//    @Column(name = "STATE")
//    private String state;
//
//    @Column(name = "ADD_DATE")
//    private Date addDate;
//
//    @Column(name = "APPROVE_DATE")
//    private Date approveDate;
//
//    @Column(name = "IS_HOT")
//    private String isHot;
//
//    @Column(name = "RECOMMEND_ID")
//    private String recommendId;
//
//    @Column(name = "RECOMMEND_DATE")
//    private Date recommendDate;
//
//    @Column(name = "CREATE_DATE")
//    private Date createDate;
//
//    /**
//     * @return USERID
//     */
//    public Long getUserid() {
//        return userid;
//    }
//
//    /**
//     * @param userid
//     */
//    public void setUserid(Long userid) {
//        this.userid = userid;
//    }
//
//    /**
//     * @return FRIEND_ID
//     */
//    public Long getFriendId() {
//        return friendId;
//    }
//
//    /**
//     * @param friendId
//     */
//    public void setFriendId(Long friendId) {
//        this.friendId = friendId;
//    }
//
//    /**
//     * @return STATE
//     */
//    public String getState() {
//        return state;
//    }
//
//    /**
//     * @param state
//     */
//    public void setState(String state) {
//        this.state = state;
//    }
//
//    /**
//     * @return ADD_DATE
//     */
//    public Date getAddDate() {
//        return addDate;
//    }
//
//    /**
//     * @param addDate
//     */
//    public void setAddDate(Date addDate) {
//        this.addDate = addDate;
//    }
//
//    /**
//     * @return APPROVE_DATE
//     */
//    public Date getApproveDate() {
//        return approveDate;
//    }
//
//    /**
//     * @param approveDate
//     */
//    public void setApproveDate(Date approveDate) {
//        this.approveDate = approveDate;
//    }
//
//    /**
//     * @return IS_HOT
//     */
//    public String getIsHot() {
//        return isHot;
//    }
//
//    /**
//     * @param isHot
//     */
//    public void setIsHot(String isHot) {
//        this.isHot = isHot;
//    }
//
//    /**
//     * @return RECOMMEND_ID
//     */
//    public String getRecommendId() {
//        return recommendId;
//    }
//
//    /**
//     * @param recommendId
//     */
//    public void setRecommendId(String recommendId) {
//        this.recommendId = recommendId;
//    }
//
//    /**
//     * @return RECOMMEND_DATE
//     */
//    public Date getRecommendDate() {
//        return recommendDate;
//    }
//
//    /**
//     * @param recommendDate
//     */
//    public void setRecommendDate(Date recommendDate) {
//        this.recommendDate = recommendDate;
//    }
//
//    /**
//     * @return CREATE_DATE
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//}