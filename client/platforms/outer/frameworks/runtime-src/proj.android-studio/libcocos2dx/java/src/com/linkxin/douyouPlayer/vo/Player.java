package com.linkxin.douyouPlayer.vo;

import net.tsz.afinal.annotation.sqlite.Id;
import net.tsz.afinal.annotation.sqlite.Table;

import java.io.Serializable;

@Table(name = "Player")
public class Player  implements Comparable<Player>, Serializable {


    /**
     * fmCurrentRank : 99
     * fmCurrentScore : 0
     * fmTotalMatch : 0
     * fmTotalScore : 0
     * * attack : 100
     * birthday : 1460649600000
     * cityId : 1
     * defense : 10
     * latitude : 23.09312
     * life : 500
     * longitude : 113.31724
     * onlineStatus : 1
     * status : 1
     */

    /**
     * 类型：
     * p表示玩家 player
     * c表示主播 compare
     */
    public static final String TYPE_PLAYER = "P";
    public static final String TYPE_COMPARE = "C";

    @Id(column = "id")
    private int id;
    private String vipLevel;
    private int fmCurrentRank;
    private int fmCurrentScore;
    private int fmTotalMatch;
    private int fmTotalScore;
    private String photoUrl;
    private int attack;
    private long birthday;
    private String cityId;
    private int defense;
    private double latitude;
    private int life;
    private double longitude;
    private String onlineStatus;
    private String status;
    //type= c表示主播，p表示玩家
    private String type;

    //本地维护的userId
    private String belongTo;

    private String userId;
    private String nickName;
    private String portraitUrl;
    private String phone;
    private String sex;
    private String age;
    private String level;
    private String city;
    private String sign;
    private String societyId;
    private String society;
    private String sortLetters; // 显示数据拼音的首字母
    private int coinsAmount;
    private String position;

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

    public String getVipLevel() {
        return vipLevel;
    }

    public void setVipLevel(String vipLevel) {
        this.vipLevel = vipLevel;
    }

    public int getAttack() {
        return attack;
    }

    public void setAttack(int attack) {
        this.attack = attack;
    }

    public long getBirthday() {
        return birthday;
    }

    public void setBirthday(long birthday) {
        this.birthday = birthday;
    }

    public String getCityId() {
        return cityId;
    }

    public void setCityId(String cityId) {
        this.cityId = cityId;
    }

    public int getDefense() {
        return defense;
    }

    public void setDefense(int defense) {
        this.defense = defense;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public int getLife() {
        return life;
    }

    public void setLife(int life) {
        this.life = life;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBelongTo() {
        return belongTo;
    }

    public void setBelongTo(String belongTo) {
        this.belongTo = belongTo;
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

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getPortraitUrl() {
        return portraitUrl;
    }

    public void setPortraitUrl(String portraitUrl) {
        this.portraitUrl = portraitUrl;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getAge() {
        return age;
    }

    public void setAge(String age) {
        this.age = age;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
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

    public String getSociety() {
        return society;
    }

    public void setSociety(String society) {
        this.society = society;
    }

    public String getSortLetters() {
        return sortLetters;
    }

    public void setSortLetters(String sortLetters) {
        this.sortLetters = sortLetters;
    }

    public int getCoinsAmount() {
        return coinsAmount;
    }

    public void setCoinsAmount(int coinsAmount) {
        this.coinsAmount = coinsAmount;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    @Override
    public int compareTo(Player another) {
        if (this.getSortLetters().equals("@")
                || another.getSortLetters().equals("#")) {
            return -1;
        } else if (this.getSortLetters().equals("#")
                || another.getSortLetters().equals("@")) {
            return 1;
        } else {
            return this.getSortLetters().compareTo(another.getSortLetters());
        }
    }
}
