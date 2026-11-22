package com.j.joker.cache.model;

import java.io.Serializable;

public class CacheGameActivityPlayer implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 组局玩家ID
	 */
	private String userId;
	
	/**
	 * 玩家头像
	 */
	private String photoUrl;
	
	/**
	 * 昵称
	 */
	private String nickName;
	
	/**
	 * 带入筹码
	 */
	private int oriCoins;
	
	/**
	 * 现筹码
	 */
	private int nowCoins;
	
	/**
	 * 赢的局数
	 */
	private int winRounds;
	
	/**
	 * 输的局数
	 */
	private int loseRounds;
	
	/**
	 * 平局局数
	 */
	private int drawRounds;
	
	private String tableId;
	
	private int status;
	
	private String phone;

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getPhotoUrl() {
		return photoUrl;
	}

	public void setPhotoUrl(String photoUrl) {
		this.photoUrl = photoUrl;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public int getOriCoins() {
		return oriCoins;
	}

	public void setOriCoins(int oriCoins) {
		this.oriCoins = oriCoins;
	}

	public int getNowCoins() {
		return nowCoins;
	}

	public void setNowCoins(int nowCoins) {
		this.nowCoins = nowCoins;
	}

	public int getWinRounds() {
		return winRounds;
	}

	public void setWinRounds(int winRounds) {
		this.winRounds = winRounds;
	}

	public int getLoseRounds() {
		return loseRounds;
	}

	public void setLoseRounds(int loseRounds) {
		this.loseRounds = loseRounds;
	}

	public int getDrawRounds() {
		return drawRounds;
	}

	public void setDrawRounds(int drawRounds) {
		this.drawRounds = drawRounds;
	}

	public String getTableId() {
		return tableId;
	}

	public void setTableId(String tableId) {
		this.tableId = tableId;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}
}
