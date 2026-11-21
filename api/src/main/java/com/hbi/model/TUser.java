package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.util.Date;

@Table(name = "t_user")
public class TUser implements Serializable {
    @Id
    private Long userid;

    private String type;
    
    private String phone;
    private String identity;

    @Column(name = "last_login")
    private Date lastLogin;

    private String password;

    private String state;

    @Column(name = "online_status")
    private String onlineStatus;

    @Column(name = "agent_id")
    private Long agentId;

    @Column(name = "small_icon")
    private String smallIcon;

    private String account;

    @Column(name = "nick_name")
    private String nickName;

    private String gender;

    private Date birthday;

    private String sign;

    @Column(name = "create_date")
    private Date createDate;

    @Column(name = "QQ")
    private String qq;
    
    @Column(name = "wechat")
    private String wechat;
    
    @Column(name = "weibo")
    private String weibo;

    private String name;

    @Column(name = "grade")
    private Float grade;

    @Column(name = "is_yaoqing")
	private Integer isYaoqing;
	
	@Column(name = "yaoqing_roomcards")
	private Integer yaoqingRoomcards;
    /**
     * 账号是否废弃：0未废弃；1废弃
     */
    private Integer deprecated;

    @Column(name = "first_charge")
    private Integer firstCharge;

    @Column(name = "first_login")
    private Integer firstLogin;

    @Column(name = "card_count")
    private Integer cardCount;

    private Integer point;
	@Column(name = "rongCloud_token")
    private String rongCloudToken;

	@Column(name = "gift_gold")
	private Integer giftGold;

	@Column(name = "gift_gold_count")
	private Integer giftGoldCount;

	/**
	 * 分享赠送的次数
	 */
	@Column(name = "gift_times")
	private Integer giftTimes;

	@Column(name = "club_limit")
	private Integer clubLimit;

	public Integer getClubLimit() {
		return clubLimit;
	}

	public void setClubLimit(Integer clubLimit) {
		this.clubLimit = clubLimit;
	}

	public Integer getGiftTimes() {
		return giftTimes;
	}

	public void setGiftTimes(Integer giftTimes) {
		this.giftTimes = giftTimes;
	}
	public Integer getGiftGoldCount() {
		return giftGoldCount;
	}

	public void setGiftGoldCount(Integer giftGoldCount) {
		this.giftGoldCount = giftGoldCount;
	}

	public String getRongCloudToken() {
		return rongCloudToken;
	}

	public void setRongCloudToken(String rongCloudToken) {
		this.rongCloudToken = rongCloudToken;
	}

	/**
     * @return userid
     */
    public Long getUserid() {
        return userid;
    }

    public String getIdentity() {
		return identity;
	}

	public void setIdentity(String identity) {
		this.identity = identity;
	}

	/**
     * @param userid
     */
    public void setUserid(Long userid) {
        this.userid = userid;
    }

    /**
     * @return type
     */
    public String getType() {
        return type;
    }

    /**
     * @param type
     */
    public void setType(String type) {
        this.type = type;
    }

    public Integer getIsYaoqing() {
		return isYaoqing;
	}

	public void setIsYaoqing(Integer isYaoqing) {
		this.isYaoqing = isYaoqing;
	}

	public Integer getYaoqingRoomcards() {
		return yaoqingRoomcards;
	}

	public void setYaoqingRoomcards(Integer yaoqingRoomcards) {
		this.yaoqingRoomcards = yaoqingRoomcards;
	}

	/**
     * @return phone
     */
    public String getPhone() {
        return phone;
    }

    /**
     * @param phone
     */
    public void setPhone(String phone) {
        this.phone = phone;
    }

    /**
     * @return last_login
     */
    public Date getLastLogin() {
        return lastLogin;
    }

    /**
     * @param lastLogin
     */
    public void setLastLogin(Date lastLogin) {
        this.lastLogin = lastLogin;
    }

    /**
     * @return password
     */
    public String getPassword() {
        return password;
    }

    /**
     * @param password
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * @return state
     */
    public String getState() {
        return state;
    }

	public String getOnlineStatus() {
		return onlineStatus;
	}

	public void setOnlineStatus(String onlineStatus) {
		this.onlineStatus = onlineStatus;
	}

	public Long getAgentId() {
		return agentId;
	}

	public void setAgentId(Long agentId) {
		this.agentId = agentId;
	}

	public String getSmallIcon() {
		return smallIcon;
	}

	public void setSmallIcon(String smallIcon) {
		this.smallIcon = smallIcon;
	}

	public String getAccount() {
		return account;
	}

	public void setAccount(String account) {
		this.account = account;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
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

	public Date getCreateDate() {
		return createDate;
	}

	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}

	public String getQq() {
		return qq;
	}

	public void setQq(String qq) {
		this.qq = qq;
	}

	public String getWechat() {
		return wechat;
	}

	public void setWechat(String wechat) {
		this.wechat = wechat;
	}

	public String getWeibo() {
		return weibo;
	}

	public void setWeibo(String weibo) {
		this.weibo = weibo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Float getGrade() {
		return grade;
	}

	public void setGrade(Float grade) {
		this.grade = grade;
	}

	public Integer getDeprecated() {
		return deprecated;
	}

	public void setDeprecated(Integer deprecated) {
		this.deprecated = deprecated;
	}

	public Integer getFirstCharge() {
		return firstCharge;
	}

	public void setFirstCharge(Integer firstCharge) {
		this.firstCharge = firstCharge;
	}

	public Integer getFirstLogin() {
		return firstLogin;
	}

	public void setFirstLogin(Integer firstLogin) {
		this.firstLogin = firstLogin;
	}

	public Integer getCardCount() {
		return cardCount;
	}

	public void setCardCount(Integer cardCount) {
		this.cardCount = cardCount;
	}

	public Integer getPoint() {
		return point;
	}

	public void setPoint(Integer point) {
		this.point = point;
	}

	public void setState(String state) {
		this.state = state;
	}

	public Integer getGiftGold() {
		return giftGold;
	}

	public void setGiftGold(Integer giftGold) {
		this.giftGold = giftGold;
	}
}