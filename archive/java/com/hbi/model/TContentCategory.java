//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_content_category")
//public class TContentCategory {
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
//    private String code;
//
//    @Column(name = "create_date")
//    private Date createDate;
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
//
//    /**
//     * @return code
//     */
//    public String getCode() {
//        return code;
//    }
//
//    /**
//     * @param code
//     */
//    public void setCode(String code) {
//        this.code = code;
//    }
//
//    /**
//     * @return create_date
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//}