package com.hbi.cache.model;

import com.hbi.cache.CacheModel;
import com.hbi.model.TGoods;

public class CacheRoomProfile extends CacheModel {

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

	private String playingGameCode;
	/**
	 * 正在玩的游戏名称
	 */
	private String playingGame;
	
	private String fmTopicId;
	
	/**
	 * 电台主题
	 */
	private String fmTopic;

	/**
	 * 房间人数
	 */
	private int count;

	private String roomPassword;

	private CacheCompereProfile compere;
	
	private String compereId;
	
	private String roomPhoto;
	
	private String liveUsername;
	
	private String livePassword;
	
	private TGoods fmTicketGoods;
	
	private String isFmStart;
	
	private String ysigWord;
	
	private int fmRounds;

	private String liveType;
	
	private String resolution;

	private Integer priority;
	
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

	public String getPlayingGameCode() {
		return playingGameCode;
	}

	public void setPlayingGameCode(String playingGameCode) {
		this.playingGameCode = playingGameCode;
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

	public String getRoomPassword() {
		return roomPassword;
	}

	public void setRoomPassword(String roomPassword) {
		this.roomPassword = roomPassword;
	}

	public CacheCompereProfile getCompere() {
		return compere;
	}

	public void setCompere(CacheCompereProfile compere) {
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

	public TGoods getFmTicketGoods() {
		return fmTicketGoods;
	}

	public void setFmTicketGoods(TGoods fmTicketGoods) {
		this.fmTicketGoods = fmTicketGoods;
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

	public String getResolution() {
		return resolution;
	}

	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getActivityPhotoUrl() {
		return activityPhotoUrl;
	}

	public void setActivityPhotoUrl(String activityPhotoUrl) {
		this.activityPhotoUrl = activityPhotoUrl;
	}
}
