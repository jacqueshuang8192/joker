package com.linkxin.douyouPlayer.vo;

import java.util.List;

/**
 * Created by lxy on 2016/5/11.
 */
public class StoreCategory {

    /**
     * categoryId : 1
     * childStoreCategories : [{"categoryId":11,"count":0,"name":"火锅","parentId":1,"photo":"","sequence":2},{"categoryId":12,"count":0,"name":"自助餐","parentId":1,"photo":"","sequence":3},{"categoryId":13,"count":0,"name":"西餐","parentId":1,"photo":"","sequence":4},{"categoryId":14,"count":0,"name":"烧烤/烤鱼","parentId":1,"photo":"","sequence":5},{"categoryId":10,"count":0,"name":"料理","parentId":1,"photo":"","sequence":1}]
     * count : 0
     * name : 美食天堂
     * photo : mstt
     * sequence : 3
     */

    private long categoryId;
    private int count;
    private String name;
    private String photo;
    private int sequence;
    private List<SubCategory> childStoreCategories;

    public long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(long categoryId) {
        this.categoryId = categoryId;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
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

    public int getSequence() {
        return sequence;
    }

    public void setSequence(int sequence) {
        this.sequence = sequence;
    }

    public List<SubCategory> getChildStoreCategories() {
        return childStoreCategories;
    }

    public void setChildStoreCategories(List<SubCategory> childStoreCategories) {
        this.childStoreCategories = childStoreCategories;
    }
}
