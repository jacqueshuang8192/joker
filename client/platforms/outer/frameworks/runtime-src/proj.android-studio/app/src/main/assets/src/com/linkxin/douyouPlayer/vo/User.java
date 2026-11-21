package com.linkxin.douyouPlayer.vo;

import java.io.Serializable;

public class User implements Comparable<User>, Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String userId;
	private String nickName;
	private String portraitUrl;
	private String phone;
	private String sex;
	private String age;
	private String level;
	private String city;
	private String sign;
	private String societyId;
	private String society;
	private String sortLetters; // 显示数据拼音的首字母
	private int coinsAmount;
	
	public int getCoinsAmount() {
		return coinsAmount;
	}

	public void setCoinsAmount(int coinsAmount) {
		this.coinsAmount = coinsAmount;
	}

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

	public String getPortraitUrl() {
		return portraitUrl;
	}

	public void setPortraitUrl(String portraitUrl) {
		this.portraitUrl = portraitUrl;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getAge() {
		return age;
	}

	public void setAge(String age) {
		this.age = age;
	}

	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getSign() {
		return sign;
	}

	public void setSign(String sign) {
		this.sign = sign;
	}

	public String getSocietyId() {
		return societyId;
	}

	public void setSocietyId(String societyId) {
		this.societyId = societyId;
	}

	public String getSociety() {
		return society;
	}

	public void setSociety(String society) {
		this.society = society;
	}

	public String getSortLetters() {
		return sortLetters;
	}

	public void setSortLetters(String sortLetters) {
		this.sortLetters = sortLetters;
	}

	@Override
	public int compareTo(User another) {
		if (this.getSortLetters().equals("@")
				|| another.getSortLetters().equals("#")) {
			return -1;
		} else if (this.getSortLetters().equals("#")
				|| another.getSortLetters().equals("@")) {
			return 1;
		} else {
			return this.getSortLetters().compareTo(another.getSortLetters());
		}
	}
}
