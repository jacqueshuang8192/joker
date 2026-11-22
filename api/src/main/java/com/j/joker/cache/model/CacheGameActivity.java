package com.j.joker.cache.model;

import com.j.joker.cache.CacheModel;

import java.util.Date;
import java.util.List;

public class CacheGameActivity extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 组局活动ID
	 */
	private String gameActivityId;
	
	/**
	 * 组局名称
	 */
	private String activityName;
	
	/**
	 * 邀请码
	 */
	private String inviteCode;
	
	/**
	 * 底注
	 */
	private int coins;
	
	/**
	 * 初始筹码
	 */
	private int oriCoins;
	/**
	 * 终局局数
	 */
//	private int rounds;
	
	/**
	 * 组局的状态, 0 准备中，1 进行中， 2 结束
	 */
	private Integer status;
	
	private Date startDate;
	/**
	 * 剩余分钟
	 */
	private int minutes;
	
	/**
	 * 游戏ID
	 */
	private String gameId;
	
	/**
	 * 游戏CODE
	 */
	private String gameCode;
	
	/**
	 * 游戏名称
	 */
	private String gameName;
	
	private String gamePhoto;
	
	/**
	 * 创建者id
	 */
	private String creatorId;
	
	/**
	 * 创建者昵称
	 */
	private String creatorNickname;
	
	/**
	 * 创建者头像
	 */
	private String creatorPhotoUrl;
	
	/**
	 * 聊天室ID
	 */
	private String chatRoomId;
	
	private int tableId;
	
	private Integer level;
	
	
    private Integer cards;

    private Integer isGold;

    private Integer maxPlayer;

    //是否观战
    private Integer isWatch;

	/**
	 * 游戏的组局配置
	 */
	private String json;

	private String payType;

	private String passWord;

	/**
	 * 联盟ID
	 */
	private Integer groupId;

	public Integer getIsWatch() {
		return isWatch;
	}

	public void setIsWatch(Integer isWatch) {
		this.isWatch = isWatch;
	}

	public Integer getGroupId(){
		return groupId;
	}

	public void setGroupId(Integer groupId){
		this.groupId = groupId;
	}

	public String getPassWord() {
		return passWord;
	}

	public void setPassWord(String passWord) {
		this.passWord = passWord;
	}

	public String getPayType() {
		return payType;
	}

	public void setPayType(String payType) {
		this.payType = payType;
	}

	public String getJson() {
		return json;
	}

	public void setJson(String json) {
		this.json = json;
	}

	/**
	 *
	 * @return
	 */

	public Integer getMaxPlayer() {
		return maxPlayer;
	}

	public void setMaxPlayer(Integer maxPlayer) {
		this.maxPlayer = maxPlayer;
	}

	/**
	 * 玩家列表
	 */
	private List<CacheGameActivityPlayer> players;

	private String activityDiscription;

	public Integer getCards() {
		return cards;
	}

	public void setCards(Integer cards) {
		this.cards = cards;
	}

	public String getGameActivityId() {
		return gameActivityId;
	}

	public void setGameActivityId(String gameActivityId) {
		this.gameActivityId = gameActivityId;
	}

	public String getActivityName() {
		return activityName;
	}

	public void setActivityName(String activityName) {
		this.activityName = activityName;
	}

	public String getInviteCode() {
		return inviteCode;
	}

	public void setInviteCode(String inviteCode) {
		this.inviteCode = inviteCode;
	}

	public int getCoins() {
		return coins;
	}

	public void setCoins(int coins) {
		this.coins = coins;
	}

	public int getOriCoins() {
		return oriCoins;
	}

	public void setOriCoins(int oriCoins) {
		this.oriCoins = oriCoins;
	}

	public Integer getStatus() {
		return status;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public int getMinutes() {
		return minutes;
	}

	public void setMinutes(int minutes) {
		this.minutes = minutes;
	}

	public String getGameCode() {
		return gameCode;
	}

	public void setGameCode(String gameCode) {
		this.gameCode = gameCode;
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

	public String getChatRoomId() {
		return chatRoomId;
	}

	public void setChatRoomId(String chatRoomId) {
		this.chatRoomId = chatRoomId;
	}

	public int getTableId() {
		return tableId;
	}

	public void setTableId(int tableId) {
		this.tableId = tableId;
	}

	public Integer getLevel() {
		return level;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}

	public List<CacheGameActivityPlayer> getPlayers() {
		return players;
	}

	public void setPlayers(List<CacheGameActivityPlayer> players) {
		this.players = players;
	}
	
	public String getActivityDiscription() {
		return activityDiscription;
	}

	public void setActivityDiscription(String activityDiscription) {
		this.activityDiscription = activityDiscription;
	}

	public Integer getIsGold() {
		return isGold;
	}

	public void setIsGold(Integer isGold) {
		this.isGold = isGold;
	}
}
