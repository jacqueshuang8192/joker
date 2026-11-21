package com.linkxin.douyouPlayer.vo;


import android.os.Parcel;
import android.os.Parcelable;

import java.util.Comparator;

/**
 * Created by lxy on 2016/4/6.
 */
public class Room implements Parcelable{

    /**
     * chatRoomId : 181960065073283508
     * cityId : 1
     * compereId : 242
     * compereName : lo
     * count : 0
     * gender : 1
     * latitude : 23.093280792236328
     * leftLife : 100
     * longitude : 113.31736755371094
     * photoUrl : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/242userHeader20160406161701.jpg
     * roomId : 1524
     * roomName : lo 的兜兜窝
     * roomPhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/242roomList20160406161753.jpg
     * status : 0
     * totalLife : 100
     */

    private String chatRoomId;
    private String cityId;
    private String compereId;
    private String compereName;
    private int count;
    private String gender;
    private double latitude;
    private int leftLife;
    private double longitude;
    private String photoUrl;
    private String roomId;
    private String roomName;
    private String roomPhoto;
    private String password;
    private String status;
    private int totalLife;

    private int fmRounds;
    private String liveId;
    private String livePassword;
    private String liveUsername;

    
    /**
     * 正在直播电台时候有该字段
     */
    private String fmTopic;
    /**
     * 真正直播游戏时候有该字段
     */
    private String playingGame;

    private Compere compere;
    private String distance;

    /**
     * 主播状态：
     *
     * 0表示有血量
     * 1表示被抓
     * 2表示被保护
     */
    public static final int STATUS_LIFE = 0;
    public static final int STATUS_CAPTURE = 1;
    public static final int STATUS_PROTECT = 2;

    private int captureStatus;
    private long protectTime;
    private String liveType;
    private int priority;

    public int getCaptureStatus() {
        return captureStatus;
    }

    public void setCaptureStatus(int captureStatus) {
        this.captureStatus = captureStatus;
    }

    public long getProtectTime() {
        return protectTime;
    }

    public void setProtectTime(long protectTime) {
        this.protectTime = protectTime;
    }

    public String getChatRoomId() {
        return chatRoomId;
    }

    public void setChatRoomId(String chatRoomId) {
        this.chatRoomId = chatRoomId;
    }

    public String getCityId() {
        return cityId;
    }

    public void setCityId(String cityId) {
        this.cityId = cityId;
    }

    public String getCompereId() {
        return compereId;
    }

    public void setCompereId(String compereId) {
        this.compereId = compereId;
    }

    public String getCompereName() {
        return compereName;
    }

    public void setCompereName(String compereName) {
        this.compereName = compereName;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public int getLeftLife() {
        return leftLife;
    }

    public void setLeftLife(int leftLife) {
        this.leftLife = leftLife;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

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

    public String getRoomPhoto() {
        return roomPhoto;
    }

    public void setRoomPhoto(String roomPhoto) {
        this.roomPhoto = roomPhoto;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getTotalLife() {
        return totalLife;
    }

    public void setTotalLife(int totalLife) {
        this.totalLife = totalLife;
    }

	public String getFmTopic() {
		return fmTopic;
	}

	public void setFmTopic(String fmTopic) {
		this.fmTopic = fmTopic;
	}

	public String getPlayingGame() {
		return playingGame;
	}

	public void setPlayingGame(String playingGame) {
		this.playingGame = playingGame;
	}

    public Compere getCompere() {
        return compere;
    }

    public void setCompere(Compere compere) {
        this.compere = compere;
    }

    public int getFmRounds() {
        return fmRounds;
    }

    public void setFmRounds(int fmRounds) {
        this.fmRounds = fmRounds;
    }

    public String getLiveId() {
        return liveId;
    }

    public void setLiveId(String liveId) {
        this.liveId = liveId;
    }

    public String getLivePassword() {
        return livePassword;
    }

    public void setLivePassword(String livePassword) {
        this.livePassword = livePassword;
    }

    public String getLiveUsername() {
        return liveUsername;
    }

    public void setLiveUsername(String liveUsername) {
        this.liveUsername = liveUsername;
    }

    public String getDistance() {
        return distance;
    }

    public void setDistance(String distance) {
        this.distance = distance;
    }

    public String getLiveType() {
        return liveType;
    }

    public void setLiveType(String liveType) {
        this.liveType = liveType;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    @Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((chatRoomId == null) ? 0 : chatRoomId.hashCode());
		result = prime * result
				+ ((compereId == null) ? 0 : compereId.hashCode());
		result = prime * result + ((roomId == null) ? 0 : roomId.hashCode());
		result = prime * result
				+ ((roomName == null) ? 0 : roomName.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Room other = (Room) obj;
		if (chatRoomId == null) {
			if (other.chatRoomId != null)
				return false;
		} else if (!chatRoomId.equals(other.chatRoomId))
			return false;
		if (compereId == null) {
			if (other.compereId != null)
				return false;
		} else if (!compereId.equals(other.compereId))
			return false;
		if (roomId == null) {
			if (other.roomId != null)
				return false;
		} else if (!roomId.equals(other.roomId))
			return false;
		if (roomName == null) {
			if (other.roomName != null)
				return false;
		} else if (!roomName.equals(other.roomName))
			return false;
		return true;
	}


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.chatRoomId);
        dest.writeString(this.cityId);
        dest.writeString(this.compereId);
        dest.writeString(this.compereName);
        dest.writeInt(this.count);
        dest.writeString(this.gender);
        dest.writeDouble(this.latitude);
        dest.writeInt(this.leftLife);
        dest.writeDouble(this.longitude);
        dest.writeString(this.photoUrl);
        dest.writeString(this.roomId);
        dest.writeString(this.roomName);
        dest.writeString(this.roomPhoto);
        dest.writeString(this.status);
        dest.writeString(this.password);
        dest.writeInt(this.totalLife);
        dest.writeInt(this.fmRounds);
        dest.writeString(this.liveId);
        dest.writeString(this.livePassword);
        dest.writeString(this.liveUsername);
        dest.writeString(this.fmTopic);
        dest.writeString(this.playingGame);
        dest.writeParcelable(this.compere, flags);
        dest.writeString(this.liveType);
        dest.writeInt(this.priority);
    }

    public Room() {
    }

    protected Room(Parcel in) {
        this.chatRoomId = in.readString();
        this.cityId = in.readString();
        this.compereId = in.readString();
        this.compereName = in.readString();
        this.count = in.readInt();
        this.gender = in.readString();
        this.latitude = in.readDouble();
        this.leftLife = in.readInt();
        this.longitude = in.readDouble();
        this.photoUrl = in.readString();
        this.roomId = in.readString();
        this.roomName = in.readString();
        this.roomPhoto = in.readString();
        this.status = in.readString();
        this.password = in.readString();
        this.totalLife = in.readInt();
        this.fmRounds = in.readInt();
        this.liveId = in.readString();
        this.livePassword = in.readString();
        this.liveUsername = in.readString();
        this.fmTopic = in.readString();
        this.playingGame = in.readString();
        this.compere = in.readParcelable(Compere.class.getClassLoader());
        this.liveType = in.readString();
        this.priority = in.readInt();
    }

    public static final Parcelable.Creator<Room> CREATOR = new Parcelable.Creator<Room>() {
        @Override
        public Room createFromParcel(Parcel source) {
            return new Room(source);
        }

        @Override
        public Room[] newArray(int size) {
            return new Room[size];
        }
    };
}
