package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

public class GameChip implements Parcelable {

    /**
     * coins : 100
     * extract : 20
     * gameId : 1
     * id : 1
     * level : 11
     * name : test1,�л�����
     * playerCount : 0
     * status : 1
     */

    private int coins;
    private int extract;
    private int oriCoins;

    public int getOriCoins() {
        return oriCoins;
    }

    public void setOriCoins(int oriCoins) {
        this.oriCoins = oriCoins;
    }

    private String gameId;
    private String id;
    private int level;
    private String name;
    private int playerCount;
    private String status;

    public int getCoins() {
        return coins;
    }

    public void setCoins(int coins) {
        this.coins = coins;
    }

    public int getExtract() {
        return extract;
    }

    public void setExtract(int extract) {
        this.extract = extract;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPlayerCount() {
        return playerCount;
    }

    public void setPlayerCount(int playerCount) {
        this.playerCount = playerCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.coins);
        dest.writeInt(this.extract);
        dest.writeInt(this.oriCoins);
        dest.writeString(this.gameId);
        dest.writeString(this.id);
        dest.writeInt(this.level);
        dest.writeString(this.name);
        dest.writeInt(this.playerCount);
        dest.writeString(this.status);
    }

    public GameChip() {
    }

    protected GameChip(Parcel in) {
        this.coins = in.readInt();
        this.extract = in.readInt();
        this.oriCoins = in.readInt();
        this.gameId = in.readString();
        this.id = in.readString();
        this.level = in.readInt();
        this.name = in.readString();
        this.playerCount = in.readInt();
        this.status = in.readString();
    }

    public static final Parcelable.Creator<GameChip> CREATOR = new Parcelable.Creator<GameChip>() {
        @Override
        public GameChip createFromParcel(Parcel source) {
            return new GameChip(source);
        }

        @Override
        public GameChip[] newArray(int size) {
            return new GameChip[size];
        }
    };
}
