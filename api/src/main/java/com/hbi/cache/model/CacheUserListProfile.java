package com.hbi.cache.model;

import java.util.Date;

import com.hbi.cache.CacheModel;

public class CacheUserListProfile extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 用户ID
	 */
	private String userId;
	
	/**
	 * 用户昵称
	 */
	private String nickName;
	
	/**
	 * 头像
	 */
	private String photoUrl;
	
	/**
	 * 用户状态
	 */
	private String status;
	
	/**
	 * 线上状态 :0：不在线；1：在线；2：在房间；3：游戏中
	 */
	private String onlineStatus;
	
	/**
	 * 正在玩的游戏
	 */
	private String playingGame;
	
	/**
	 * 排麦位置， 只有作为直播间玩家列表展示才使用
	 */
	private String position;
	
	/**
	 * 类型, P 玩家, C 主播
	 */
	private String type;
	
	/**
	 * 性别 1 男 2 女
	 */
	private String sex;

	/**
	 * 生日
	 */
	private Date birthday;
	
	/**
	 * 公会ID
	 */
	private Long societyId;
	
	/**
	 * 签名
	 */
	private String sign;
	
	/**
	 * 城市
	 */
	private String city;
	
	/**
	 * 城市ID
	 */
	private String cityId;
	
    /**
     * 攻击
     */
    private Long attack;
    
    /**
     * 防御
     */
    private Long defense;
    
    /**
     * 生命
     */
    private Long life;
	
	private Float longitude;

    private Float latitude;
    
    private String phone;

	private String account;
    
    private int fmTotalMatch;
    
    private int fmTotalScore;
    
    private int fmCurrentRank = 99;
    
    private int fmCurrentScore;

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

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getOnlineStatus() {
		return onlineStatus;
	}

	public void setOnlineStatus(String onlineStatus) {
		this.onlineStatus = onlineStatus;
	}

	public String getPlayingGame() {
		return playingGame;
	}

	public void setPlayingGame(String playingGame) {
		this.playingGame = playingGame;
	}

	public String getPosition() {
		return position;
	}

	public void setPosition(String position) {
		this.position = position;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public Date getBirthday() {
		return birthday;
	}

	public void setBirthday(Date birthday) {
		this.birthday = birthday;
	}

	public String getSign() {
		return sign;
	}

	public void setSign(String sign) {
		this.sign = sign;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getCityId() {
		return cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	public Float getLongitude() {
		return longitude;
	}

	public void setLongitude(Float longitude) {
		this.longitude = longitude;
	}

	public Float getLatitude() {
		return latitude;
	}

	public void setLatitude(Float latitude) {
		this.latitude = latitude;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

    public Long getAttack() {
        return attack;
    }

    public void setAttack(Long attack) {
        this.attack = attack;
    }

    public Long getDefense() {
        return defense;
    }

    public void setDefense(Long defense) {
        this.defense = defense;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

    public Long getSocietyId() {
        return societyId;
    }

    public void setSocietyId(Long societyId) {
        this.societyId = societyId;
    }

	public int getFmTotalMatch() {
		return fmTotalMatch;
	}

	public void setFmTotalMatch(int fmTotalMatch) {
		this.fmTotalMatch = fmTotalMatch;
	}

	public int getFmTotalScore() {
		return fmTotalScore;
	}

	public void setFmTotalScore(int fmTotalScore) {
		this.fmTotalScore = fmTotalScore;
	}

	public int getFmCurrentRank() {
		return fmCurrentRank;
	}

	public void setFmCurrentRank(int fmCurrentRank) {
		this.fmCurrentRank = fmCurrentRank;
	}

	public int getFmCurrentScore() {
		return fmCurrentScore;
	}

	public void setFmCurrentScore(int fmCurrentScore) {
		this.fmCurrentScore = fmCurrentScore;
	}

	public String getAccount() {
		return account;
	}

	public void setAccount(String account) {
		this.account = account;
	}
}
