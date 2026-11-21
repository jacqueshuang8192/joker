package com.linkxin.douyouPlayer.vo;


public class LiveRoomUser implements Comparable<LiveRoomUser>{

	private String userId;
	private String nickName;
	private String photoUrl;
	private int position;
	private boolean isManager;
	private boolean isCanSpeak;
	private boolean isSpeaking;

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public String getPhotoUrl() {
		return photoUrl;
	}

	public void setPhotoUrl(String photoUrl) {
		this.photoUrl = photoUrl;
	}

	public int getPosition() {
		return position;
	}

	public void setPosition(int position) {
		this.position = position;
	}

	public boolean isManager() {
		return isManager;
	}

	public void setManager(boolean isManager) {
		this.isManager = isManager;
	}

	public boolean isCanSpeak() {
		return isCanSpeak;
	}

	public void setCanSpeak(boolean isCanSpeak) {
		this.isCanSpeak = isCanSpeak;
	}

	public boolean isSpeaking() {
		return isSpeaking;
	}

	public void setSpeaking(boolean isSpeaking) {
		this.isSpeaking = isSpeaking;
	}

	@Override
	public int compareTo(LiveRoomUser another) {
		if (this.isManager) {
			return 1;
		} else if (this.isCanSpeak || this.isSpeaking) {
			return 1;
		} else if (another.isManager) {
			return -1;
		} else if (another.isCanSpeak || another.isSpeaking) {
			return -1;
		}
		return 0;
	}

}
