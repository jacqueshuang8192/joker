//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//import java.util.Date;
//import java.util.List;
//
///**
// * one yuan treasure
// * Created by yrou on 4/20/2016.
// */
//@Table(name="t_online_treasure_activity")
//public class TOnlineTreasureActivity {
//    @Id
//    private Long id;
//
//    @Column(name = "treasure_id")
//    private Long treasureId;
//
//    @Column(name = "agent_id")
//    private Long agentId;
//
//    /**
//     * 分组ID
//     */
//    @Column(name = "group_id")
//    private Long groupId;
//
//    /**
//     * 分组名称
//     */
//    @Transient
//    private String groupName;
//
//    /**
//     * 产品名称
//     */
//    @Column(name = "produce_name")
//    private String produceName;
//
//    /**
//     * 产品描述
//     */
//    @Column(name = "produce_description")
//    private String produceDescription;
//
//    /**
//     * 活动描述
//     */
//    @Column(name = "activity_description")
//    private String activityDescription;
//
//    /**
//     * 小图标
//     */
//    @Column(name = "produce_small_icon_url")
//    private String produceSmallIconUrl;
//
//    /**
//     * 大图标
//     */
//    @Column(name = "produce_big_icon_url")
//    private String produceBigIconUrl;
//
//    /**
//     * 产地
//     */
//    @Column(name = "produce_area")
//    private String produceArea;
//
//    /**
//     * 颜色
//     */
//    @Column(name = "produce_color")
//    private String produceColor;
//
//    /**
//     * 实际价格
//     */
//    @Column(name = "produce_actual_price")
//    private Integer produceActualPrice;
//
//    /**
//     * 活动类型
//     */
//    private String type;
//
//    @Column(name = "city_id")
//    private Long cityId;
//
//    /**
//     * 活动地点
//     */
//    private String city;
//
//    /**
//     * 开奖阈值
//     */
//    private Integer threshold;
//
//    /**
//     * 活动状态：1草稿；2发布；3过期
//     */
//    private String status;
//
//    /**
//     * 获奖码
//     */
//    @Column(name = "reward_code")
//    private String rewardCode;
//
//    /**
//     * 获奖者ID
//     */
//    @Column(name = "winner_id")
//    private Long winnerId;
//
//    /**
//     * 获奖者名称
//     */
//    @Column(name = "winner_name")
//    private String winnerName;
//
//    @Column(name = "selled_amount")
//    private Integer selledAmount;
//
//    @Column(name = "draw_time")
//    private Date drawTime;
//
//    @Column(name = "address_id")
//    private Long addressId;
//
//    @Column(name = "category_id")
//    private Long categoryId;
//
//    @Transient
//    private List<TOnlineTreasureRecord> records;
//
//    /**
//     * 剩余开奖时间，毫秒
//     */
//    @Transient
//    private Long leftTime;
//
//    public String getActivityDescription() {
//        return activityDescription;
//    }
//
//    public void setActivityDescription(String activityDescription) {
//        this.activityDescription = activityDescription;
//    }
//
//    public String getCity() {
//        return city;
//    }
//
//    public void setCity(String city) {
//        this.city = city;
//    }
//
//    public Long getGroupId() {
//        return groupId;
//    }
//
//    public void setGroupId(Long groupId) {
//        this.groupId = groupId;
//    }
//
//    public String getGroupName() {
//        return groupName;
//    }
//
//    public void setGroupName(String groupName) {
//        this.groupName = groupName;
//    }
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Integer getProduceActualPrice() {
//        return produceActualPrice;
//    }
//
//    public void setProduceActualPrice(Integer produceActualPrice) {
//        this.produceActualPrice = produceActualPrice;
//    }
//
//    public String getProduceArea() {
//        return produceArea;
//    }
//
//    public void setProduceArea(String produceArea) {
//        this.produceArea = produceArea;
//    }
//
//    public String getProduceBigIconUrl() {
//        return produceBigIconUrl;
//    }
//
//    public void setProduceBigIconUrl(String produceBigIconUrl) {
//        this.produceBigIconUrl = produceBigIconUrl;
//    }
//
//    public String getProduceColor() {
//        return produceColor;
//    }
//
//    public void setProduceColor(String produceColor) {
//        this.produceColor = produceColor;
//    }
//
//    public String getProduceDescription() {
//        return produceDescription;
//    }
//
//    public void setProduceDescription(String produceDescription) {
//        this.produceDescription = produceDescription;
//    }
//
//    public String getProduceName() {
//        return produceName;
//    }
//
//    public void setProduceName(String produceName) {
//        this.produceName = produceName;
//    }
//
//    public String getProduceSmallIconUrl() {
//        return produceSmallIconUrl;
//    }
//
//    public void setProduceSmallIconUrl(String produceSmallIconUrl) {
//        this.produceSmallIconUrl = produceSmallIconUrl;
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
//    public Integer getThreshold() {
//        return threshold;
//    }
//
//    public void setThreshold(Integer threshold) {
//        this.threshold = threshold;
//    }
//
//    public String getType() {
//        return type;
//    }
//
//    public void setType(String type) {
//        this.type = type;
//    }
//
//    public String getRewardCode() {
//        return rewardCode;
//    }
//
//    public void setRewardCode(String rewardCode) {
//        this.rewardCode = rewardCode;
//    }
//
//    public Long getWinnerId() {
//        return winnerId;
//    }
//
//    public void setWinnerId(Long winnerId) {
//        this.winnerId = winnerId;
//    }
//
//    public String getWinnerName() {
//        return winnerName;
//    }
//
//    public void setWinnerName(String winnerName) {
//        this.winnerName = winnerName;
//    }
//
//    public Long getTreasureId() {
//        return treasureId;
//    }
//
//    public void setTreasureId(Long treasureId) {
//        this.treasureId = treasureId;
//    }
//
//    public List<TOnlineTreasureRecord> getRecords() {
//        return records;
//    }
//
//    public void setRecords(List<TOnlineTreasureRecord> records) {
//        this.records = records;
//    }
//
//    public Integer getSelledAmount() {
//        return selledAmount;
//    }
//
//    public void setSelledAmount(Integer selledAmount) {
//        this.selledAmount = selledAmount;
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
//    public Date getDrawTime() {
//        return drawTime;
//    }
//
//    public void setDrawTime(Date drawTime) {
//        this.drawTime = drawTime;
//    }
//
//    public Long getLeftTime() {
//        return leftTime;
//    }
//
//    public void setLeftTime(Long leftTime) {
//        this.leftTime = leftTime;
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
//    public Long getCityId() {
//        return cityId;
//    }
//
//    public void setCityId(Long cityId) {
//        this.cityId = cityId;
//    }
//
//    public Long getAddressId() {
//        return addressId;
//    }
//
//    public void setAddressId(Long addressId) {
//        this.addressId = addressId;
//    }
//}
