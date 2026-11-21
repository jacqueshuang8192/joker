package com.linkxin.douyouPlayer.vo;

import net.tsz.afinal.annotation.sqlite.Id;

/**
 * Created by zhongweihao on 16/6/16.
 */
public class UserCity {

    @Id
    private String userId;

    //主播房间城市
    private String roomCityId;
    private String roomCityName;

    //工会城市
    private String societyCityId;
    private String societyCityName;

    //线下商城城市
    private String offlineStoreCityId;
    private String offlineStoreCityName;

    //约饭城市
    private String datingCityId;
    private String datingCityName;

    //一元夺宝城市
    private String treasureCityId;
    private String treasureCityName;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getRoomCityId() {
        return roomCityId;
    }

    public void setRoomCityId(String roomCityId) {
        this.roomCityId = roomCityId;
    }

    public String getRoomCityName() {
        return roomCityName;
    }

    public void setRoomCityName(String roomCityName) {
        this.roomCityName = roomCityName;
    }

    public String getSocietyCityId() {
        return societyCityId;
    }

    public void setSocietyCityId(String societyCityId) {
        this.societyCityId = societyCityId;
    }

    public String getSocietyCityName() {
        return societyCityName;
    }

    public void setSocietyCityName(String societyCityName) {
        this.societyCityName = societyCityName;
    }

    public String getOfflineStoreCityId() {
        return offlineStoreCityId;
    }

    public void setOfflineStoreCityId(String offlineStoreCityId) {
        this.offlineStoreCityId = offlineStoreCityId;
    }

    public String getOfflineStoreCityName() {
        return offlineStoreCityName;
    }

    public void setOfflineStoreCityName(String offlineStoreCityName) {
        this.offlineStoreCityName = offlineStoreCityName;
    }

    public String getDatingCityId() {
        return datingCityId;
    }

    public void setDatingCityId(String datingCityId) {
        this.datingCityId = datingCityId;
    }

    public String getDatingCityName() {
        return datingCityName;
    }

    public void setDatingCityName(String datingCityName) {
        this.datingCityName = datingCityName;
    }

    public String getTreasureCityId() {
        return treasureCityId;
    }

    public void setTreasureCityId(String treasureCityId) {
        this.treasureCityId = treasureCityId;
    }

    public String getTreasureCityName() {
        return treasureCityName;
    }

    public void setTreasureCityName(String treasureCityName) {
        this.treasureCityName = treasureCityName;
    }
}
