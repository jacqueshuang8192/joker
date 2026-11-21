package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Administrator on 2016-05-13.
 */
public class SocietyCompere implements Parcelable {


    /**
     * attack : 100
     * birthday : 1970-01-01 00:00:00
     * city :
     * cityId :
     * data :
     * defense : 10
     * fansCount : 0
     * fmCurrentRank : 99
     * fmCurrentScore : 0
     * fmTotalMatch : 0
     * fmTotalScore : 0
     * latitude :
     * level : 11
     * life : 500
     * longitude :
     * nickName : 张婧
     * onlineStatus : 1
     * phone :
     * photoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/310userHeader20160411143349.jpg
     * playingGame :
     * position :
     * resultMessage :
     * returnCode :
     * sex : 2
     * sign :
     * societyId : 19
     * status : 1
     * type : C
     * userId : 310
     */

    private int attack;
    private String birthday;
    private String city;
    private String cityId;
    private String data;
    private int defense;
    private int fansCount;
    private int fmCurrentRank;
    private int fmCurrentScore;
    private int fmTotalMatch;
    private int fmTotalScore;
    private String latitude;
    private int level;
    private int life;
    private String longitude;
    private String nickName;
    private String onlineStatus;
    private String phone;
    private String photoUrl;
    private String playingGame;
    private String position;
    private String resultMessage;
    private String returnCode;
    private String sex;
    private String sign;
    private long societyId;
    private String status;
    private String type;
    private String userId;

    public int getAttack() {
        return attack;
    }

    public void setAttack(int attack) {
        this.attack = attack;
    }

    public String getBirthday() {
        return birthday;
    }

    public void setBirthday(String birthday) {
        this.birthday = birthday;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getCityId() {
        return cityId;
    }

    public void setCityId(String cityId) {
        this.cityId = cityId;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public int getDefense() {
        return defense;
    }

    public void setDefense(int defense) {
        this.defense = defense;
    }

    public int getFansCount() {
        return fansCount;
    }

    public void setFansCount(int fansCount) {
        this.fansCount = fansCount;
    }

    public int getFmCurrentRank() {
        return fmCurrentRank;
    }

    public void setFmCurrentRank(int fmCurrentRank) {
        this.fmCurrentRank = fmCurrentRank;
    }

    public int getFmCurrentScore() {
        return fmCurrentScore;
    }

    public void setFmCurrentScore(int fmCurrentScore) {
        this.fmCurrentScore = fmCurrentScore;
    }

    public int getFmTotalMatch() {
        return fmTotalMatch;
    }

    public void setFmTotalMatch(int fmTotalMatch) {
        this.fmTotalMatch = fmTotalMatch;
    }

    public int getFmTotalScore() {
        return fmTotalScore;
    }

    public void setFmTotalScore(int fmTotalScore) {
        this.fmTotalScore = fmTotalScore;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getLife() {
        return life;
    }

    public void setLife(int life) {
        this.life = life;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getPlayingGame() {
        return playingGame;
    }

    public void setPlayingGame(String playingGame) {
        this.playingGame = playingGame;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public String getResultMessage() {
        return resultMessage;
    }

    public void setResultMessage(String resultMessage) {
        this.resultMessage = resultMessage;
    }

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    public long getSocietyId() {
        return societyId;
    }

    public void setSocietyId(long societyId) {
        this.societyId = societyId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.attack);
        dest.writeString(this.birthday);
        dest.writeString(this.city);
        dest.writeString(this.cityId);
        dest.writeString(this.data);
        dest.writeInt(this.defense);
        dest.writeInt(this.fansCount);
        dest.writeInt(this.fmCurrentRank);
        dest.writeInt(this.fmCurrentScore);
        dest.writeInt(this.fmTotalMatch);
        dest.writeInt(this.fmTotalScore);
        dest.writeString(this.latitude);
        dest.writeInt(this.level);
        dest.writeInt(this.life);
        dest.writeString(this.longitude);
        dest.writeString(this.nickName);
        dest.writeString(this.onlineStatus);
        dest.writeString(this.phone);
        dest.writeString(this.photoUrl);
        dest.writeString(this.playingGame);
        dest.writeString(this.position);
        dest.writeString(this.resultMessage);
        dest.writeString(this.returnCode);
        dest.writeString(this.sex);
        dest.writeString(this.sign);
        dest.writeLong(this.societyId);
        dest.writeString(this.status);
        dest.writeString(this.type);
        dest.writeString(this.userId);
    }

    public SocietyCompere() {
    }

    protected SocietyCompere(Parcel in) {
        this.attack = in.readInt();
        this.birthday = in.readString();
        this.city = in.readString();
        this.cityId = in.readString();
        this.data = in.readString();
        this.defense = in.readInt();
        this.fansCount = in.readInt();
        this.fmCurrentRank = in.readInt();
        this.fmCurrentScore = in.readInt();
        this.fmTotalMatch = in.readInt();
        this.fmTotalScore = in.readInt();
        this.latitude = in.readString();
        this.level = in.readInt();
        this.life = in.readInt();
        this.longitude = in.readString();
        this.nickName = in.readString();
        this.onlineStatus = in.readString();
        this.phone = in.readString();
        this.photoUrl = in.readString();
        this.playingGame = in.readString();
        this.position = in.readString();
        this.resultMessage = in.readString();
        this.returnCode = in.readString();
        this.sex = in.readString();
        this.sign = in.readString();
        this.societyId = in.readLong();
        this.status = in.readString();
        this.type = in.readString();
        this.userId = in.readString();
    }

    public static final Parcelable.Creator<SocietyCompere> CREATOR = new Parcelable.Creator<SocietyCompere>() {
        @Override
        public SocietyCompere createFromParcel(Parcel source) {
            return new SocietyCompere(source);
        }

        @Override
        public SocietyCompere[] newArray(int size) {
            return new SocietyCompere[size];
        }
    };
}
