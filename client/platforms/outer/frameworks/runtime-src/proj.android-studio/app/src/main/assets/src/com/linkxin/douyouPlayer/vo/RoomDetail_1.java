package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by zhongweihao on 16/4/28.
 */
public class RoomDetail implements Parcelable {


    /**
     * 房间ID
     */
    private String roomId;

    /**
     * 房间名称
     */
    private String roomName;

    /**
     * 直播ID
     */
    private String liveId;

    /**
     * 聊天室ID
     */
    private String chatRoomId;

    /**
     * 麦克风状态 0 空闲 1 主播占用 2 抢麦中 3 玩家占用
     */
    private String microphone;

    /**
     * 正在玩的游戏ID
     */
    private String playingGameId;

    /**
     * 正在玩的游戏名称
     */
    private String playingGame;

    private String fmTopicId;

    /**
     * 电台主题
     */
    private String fmTopic;

    private LiveRoomGoods fmTicketGoods;
    /**
     * 房间人数
     */
    private int count;

    private String roomPassword;

    private Compere compere;

    private String compereId;

    private String roomPhoto;

    private String liveUsername;

    private String livePassword;

//        private TGoods fmTicketGoods;

    private String isFmStart;

    private String ysigWord;

    private int fmRounds;

    private String liveType;

    private String activityPhotoUrl;

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getLiveId() {
        return liveId;
    }

    public void setLiveId(String liveId) {
        this.liveId = liveId;
    }

    public String getChatRoomId() {
        return chatRoomId;
    }

    public void setChatRoomId(String chatRoomId) {
        this.chatRoomId = chatRoomId;
    }

    public String getMicrophone() {
        return microphone;
    }

    public void setMicrophone(String microphone) {
        this.microphone = microphone;
    }

    public String getPlayingGameId() {
        return playingGameId;
    }

    public void setPlayingGameId(String playingGameId) {
        this.playingGameId = playingGameId;
    }

    public String getPlayingGame() {
        return playingGame;
    }

    public void setPlayingGame(String playingGame) {
        this.playingGame = playingGame;
    }

    public String getFmTopicId() {
        return fmTopicId;
    }

    public void setFmTopicId(String fmTopicId) {
        this.fmTopicId = fmTopicId;
    }

    public String getFmTopic() {
        return fmTopic;
    }

    public void setFmTopic(String fmTopic) {
        this.fmTopic = fmTopic;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public LiveRoomGoods getFmTicketGoods() {
        return fmTicketGoods;
    }

    public void setFmTicketGoods(LiveRoomGoods fmTicketGoods) {
        this.fmTicketGoods = fmTicketGoods;
    }

    public String getRoomPassword() {
        return roomPassword;
    }

    public void setRoomPassword(String roomPassword) {
        this.roomPassword = roomPassword;
    }

    public Compere getCompere() {
        return compere;
    }

    public void setCompere(Compere compere) {
        this.compere = compere;
    }

    public String getCompereId() {
        return compereId;
    }

    public void setCompereId(String compereId) {
        this.compereId = compereId;
    }

    public String getRoomPhoto() {
        return roomPhoto;
    }

    public void setRoomPhoto(String roomPhoto) {
        this.roomPhoto = roomPhoto;
    }

    public String getLiveUsername() {
        return liveUsername;
    }

    public void setLiveUsername(String liveUsername) {
        this.liveUsername = liveUsername;
    }

    public String getLivePassword() {
        return livePassword;
    }

    public void setLivePassword(String livePassword) {
        this.livePassword = livePassword;
    }

    public String getIsFmStart() {
        return isFmStart;
    }

    public void setIsFmStart(String isFmStart) {
        this.isFmStart = isFmStart;
    }

    public String getYsigWord() {
        return ysigWord;
    }

    public void setYsigWord(String ysigWord) {
        this.ysigWord = ysigWord;
    }

    public int getFmRounds() {
        return fmRounds;
    }

    public void setFmRounds(int fmRounds) {
        this.fmRounds = fmRounds;
    }

    public String getLiveType() {
        return liveType;
    }

    public void setLiveType(String liveType) {
        this.liveType = liveType;
    }

    public String getActivityPhotoUrl() {
        return activityPhotoUrl;
    }

    public void setActivityPhotoUrl(String activityPhotoUrl) {
        this.activityPhotoUrl = activityPhotoUrl;
    }

    public RoomDetail() {
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.roomId);
        dest.writeString(this.roomName);
        dest.writeString(this.liveId);
        dest.writeString(this.chatRoomId);
        dest.writeString(this.microphone);
        dest.writeString(this.playingGameId);
        dest.writeString(this.playingGame);
        dest.writeString(this.fmTopicId);
        dest.writeString(this.fmTopic);
        dest.writeParcelable(this.fmTicketGoods, flags);
        dest.writeInt(this.count);
        dest.writeString(this.roomPassword);
        dest.writeParcelable(this.compere, flags);
        dest.writeString(this.compereId);
        dest.writeString(this.roomPhoto);
        dest.writeString(this.liveUsername);
        dest.writeString(this.livePassword);
        dest.writeString(this.isFmStart);
        dest.writeString(this.ysigWord);
        dest.writeInt(this.fmRounds);
        dest.writeString(this.liveType);
        dest.writeString(this.activityPhotoUrl);
    }

    protected RoomDetail(Parcel in) {
        this.roomId = in.readString();
        this.roomName = in.readString();
        this.liveId = in.readString();
        this.chatRoomId = in.readString();
        this.microphone = in.readString();
        this.playingGameId = in.readString();
        this.playingGame = in.readString();
        this.fmTopicId = in.readString();
        this.fmTopic = in.readString();
        this.fmTicketGoods = in.readParcelable(LiveRoomGoods.class.getClassLoader());
        this.count = in.readInt();
        this.roomPassword = in.readString();
        this.compere = in.readParcelable(Compere.class.getClassLoader());
        this.compereId = in.readString();
        this.roomPhoto = in.readString();
        this.liveUsername = in.readString();
        this.livePassword = in.readString();
        this.isFmStart = in.readString();
        this.ysigWord = in.readString();
        this.fmRounds = in.readInt();
        this.liveType = in.readString();
        this.activityPhotoUrl = in.readString();
    }

    public static final Creator<RoomDetail> CREATOR = new Creator<RoomDetail>() {
        @Override
        public RoomDetail createFromParcel(Parcel source) {
            return new RoomDetail(source);
        }

        @Override
        public RoomDetail[] newArray(int size) {
            return new RoomDetail[size];
        }
    };
}
