package com.j.joker.cache.model;

import java.util.Date;

import com.j.joker.cache.CacheModel;

public class CacheMerchantGoodsProfile extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Long id;
    private String goodsName;
    private Long primaryCategoryId;
    private Long secondaryCategoryId;
    private Integer goodsPrice;
    private Date startTime;
    private Date endTime;
    private String goodsDescribe;
    private String goodsPhotos;
    private Long storeId;
    private Integer hot;
    private CacheMerchantStoreProfile store;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getGoodsName() {
        return goodsName;
    }

    public void setGoodsName(String goodsName) {
        this.goodsName = goodsName;
    }

    public Long getPrimaryCategoryId() {
        return primaryCategoryId;
    }

    public void setPrimaryCategoryId(Long primaryCategoryId) {
        this.primaryCategoryId = primaryCategoryId;
    }

    public Long getSecondaryCategoryId() {
        return secondaryCategoryId;
    }

    public void setSecondaryCategoryId(Long secondaryCategoryId) {
        this.secondaryCategoryId = secondaryCategoryId;
    }

    public Integer getGoodsPrice() {
        return goodsPrice;
    }

    public void setGoodsPrice(Integer goodsPrice) {
        this.goodsPrice = goodsPrice;
    }

    public Date getStartTime() {
        return startTime;
    }

    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }

    public Date getEndTime() {
        return endTime;
    }

    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }

    public String getGoodsDescribe() {
        return goodsDescribe;
    }

    public void setGoodsDescribe(String goodsDescribe) {
        this.goodsDescribe = goodsDescribe;
    }

    public String getGoodsPhotos() {
        return goodsPhotos;
    }

    public void setGoodsPhotos(String goodsPhotos) {
        this.goodsPhotos = goodsPhotos;
    }

    public Long getStoreId() {
        return storeId;
    }

    public void setStoreId(Long storeId) {
        this.storeId = storeId;
    }

    public Integer getHot() {
        return hot;
    }

    public void setHot(Integer hot) {
        this.hot = hot;
    }

    public CacheMerchantStoreProfile getStore() {
        return store;
    }

    public void setStore(CacheMerchantStoreProfile store) {
        this.store = store;
    }

}
