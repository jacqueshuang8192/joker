package com.linkxin.douyouPlayer.vo;

/**
 * Created by lxy on 2016/5/11.
 */
public class SubCategory {

    /**
     * categoryId : 11
     * count : 0
     * name : 火锅
     * parentId : 1
     * photo :
     * sequence : 2
     */

    private long categoryId;
    private int count;
    private String name;
    private int parentId;
    private String photo;
    private int sequence;

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

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
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
}
