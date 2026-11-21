package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Administrator on 2016-05-13.
 */
public class SocietyMember implements Parcelable {


    /**
     * attack : 51
     * birthday : 1970-01-01 00:00:00
     * city :
     * cityId :
     * contribution : 0
     * data :
     * defense : 6
     * fmCurrentRank : 99
     * fmCurrentScore : 0
     * fmTotalMatch : 0
     * fmTotalScore : 0
     * latitude :
     * level :
     * life : 271
     * longitude :
     * nickName : 张婧
     * onlineStatus : 1
     * phone :
     * photoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/(null)userHeader20160411140036.jpg
     * playingGame :
     * position :
     * resultMessage :
     * returnCode :
     * sex : 2
     * sign :
     * societyId :
     * status :
     * type :
     * userId : 363
     * vipLevel : 9
     * wealth : 0
     */

    private int attack;
    private String birthday;
    private String city;
    private String cityId;
    private int contribution;
    private String data;
    private int defense;
    private int fmCurrentRank;
    private int fmCurrentScore;
    private int fmTotalMatch;
    private int fmTotalScore;
    private String latitude;
    private String level;
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
    private String societyId;
    private String status;
    private String type;
    private String userId;
    private String vipLevel;
    private int wealth;

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

    public int getContribution() {
        return contribution;
    }

    public void setContribution(int contribution) {
        this.contribution = contribution;
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

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
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

    public String getSocietyId() {
        return societyId;
    }

    public void setSocietyId(String societyId) {
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

    public String getVipLevel() {
        return vipLevel;
    }

    public void setVipLevel(String vipLevel) {
        this.vipLevel = vipLevel;
    }

    public int getWealth() {
        return wealth;
    }

    public void setWealth(int wealth) {
        this.wealth = wealth;
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
        dest.writeInt(this.contribution);
        dest.writeString(this.data);
        dest.writeInt(this.defense);
        dest.writeInt(this.fmCurrentRank);
        dest.writeInt(this.fmCurrentScore);
        dest.writeInt(this.fmTotalMatch);
        dest.writeInt(this.fmTotalScore);
        dest.writeString(this.latitude);
        dest.writeString(this.level);
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
        dest.writeString(this.societyId);
        dest.writeString(this.status);
        dest.writeString(this.type);
        dest.writeString(this.userId);
        dest.writeString(this.vipLevel);
        dest.writeInt(this.wealth);
    }

    public SocietyMember() {
    }

    protected SocietyMember(Parcel in) {
        this.attack = in.readInt();
        this.birthday = in.readString();
        this.city = in.readString();
        this.cityId = in.readString();
        this.contribution = in.readInt();
        this.data = in.readString();
        this.defense = in.readInt();
        this.fmCurrentRank = in.readInt();
        this.fmCurrentScore = in.readInt();
        this.fmTotalMatch = in.readInt();
        this.fmTotalScore = in.readInt();
        this.latitude = in.readString();
        this.level = in.readString();
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
        this.societyId = in.readString();
        this.status = in.readString();
        this.type = in.readString();
        this.userId = in.readString();
        this.vipLevel = in.readString();
        this.wealth = in.readInt();
    }

    public static final Parcelable.Creator<SocietyMember> CREATOR = new Parcelable.Creator<SocietyMember>() {
        @Override
        public SocietyMember createFromParcel(Parcel source) {
            return new SocietyMember(source);
        }

        @Override
        public SocietyMember[] newArray(int size) {
            return new SocietyMember[size];
        }
    };
}
