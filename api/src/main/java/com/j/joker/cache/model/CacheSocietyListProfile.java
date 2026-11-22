package com.j.joker.cache.model;

import java.util.Date;

import com.j.joker.cache.CacheModel;

public class CacheSocietyListProfile extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    /**
     * 公会ID
     */
    private Long societyId;

    /**
     * 公会名称
     */
    private String name;

    /**
     * 公会头像
     */
    private String photoUrl;

    /**
     * 描述
     */
    private String desc;

    /**
     * 公会等级
     */
    private String level;

    /**
     * 所在省
     */
    private String province;

    /**
     * 所在城市id
     */
    private Long cityId;

    /**
     * 所在城市
     */
    private String city;

    /**
     * 主播人数
     */
    private int compereNum;

    /**
     * 玩家人数
     */
    private int playerNum;

    /**
     * 建立日期
     */
    private Date startDate;

    /**
     * 爆矿基线
     */
    private Long boomLine;

    /**
     * 累积资金
     */
    private Long cumulation;

    /**
     * 纬度
     */
    private double latitude;

    /**
     * 经度
     */
    private double longitude;

    /**
     * 公会最热主播名
     */
    private String compereName;

    /**
     * 防守人数
     */
    private Integer defenseNum;

    /**
     * 攻击人数
     */
    private Integer attackerNum;
    
    /**
     * 抢矿活动ID,无活动时为0
     */
    private Long activityId;
    
    /**
     * 一个抢矿活动最大抢夺人数，即矿坑数量
     */
    private Integer maxAttackNum;

    public Long getSocietyId() {
        return societyId;
    }

    public void setSocietyId(Long societyId) {
        this.societyId = societyId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public int getCompereNum() {
        return compereNum;
    }

    public void setCompereNum(int compereNum) {
        this.compereNum = compereNum;
    }

    public int getPlayerNum() {
        return playerNum;
    }

    public void setPlayerNum(int playerNum) {
        this.playerNum = playerNum;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Long getBoomLine() {
        return boomLine;
    }

    public void setBoomLine(Long boomLine) {
        this.boomLine = boomLine;
    }

    public Long getCumulation() {
        return cumulation;
    }

    public void setCumulation(Long cumulation) {
        this.cumulation = cumulation;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public Long getCityId() {
        return cityId;
    }

    public void setCityId(Long cityId) {
        this.cityId = cityId;
    }

    public String getCompereName() {
        return compereName;
    }

    public void setCompereName(String compereName) {
        this.compereName = compereName;
    }

    public Integer getDefenseNum() {
        return defenseNum;
    }

    public void setDefenseNum(Integer defenseNum) {
        this.defenseNum = defenseNum;
    }

    public Integer getMaxAttackNum() {
        return maxAttackNum;
    }

    public void setMaxAttackNum(Integer maxAttackNum) {
        this.maxAttackNum = maxAttackNum;
    }

    public Integer getAttackerNum() {
        return attackerNum;
    }

    public void setAttackerNum(Integer attackerNum) {
        this.attackerNum = attackerNum;
    }

    public Long getActivityId() {
        return activityId;
    }

    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }
}
