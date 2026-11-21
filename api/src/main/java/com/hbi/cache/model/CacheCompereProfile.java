package com.hbi.cache.model;

import java.util.Date;
import java.util.Map;

import javax.persistence.Column;

public class CacheCompereProfile extends CacheUserProfile {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 主播等级
	 */
	private Integer level;

	/**
	 * 主播数量
	 */
	private Integer fansCount;

	/**
	 * 上级代理ID
	 */
	private String delegateId;

	/**
	 * 管理员列表，ID1_ID2
	 */
	private String admins;

	/**
	 * 电话
	 */
	private String phone;

	private String isFan;

	/**
     * 抢主播攻击力
     */
    private Long captureAttack;
    
    /**
     * 抢主播防御力
     */
    private Long captureDefense;
    
	/**
	 * 主播被抓状态：0自由；1被抓；2保护
	 */
	private Integer captureStatus;

	/**
	 * 抓主播中主播的剩余血量
	 */
//	private Long leftLife;
//
//	/**
//	 * 抓主播中主播的总血量
//	 */
//	private Long totalLife;

	/**
	 * 所有者ID
	 */
	private Long ownerId;

	/**
	 * 所有者头像
	 */
	private String ownerPhotoUrl;

	/**
	 * 所有者昵称
	 */
	private String ownerNickname;

	/**
	 * 当俘虏预计被释放时间
	 */
	@Column(name = "release_time")
	private Date releaseTime;

	private Date protectTime;

	/**
	 * 主播称号
	 */
	private String title;

	/**
	 * 被玩家占有的收益
	 */
	private Long sharedProfit;
	
	private String roomName;
	
	private String roomId;
	
	private String roomPassword;
	/**
	 * 房间活动类型 1 游戏 2 电台
	 */
	private String liveActivityType;
	
	/**
	 * 房间活动名称
	 */
	private String liveActivityName;

	/**
	 * 环信聊天室ID
	 */
	private String chatroomId;

	/**
	 * 百人牛牛房间号
	 */
	private Integer bullfightLevel;

	private Integer priority;

	public Integer getLevel() {
		return level;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}

	public Integer getFansCount() {
		return fansCount;
	}

	public void setFansCount(Integer fansCount) {
		this.fansCount = fansCount;
	}

	public String getDelegateId() {
		return delegateId;
	}

	public void setDelegateId(String delegateId) {
		this.delegateId = delegateId;
	}

	public String getAdmins() {
		return admins;
	}

	public void setAdmins(String admins) {
		this.admins = admins;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getIsFan() {
		return isFan;
	}

	public void setIsFan(String isFan) {
		this.isFan = isFan;
	}

	public Integer getCaptureStatus() {
		return captureStatus;
	}

	public void setCaptureStatus(Integer captureStatus) {
		this.captureStatus = captureStatus;
	}

	public Long getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(Long ownerId) {
		this.ownerId = ownerId;
	}

	public Date getReleaseTime() {
		return releaseTime;
	}

	public void setReleaseTime(Date releaseTime) {
		this.releaseTime = releaseTime;
	}

	public Date getProtectTime() {
		return protectTime;
	}

	public void setProtectTime(Date protectTime) {
		this.protectTime = protectTime;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public Long getSharedProfit() {
		return sharedProfit;
	}

	public void setSharedProfit(Long sharedProfit) {
		this.sharedProfit = sharedProfit;
	}

    public Long getCaptureAttack() {
        return captureAttack;
    }

    public void setCaptureAttack(Long captureAttack) {
        this.captureAttack = captureAttack;
    }

    public Long getCaptureDefense() {
        return captureDefense;
    }

    public void setCaptureDefense(Long captureDefense) {
        this.captureDefense = captureDefense;
    }

	public String getRoomName() {
		return roomName;
	}

	public void setRoomName(String roomName) {
		this.roomName = roomName;
	}

	public String getRoomId() {
		return roomId;
	}

	public void setRoomId(String roomId) {
		this.roomId = roomId;
	}

	public String getRoomPassword() {
		return roomPassword;
	}

	public void setRoomPassword(String roomPassword) {
		this.roomPassword = roomPassword;
	}

	public String getLiveActivityType() {
		return liveActivityType;
	}

	public void setLiveActivityType(String liveActivityType) {
		this.liveActivityType = liveActivityType;
	}

	public String getLiveActivityName() {
		return liveActivityName;
	}

	public void setLiveActivityName(String liveActivityName) {
		this.liveActivityName = liveActivityName;
	}

	public String getOwnerNickname() {
		return ownerNickname;
	}

	public void setOwnerNickname(String ownerNickname) {
		this.ownerNickname = ownerNickname;
	}

	public String getOwnerPhotoUrl() {
		return ownerPhotoUrl;
	}

	public void setOwnerPhotoUrl(String ownerPhotoUrl) {
		this.ownerPhotoUrl = ownerPhotoUrl;
	}

	public String getChatroomId() {
		return chatroomId;
	}

	public void setChatroomId(String chatroomId) {
		this.chatroomId = chatroomId;
	}

	public Integer getBullfightLevel() {
		return bullfightLevel;
	}

	public void setBullfightLevel(Integer bullfightLevel) {
		this.bullfightLevel = bullfightLevel;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}
}
