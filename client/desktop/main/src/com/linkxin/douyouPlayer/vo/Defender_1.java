package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by lxy on 2016/4/19.
 */
public class Defender implements Parcelable {

    /**
     * captureStatus :
     * compereBirthday : 1970-01-01 00:00:00
     * compereGender : 1
     * compereId : 245
     * compereLatitude : 23.0932
     * compereLevel :
     * compereLevelBadge :
     * compereLongitude : 113.317
     * compereNickname : zhi
     * comperePhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/245userHeader20160407221758.jpg
     * endDate : 2019-04-07 22:20:53
     * id : 15
     * playerBirthday : 2000-01-01 00:00:00
     * playerGender : 1
     * playerId : 202
     * playerLatitude : 23.0935
     * playerLongitude : 113.317
     * playerNickname : yac
     * playerPhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/202userHeader20160318141712.jpg
     * playerVipLevel : 13
     * startDate : 2016-04-07 22:20:53
     * type : 3
     */

    private String captureStatus;
    private String compereBirthday;
    private String compereGender;
    private String compereId;
    private String compereLatitude;
    private String compereLevel;
    private String compereLevelBadge;
    private String compereLongitude;
    private String compereNickname;
    private String comperePhoto;
    private String endDate;
    private String id;
    private String playerBirthday;
    private String playerGender;
    private String playerId;
    private String playerLatitude;
    private String playerLongitude;
    private String playerNickname;
    private String playerPhoto;
    private String playerVipLevel;
    private String startDate;
    private int type;

    public String getCaptureStatus() {
        return captureStatus;
    }

    public void setCaptureStatus(String captureStatus) {
        this.captureStatus = captureStatus;
    }

    public String getCompereBirthday() {
        return compereBirthday;
    }

    public void setCompereBirthday(String compereBirthday) {
        this.compereBirthday = compereBirthday;
    }

    public String getCompereGender() {
        return compereGender;
    }

    public void setCompereGender(String compereGender) {
        this.compereGender = compereGender;
    }

    public String getCompereId() {
        return compereId;
    }

    public void setCompereId(String compereId) {
        this.compereId = compereId;
    }

    public String getCompereLatitude() {
        return compereLatitude;
    }

    public void setCompereLatitude(String compereLatitude) {
        this.compereLatitude = compereLatitude;
    }

    public String getCompereLevel() {
        return compereLevel;
    }

    public void setCompereLevel(String compereLevel) {
        this.compereLevel = compereLevel;
    }

    public String getCompereLevelBadge() {
        return compereLevelBadge;
    }

    public void setCompereLevelBadge(String compereLevelBadge) {
        this.compereLevelBadge = compereLevelBadge;
    }

    public String getCompereLongitude() {
        return compereLongitude;
    }

    public void setCompereLongitude(String compereLongitude) {
        this.compereLongitude = compereLongitude;
    }

    public String getCompereNickname() {
        return compereNickname;
    }

    public void setCompereNickname(String compereNickname) {
        this.compereNickname = compereNickname;
    }

    public String getComperePhoto() {
        return comperePhoto;
    }

    public void setComperePhoto(String comperePhoto) {
        this.comperePhoto = comperePhoto;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPlayerBirthday() {
        return playerBirthday;
    }

    public void setPlayerBirthday(String playerBirthday) {
        this.playerBirthday = playerBirthday;
    }

    public String getPlayerGender() {
        return playerGender;
    }

    public void setPlayerGender(String playerGender) {
        this.playerGender = playerGender;
    }

    public String getPlayerId() {
        return playerId;
    }

    public void setPlayerId(String playerId) {
        this.playerId = playerId;
    }

    public String getPlayerLatitude() {
        return playerLatitude;
    }

    public void setPlayerLatitude(String playerLatitude) {
        this.playerLatitude = playerLatitude;
    }

    public String getPlayerLongitude() {
        return playerLongitude;
    }

    public void setPlayerLongitude(String playerLongitude) {
        this.playerLongitude = playerLongitude;
    }

    public String getPlayerNickname() {
        return playerNickname;
    }

    public void setPlayerNickname(String playerNickname) {
        this.playerNickname = playerNickname;
    }

    public String getPlayerPhoto() {
        return playerPhoto;
    }

    public void setPlayerPhoto(String playerPhoto) {
        this.playerPhoto = playerPhoto;
    }

    public String getPlayerVipLevel() {
        return playerVipLevel;
    }

    public void setPlayerVipLevel(String playerVipLevel) {
        this.playerVipLevel = playerVipLevel;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.captureStatus);
        dest.writeString(this.compereBirthday);
        dest.writeString(this.compereGender);
        dest.writeString(this.compereId);
        dest.writeString(this.compereLatitude);
        dest.writeString(this.compereLevel);
        dest.writeString(this.compereLevelBadge);
        dest.writeString(this.compereLongitude);
        dest.writeString(this.compereNickname);
        dest.writeString(this.comperePhoto);
        dest.writeString(this.endDate);
        dest.writeString(this.id);
        dest.writeString(this.playerBirthday);
        dest.writeString(this.playerGender);
        dest.writeString(this.playerId);
        dest.writeString(this.playerLatitude);
        dest.writeString(this.playerLongitude);
        dest.writeString(this.playerNickname);
        dest.writeString(this.playerPhoto);
        dest.writeString(this.playerVipLevel);
        dest.writeString(this.startDate);
        dest.writeInt(this.type);
    }

    public Defender() {
    }

    protected Defender(Parcel in) {
        this.captureStatus = in.readString();
        this.compereBirthday = in.readString();
        this.compereGender = in.readString();
        this.compereId = in.readString();
        this.compereLatitude = in.readString();
        this.compereLevel = in.readString();
        this.compereLevelBadge = in.readString();
        this.compereLongitude = in.readString();
        this.compereNickname = in.readString();
        this.comperePhoto = in.readString();
        this.endDate = in.readString();
        this.id = in.readString();
        this.playerBirthday = in.readString();
        this.playerGender = in.readString();
        this.playerId = in.readString();
        this.playerLatitude = in.readString();
        this.playerLongitude = in.readString();
        this.playerNickname = in.readString();
        this.playerPhoto = in.readString();
        this.playerVipLevel = in.readString();
        this.startDate = in.readString();
        this.type = in.readInt();
    }

    public static final Parcelable.Creator<Defender> CREATOR = new Parcelable.Creator<Defender>() {
        @Override
        public Defender createFromParcel(Parcel source) {
            return new Defender(source);
        }

        @Override
        public Defender[] newArray(int size) {
            return new Defender[size];
        }
    };
}
