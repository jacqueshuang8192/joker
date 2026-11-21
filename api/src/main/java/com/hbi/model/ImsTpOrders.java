package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Table;

/**
 * Created by muzi on 06/12/2017.
 */
@Table(name = "ims_tporders")
public class ImsTpOrders {
    @Column(name = "orderid")
    private Integer orderId;

    @Column(name = "order_no")
    private String orderNo;

    @Column(name = "goodsid")
    private Integer goodsId;

    @Column(name = "price")
    private Double price;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "ordersstatus")
    private Integer orderstatus;

    @Column(name = "count")
    private Integer count;

    @Column(name = "type")
    private Integer type;

    @Column(name = "create_at")
    private String createAt;

    @Column(name = "parentid")
    private Integer parentId;

    @Column(name = "commissionlevel")
    private Integer commissionlevel;

    @Column(name = "year")
    private Integer year;

    @Column(name = "month")
    private Integer month;

    @Column(name = "myselfrebate")
    private Double myselfRebate;

    @Column(name = "player_id")
    private Integer playerId;

    @Column(name = "thirdparty_order_num")
    private String thirdpartyOrderNum;

    @Column(name = "callback_time")
    private String callbackTime;

    @Column(name = "actually_paid")
    private String actuallyPaid;

    @Column(name = "wx_order_num")
    private String wxOrderNum;

    @Column(name = "good_type")
    private Integer goodType;

    @Column(name = "commission")
    private Integer commission;

    @Column(name = "commission_money")
    private Integer commissionMoney;

    public Integer getCommission() {
        return commission;
    }

    public void setCommission(Integer commission) {
        this.commission = commission;
    }

    public Integer getCommissionMoney() {
        return commissionMoney;
    }

    public void setCommissionMoney(Integer commissionMoney) {
        this.commissionMoney = commissionMoney;
    }

    public Integer getGoodType() {
        return goodType;
    }

    public void setGoodType(Integer goodType) {
        this.goodType = goodType;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public Integer getGoodsId() {
        return goodsId;
    }

    public void setGoodsId(Integer goodsId) {
        this.goodsId = goodsId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getOrderstatus() {
        return orderstatus;
    }

    public void setOrderstatus(Integer orderstatus) {
        this.orderstatus = orderstatus;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getCreateAt() {
        return createAt;
    }

    public void setCreateAt(String createAt) {
        this.createAt = createAt;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public Integer getCommissionlevel() {
        return commissionlevel;
    }

    public void setCommissionlevel(Integer commissionlevel) {
        this.commissionlevel = commissionlevel;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }


    public Integer getPlayerId() {
        return playerId;
    }

    public void setPlayerId(Integer playerId) {
        this.playerId = playerId;
    }

    public String getThirdpartyOrderNum() {
        return thirdpartyOrderNum;
    }

    public void setThirdpartyOrderNum(String thirdpartyOrderNum) {
        this.thirdpartyOrderNum = thirdpartyOrderNum;
    }

    public String getCallbackTime() {
        return callbackTime;
    }

    public void setCallbackTime(String callbackTime) {
        this.callbackTime = callbackTime;
    }

    public String getActuallyPaid() {
        return actuallyPaid;
    }

    public void setActuallyPaid(String actuallyPaid) {
        this.actuallyPaid = actuallyPaid;
    }

    public String getWxOrderNum() {
        return wxOrderNum;
    }

    public void setWxOrderNum(String wxOrderNum) {
        this.wxOrderNum = wxOrderNum;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public Double getMyselfRebate() {
        return myselfRebate;
    }

    public void setMyselfRebate(Double myselfRebate) {
        this.myselfRebate = myselfRebate;
    }
}
