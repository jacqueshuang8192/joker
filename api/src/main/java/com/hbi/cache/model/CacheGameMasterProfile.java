package com.hbi.cache.model;

import com.hbi.cache.CacheModel;

public class CacheGameMasterProfile extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 游戏ID
	 */
	private String gameId;
	
	/**
	 * 游戏名称
	 */
	private String gameName;
	
	/**
	 * 描述
	 */
	private String desc;
	
	/**
	 * 段位等级名称
	 */
	private String levelName;
	
	/**
	 * 段位等级
	 */
	private String level;
	
	/**
	 * 胜场
	 */
	private int successCount;
	
	/**
	 * 败场
	 */
	private int failureCount;
	
	/**
	 * 经验槽
	 */
	private int experienceLine;
	
	/**
	 * 当前经验
	 */
	private int experience;
	
	/**
	 * 状态，比如5进4升段中，涨经验中
	 */
	private String status;
	
	/**
	 * 段位排名
	 */
	private int rank;
	
	/**
	 * 最近游戏时间
	 */
//	private Date latestPlayDate;
//	

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

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

	public String getLevelName() {
		return levelName;
	}

	public void setLevelName(String levelName) {
		this.levelName = levelName;
	}

	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}

	public int getSuccessCount() {
		return successCount;
	}

	public void setSuccessCount(int successCount) {
		this.successCount = successCount;
	}

	public int getFailureCount() {
		return failureCount;
	}

	public void setFailureCount(int failureCount) {
		this.failureCount = failureCount;
	}

	public int getExperienceLine() {
		return experienceLine;
	}

	public void setExperienceLine(int experienceLine) {
		this.experienceLine = experienceLine;
	}

	public int getExperience() {
		return experience;
	}

	public void setExperience(int experience) {
		this.experience = experience;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public int getRank() {
		return rank;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}
	
}
