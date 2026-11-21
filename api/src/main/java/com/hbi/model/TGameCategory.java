//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_game_category")
//public class TGameCategory {
//    @Id
//    @Column(name = "category_id")
//    private Long categoryId;
//
//    @Column(name = "parent_id")
//    private Long parentId;
//
//    private String name;
//
//    private String remark;
//
//    /**
//     * @return category_id
//     */
//    public Long getCategoryId() {
//        return categoryId;
//    }
//
//    /**
//     * @param categoryId
//     */
//    public void setCategoryId(Long categoryId) {
//        this.categoryId = categoryId;
//    }
//
//    /**
//     * @return parent_id
//     */
//    public Long getParentId() {
//        return parentId;
//    }
//
//    /**
//     * @param parentId
//     */
//    public void setParentId(Long parentId) {
//        this.parentId = parentId;
//    }
//
//    /**
//     * @return name
//     */
//    public String getName() {
//        return name;
//    }
//
//    /**
//     * @param name
//     */
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    /**
//     * @return remark
//     */
//    public String getRemark() {
//        return remark;
//    }
//
//    /**
//     * @param remark
//     */
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//}