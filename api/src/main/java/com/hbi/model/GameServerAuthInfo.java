package com.hbi.model;

import com.alibaba.fastjson.JSONArray;
import com.hbi.cache.model.CachePlayerProfile;


/**
 * Created by ceeuoo on 5/24/2016.
 */
public class  GameServerAuthInfo {
    private CachePlayerProfile playerProfile;

    private TGameServer hall;

    private String mtKey;

    private Integer everydayLoginSendCard;

//    private Date redMonthCardEndDate;
//
//    private Date blueMonthCardEndDate;

//    private Integer monthCardPrice;
//
//    private Integer monthCardSignInAmount;

//    private Integer redMonthCardSignInAmount;
//
//    private Integer blueMonthCardSignInAmount;
//
//    private Integer blueMonthCardPrice;
//
//    private Integer redMonthCardPrice;

//    private Integer isFirstCharged;

    private Integer isGameSignIn;

//    private Integer hasRedMonthCard;
//
//    private Integer hasBlueMonthCard;

    private Integer isFirstLogin;

    private JSONArray announcement;

    public JSONArray getAnnouncement() {
        return announcement;
    }

    public void setAnnouncement(JSONArray announcement) {
        this.announcement = announcement;
    }

    public TGameServer getHall() {
        return hall;
    }

    public void setHall(TGameServer hall) {
        this.hall = hall;
    }

    public CachePlayerProfile getPlayerProfile() {
        return playerProfile;
    }

    public void setPlayerProfile(CachePlayerProfile playerProfile) {
        this.playerProfile = playerProfile;
    }

    public String getMtKey() {
        return mtKey;
    }

    public void setMtKey(String mtKey) {
        this.mtKey = mtKey;
    }

    public Integer getIsGameSignIn() {
        return isGameSignIn;
    }

    public void setIsGameSignIn(Integer isGameSignIn) {
        this.isGameSignIn = isGameSignIn;
    }

    public Integer getIsFirstLogin() {
        return isFirstLogin;
    }

    public void setIsFirstLogin(Integer isFirstLogin) {
        this.isFirstLogin = isFirstLogin;
    }

    public Integer getEverydayLoginSendCard() {
        return everydayLoginSendCard;
    }

    public void setEverydayLoginSendCard(Integer everydayLoginSendCard) {
        this.everydayLoginSendCard = everydayLoginSendCard;
    }
}
