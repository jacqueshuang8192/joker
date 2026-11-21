package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.List;

/**
 * Created by lxy on 2016/4/19.
 */
public class Compere implements Parcelable {

    /**
     * agentId : 67
     * attack : 100
     * birthday : -28800000
     * captureAttack : 245
     * captureDefense : 10
     * captureStatus : 2  0自由 1被捉 2保护
     * chatroomId : 182069574420660676
     * city : 广州
     * cityId : 1
     * datingNum : 0
     * defense : 10
     * experience : 28144400
     * fansCount : 7
     * grade : 0
     * hasPayPassword : false
     * isFan : 0
     * latitude : 23.09321
     * level : 9
     * life : 100
     * livePhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/245userHeader16_920160407221754.jpg
     * longitude : 113.31717
     * name : 98765432109
     * nickName : zhi
     * onlineStatus : 1
     * phone : 98765432109
     * photoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/245userHeader20160407221758.jpg
     * protectTime : 1459581767000
     * province : 广东
     * provinceId : 1
     * roomId : 1814
     * roomName : zhi 的兜兜窝
     * roomPhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/245userHeader20160407221758.jpg
     * sex : 1
     * sharedProfit : 0
     * status : 1
     * town : 越秀
     * townId : 1
     * userId : 245
     */

    private long agentId;
    private int attack;
    private long birthday;
    private int captureAttack;
    private int captureDefense;
    private int captureStatus;
    private String chatroomId;
    private String city;
    private String cityId;
    private int datingNum;
    private int defense;
    private int experience;
    private int fansCount;
    private double grade;
    private boolean hasPayPassword;
    private String isFan;
    private double latitude;
    private int level;
    private int life;
    private String livePhoto;
    private double longitude;
    private String name;
    private String nickName;
    private String onlineStatus;
    private String phone;
    private String photoUrl;
    private long protectTime;
    private String province;
    private String provinceId;
    private String roomId;
    private String roomPassword;
    private String roomName;
    private String roomPhoto;
    private String sex;
    private int sharedProfit;
    private String status;
    private String town;
    private String townId;
    private String userId;
    private String societyId;
    private String society;
    private String societyMasterId;
    private String societyMasterPhone;
    /**
     * coinAmount : 96999677
     * jewelAmount : 200
     * liveActivityType : 2
     * moments : [{"createDate":1460689790000,"id":181,"list":[{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109510.jpg","photoId":334,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109511.jpg","photoId":335,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109512.jpg","photoId":336,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109523.jpg","photoId":337,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109524.jpg","photoId":338,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109525.jpg","photoId":339,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109526.jpg","photoId":340,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109527.jpg","photoId":341,"type":"0","uploadDate":1460689790000,"userid":290},{"momentId":181,"path":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/290anchorPhoto201604151109528.jpg","photoId":342,"type":"0","uploadDate":1460689790000,"userid":290}],"status":"1","text":"美女如云","userId":290}]
     * sign : 答疑咨询找我
     * token : huangyuhaohahahahahahah1231
     */

    private int coinAmount;
    private int jewelAmount;
    private String liveActivityType;
    private String sign;
    private String token;
    private String invitationCode;

    /**
     * 所有者
     */
    private long ownerId;
    private String ownerPhotoUrl;
    private String ownerNickname;


    /**
     * 直播状态：2表示正在直播
     */
    public static final String OFF_LINE = "0";
    public static final String ON_LINE = "1";
    public static final String IN_ROOM = "2";
    public static final String IN_GAME = "3";

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

    public long getAgentId() {
        return agentId;
    }

    public void setAgentId(long agentId) {
        this.agentId = agentId;
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

    public int getCaptureStatus() {
        return captureStatus;
    }

    public void setCaptureStatus(int captureStatus) {
        this.captureStatus = captureStatus;
    }

    public String getChatroomId() {
        return chatroomId;
    }

    public void setChatroomId(String chatroomId) {
        this.chatroomId = chatroomId;
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

    public int getFansCount() {
        return fansCount;
    }

    public void setFansCount(int fansCount) {
        this.fansCount = fansCount;
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

    public String getIsFan() {
        return isFan;
    }

    public void setIsFan(String isFan) {
        this.isFan = isFan;
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

    public String getLivePhoto() {
        return livePhoto;
    }

    public void setLivePhoto(String livePhoto) {
        this.livePhoto = livePhoto;
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

    public long getProtectTime() {
        return protectTime;
    }

    public void setProtectTime(long protectTime) {
        this.protectTime = protectTime;
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

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomPassword() {
        return roomPassword;
    }

    public void setRoomPassword(String roomPassword) {
        this.roomPassword = roomPassword;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomPhoto() {
        return roomPhoto;
    }

    public void setRoomPhoto(String roomPhoto) {
        this.roomPhoto = roomPhoto;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public int getSharedProfit() {
        return sharedProfit;
    }

    public void setSharedProfit(int sharedProfit) {
        this.sharedProfit = sharedProfit;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getSocietyMasterPhone() {
        return societyMasterPhone;
    }

    public void setSocietyMasterId(String societyMasterId) {
        this.societyMasterId = societyMasterId;
    }

    public String getSocietyMasterId() {
        return societyMasterId;
    }

    public void setSocietyMasterPhone(String societyMasterPhone) {
        this.societyMasterPhone = societyMasterPhone;
    }

    public int getCoinAmount() {
        return coinAmount;
    }

    public void setCoinAmount(int coinAmount) {
        this.coinAmount = coinAmount;
    }

    public int getJewelAmount() {
        return jewelAmount;
    }

    public void setJewelAmount(int jewelAmount) {
        this.jewelAmount = jewelAmount;
    }

    public String getLiveActivityType() {
        return liveActivityType;
    }

    public void setLiveActivityType(String liveActivityType) {
        this.liveActivityType = liveActivityType;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public long getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(long ownerId) {
        this.ownerId = ownerId;
    }

    public String getOwnerPhotoUrl() {
        return ownerPhotoUrl;
    }

    public void setOwnerPhotoUrl(String ownerPhotoUrl) {
        this.ownerPhotoUrl = ownerPhotoUrl;
    }

    public String getOwnerNickname() {
        return ownerNickname;
    }

    public void setOwnerNickname(String ownerNickname) {
        this.ownerNickname = ownerNickname;
    }

    public String getInvitationCode() {
        return invitationCode;
    }

    public void setInvitationCode(String invitationCode) {
        this.invitationCode = invitationCode;
    }

    public Compere() {
    }


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(this.agentId);
        dest.writeInt(this.attack);
        dest.writeLong(this.birthday);
        dest.writeInt(this.captureAttack);
        dest.writeInt(this.captureDefense);
        dest.writeInt(this.captureStatus);
        dest.writeString(this.chatroomId);
        dest.writeString(this.city);
        dest.writeString(this.cityId);
        dest.writeInt(this.datingNum);
        dest.writeInt(this.defense);
        dest.writeInt(this.experience);
        dest.writeInt(this.fansCount);
        dest.writeDouble(this.grade);
        dest.writeByte(hasPayPassword ? (byte) 1 : (byte) 0);
        dest.writeString(this.isFan);
        dest.writeDouble(this.latitude);
        dest.writeInt(this.level);
        dest.writeInt(this.life);
        dest.writeString(this.livePhoto);
        dest.writeDouble(this.longitude);
        dest.writeString(this.name);
        dest.writeString(this.nickName);
        dest.writeString(this.onlineStatus);
        dest.writeString(this.phone);
        dest.writeString(this.photoUrl);
        dest.writeLong(this.protectTime);
        dest.writeString(this.province);
        dest.writeString(this.provinceId);
        dest.writeString(this.roomId);
        dest.writeString(this.roomPassword);
        dest.writeString(this.roomName);
        dest.writeString(this.roomPhoto);
        dest.writeString(this.sex);
        dest.writeInt(this.sharedProfit);
        dest.writeString(this.status);
        dest.writeString(this.town);
        dest.writeString(this.townId);
        dest.writeString(this.userId);
        dest.writeString(this.societyId);
        dest.writeString(this.society);
        dest.writeString(this.societyMasterId);
        dest.writeString(this.societyMasterPhone);
        dest.writeInt(this.coinAmount);
        dest.writeInt(this.jewelAmount);
        dest.writeString(this.liveActivityType);
        dest.writeString(this.sign);
        dest.writeString(this.token);
        dest.writeLong(this.ownerId);
        dest.writeString(this.ownerNickname);
        dest.writeString(this.ownerPhotoUrl);
        dest.writeString(this.invitationCode);
    }

    protected Compere(Parcel in) {
        this.agentId = in.readLong();
        this.attack = in.readInt();
        this.birthday = in.readLong();
        this.captureAttack = in.readInt();
        this.captureDefense = in.readInt();
        this.captureStatus = in.readInt();
        this.chatroomId = in.readString();
        this.city = in.readString();
        this.cityId = in.readString();
        this.datingNum = in.readInt();
        this.defense = in.readInt();
        this.experience = in.readInt();
        this.fansCount = in.readInt();
        this.grade = in.readDouble();
        this.hasPayPassword = in.readByte() != 0;
        this.isFan = in.readString();
        this.latitude = in.readDouble();
        this.level = in.readInt();
        this.life = in.readInt();
        this.livePhoto = in.readString();
        this.longitude = in.readDouble();
        this.name = in.readString();
        this.nickName = in.readString();
        this.onlineStatus = in.readString();
        this.phone = in.readString();
        this.photoUrl = in.readString();
        this.protectTime = in.readLong();
        this.province = in.readString();
        this.provinceId = in.readString();
        this.roomId = in.readString();
        this.roomPassword = in.readString();
        this.roomName = in.readString();
        this.roomPhoto = in.readString();
        this.sex = in.readString();
        this.sharedProfit = in.readInt();
        this.status = in.readString();
        this.town = in.readString();
        this.townId = in.readString();
        this.userId = in.readString();
        this.societyId = in.readString();
        this.society = in.readString();
        this.societyMasterId = in.readString();
        this.societyMasterPhone = in.readString();
        this.coinAmount = in.readInt();
        this.jewelAmount = in.readInt();
        this.liveActivityType = in.readString();
        this.sign = in.readString();
        this.token = in.readString();
        this.ownerId = in.readLong();
        this.ownerNickname = in.readString();
        this.ownerPhotoUrl = in.readString();
        this.invitationCode = in.readString();
    }

    public static final Creator<Compere> CREATOR = new Creator<Compere>() {
        @Override
        public Compere createFromParcel(Parcel source) {
            return new Compere(source);
        }

        @Override
        public Compere[] newArray(int size) {
            return new Compere[size];
        }
    };
}
