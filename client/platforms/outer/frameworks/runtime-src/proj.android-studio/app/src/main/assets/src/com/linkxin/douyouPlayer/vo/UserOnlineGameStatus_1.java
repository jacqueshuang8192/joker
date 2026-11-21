package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Administrator on 2016-06-08.
 */
public class UserOnlineGameStatus implements Parcelable {

    private String gameId;
    private String gameStatus;
    private String type;// R 组局 G 自由场

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getGameStatus() {
        return gameStatus;
    }

    public void setGameStatus(String gameStatus) {
        this.gameStatus = gameStatus;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.gameId);
        dest.writeString(this.gameStatus);
        dest.writeString(this.type);
    }

    public UserOnlineGameStatus() {
    }

    protected UserOnlineGameStatus(Parcel in) {
        this.gameId = in.readString();
        this.gameStatus = in.readString();
        this.type = in.readString();
    }

    public static final Parcelable.Creator<UserOnlineGameStatus> CREATOR = new Parcelable.Creator<UserOnlineGameStatus>() {
        @Override
        public UserOnlineGameStatus createFromParcel(Parcel source) {
            return new UserOnlineGameStatus(source);
        }

        @Override
        public UserOnlineGameStatus[] newArray(int size) {
            return new UserOnlineGameStatus[size];
        }
    };
}
