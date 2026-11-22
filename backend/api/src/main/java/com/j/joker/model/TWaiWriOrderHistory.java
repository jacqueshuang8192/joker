package com.j.joker.model;


import java.util.Date;

public class TWaiWriOrderHistory {
    public Integer userId;
    public String orderId;
    public String createTime;
    public Integer money;
    public Integer surplusMoney;
    public Integer status;
    public Integer result;


    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public Integer getMoney() {
        return money;
    }

    public void setMoney(Integer money) {
        this.money = money;
    }

    public Integer getSurplusMoney() {
        return surplusMoney;
    }

    public void setSurplusMoney(Integer surplusMoney) {
        this.surplusMoney = surplusMoney;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getResult() {
        return result;
    }

    public void setResult(Integer result) {
        this.result = result;
    }
}
