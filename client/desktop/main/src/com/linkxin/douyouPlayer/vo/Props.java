package com.linkxin.douyouPlayer.vo;

import android.text.TextUtils;

/**
 * 道具
 * Created by lxy on 2016/5/16.
 */
public class Props {

    /**
     * amount : 1
     * categoryCode :
     * categoryId : 23
     * categoryName : 饭卡
     * categoryPhoto : icon_silvermeal.png
     * categoryType : 4
     * id : 1777
     * totalPrice : 8500
     * userId : 272
     */

    private int amount;
    private String categoryCode;
    private long categoryId;
    private String categoryName;
    private String categoryPhoto;
    private String categoryType;
    private long id;
    private int totalPrice;
    private long userId;

    public boolean isLoudSpeaker(){
        return TextUtils.equals("loudspeaker",categoryCode);
    }
    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getCategoryPhoto() {
        return categoryPhoto;
    }

    public void setCategoryPhoto(String categoryPhoto) {
        this.categoryPhoto = categoryPhoto;
    }

    public String getCategoryType() {
        return categoryType;
    }

    public void setCategoryType(String categoryType) {
        this.categoryType = categoryType;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(int totalPrice) {
        this.totalPrice = totalPrice;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

}
