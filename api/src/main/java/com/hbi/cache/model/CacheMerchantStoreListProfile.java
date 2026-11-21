package com.hbi.cache.model;

import com.hbi.cache.CacheModel;

public class CacheMerchantStoreListProfile extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Long id;
    private String storeName;
    private String storeLogo;
    private String storePhotos;
    private Double minGoodsPrice;
    private String longitude;
    private String latitude;
    private int hot;

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

    public String getStorePhotos() {
        return storePhotos;
    }

    public void setStorePhotos(String storePhotos) {
        this.storePhotos = storePhotos;
    }

    public Double getMinGoodsPrice() {
        return minGoodsPrice;
    }

    public void setMinGoodsPrice(Double minGoodsPrice) {
        this.minGoodsPrice = minGoodsPrice;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public int getHot() {
        return hot;
    }

    public void setHot(int hot) {
        this.hot = hot;
    }

}
