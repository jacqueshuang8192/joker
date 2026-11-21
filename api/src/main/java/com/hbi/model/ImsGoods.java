package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Date;

@Table(name = "ims_tpgoods")
public class ImsGoods {
    @Id
    @Column(name = "goodsid")
    private Long goodsId;

    @Column(name = "goodsname")
    private String name;

    @Column(name = "photo")
    private String photo;

    @Column(name = "cardnum")
    private Integer amount;

    @Column(name = "goodsprice")
    private Integer price;

    @Column(name = "goodscreatetime")
    private Date createDate;

    @Column(name = "category_type")
    private String categoryType;

    @Column(name = "goodscreateperson")
    private String remark;

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public Long getGoodsId() {
        return goodsId;
    }

    public void setGoodsId(Long goodsId) {
        this.goodsId = goodsId;
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

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public Integer getPrice() {
        return price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }


    public String getCategoryType() {
        return categoryType;
    }

    public void setCategoryType(String categoryType) {
        this.categoryType = categoryType;
    }
}