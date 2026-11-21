package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.List;

/**
 * Created by Administrator on 2016-04-20.
 */
public class CompereStatus implements Parcelable {

    /**
     * captureStatus : 2
     * comperePhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/245userHeader20160407221758.jpg
     * defenderList : [{"captureStatus":"","compereBirthday":"1970-01-01 00:00:00","compereGender":"1","compereId":245,"compereLatitude":23.0932,"compereLevel":"","compereLevelBadge":"","compereLongitude":113.317,"compereNickname":"zhi","comperePhoto":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/245userHeader20160407221758.jpg","endDate":"2019-04-07 22:20:53","id":15,"playerBirthday":"2000-01-01 00:00:00","playerGender":"1","playerId":202,"playerLatitude":23.0935,"playerLongitude":113.317,"playerNickname":"yac","playerPhoto":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/202userHeader20160318141712.jpg","playerVipLevel":13,"startDate":"2016-04-07 22:20:53","type":3}]
     * leftLife : 26152
     * owner :
     * ownerId :
     * title :
     * totalLife : 26152
     */

    private int captureStatus;
    private String comperePhoto;
    private int leftLife;
    private String owner;
    private String ownerId;
    private String title;
    private int totalLife;
    private List<Defender> defenderList;

    public List<Defender> getDefenderList() {
        return defenderList;
    }

    public void setDefenderList(List<Defender> defenderList) {
        this.defenderList = defenderList;
    }

    public int getCaptureStatus() {
        return captureStatus;
    }

    public void setCaptureStatus(int captureStatus) {
        this.captureStatus = captureStatus;
    }

    public String getComperePhoto() {
        return comperePhoto;
    }

    public void setComperePhoto(String comperePhoto) {
        this.comperePhoto = comperePhoto;
    }

    public int getLeftLife() {
        return leftLife;
    }

    public void setLeftLife(int leftLife) {
        this.leftLife = leftLife;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(String ownerId) {
        this.ownerId = ownerId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getTotalLife() {
        return totalLife;
    }

    public void setTotalLife(int totalLife) {
        this.totalLife = totalLife;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.captureStatus);
        dest.writeString(this.comperePhoto);
        dest.writeInt(this.leftLife);
        dest.writeString(this.owner);
        dest.writeString(this.ownerId);
        dest.writeString(this.title);
        dest.writeInt(this.totalLife);
        dest.writeTypedList(defenderList);
    }

    public CompereStatus() {
    }

    protected CompereStatus(Parcel in) {
        this.captureStatus = in.readInt();
        this.comperePhoto = in.readString();
        this.leftLife = in.readInt();
        this.owner = in.readString();
        this.ownerId = in.readString();
        this.title = in.readString();
        this.totalLife = in.readInt();
        this.defenderList = in.createTypedArrayList(Defender.CREATOR);
    }

    public static final Parcelable.Creator<CompereStatus> CREATOR = new Parcelable.Creator<CompereStatus>() {
        @Override
        public CompereStatus createFromParcel(Parcel source) {
            return new CompereStatus(source);
        }

        @Override
        public CompereStatus[] newArray(int size) {
            return new CompereStatus[size];
        }
    };
}
