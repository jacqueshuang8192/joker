package com.linkxin.douyouPlayer.vo;

import java.io.Serializable;


public class HomePageInfoListModel implements Serializable {

	private String portraitUrl;
	private String anchorName;
	private String distance;
	private int roomUserCount;
	private String livePictureUrl;
	private String roomId;

	public HomePageInfoListModel(String portraitUrl, String anchorName,
			String distance, int roomUserCount, String livePictureUrl,
			String roomId) {
		super();
		this.portraitUrl = portraitUrl;
		this.anchorName = anchorName;
		this.distance = distance;
		this.roomUserCount = roomUserCount;
		this.livePictureUrl = livePictureUrl;
		this.roomId = roomId;
	}

	public String getLivePictureUrl() {
		return livePictureUrl;
	}

	public void setLivePictureUrl(String livePictureUrl) {
		this.livePictureUrl = livePictureUrl;
	}

	public String getPortraitUrl() {
		return portraitUrl;
	}

	public void setPortraitUrl(String portraitUrl) {
		this.portraitUrl = portraitUrl;
	}

	public String getAnchorName() {
		return anchorName;
	}

	public void setAnchorName(String anchorName) {
		this.anchorName = anchorName;
	}

	public String getDistance() {
		return distance;
	}

	public void setDistance(String distance) {
		this.distance = distance;
	}

	public int getRoomUserCount() {
		return roomUserCount;
	}

	public void setRoomUserCount(int roomUserCount) {
		this.roomUserCount = roomUserCount;
	}

	public String getRoomId() {
		return roomId;
	}

	public void setRoomId(String roomId) {
		this.roomId = roomId;
	}
	
}
