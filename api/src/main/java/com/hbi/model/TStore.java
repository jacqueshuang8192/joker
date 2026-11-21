//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_store")
//public class TStore {
//
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "store_name")
//    private String storeName;
//    @Column(name = "store_logo")
//    private String storeLogo;
//    @Column(name = "province_id")
//    private Long provinceId;
//    @Column(name = "city_id")
//    private Long cityId;
//    @Column(name = "town_id")
//    private Long townId;
//    @Column(name = "store_address")
//    private String storeAddress;
//    @Column(name = "longitude")
//    private Float longitude;
//    @Column(name = "latitude")
//    private Float latitude;
//    @Column(name = "activity_content")
//    private String activityContent;
//    @Column(name = "store_photos")
//    private String storePhotos;
//    @Column(name = "owner_id")
//    private Long ownerId;
//    @Column(name = "owner_user_type")
//    private String ownerUserType;
//    @Column(name = "contact")
//    private String contact;
//    @Column(name = "primary_category_id")
//    private Long primaryCategoryId;
//    @Column(name = "secondary_category_id")
//    private Long secondaryCategoryId;
//    @Column(name = "min_goods_price")
//    private Double minGoodsPrice;
//    @Column(name = "goods_count")
//    private Integer goodsCount;
//    @Column(name = "status")
//    private String status;
//    @Column(name = "hot")
//    private Integer hot;
//    @Column(name = "ad_priority")
//    private Integer adPriority;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getStoreName() {
//        return storeName;
//    }
//
//    public void setStoreName(String storeName) {
//        this.storeName = storeName;
//    }
//
//    public String getStoreLogo() {
//        return storeLogo;
//    }
//
//    public void setStoreLogo(String storeLogo) {
//        this.storeLogo = storeLogo;
//    }
//
//    public Long getProvinceId() {
//        return provinceId;
//    }
//
//    public void setProvinceId(Long provinceId) {
//        this.provinceId = provinceId;
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
//    public Long getTownId() {
//        return townId;
//    }
//
//    public void setTownId(Long townId) {
//        this.townId = townId;
//    }
//
//    public String getStoreAddress() {
//        return storeAddress;
//    }
//
//    public void setStoreAddress(String storeAddress) {
//        this.storeAddress = storeAddress;
//    }
//
//    public Float getLongitude() {
//        return longitude;
//    }
//
//    public void setLongitude(Float longitude) {
//        this.longitude = longitude;
//    }
//
//    public Float getLatitude() {
//        return latitude;
//    }
//
//    public void setLatitude(Float latitude) {
//        this.latitude = latitude;
//    }
//
//    public String getActivityContent() {
//        return activityContent;
//    }
//
//    public void setActivityContent(String activityContent) {
//        this.activityContent = activityContent;
//    }
//
//    public String getStorePhotos() {
//        return storePhotos;
//    }
//
//    public void setStorePhotos(String storePhotos) {
//        this.storePhotos = storePhotos;
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
//    public String getOwnerUserType() {
//        return ownerUserType;
//    }
//
//    public void setOwnerUserType(String ownerUserType) {
//        this.ownerUserType = ownerUserType;
//    }
//
//    public String getContact() {
//        return contact;
//    }
//
//    public void setContact(String contact) {
//        this.contact = contact;
//    }
//
//    public Long getPrimaryCategoryId() {
//        return primaryCategoryId;
//    }
//
//    public void setPrimaryCategoryId(Long primaryCategoryId) {
//        this.primaryCategoryId = primaryCategoryId;
//    }
//
//    public Long getSecondaryCategoryId() {
//        return secondaryCategoryId;
//    }
//
//    public void setSecondaryCategoryId(Long secondaryCategoryId) {
//        this.secondaryCategoryId = secondaryCategoryId;
//    }
//
//    public Double getMinGoodsPrice() {
//        return minGoodsPrice;
//    }
//
//    public void setMinGoodsPrice(Double minGoodsPrice) {
//        this.minGoodsPrice = minGoodsPrice;
//    }
//
//    public Integer getGoodsCount() {
//        return goodsCount;
//    }
//
//    public void setGoodsCount(Integer goodsCount) {
//        this.goodsCount = goodsCount;
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
//    public Integer getHot() {
//        return hot;
//    }
//
//    public void setHot(Integer hot) {
//        this.hot = hot;
//    }
//
//    public Integer getAdPriority() {
//        return adPriority;
//    }
//
//    public void setAdPriority(Integer adPriority) {
//        this.adPriority = adPriority;
//    }
//}