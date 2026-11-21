package com.hbi.model;

import java.util.Date;
import jakarta.persistence.*;

@Table(name = "t_user_goods_buy_record")
public class TUserGoodsBuyRecord {
	
	@Id
    @Column(name = "id")
    private Long id;

	@Column(name="user_id")
    private Long userId;

    private String type;

    @Column(name = "goods_id")
    private Long goodsId;

    @Column(name = "goods_photo")
    private String goodsPhoto;

    @Column(name = "goods_name")
    private String goodsName;

    @Column(name = "total_price")
    private Integer totalPrice;

    private Integer amount;

    @Column(name = "buy_date")
    private Date buyDate;

    public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	/**
     * @return userId
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * @param userId
     */
    public void setUserId(Long userId) {
        this.userId = userId;
    }

    /**
     * @return type
     */
    public String getType() {
        return type;
    }

    /**
     * @param type
     */
    public void setType(String type) {
        this.type = type;
    }

    /**
     * @return goods_id
     */
    public Long getGoodsId() {
        return goodsId;
    }

    /**
     * @param goodsId
     */
    public void setGoodsId(Long goodsId) {
        this.goodsId = goodsId;
    }

    /**
     * @return goodsPhoto
     */
    public String getGoodsPhoto() {
        return goodsPhoto;
    }

    /**
     * @param goodsPhoto
     */
    public void setGoodsPhoto(String goodsPhoto) {
        this.goodsPhoto = goodsPhoto;
    }

    /**
     * @return goods_name
     */
    public String getGoodsName() {
        return goodsName;
    }

    /**
     * @param goodsName
     */
    public void setGoodsName(String goodsName) {
        this.goodsName = goodsName;
    }

    /**
     * @return total_price
     */
    public Integer getTotalPrice() {
        return totalPrice;
    }

    /**
     * @param totalPrice
     */
    public void setTotalPrice(Integer totalPrice) {
        this.totalPrice = totalPrice;
    }

    /**
     * @return amount
     */
    public Integer getAmount() {
        return amount;
    }

    /**
     * @param amount
     */
    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    /**
     * @return buy_date
     */
    public Date getBuyDate() {
        return buyDate;
    }

    /**
     * @param buyDate
     */
    public void setBuyDate(Date buyDate) {
        this.buyDate = buyDate;
    }

}