//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//
//@Table(name = "t_compere")
//public class TCompere {
//    @Id
//    @Column(name = "compere_id")
//    private Long compereId;
//
//    @Column(name = "agent_id")
//    private Long agentId;
//
//    @Column(name = "province_id")
//    private Long provinceId;
//
//    @Column(name = "city_id")
//    private Long cityId;
//
//    @Column(name = "town_id")
//    private Long townId;
//
//    @Transient
//    private TUser user;
//
//    private String tel;
//
//    private String mail;
//
//    private Long level;
//
//    @Column(name = "invitation_code")
//    private String invitationCode;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    @Column(name = "expiric_value")
//    private Integer expiricValue;
//
//    @Column(name = "channel_num")
//    private String channelNum;
//
//    @Column(name = "channel_name")
//    private String channelName;
//
//    @Column(name = "extract_income")
//    private Long extractIncome;
//
//    @Column(name = "player_num")
//    private Long playerNum;
//
//    @Column(name = "capture_status")
//    private Integer captureStatus;
//
//    /**
//     * 主播采矿攻击力
//     */
//    @Column(name = "mine_attack")
//    private Long mineAttack;
//
//    /**
//     * 主播采矿防御力
//     */
//    @Column(name = "mine_defense")
//    private Long mineDefense;
//
//    /**
//     * 主播采矿生命
//     */
//    @Column(name = "mine_life")
//    private Long mineLife;
//
//    /**
//     * 抓主播攻击力
//     */
//    @Column(name = "capture_attack")
//    private Long captureAttack;
//
//    /**
//     * 抓主播防御力
//     */
//    @Column(name = "capture_defense")
//    private Long captureDefense;
//
//    /**
//     * 抓主播中主播的剩余血量
//     */
//    @Column(name = "left_life")
//    private Long leftLife;
//
//    /**
//     * 抓主播中主播的总血量
//     */
//    @Column(name = "total_life")
//    private Long totalLife;
//
//    /**
//     * 所有者ID
//     */
//    @Column(name = "owner_id")
//    private Long ownerId;
//
//    /**
//     * 当俘虏被释放时间
//     */
//    @Column(name = "release_time")
//    private Date releaseTime;
//
//    /**
//     * 保护剩余时间
//     */
//    @Column(name = "protect_time")
//    private Date protectTime;
//
//    /**
//     * 主播称号
//     */
//    private String title;
////    @Column(name = "title_id")
////    private Long titleId;
//
//    /**
//     * 被玩家占有的收益
//     */
//    @Column(name = "shared_profit")
//    private Long sharedProfit;
//
//    @Column(name = "chatroom_id")
//    private String chatroomId;
//
//    private Integer priority;
//
//    /**
//     * @return compere_id
//     */
//    public Long getCompereId() {
//        return compereId;
//    }
//
//    /**
//     * @param compereId
//     */
//    public void setCompereId(Long compereId) {
//        this.compereId = compereId;
//    }
//
//    /**
//     * @return province_id
//     */
//    public Long getProvinceId() {
//        return provinceId;
//    }
//
//    /**
//     * @param provinceId
//     */
//    public void setProvinceId(Long provinceId) {
//        this.provinceId = provinceId;
//    }
//
//    /**
//     * @return city_id
//     */
//    public Long getCityId() {
//        return cityId;
//    }
//
//    /**
//     * @param cityId
//     */
//    public void setCityId(Long cityId) {
//        this.cityId = cityId;
//    }
//
//    /**
//     * @return town_id
//     */
//    public Long getTownId() {
//        return townId;
//    }
//
//    /**
//     * @param townId
//     */
//    public void setTownId(Long townId) {
//        this.townId = townId;
//    }
//
//    /**
//     * @return tel
//     */
//    public String getTel() {
//        return tel;
//    }
//
//    /**
//     * @param tel
//     */
//    public void setTel(String tel) {
//        this.tel = tel;
//    }
//
//    /**
//     * @return mail
//     */
//    public String getMail() {
//        return mail;
//    }
//
//    /**
//     * @param mail
//     */
//    public void setMail(String mail) {
//        this.mail = mail;
//    }
//
//    /**
//     * @return invitation_code
//     */
//    public String getInvitationCode() {
//        return invitationCode;
//    }
//
//    /**
//     * @param invitationCode
//     */
//    public void setInvitationCode(String invitationCode) {
//        this.invitationCode = invitationCode;
//    }
//
//    /**
//     * @return create_date
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
//
//    /**
//     * @return expiric_value
//     */
//    public Integer getExpiricValue() {
//        return expiricValue;
//    }
//
//    /**
//     * @param expiricValue
//     */
//    public void setExpiricValue(Integer expiricValue) {
//        this.expiricValue = expiricValue;
//    }
//
//    /**
//     * @return channel_num
//     */
//    public String getChannelNum() {
//        return channelNum;
//    }
//
//    /**
//     * @param channelNum
//     */
//    public void setChannelNum(String channelNum) {
//        this.channelNum = channelNum;
//    }
//
//    /**
//     * @return channel_name
//     */
//    public String getChannelName() {
//        return channelName;
//    }
//
//    /**
//     * @param channelName
//     */
//    public void setChannelName(String channelName) {
//        this.channelName = channelName;
//    }
//
//    public TUser getUser() {
//        return user;
//    }
//
//    public void setUser(TUser user) {
//        this.user = user;
//    }
//
//    public Long getLevel() {
//        return level;
//    }
//
//    public void setLevel(Long level) {
//        this.level = level;
//    }
//
//    public Long getAgentId() {
//        return agentId;
//    }
//
//    public void setAgentId(Long agentId) {
//        this.agentId = agentId;
//    }
//
//    public Long getPlayerNum() {
//        return playerNum;
//    }
//
//    public void setPlayerNum(Long playerNum) {
//        this.playerNum = playerNum;
//    }
//
//    public Integer getCaptureStatus() {
//        return captureStatus;
//    }
//
//    public void setCaptureStatus(Integer captureStatus) {
//        this.captureStatus = captureStatus;
//    }
//
//    public Long getLeftLife() {
//        return leftLife;
//    }
//
//    public void setLeftLife(Long leftLife) {
//        this.leftLife = leftLife;
//    }
//
//    public Long getTotalLife() {
//        return totalLife;
//    }
//
//    public void setTotalLife(Long totalLife) {
//        this.totalLife = totalLife;
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
//    public Date getReleaseTime() {
//        return releaseTime;
//    }
//
//    public void setReleaseTime(Date releaseTime) {
//        this.releaseTime = releaseTime;
//    }
//
//    public Date getProtectTime() {
//        return protectTime;
//    }
//
//    public void setProtectTime(Date protectTime) {
//        this.protectTime = protectTime;
//    }
//
////    public Long getTitleId() {
////        return titleId;
////    }
////
////    public void setTitleId(Long titleId) {
////        this.titleId = titleId;
////    }
//
//    public Long getSharedProfit() {
//        return sharedProfit;
//    }
//
//    public void setSharedProfit(Long sharedProfit) {
//        this.sharedProfit = sharedProfit;
//    }
//
//    public Long getExtractIncome() {
//        return extractIncome;
//    }
//
//    public void setExtractIncome(Long extractIncome) {
//        this.extractIncome = extractIncome;
//    }
//
//    public Long getMineAttack() {
//        return mineAttack;
//    }
//
//    public void setMineAttack(Long mineAttack) {
//        this.mineAttack = mineAttack;
//    }
//
//    public Long getMineDefense() {
//        return mineDefense;
//    }
//
//    public void setMineDefense(Long mineDefense) {
//        this.mineDefense = mineDefense;
//    }
//
//    public Long getMineLife() {
//        return mineLife;
//    }
//
//    public void setMineLife(Long mineLife) {
//        this.mineLife = mineLife;
//    }
//
//    public Long getCaptureAttack() {
//        return captureAttack;
//    }
//
//    public void setCaptureAttack(Long captureAttack) {
//        this.captureAttack = captureAttack;
//    }
//
//    public Long getCaptureDefense() {
//        return captureDefense;
//    }
//
//    public void setCaptureDefense(Long captureDefense) {
//        this.captureDefense = captureDefense;
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
//    public String getTitle() {
//        return title;
//    }
//
//    public void setTitle(String title) {
//        this.title = title;
//    }
//
//    public Integer getPriority() {
//        return priority;
//    }
//
//    public void setPriority(Integer priority) {
//        this.priority = priority;
//    }
//}