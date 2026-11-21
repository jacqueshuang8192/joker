package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Administrator on 2016-05-18.
 */
public class CustomUserInfo implements Parcelable {

    String userId;
    String nickName;
    String type;
    String photoUrl;
    String sign;
    String latitude;
    String longitude;
    String city;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.userId);
        dest.writeString(this.nickName);
        dest.writeString(this.type);
        dest.writeString(this.photoUrl);
        dest.writeString(this.sign);
        dest.writeString(this.latitude);
        dest.writeString(this.longitude);
        dest.writeString(this.city);
    }

    public CustomUserInfo() {
    }

    protected CustomUserInfo(Parcel in) {
        this.userId = in.readString();
        this.nickName = in.readString();
        this.type = in.readString();
        this.photoUrl = in.readString();
        this.sign = in.readString();
        this.latitude = in.readString();
        this.longitude = in.readString();
        this.city = in.readString();
    }

    public static final Parcelable.Creator<CustomUserInfo> CREATOR = new Parcelable.Creator<CustomUserInfo>() {
        @Override
        public CustomUserInfo createFromParcel(Parcel source) {
            return new CustomUserInfo(source);
        }

        @Override
        public CustomUserInfo[] newArray(int size) {
            return new CustomUserInfo[size];
        }
    };
}
