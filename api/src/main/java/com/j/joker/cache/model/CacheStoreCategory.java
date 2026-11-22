package com.j.joker.cache.model;

import java.util.List;

public class CacheStoreCategory {
    private Long categoryId;
    private Long parentId;
    private String name;
    private String photo;
    private Integer count;
    private Integer sequence;
    private List<CacheStoreCategory> childStoreCategories;

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public Integer getSequence() {
        return sequence;
    }

    public void setSequence(Integer sequence) {
        this.sequence = sequence;
    }

    public List<CacheStoreCategory> getChildStoreCategories() {
        return childStoreCategories;
    }

    public void setChildStoreCategories(List<CacheStoreCategory> childStoreCategories) {
        this.childStoreCategories = childStoreCategories;
    }

}