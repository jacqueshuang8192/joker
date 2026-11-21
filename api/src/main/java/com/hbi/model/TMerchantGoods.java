//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_merchant_goods")
//public class TMerchantGoods {
//
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "goods_name")
//    private String goodsName;
//    @Column(name = "goods_price")
//    private Integer goodsPrice;
//    @Column(name = "start_time")
//    private Date startTime;
//    @Column(name = "end_time")
//    private Date endTime;
//    @Column(name = "goods_describe")
//    private String goodsDescribe;
//    @Column(name = "goods_photos")
//    private String goodsPhotos;
//    @Column(name = "store_id")
//    private Long storeId;
//    @Column(name = "status")
//    private String status;
//    @Column(name = "hot")
//    private Integer hot;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getGoodsName() {
//        return goodsName;
//    }
//
//    public void setGoodsName(String goodsName) {
//        this.goodsName = goodsName;
//    }
//
//    public Integer getGoodsPrice() {
//        return goodsPrice;
//    }
//
//    public void setGoodsPrice(Integer goodsPrice) {
//        this.goodsPrice = goodsPrice;
//    }
//
//    public Date getStartTime() {
//        return startTime;
//    }
//
//    public void setStartTime(Date startTime) {
//        this.startTime = startTime;
//    }
//
//    public Date getEndTime() {
//        return endTime;
//    }
//
//    public void setEndTime(Date endTime) {
//        this.endTime = endTime;
//    }
//
//    public String getGoodsDescribe() {
//        return goodsDescribe;
//    }
//
//    public void setGoodsDescribe(String goodsDescribe) {
//        this.goodsDescribe = goodsDescribe;
//    }
//
//    public String getGoodsPhotos() {
//        return goodsPhotos;
//    }
//
//    public void setGoodsPhotos(String goodsPhotos) {
//        this.goodsPhotos = goodsPhotos;
//    }
//
//    public Long getStoreId() {
//        return storeId;
//    }
//
//    public void setStoreId(Long storeId) {
//        this.storeId = storeId;
//    }
//
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    public Integer getHot() {
//        return hot;
//    }
//
//    public void setHot(Integer hot) {
//        this.hot = hot;
//    }
//}