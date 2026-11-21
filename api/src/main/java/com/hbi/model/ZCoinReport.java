//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "z_coin_report")
//public class ZCoinReport {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    private String produce;
//
//    @Column(name = "playerPay")
//    private String playerpay;
//
//    @Column(name = "systemProduce")
//    private String systemproduce;
//
//    @Column(name = "activityProduce")
//    private String activityproduce;
//
//    @Column(name = "robotProduce")
//    private String robotproduce;
//
//    private String cost;
//
//    @Column(name = "userHold")
//    private String userhold;
//
//    @Column(name = "userExchange")
//    private String userexchange;
//
//    @Column(name = "userCost")
//    private String usercost;
//
//    @Column(name = "societyHold")
//    private String societyhold;
//
//    /**
//     * @return id
//     */
//    public Long getId() {
//        return id;
//    }
//
//    /**
//     * @param id
//     */
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    /**
//     * @return produce
//     */
//    public String getProduce() {
//        return produce;
//    }
//
//    /**
//     * @param produce
//     */
//    public void setProduce(String produce) {
//        this.produce = produce;
//    }
//
//    /**
//     * @return playerPay
//     */
//    public String getPlayerpay() {
//        return playerpay;
//    }
//
//    /**
//     * @param playerpay
//     */
//    public void setPlayerpay(String playerpay) {
//        this.playerpay = playerpay;
//    }
//
//    /**
//     * @return systemProduce
//     */
//    public String getSystemproduce() {
//        return systemproduce;
//    }
//
//    /**
//     * @param systemproduce
//     */
//    public void setSystemproduce(String systemproduce) {
//        this.systemproduce = systemproduce;
//    }
//
//    /**
//     * @return activityProduce
//     */
//    public String getActivityproduce() {
//        return activityproduce;
//    }
//
//    /**
//     * @param activityproduce
//     */
//    public void setActivityproduce(String activityproduce) {
//        this.activityproduce = activityproduce;
//    }
//
//    /**
//     * @return robotProduce
//     */
//    public String getRobotproduce() {
//        return robotproduce;
//    }
//
//    /**
//     * @param robotproduce
//     */
//    public void setRobotproduce(String robotproduce) {
//        this.robotproduce = robotproduce;
//    }
//
//    /**
//     * @return cost
//     */
//    public String getCost() {
//        return cost;
//    }
//
//    /**
//     * @param cost
//     */
//    public void setCost(String cost) {
//        this.cost = cost;
//    }
//
//    /**
//     * @return userHold
//     */
//    public String getUserhold() {
//        return userhold;
//    }
//
//    /**
//     * @param userhold
//     */
//    public void setUserhold(String userhold) {
//        this.userhold = userhold;
//    }
//
//    /**
//     * @return userExchange
//     */
//    public String getUserexchange() {
//        return userexchange;
//    }
//
//    /**
//     * @param userexchange
//     */
//    public void setUserexchange(String userexchange) {
//        this.userexchange = userexchange;
//    }
//
//    /**
//     * @return userCost
//     */
//    public String getUsercost() {
//        return usercost;
//    }
//
//    /**
//     * @param usercost
//     */
//    public void setUsercost(String usercost) {
//        this.usercost = usercost;
//    }
//
//    /**
//     * @return societyHold
//     */
//    public String getSocietyhold() {
//        return societyhold;
//    }
//
//    /**
//     * @param societyhold
//     */
//    public void setSocietyhold(String societyhold) {
//        this.societyhold = societyhold;
//    }
//}