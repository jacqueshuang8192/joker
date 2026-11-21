//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_mining_game_defenser")
//public class TMiningGameDefenser {
//    @Id
//    @Column(name = "activity_id")
//    private Long activityId;
//
//    @Id
//    @Column(name = "player_id")
//    private Long playerId;
//
//    @Column(name = "init_life_value")
//    private Long initLifeValue;
//
//    @Column(name = "life_value")
//    private Long lifeValue;
//
//    private String state;
//
//    @Column(name = "start_date")
//    private Date startDate;
//
//    @Column(name = "end_date")
//    private Date endDate;
//
//    /**
//     * @return activity_id
//     */
//    public Long getActivityId() {
//        return activityId;
//    }
//
//    /**
//     * @param activityId
//     */
//    public void setActivityId(Long activityId) {
//        this.activityId = activityId;
//    }
//
//    /**
//     * @return player_id
//     */
//    public Long getPlayerId() {
//        return playerId;
//    }
//
//    /**
//     * @param playerId
//     */
//    public void setPlayerId(Long playerId) {
//        this.playerId = playerId;
//    }
//
//    /**
//     * @return init_life_value
//     */
//    public Long getInitLifeValue() {
//        return initLifeValue;
//    }
//
//    /**
//     * @param initLifeValue
//     */
//    public void setInitLifeValue(Long initLifeValue) {
//        this.initLifeValue = initLifeValue;
//    }
//
//    /**
//     * @return life_value
//     */
//    public Long getLifeValue() {
//        return lifeValue;
//    }
//
//    /**
//     * @param lifeValue
//     */
//    public void setLifeValue(Long lifeValue) {
//        this.lifeValue = lifeValue;
//    }
//
//    /**
//     * @return state
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
//     * @return start_date
//     */
//    public Date getStartDate() {
//        return startDate;
//    }
//
//    /**
//     * @param startDate
//     */
//    public void setStartDate(Date startDate) {
//        this.startDate = startDate;
//    }
//
//    /**
//     * @return end_date
//     */
//    public Date getEndDate() {
//        return endDate;
//    }
//
//    /**
//     * @param endDate
//     */
//    public void setEndDate(Date endDate) {
//        this.endDate = endDate;
//    }
//}