package com.hbi.cache.model;

public class CachePlayerListProfile extends CacheUserListProfile {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 平台等级
	 */
	private String level;
	
	/**
	 * vip等级
	 */
	private String vipLevel;
	
	/**
	 * 贡献度，只有在对象作为贡献排行榜项元素时才使用
	 */
	private int contribution;
	
	/**
	 * 财富，只有在对象作为财富排行榜项元素时才使用
	 */
	private int wealth;
	
	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}

	public String getVipLevel() {
		return vipLevel;
	}

	public void setVipLevel(String vipLevel) {
		this.vipLevel = vipLevel;
	}

	public int getContribution() {
		return contribution;
	}

	public void setContribution(int contribution) {
		this.contribution = contribution;
	}

	public int getWealth() {
		return wealth;
	}

	public void setWealth(int wealth) {
		this.wealth = wealth;
	}
}
