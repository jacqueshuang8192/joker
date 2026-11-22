package com.j.joker.cache.model;

import java.util.Date;
import java.util.List;

import com.j.joker.cache.CacheModel;

public class CacheRoomListProfile extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 房间ID
	 */
	private String roomId;
	
	/**
	 * 房间名称
	 */
	private String roomName;
	
	/**
	 * 主播ID
	 */
	private String compereId;
	
	/**
	 * 主播头像
	 */
	private String photoUrl;
	
	private String compereRoomPhoto;
	private String compereLivePhoto;
	
	/**
	 * 房间图片
	 */
	private String roomPhoto;
	
	/**
	 * 主播名字
	 */
	private String compereName;

	/**
	 * 主播性别
	 */
	private String gender;

	/**
	 * 主播剩余血量
	 */
	private Long leftLife;

	/**
	 * 主播总血量
	 */
	private Long totalLife;

	/**
	 * 房间密码
	 */
	private String password;
	
	/**
	 * 游戏名称
	 */
	private String playingGame;
	
	/**
	 * 电台主题
	 */
	private String fmTopic;
	
	/**
	 * 房间人数
	 */
	private int count;
	
	/**
	 * 直播帧
	 */
	private String liveCut;
	
	/**
	 * 主播幻灯片
	 */
	private List<String> photos;
	
	/**
	 * 纬度
	 */
	private double latitude;
	
	/**
	 * 经度
	 */
	private double longitude;
	
	/**
	 * 状态  0 未直播 1 直播中
	 */
	private String status;
	
	/**
	 * 直播ID
	 */
	private String liveId;

	/**
	 * 聊天室ID
	 */
	private String chatRoomId;

	/**
	 * 城市ID
	 */
	private String cityId;
	/**
	 * 主播被抓状态
	 */
	private Integer captureStatus;

	private Date protectTime;

	private String liveType;

	private Integer priority;
	
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

	public String getCompereId() {
		return compereId;
	}

	public void setCompereId(String compereId) {
		this.compereId = compereId;
	}

	public String getPhotoUrl() {
		return photoUrl;
	}

	public void setPhotoUrl(String photoUrl) {
		this.photoUrl = photoUrl;
	}

	public String getCompereRoomPhoto() {
        return compereRoomPhoto;
    }

    public void setCompereRoomPhoto(String compereRoomPhoto) {
        this.compereRoomPhoto = compereRoomPhoto;
    }

    public String getCompereLivePhoto() {
        return compereLivePhoto;
    }

    public void setCompereLivePhoto(String compereLivePhoto) {
        this.compereLivePhoto = compereLivePhoto;
    }

    public String getRoomPhoto() {
		return roomPhoto;
	}

	public void setRoomPhoto(String roomPhoto) {
		this.roomPhoto = roomPhoto;
	}

	public String getCompereName() {
		return compereName;
	}

	public void setCompereName(String compereName) {
		this.compereName = compereName;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getPlayingGame() {
		return playingGame;
	}

	public void setPlayingGame(String playingGame) {
		this.playingGame = playingGame;
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

	public String getLiveCut() {
		return liveCut;
	}

	public void setLiveCut(String liveCut) {
		this.liveCut = liveCut;
	}

	public List<String> getPhotos() {
		return photos;
	}

	public void setPhotos(List<String> photos) {
		this.photos = photos;
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

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
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

	public String getCityId() {
		return cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public Long getLeftLife() {
		return leftLife;
	}

	public void setLeftLife(Long leftLife) {
		this.leftLife = leftLife;
	}

	public Long getTotalLife() {
		return totalLife;
	}

	public void setTotalLife(Long totalLife) {
		this.totalLife = totalLife;
	}

	public Integer getCaptureStatus() {
		return captureStatus;
	}

	public void setCaptureStatus(Integer captureStatus) {
		this.captureStatus = captureStatus;
	}

	public Date getProtectTime() {
		return protectTime;
	}

	public void setProtectTime(Date protectTime) {
		this.protectTime = protectTime;
	}

	public String getLiveType() {
		return liveType;
	}

	public void setLiveType(String liveType) {
		this.liveType = liveType;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}
}
