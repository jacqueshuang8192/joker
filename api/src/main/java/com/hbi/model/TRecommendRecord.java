//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_recommend_record")
//public class TRecommendRecord {
//    @Id
//    @Column(name = "recommend_id")
//    private Long recommendId;
//
//    private Long userid;
//
//    @Column(name = "recommend_userid")
//    private Long recommendUserid;
//
//    private String type;
//
//    private String content;
//
//    @Column(name = "recommend_date")
//    private Date recommendDate;
//
//    @Column(name = "activity_id")
//    private String activityId;
//
//    /**
//     * @return recommend_id
//     */
//    public Long getRecommendId() {
//        return recommendId;
//    }
//
//    /**
//     * @param recommendId
//     */
//    public void setRecommendId(Long recommendId) {
//        this.recommendId = recommendId;
//    }
//
//    /**
//     * @return userid
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
//     * @return recommend_userid
//     */
//    public Long getRecommendUserid() {
//        return recommendUserid;
//    }
//
//    /**
//     * @param recommendUserid
//     */
//    public void setRecommendUserid(Long recommendUserid) {
//        this.recommendUserid = recommendUserid;
//    }
//
//    /**
//     * @return type
//     */
//    public String getType() {
//        return type;
//    }
//
//    /**
//     * @param type
//     */
//    public void setType(String type) {
//        this.type = type;
//    }
//
//    /**
//     * @return content
//     */
//    public String getContent() {
//        return content;
//    }
//
//    /**
//     * @param content
//     */
//    public void setContent(String content) {
//        this.content = content;
//    }
//
//    /**
//     * @return recommend_date
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
//     * @return activity_id
//     */
//    public String getActivityId() {
//        return activityId;
//    }
//
//    /**
//     * @param activityId
//     */
//    public void setActivityId(String activityId) {
//        this.activityId = activityId;
//    }
//}