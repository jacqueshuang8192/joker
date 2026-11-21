//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//
//
///**
// * one yuan treasure
// * Created by yrou on 4/20/2016.
// */
//@Table(name="t_online_treasure")
//public class TOnlineTreasure {
//    @Id
//    private Long id;
//
//    @Column(name = "group_id")
//    private Long groupId;
//
//    @Transient
//    private String groupName;
//
//    @Column(name = "agent_id")
//    private Long agentId;
//
//    @Column(name = "produce_name")
//    private String produceName;
//
//    @Column(name = "produce_description")
//    private String produceDescription;
//
//    @Column(name = "activity_description")
//    private String activityDescription;
//
//    @Column(name = "produce_small_icon_url")
//    private String produceSmallIconUrl;
//
//    @Column(name = "produce_big_icon_url")
//    private String produceBigIconUrl;
//
//    @Column(name = "produce_area")
//    private String produceArea;
//
//    @Column(name = "produce_color")
//    private String produceColor;
//
//    @Column(name = "produce_actual_price")
//    private Integer produceActualPrice;
//
//    private String type;
//
//    @Column(name = "category_id")
//    private Long categoryId;
//
//    @Column(name = "city_id")
//    private Long cityId;
//
//    private String city;
//
//    private Integer threshold;
//
//    private Integer inventory;
//
//    private String status;
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
//    public Integer getInventory() {
//        return inventory;
//    }
//
//    public void setInventory(Integer inventory) {
//        this.inventory = inventory;
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
//}
