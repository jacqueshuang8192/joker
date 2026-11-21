//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//
//@Table(name = "t_mining_game")
//public class TMiningGame {
//    @Id
//    @Column(name = "ACTIVITY_ID")
//    private Long activityId;
//
//    @Column(name = "SOCIETY_ID")
//    private Long societyId;
//
//    @Transient
//    private String societyName;
//
//    @Transient
//    private Integer playerNum;
//
//    @Transient
//    private Integer compereNum;
//
//    @Transient
//    private String compereName;
//
//    @Transient
//    private String photo;
//
//    /**
//     * 纬度
//     */
//    @Transient
//    private double latitude;
//
//    /**
//     * 经度
//     */
//    @Transient
//    private double longitude;
//
//    @Column(name = "START_DATE")
//    private String startDate;
//
//    @Column(name = "END_DATE")
//    private String endDate;
//
//    @Column(name = "AWARD_AMOUNT")
//    private Long awardAmount;
//
//    @Column(name = "FULL_AMOUNT")
//    private Long fullAmount;
//
//    @Column(name = "REAL_AMOUNT")
//    private Long realAmount;
//
//    private String status;
//
//    @Column(name = "CREATE_DATE")
//    private String createDate;
//
//    /**
//     * 防守人数
//     */
//    @Transient
//    private Integer defenseNum;
//
//    /**
//     * 攻击人数
//     */
//    @Transient
//    private Integer attackerNum;
//
//    /**
//     * 一个抢矿活动最大抢夺人数，即矿坑数量
//     */
//    @Transient
//    private Integer maxAttackNum;
//
//    public Long getActivityId() {
//        return activityId;
//    }
//
//    public void setActivityId(Long activityId) {
//        this.activityId = activityId;
//    }
//
//    public Long getSocietyId() {
//        return societyId;
//    }
//
//    public void setSocietyId(Long societyId) {
//        this.societyId = societyId;
//    }
//
//    public String getStartDate() {
//        return startDate;
//    }
//
//    public void setStartDate(String startDate) {
//        this.startDate = startDate;
//    }
//
//    public String getEndDate() {
//        return endDate;
//    }
//
//    public void setEndDate(String endDate) {
//        this.endDate = endDate;
//    }
//
//    public Long getAwardAmount() {
//        return awardAmount;
//    }
//
//    public void setAwardAmount(Long awardAmount) {
//        this.awardAmount = awardAmount;
//    }
//
//    public Long getFullAmount() {
//        return fullAmount;
//    }
//
//    public void setFullAmount(Long fullAmount) {
//        this.fullAmount = fullAmount;
//    }
//
//    public Long getRealAmount() {
//        return realAmount;
//    }
//
//    public void setRealAmount(Long realAmount) {
//        this.realAmount = realAmount;
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
//    public String getCreateDate() {
//        return createDate;
//    }
//
//    public void setCreateDate(String createDate) {
//        this.createDate = createDate;
//    }
//
//    public String getSocietyName() {
//        return societyName;
//    }
//
//    public void setSocietyName(String societyName) {
//        this.societyName = societyName;
//    }
//
//    public Integer getPlayerNum() {
//        return playerNum;
//    }
//
//    public void setPlayerNum(Integer playerNum) {
//        this.playerNum = playerNum;
//    }
//
//    public Integer getCompereNum() {
//        return compereNum;
//    }
//
//    public void setCompereNum(Integer compereNum) {
//        this.compereNum = compereNum;
//    }
//
//    public String getCompereName() {
//        return compereName;
//    }
//
//    public void setCompereName(String compereName) {
//        this.compereName = compereName;
//    }
//
//    public String getPhoto() {
//        return photo;
//    }
//
//    public void setPhoto(String photo) {
//        this.photo = photo;
//    }
//
//    public Integer getDefenseNum() {
//        return defenseNum;
//    }
//
//    public void setDefenseNum(Integer defenseNum) {
//        this.defenseNum = defenseNum;
//    }
//
//    public Integer getMaxAttackNum() {
//        return maxAttackNum;
//    }
//
//    public void setMaxAttackNum(Integer maxAttackNum) {
//        this.maxAttackNum = maxAttackNum;
//    }
//
//    public Integer getAttackerNum() {
//        return attackerNum;
//    }
//
//    public void setAttackerNum(Integer attackerNum) {
//        this.attackerNum = attackerNum;
//    }
//
//    public double getLatitude() {
//        return latitude;
//    }
//
//    public void setLatitude(double latitude) {
//        this.latitude = latitude;
//    }
//
//    public double getLongitude() {
//        return longitude;
//    }
//
//    public void setLongitude(double longitude) {
//        this.longitude = longitude;
//    }
//}
