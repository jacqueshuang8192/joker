//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_store_category")
//public class TStoreCategory {
//    @Id
//    @Column(name = "category_id")
//    private Long categoryId;
//    @Column(name = "parent_id")
//    private Long parentId;
//    @Column(name = "name")
//    private String name;
//    @Column(name = "photo")
//    private String photo;
//    @Column(name = "sequence")
//    private Integer sequence;
//
//    public Long getCategoryId() {
//        return categoryId;
//    }
//
//    public void setCategoryId(Long categoryId) {
//        this.categoryId = categoryId;
//    }
//
//    public Long getParentId() {
//        return parentId;
//    }
//
//    public void setParentId(Long parentId) {
//        this.parentId = parentId;
//    }
//
//    public String getName() {
//        return name;
//    }
//
//    public void setName(String name) {
//        this.name = name;
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
//    public Integer getSequence() {
//        return sequence;
//    }
//
//    public void setSequence(Integer sequence) {
//        this.sequence = sequence;
//    }
//
//}