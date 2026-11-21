package com.hbi.cache.model;


public class CacheCompereListProfile extends CacheUserListProfile {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 主播等级
	 */
	private Integer level;
	
	/**
	 * 粉丝数量
	 */
	private int fansCount;

	public Integer getLevel() {
		return level;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}

	public int getFansCount() {
		return fansCount;
	}

	public void setFansCount(int fansCount) {
		this.fansCount = fansCount;
	}
	
}
