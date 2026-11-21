//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Table;
//
//@Table(name = "t_user_goods")
//public class TUserGoods {
//    @Column(name = "id")
//    private Long id;
//
//    @Column(name = "user_id")
//    private Long userId;
//
//    @Column(name = "total_price")
//    private Integer totalPrice;
//
//    private Integer amount;
//
//    @Column(name = "unit_price")
//    private Integer unitPrice;
//
//    @Column(name = "goods_id")
//    private Long goodsId;
//
//    /**
//     * @return order_id
//     */
//    public Long getId() {
//        return id;
//    }
//
//    /**
//     * @param id
//     */
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    /**
//     * @return userId
//     */
//    public Long getUserId() {
//        return userId;
//    }
//
//    /**
//     * @param userId
//     */
//    public void setUserId(Long userId) {
//        this.userId = userId;
//    }
//
//    /**
//     * @return total_price
//     */
//    public Integer getTotalPrice() {
//        return totalPrice;
//    }
//
//    /**
//     * @param totalPrice
//     */
//    public void setTotalPrice(Integer totalPrice) {
//        this.totalPrice = totalPrice;
//    }
//
//    /**
//     * @return amount
//     */
//    public Integer getAmount() {
//        return amount;
//    }
//
//    /**
//     * @param amount
//     */
//    public void setAmount(Integer amount) {
//        this.amount = amount;
//    }
//
//    public Integer getUnitPrice() {
//        return unitPrice;
//    }
//
//    public void setUnitPrice(Integer unitPrice) {
//        this.unitPrice = unitPrice;
//    }
//
//    public Long getGoodsId() {
//        return goodsId;
//    }
//
//    public void setGoodsId(Long goodsId) {
//        this.goodsId = goodsId;
//    }
//}