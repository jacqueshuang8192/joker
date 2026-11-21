package com.hbi.cache.model;

import java.util.List;

import com.hbi.cache.CacheModel;

public class CacheMerchantStoreProfile extends CacheModel implements Comparable<CacheMerchantStoreProfile> {
    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Long id;
    private String storeName;
    private String storeLogo;
    private String storeAddress;
    private Float longitude;
    private Float latitude;
    private String storePhotos;
    private Integer averagePrice;
    private String contact;
    private String activityContent;
    private int hot;
    private double minGoodsPrice;
    private int goodsCount;
    private Long ownerId;
    private Long cityId;
    private String cityName;
    private Long townId;
    private String townName;
    private Long primaryCategoryId;
    private Long secondCategoryId;
    private String secondCategoryName;
    private String ownerUserType;
    private CacheCompereProfile owner;
    private List<CacheMerchantGoodsProfile> merchantGoods;
    private Integer adPriority;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public String getStoreLogo() {
        return storeLogo;
    }

    public void setStoreLogo(String storeLogo) {
        this.storeLogo = storeLogo;
    }

    public String getStoreAddress() {
        return storeAddress;
    }

    public void setStoreAddress(String storeAddress) {
        this.storeAddress = storeAddress;
    }

    public Float getLongitude() {
        return longitude;
    }

    public void setLongitude(Float longitude) {
        this.longitude = longitude;
    }

    public Float getLatitude() {
        return latitude;
    }

    public void setLatitude(Float latitude) {
        this.latitude = latitude;
    }

    public String getStorePhotos() {
        return storePhotos;
    }

    public void setStorePhotos(String storePhotos) {
        this.storePhotos = storePhotos;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getActivityContent() {
        return activityContent;
    }

    public void setActivityContent(String activityContent) {
        this.activityContent = activityContent;
    }

    public int getHot() {
        return hot;
    }

    public void setHot(int hot) {
        this.hot = hot;
    }

    public String getOwnerUserType() {
        return ownerUserType;
    }

    public void setOwnerUserType(String ownerUserType) {
        this.ownerUserType = ownerUserType;
    }

    public double getMinGoodsPrice() {
        return minGoodsPrice;
    }

    public void setMinGoodsPrice(double minGoodsPrice) {
        this.minGoodsPrice = minGoodsPrice;
    }

    public int getGoodsCount() {
        return goodsCount;
    }

    public void setGoodsCount(int goodsCount) {
        this.goodsCount = goodsCount;
    }

    public Long getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Long ownerId) {
        this.ownerId = ownerId;
    }

    public CacheCompereProfile getOwner() {
        return owner;
    }

    public void setOwner(CacheCompereProfile owner) {
        this.owner = owner;
    }

    public List<CacheMerchantGoodsProfile> getMerchantGoods() {
        return merchantGoods;
    }

    public void setMerchantGoods(List<CacheMerchantGoodsProfile> merchantGoods) {
        this.merchantGoods = merchantGoods;
    }

    public Integer getAdPriority() {
        return adPriority;
    }

    public void setAdPriority(Integer adPriority) {
        this.adPriority = adPriority;
    }

    public Long getSecondCategoryId() {
        return secondCategoryId;
    }

    public void setSecondCategoryId(Long secondCategoryId) {
        this.secondCategoryId = secondCategoryId;
    }

    public String getSecondCategoryName() {
        return secondCategoryName;
    }

    public void setSecondCategoryName(String secondCategoryName) {
        this.secondCategoryName = secondCategoryName;
    }

    public Long getCityId() {
        return cityId;
    }

    public void setCityId(Long cityId) {
        this.cityId = cityId;
    }

    public Integer getAveragePrice() {
        return averagePrice;
    }

    public void setAveragePrice(Integer averagePrice) {
        this.averagePrice = averagePrice;
    }

    public Long getPrimaryCategoryId() {
        return primaryCategoryId;
    }

    public void setPrimaryCategoryId(Long primaryCategoryId) {
        this.primaryCategoryId = primaryCategoryId;
    }

    public String getCityName() {
        return cityName;
    }

    public void setCityName(String cityName) {
        this.cityName = cityName;
    }

    public Long getTownId() {
        return townId;
    }

    public void setTownId(Long townId) {
        this.townId = townId;
    }

    public String getTownName() {
        return townName;
    }

    public void setTownName(String townName) {
        this.townName = townName;
    }

    @Override
    public int compareTo(CacheMerchantStoreProfile o) {
        if (hot > o.getHot()) {
            return 1;
        } else if (hot < o.getHot()) {
            return -1;
        }
        return 0;
    }

}
