package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Administrator on 2016-05-07.
 */
public class GroupBureauHistoryInfo implements Parcelable {

    /**
     * activityId : 373
     * coins : 100
     * creatorNickname : 精忠岳飞
     * creatorPhotoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/(null)userHeader20160411193133.jpg
     * gameId : 1
     * gameName : 斗地主
     * inviteCode : 037870
     * name : 开房咯
     * rounds : 0
     * level: 35
     * startDate : 1462608160000
     * status : 2
     */

    private String activityId;
    private int coins;
    private String creatorNickname;
    private String creatorPhotoUrl;
    private String gameId;
    private String gameName;
    private String inviteCode;
    private String name;
    private int rounds;
    private long startDate;
    private String status;
    private int level;

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getActivityId() {
        return activityId;
    }

    public void setActivityId(String activityId) {
        this.activityId = activityId;
    }

    public int getCoins() {
        return coins;
    }

    public void setCoins(int coins) {
        this.coins = coins;
    }

    public String getCreatorNickname() {
        return creatorNickname;
    }

    public void setCreatorNickname(String creatorNickname) {
        this.creatorNickname = creatorNickname;
    }

    public String getCreatorPhotoUrl() {
        return creatorPhotoUrl;
    }

    public void setCreatorPhotoUrl(String creatorPhotoUrl) {
        this.creatorPhotoUrl = creatorPhotoUrl;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getGameName() {
        return gameName;
    }

    public void setGameName(String gameName) {
        this.gameName = gameName;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getRounds() {
        return rounds;
    }

    public void setRounds(int rounds) {
        this.rounds = rounds;
    }

    public long getStartDate() {
        return startDate;
    }

    public void setStartDate(long startDate) {
        this.startDate = startDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public GroupBureauHistoryInfo() {
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.activityId);
        dest.writeInt(this.coins);
        dest.writeString(this.creatorNickname);
        dest.writeString(this.creatorPhotoUrl);
        dest.writeString(this.gameId);
        dest.writeString(this.gameName);
        dest.writeString(this.inviteCode);
        dest.writeString(this.name);
        dest.writeInt(this.rounds);
        dest.writeLong(this.startDate);
        dest.writeString(this.status);
        dest.writeInt(this.level);
    }

    protected GroupBureauHistoryInfo(Parcel in) {
        this.activityId = in.readString();
        this.coins = in.readInt();
        this.creatorNickname = in.readString();
        this.creatorPhotoUrl = in.readString();
        this.gameId = in.readString();
        this.gameName = in.readString();
        this.inviteCode = in.readString();
        this.name = in.readString();
        this.rounds = in.readInt();
        this.startDate = in.readLong();
        this.status = in.readString();
        this.level = in.readInt();
    }

    public static final Creator<GroupBureauHistoryInfo> CREATOR = new Creator<GroupBureauHistoryInfo>() {
        @Override
        public GroupBureauHistoryInfo createFromParcel(Parcel source) {
            return new GroupBureauHistoryInfo(source);
        }

        @Override
        public GroupBureauHistoryInfo[] newArray(int size) {
            return new GroupBureauHistoryInfo[size];
        }
    };
}
