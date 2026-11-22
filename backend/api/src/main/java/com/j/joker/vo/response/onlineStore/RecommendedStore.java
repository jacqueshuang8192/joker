package com.j.joker.vo.response.onlineStore;

import java.util.List;

import com.j.joker.cache.model.CacheMerchantStoreProfile;

public class RecommendedStore {

    private Long categoryId;
    private String categoryName;
    private List<CacheMerchantStoreProfile> stores;

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public List<CacheMerchantStoreProfile> getStores() {
        return stores;
    }

    public void setStores(List<CacheMerchantStoreProfile> stores) {
        this.stores = stores;
    }

}
