package com.hbi.cache.model;

import java.util.Date;
import java.util.List;

import com.hbi.cache.CacheModel;
//import com.hbi.model.TMoments;

public class CacheUserProfile extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    /**
     * 用户ID
     */
    private String userId;

    /**
     * 名字
     */
    private String name;

    /**
     * 昵称
     */
    private String nickName;

    /**
     * 用户类型
     */
    private String userType;

    /**
     * 头像
     */
    private String photoUrl;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 性别 1 男 2 女
     */
    private String sex;

    /**
     * 生日
     */
    private Date birthday;

    private String roomPhoto;

    private String livePhoto;

    /**
     * 省
     */
    private String province;

    /**
     * 省ID
     */
    private String provinceId;

    /**
     * 城市
     */
    private String city;

    /**
     * 城市ID
     */
    private String cityId;

    /**
     * 区
     */
    private String town;

    /**
     * 区ID
     */
    private String townId;

    /**
     * 签名
     */
    private String sign;

    /**
     * 公会会长ID
     */
    private String societyMasterId;

    /**
     * 公会会长名称
     */
    private String societyMasterPhone;

    /**
     * 公会
     */
    private String society;

    /**
     * 公会ID
     */
    private String societyId;

    /**
     * 状态
     */
    private String status;

    /**
     * 经验值
     */
    private Integer experience;

    /**
     * 升级总经验
     */
    private Integer totalExperience;

    /**
     * 线上状态
     */
    private String onlineStatus;

    /**
     * 正在玩的游戏
     */
    private String playingGame;

    /**
     * 拥有的币
     */
    private Long coinAmount;

    /**
     * 拥有的房卡
     */
    private Integer jewelAmount;

    /**
     * 玩家的token
     */
    private String token;

    /**
     * 抢矿攻击
     */
    private Long attack;

    /**
     * 抢矿防御
     */
    private Long defense;

    /**
     * 抢矿生命
     */
    private Long life;

    private Long agentId;

    private String agentName;

    private Float longitude;
    private Float latitude;

    private String invitationCode;

    /**
     * 是否有支付密码
     */
    private boolean hasPayPassword;

    private String payPassword;

    private String account;

    /**
     * 约饭评分
     */
    private Float grade;

    /**
     * 约饭接单数量
     */
    private Integer datingNum;

//    private List<TMoments> moments;

    /**
     * 相册图片，用于约饭
     */
//    private List<String> albumUrls;

    /**
     * 饭卡数量
     */
    private Integer auctionCardCount;

    private boolean hasBindPhone;

    private Integer isRobot;

    private Integer cardCount;

    private Integer clubLimit;

    public Integer getClubLimit() {
        return clubLimit;
    }

    public void setClubLimit(Integer clubLimit) {
        this.clubLimit = clubLimit;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
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

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public Date getBirthday() {
        return birthday;
    }

    public void setBirthday(Date birthday) {
        this.birthday = birthday;
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

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public String getPlayingGame() {
        return playingGame;
    }

    public void setPlayingGame(String playingGame) {
        this.playingGame = playingGame;
    }

    public Long getCoinAmount() {
        return coinAmount;
    }

    public void setCoinAmount(Long coinAmount) {
        this.coinAmount = coinAmount;
    }

    public Integer getJewelAmount() {
        return jewelAmount;
    }

    public void setJewelAmount(Integer jewelAmount) {
        this.jewelAmount = jewelAmount;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Integer getExperience() {
        return experience;
    }

    public void setExperience(Integer experience) {
        this.experience = experience;
    }

    public Integer getTotalExperience() {
        return totalExperience;
    }

    public void setTotalExperience(Integer totalExperience) {
        this.totalExperience = totalExperience;
    }

    public Long getAgentId() {
        return agentId;
    }

    public void setAgentId(Long agentId) {
        this.agentId = agentId;
    }

    public Float getLongitude() {
        return longitude;
    }

    public void setLongitude(Float longitude) {
        this.longitude = longitude;
    }

    public Float getLatitude() {
        return latitude;
    }

    public void setLatitude(Float latitude) {
        this.latitude = latitude;
    }

    public boolean isHasPayPassword() {
        return hasPayPassword;
    }

    public void setHasPayPassword(boolean hasPayPassword) {
        this.hasPayPassword = hasPayPassword;
    }

    public String getPayPassword() {
        return payPassword;
    }

    public void setPayPassword(String payPassword) {
        this.payPassword = payPassword;
    }

    public Long getAttack() {
        return attack;
    }

    public void setAttack(Long attack) {
        this.attack = attack;
    }

    public Long getDefense() {
        return defense;
    }

    public void setDefense(Long defense) {
        this.defense = defense;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

    public Float getGrade() {
        return grade;
    }

    public void setGrade(Float grade) {
        this.grade = grade;
    }

    public Integer getDatingNum() {
        return datingNum;
    }

    public void setDatingNum(Integer datingNum) {
        this.datingNum = datingNum;
    }

//    public List<TMoments> getMoments() {
//        return moments;
//    }
//
//    public void setMoments(List<TMoments> moments) {
//        this.moments = moments;
//    }
//
//    public List<String> getAlbumUrls() {
//        return albumUrls;
//    }

//    public void setAlbumUrls(List<String> albumUrls) {
//        this.albumUrls = albumUrls;
//    }

    public String getLivePhoto() {
        return livePhoto;
    }

    public void setLivePhoto(String livePhoto) {
        this.livePhoto = livePhoto;
    }

    public String getRoomPhoto() {
        return roomPhoto;
    }

    public void setRoomPhoto(String roomPhoto) {
        this.roomPhoto = roomPhoto;
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

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public Integer getAuctionCardCount() {
        return auctionCardCount;
    }

    public void setAuctionCardCount(Integer auctionCardCount) {
        this.auctionCardCount = auctionCardCount;
    }

    public String getInvitationCode() {
        return invitationCode;
    }

    public void setInvitationCode(String invitationCode) {
        this.invitationCode = invitationCode;
    }

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public boolean isHasBindPhone() {
        return hasBindPhone;
    }

    public void setHasBindPhone(boolean hasBindPhone) {
        this.hasBindPhone = hasBindPhone;
    }

    public Integer getIsRobot() {
        return isRobot;
    }

    public void setIsRobot(Integer isRobot) {
        this.isRobot = isRobot;
    }

    public Integer getCardCount() {
        return cardCount;
    }

    public void setCardCount(Integer cardCount) {
        this.cardCount = cardCount;
    }

    public String getAgentName() {
        return agentName;
    }

    public void setAgentName(String agentName) {
        this.agentName = agentName;
    }
}
