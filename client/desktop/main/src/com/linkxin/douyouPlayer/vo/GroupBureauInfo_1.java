package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

import com.linkxin.library.model.GroupBureauPlayer;

import java.util.List;


/**
 * Created by Administrator on 2016-05-06.
 */
public class GroupBureauInfo implements Parcelable {

    /**
     * activityName : 测试
     * chatRoomId : 192792999380386240
     * coins : 100
     * creatorId : 272
     * creatorNickname : 龙傲天
     * creatorPhotoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/(null)userHeader20160409164815.jpg
     * gameActivityId : 366
     * gameId : 1
     * gameName : 斗地主
     * gamePhoto : doudizhu
     * inviteCode : 021387
     * minutes : 30
     * oriCoins : 100
     * players : [{"drawRounds":0,"loseRounds":0,"nickName":"龙傲天","nowCoins":100,"oriCoins":100,"photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/(null)userHeader20160409164815.jpg","status":0,"userId":"272","winRounds":0}]
     * startDate : 1462452917977
     * status : 0
     * tableId : 118030336
     * level : 35
     * gameCode : 斗地主
     */

    private String activityName;
    private String chatRoomId;
    private int coins;
    private String creatorId;
    private String creatorNickname;
    private String creatorPhotoUrl;
    private String gameActivityId;
    private String gameId;
    private String gameName;
    private String gamePhoto;
    private String inviteCode;
    private int minutes;
    private int oriCoins;
    private long startDate;
    private int status;
    private String tableId;
    private int level;
    private String gameCode;

    public String getGameCode() {
        return gameCode;
    }

    public void setGameCode(String gameCode) {
        this.gameCode = gameCode;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    private List<GroupBureauPlayer> players;

    public List<GroupBureauPlayer> getPlayers() {
        return players;
    }

    public void setPlayers(List<GroupBureauPlayer> players) {
        this.players = players;
    }

    public String getActivityName() {
        return activityName;
    }

    public void setActivityName(String activityName) {
        this.activityName = activityName;
    }

    public String getChatRoomId() {
        return chatRoomId;
    }

    public void setChatRoomId(String chatRoomId) {
        this.chatRoomId = chatRoomId;
    }

    public int getCoins() {
        return coins;
    }

    public void setCoins(int coins) {
        this.coins = coins;
    }

    public String getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(String creatorId) {
        this.creatorId = creatorId;
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

    public String getGameActivityId() {
        return gameActivityId;
    }

    public void setGameActivityId(String gameActivityId) {
        this.gameActivityId = gameActivityId;
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

    public String getGamePhoto() {
        return gamePhoto;
    }

    public void setGamePhoto(String gamePhoto) {
        this.gamePhoto = gamePhoto;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public int getMinutes() {
        return minutes;
    }

    public void setMinutes(int minutes) {
        this.minutes = minutes;
    }

    public int getOriCoins() {
        return oriCoins;
    }

    public void setOriCoins(int oriCoins) {
        this.oriCoins = oriCoins;
    }

    public long getStartDate() {
        return startDate;
    }

    public void setStartDate(long startDate) {
        this.startDate = startDate;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getTableId() {
        return tableId;
    }

    public void setTableId(String tableId) {
        this.tableId = tableId;
    }

    public GroupBureauInfo() {
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.activityName);
        dest.writeString(this.chatRoomId);
        dest.writeInt(this.coins);
        dest.writeString(this.creatorId);
        dest.writeString(this.creatorNickname);
        dest.writeString(this.creatorPhotoUrl);
        dest.writeString(this.gameActivityId);
        dest.writeString(this.gameId);
        dest.writeString(this.gameName);
        dest.writeString(this.gamePhoto);
        dest.writeString(this.inviteCode);
        dest.writeInt(this.minutes);
        dest.writeInt(this.oriCoins);
        dest.writeLong(this.startDate);
        dest.writeInt(this.status);
        dest.writeString(this.tableId);
        dest.writeInt(this.level);
        dest.writeString(this.gameCode);
        dest.writeTypedList(this.players);
    }

    protected GroupBureauInfo(Parcel in) {
        this.activityName = in.readString();
        this.chatRoomId = in.readString();
        this.coins = in.readInt();
        this.creatorId = in.readString();
        this.creatorNickname = in.readString();
        this.creatorPhotoUrl = in.readString();
        this.gameActivityId = in.readString();
        this.gameId = in.readString();
        this.gameName = in.readString();
        this.gamePhoto = in.readString();
        this.inviteCode = in.readString();
        this.minutes = in.readInt();
        this.oriCoins = in.readInt();
        this.startDate = in.readLong();
        this.status = in.readInt();
        this.tableId = in.readString();
        this.level = in.readInt();
        this.gameCode = in.readString();
        this.players = in.createTypedArrayList(GroupBureauPlayer.CREATOR);
    }

    public static final Creator<GroupBureauInfo> CREATOR = new Creator<GroupBureauInfo>() {
        @Override
        public GroupBureauInfo createFromParcel(Parcel source) {
            return new GroupBureauInfo(source);
        }

        @Override
        public GroupBureauInfo[] newArray(int size) {
            return new GroupBureauInfo[size];
        }
    };
}
