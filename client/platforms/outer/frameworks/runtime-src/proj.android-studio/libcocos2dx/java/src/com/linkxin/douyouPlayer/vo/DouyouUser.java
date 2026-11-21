package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

import net.tsz.afinal.annotation.sqlite.Id;
import net.tsz.afinal.annotation.sqlite.Table;

import java.util.List;

/**
 * Created by lxy on 2016/4/6.
 */
@Table(name="DouyouUser")
public class DouyouUser implements Parcelable {

    /**
     * attack : 100
     * birthday : -28800000
     * captureAttack : 100
     * captureDefense : 10
     * captureLife : 100
     * chargeSum : 28000
     * city : 广州
     * cityId : 1
     * coinAmount : 8557950
     * datingNum : 2
     * defense : 10
     * experience : 305
     * grade : 4.25
     * hasPayPassword : false
     * jewelAmount : 0
     * latitude : 23.09303
     * level : 4
     * life : 100
     * longitude : 113.31719
     * moments : [{"createDate":1457954795000,"id":19,"list":[{"momentId":19,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/207anchorPhoto201603141926340.jpg","photoId":34,"type":"0","uploadDate":1457954795000,"userid":207}],"status":"1","userId":207}]
     * name : 13798958003
     * nickName : 良
     * onlineStatus : 1
     * phone : 13798958003
     * photoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/207userHeader20160401115830.jpg
     * promoCode : 00000207
     * province : 广东
     * provinceId : 1
     * sex : 1
     * sign : 345678
     * society : 兜游帅联
     * societyId : 1
     * status : 1
     * token : huangyuhaohahahahahahah1231
     * totalExperience : 400
     * town : 越秀
     * townId : 1
     * userId : 207
     * vipLevel : 9
     * wealth : 0
     */

	@Id(column="userId")
	private String userId;
    private int attack;
    private long birthday;
    private int captureAttack;
    private int captureDefense;
    private int captureLife;
    private int chargeSum;
    private String city;
    private String cityId;
    private int coinAmount;
    private int datingNum;
    private int defense;
    private int experience;
    private double grade;
    private boolean hasPayPassword;
    private int jewelAmount;
    private double latitude;
    private int level;
    private int life;
    private double longitude;
    private String name;
    private String nickName;
    private String onlineStatus;
    private String phone;
    private String photoUrl;
    private String promoCode;
    private String province;
    private String provinceId;
    private String sex;
    private String sign;
    private String society;
    private String societyId;
    private String status;
    private String token;
    private int totalExperience;
    private String town;
    private String townId;
    private int vipLevel;
    private int wealth;
    private int sendCardCount;
    private int cardCount;

    /**
     * bindCompereId : 341
     * moments : []
     * societyMasterId : 322
     * societyMasterPhone : 15677362896
     */

    private String bindCompereId;
    private long promoterId;
    private String societyMasterId;
    private String societyMasterPhone;

    private String selectedCityId;
    private String selectedCityName;

    private boolean hasBindPhone;

    public int getCardCount() {
        return cardCount;
    }

    public void setCardCount(int cardCount) {
        this.cardCount = cardCount;
    }

    public int getSendCardCount() {
        return sendCardCount;
    }

    public void setSendCardCount(int sendCardCount) {
        this.sendCardCount = sendCardCount;
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

    public int getCaptureAttack() {
        return captureAttack;
    }

    public void setCaptureAttack(int captureAttack) {
        this.captureAttack = captureAttack;
    }

    public int getCaptureDefense() {
        return captureDefense;
    }

    public void setCaptureDefense(int captureDefense) {
        this.captureDefense = captureDefense;
    }

    public int getCaptureLife() {
        return captureLife;
    }

    public void setCaptureLife(int captureLife) {
        this.captureLife = captureLife;
    }

    public int getChargeSum() {
        return chargeSum;
    }

    public void setChargeSum(int chargeSum) {
        this.chargeSum = chargeSum;
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

    public int getCoinAmount() {
        return coinAmount;
    }

    public void setCoinAmount(int coinAmount) {
        this.coinAmount = coinAmount;
    }

    public int getDatingNum() {
        return datingNum;
    }

    public void setDatingNum(int datingNum) {
        this.datingNum = datingNum;
    }

    public int getDefense() {
        return defense;
    }

    public void setDefense(int defense) {
        this.defense = defense;
    }

    public int getExperience() {
        return experience;
    }

    public void setExperience(int experience) {
        this.experience = experience;
    }

    public double getGrade() {
        return grade;
    }

    public void setGrade(double grade) {
        this.grade = grade;
    }

    public boolean isHasPayPassword() {
        return hasPayPassword;
    }

    public void setHasPayPassword(boolean hasPayPassword) {
        this.hasPayPassword = hasPayPassword;
    }

    public int getJewelAmount() {
        return jewelAmount;
    }

    public void setJewelAmount(int jewelAmount) {
        this.jewelAmount = jewelAmount;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
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

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getPromoCode() {
        return promoCode;
    }

    public void setPromoCode(String promoCode) {
        this.promoCode = promoCode;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(String provinceId) {
        this.provinceId = provinceId;
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

    public String getSociety() {
        return society;
    }

    public void setSociety(String society) {
        this.society = society;
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

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public int getTotalExperience() {
        return totalExperience;
    }

    public void setTotalExperience(int totalExperience) {
        this.totalExperience = totalExperience;
    }

    public String getTown() {
        return town;
    }

    public void setTown(String town) {
        this.town = town;
    }

    public String getTownId() {
        return townId;
    }

    public void setTownId(String townId) {
        this.townId = townId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public int getVipLevel() {
        return vipLevel;
    }

    public void setVipLevel(int vipLevel) {
        this.vipLevel = vipLevel;
    }

    public int getWealth() {
        return wealth;
    }

    public void setWealth(int wealth) {
        this.wealth = wealth;
    }

    public DouyouUser() {
    }

    public String getBindCompereId() {
        return bindCompereId;
    }

    public void setBindCompereId(String bindCompereId) {
        this.bindCompereId = bindCompereId;
    }

    public long getPromoterId() {
        return promoterId;
    }

    public void setPromoterId(long promoterId) {
        this.promoterId = promoterId;
    }

    public String getSocietyMasterId() {
        return societyMasterId;
    }

    public void setSocietyMasterId(String societyMasterId) {
        this.societyMasterId = societyMasterId;
    }

    public String getSocietyMasterPhone() {
        return societyMasterPhone;
    }

    public void setSocietyMasterPhone(String societyMasterPhone) {
        this.societyMasterPhone = societyMasterPhone;
    }

    public String getSelectedCityId() {
        return selectedCityId;
    }

    public void setSelectedCityId(String selectedCityId) {
        this.selectedCityId = selectedCityId;
    }

    public String getSelectedCityName() {
        return selectedCityName;
    }

    public void setSelectedCityName(String selectedCityName) {
        this.selectedCityName = selectedCityName;
    }

    public boolean isHasBindPhone() {
        return hasBindPhone;
    }

    public void setHasBindPhone(boolean hasBindPhone) {
        this.hasBindPhone = hasBindPhone;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.userId);
        dest.writeInt(this.attack);
        dest.writeLong(this.birthday);
        dest.writeInt(this.captureAttack);
        dest.writeInt(this.captureDefense);
        dest.writeInt(this.captureLife);
        dest.writeInt(this.chargeSum);
        dest.writeString(this.city);
        dest.writeString(this.cityId);
        dest.writeInt(this.coinAmount);
        dest.writeInt(this.datingNum);
        dest.writeInt(this.defense);
        dest.writeInt(this.experience);
        dest.writeDouble(this.grade);
        dest.writeByte(this.hasPayPassword ? (byte) 1 : (byte) 0);
        dest.writeInt(this.jewelAmount);
        dest.writeDouble(this.latitude);
        dest.writeInt(this.level);
        dest.writeInt(this.life);
        dest.writeDouble(this.longitude);
        dest.writeString(this.name);
        dest.writeString(this.nickName);
        dest.writeString(this.onlineStatus);
        dest.writeString(this.phone);
        dest.writeString(this.photoUrl);
        dest.writeString(this.promoCode);
        dest.writeString(this.province);
        dest.writeString(this.provinceId);
        dest.writeString(this.sex);
        dest.writeString(this.sign);
        dest.writeString(this.society);
        dest.writeString(this.societyId);
        dest.writeString(this.status);
        dest.writeString(this.token);
        dest.writeInt(this.totalExperience);
        dest.writeString(this.town);
        dest.writeString(this.townId);
        dest.writeInt(this.vipLevel);
        dest.writeInt(this.wealth);
        dest.writeInt(this.sendCardCount);
        dest.writeInt(this.cardCount);
        dest.writeString(this.bindCompereId);
        dest.writeLong(this.promoterId);
        dest.writeString(this.societyMasterId);
        dest.writeString(this.societyMasterPhone);
        dest.writeString(this.selectedCityId);
        dest.writeString(this.selectedCityName);
        dest.writeByte(this.hasBindPhone ? (byte) 1 : (byte) 0);
    }

    protected DouyouUser(Parcel in) {
        this.userId = in.readString();
        this.attack = in.readInt();
        this.birthday = in.readLong();
        this.captureAttack = in.readInt();
        this.captureDefense = in.readInt();
        this.captureLife = in.readInt();
        this.chargeSum = in.readInt();
        this.city = in.readString();
        this.cityId = in.readString();
        this.coinAmount = in.readInt();
        this.datingNum = in.readInt();
        this.defense = in.readInt();
        this.experience = in.readInt();
        this.grade = in.readDouble();
        this.hasPayPassword = in.readByte() != 0;
        this.jewelAmount = in.readInt();
        this.latitude = in.readDouble();
        this.level = in.readInt();
        this.life = in.readInt();
        this.longitude = in.readDouble();
        this.name = in.readString();
        this.nickName = in.readString();
        this.onlineStatus = in.readString();
        this.phone = in.readString();
        this.photoUrl = in.readString();
        this.promoCode = in.readString();
        this.province = in.readString();
        this.provinceId = in.readString();
        this.sex = in.readString();
        this.sign = in.readString();
        this.society = in.readString();
        this.societyId = in.readString();
        this.status = in.readString();
        this.token = in.readString();
        this.totalExperience = in.readInt();
        this.town = in.readString();
        this.townId = in.readString();
        this.vipLevel = in.readInt();
        this.wealth = in.readInt();
        this.sendCardCount = in.readInt();
        this.cardCount = in.readInt();
        this.bindCompereId = in.readString();
        this.promoterId = in.readLong();
        this.societyMasterId = in.readString();
        this.societyMasterPhone = in.readString();
        this.selectedCityId = in.readString();
        this.selectedCityName = in.readString();
        this.hasBindPhone = in.readByte() != 0;
    }

    public static final Creator<DouyouUser> CREATOR = new Creator<DouyouUser>() {
        @Override
        public DouyouUser createFromParcel(Parcel source) {
            return new DouyouUser(source);
        }

        @Override
        public DouyouUser[] newArray(int size) {
            return new DouyouUser[size];
        }
    };
}
