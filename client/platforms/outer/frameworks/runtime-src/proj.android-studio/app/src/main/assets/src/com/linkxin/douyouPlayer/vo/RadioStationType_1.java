package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by zhongweihao on 16/4/27.
 */
public class RadioStationType implements Parcelable {


    /**
     * code : JOKE
     * createDate : 1457341343000
     * creatorId : 27
     * id : 1
     * lastModifierId : 27
     * lastModifyDate : 1457341343000
     * name : 开心段子
     * remark : 开心段子
     * status : 2
     */

    private String code;
    private long createDate;
    private long creatorId;
    private long id;
    private long lastModifierId;
    private long lastModifyDate;
    private String name;
    private String remark;
    private String status;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public long getCreateDate() {
        return createDate;
    }

    public void setCreateDate(long createDate) {
        this.createDate = createDate;
    }

    public long getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(long creatorId) {
        this.creatorId = creatorId;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getLastModifierId() {
        return lastModifierId;
    }

    public void setLastModifierId(long lastModifierId) {
        this.lastModifierId = lastModifierId;
    }

    public long getLastModifyDate() {
        return lastModifyDate;
    }

    public void setLastModifyDate(long lastModifyDate) {
        this.lastModifyDate = lastModifyDate;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.code);
        dest.writeLong(this.createDate);
        dest.writeLong(this.creatorId);
        dest.writeLong(this.id);
        dest.writeLong(this.lastModifierId);
        dest.writeLong(this.lastModifyDate);
        dest.writeString(this.name);
        dest.writeString(this.remark);
        dest.writeString(this.status);
    }

    public RadioStationType() {
    }

    protected RadioStationType(Parcel in) {
        this.code = in.readString();
        this.createDate = in.readLong();
        this.creatorId = in.readLong();
        this.id = in.readLong();
        this.lastModifierId = in.readLong();
        this.lastModifyDate = in.readLong();
        this.name = in.readString();
        this.remark = in.readString();
        this.status = in.readString();
    }

    public static final Parcelable.Creator<RadioStationType> CREATOR = new Parcelable.Creator<RadioStationType>() {
        @Override
        public RadioStationType createFromParcel(Parcel source) {
            return new RadioStationType(source);
        }

        @Override
        public RadioStationType[] newArray(int size) {
            return new RadioStationType[size];
        }
    };
}
