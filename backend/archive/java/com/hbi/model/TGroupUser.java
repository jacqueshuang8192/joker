//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_group_user")
//public class TGroupUser {
//    @Id
//    @Column(name = "group_id")
//    private Long groupId;
//
//    @Id
//    private Long userid;
//
//    @Column(name = "nick_name")
//    private String nickName;
//
//    private String state;
//
//    @Column(name = "receive_strategy")
//    private String receiveStrategy;
//
//    @Column(name = "join_date")
//    private Date joinDate;
//
//    @Column(name = "is_master")
//    private String isMaster;
//
//    /**
//     * @return group_id
//     */
//    public Long getGroupId() {
//        return groupId;
//    }
//
//    /**
//     * @param groupId
//     */
//    public void setGroupId(Long groupId) {
//        this.groupId = groupId;
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
//     * @return nick_name
//     */
//    public String getNickName() {
//        return nickName;
//    }
//
//    /**
//     * @param nickName
//     */
//    public void setNickName(String nickName) {
//        this.nickName = nickName;
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
//     * @return receive_strategy
//     */
//    public String getReceiveStrategy() {
//        return receiveStrategy;
//    }
//
//    /**
//     * @param receiveStrategy
//     */
//    public void setReceiveStrategy(String receiveStrategy) {
//        this.receiveStrategy = receiveStrategy;
//    }
//
//    /**
//     * @return join_date
//     */
//    public Date getJoinDate() {
//        return joinDate;
//    }
//
//    /**
//     * @param joinDate
//     */
//    public void setJoinDate(Date joinDate) {
//        this.joinDate = joinDate;
//    }
//
//    /**
//     * @return is_master
//     */
//    public String getIsMaster() {
//        return isMaster;
//    }
//
//    /**
//     * @param isMaster
//     */
//    public void setIsMaster(String isMaster) {
//        this.isMaster = isMaster;
//    }
//}