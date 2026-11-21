package com.hbi.model;

import javax.persistence.Transient;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

public class FreeGameActivityInfo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private Long activityId;

	private Long userId;
	
	private String name;
	
	private Long gameId;
	
	private String gameCode;
	
	private String gameName;
	
	/**
	 * 0 待开始 1 已开始 2 已结束
	 */
	private String status;
	
	private int rounds;
	
	private int coins;
	
	private Date startDate;
	
	private String creatorNickname;
	private String discription;
	
	private String creatorPhotoUrl;
	
	private String inviteCode;
	
	private int level;
	
	private int isJoin;
	
	private Long creatorId;
	private Integer cards;

	//是否是房卡场
	private Integer isGold;
	//房卡场的tid
	private Long tid;

	@Transient
	private String json;

	public String getJson() {
		return json;
	}

	public void setJson(String json) {
		this.json = json;
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public Long getTid() {
		return tid;
	}

	public void setTid(Long tid) {
		this.tid = tid;
	}

	public Integer getIsGold() {
		return isGold;
	}

	public void setIsGold(Integer isGold) {
		this.isGold = isGold;
	}

	public String getDiscription() {
		return discription;
	}

	public void setDiscription(String discription) {
		this.discription = discription;
	}

	private List<TActivityUser> players;

	public Integer getCards() {
		return cards;
	}

	public void setCards(Integer cards) {
		this.cards = cards;
	}

	public Long getActivityId() {
		return activityId;
	}

	public void setActivityId(Long activityId) {
		this.activityId = activityId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getGameCode() {
		return gameCode;
	}

	public void setGameCode(String gameCode) {
		this.gameCode = gameCode;
	}

	public Long getGameId() {
		return gameId;
	}

	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}

	public String getGameName() {
		return gameName;
	}

	public void setGameName(String gameName) {
		this.gameName = gameName;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public int getRounds() {
		return rounds;
	}

	public void setRounds(int rounds) {
		this.rounds = rounds;
	}

	public int getCoins() {
		return coins;
	}

	public void setCoins(int coins) {
		this.coins = coins;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
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

	public String getInviteCode() {
		return inviteCode;
	}

	public void setInviteCode(String inviteCode) {
		this.inviteCode = inviteCode;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getIsJoin() {
		return isJoin;
	}

	public void setIsJoin(int isJoin) {
		this.isJoin = isJoin;
	}

	public Long getCreatorId() {
		return creatorId;
	}

	public void setCreatorId(Long creatorId) {
		this.creatorId = creatorId;
	}

	public List<TActivityUser> getPlayers() {
		return players;
	}

	public void setPlayers(List<TActivityUser> players) {
		this.players = players;
	}

}
