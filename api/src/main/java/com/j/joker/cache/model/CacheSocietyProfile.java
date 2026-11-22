package com.j.joker.cache.model;

import java.util.Date;
import java.util.List;

import com.j.joker.cache.CacheModel;

public class CacheSocietyProfile extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 公会ID
	 */
	private Long societyId;
	
	/**
	 * 公会名称
	 */
	private String name;

	private String address;
	
	/**
	 * 公会头像
	 */
	private String photoUrl;
	
	/**
	 * 公会轮播图
	 */
	private String societyPhotos;
	
	/**
	 * 描述
	 */
	private String remark;
	
	/**
	 * 公会等级
	 */
	private String level;
	
	/**
	 * 所在省
	 */
	private String province;
	
	/**
     * 所在城市id
     */
	private Long cityId;
	
	/**
	 * 所在城市
	 */
	private String city;
	
	/**
	 * 主播人数
	 */
	private Integer compereNum;
	
	/**
	 * 玩家人数
	 */
	private int playerNum;
	
	/**
	 * 公会最热主播名
	 */
	private String compereName;
	
	/**
	 * 建立日期
	 */
	private Date startDate;
	
	/**
	 * 公会状态，0无效；1正常；2爆矿中
	 */
	private Integer status;
	
	/**
	 * 公会会长ID
	 */
	private String masterId;
	
	/**
	 * 会长名字
	 */
	private String masterName;
	
	private String masterPhone;
	
	/**
	 * 爆矿基线
	 */
	private Long boomLine;
	
	/**
	 * 累积资金
	 */
	private Long cumulation;
	
	/**
     * 纬度
     */
    private double latitude;
    
    /**
     * 经度
     */
    private double longitude;
    
    /**
     * 采矿结束时间
     */
    private String mineEndTime;
    
    /**
     * 公会公告
     */
    private String activityContent;
	
	/**
	 * 管理员ID列表
	 */
	private List<String> admins;
	
	/**
	 * 抢矿活动ID,无活动时为0
	 */
	private Long activityId;
	
//	/**
//	 * 公会轮播图
//	 */
//	private List<String> photos;
	
    private String chatroomId;
	
	/**
     * 防守人数
     */
    private Integer defenseNum;
    
    
    /**
     * 一个抢矿活动最大抢夺人数，即矿坑数量
     */
    private Integer maxAttackNum;
    
    /**
     * 攻击人数
     */
    private Integer attackerNum;
    
    private boolean hasCompere;
    
    private boolean hasPlayer;
    
	public Long getSocietyId() {
		return societyId;
	}

	public void setSocietyId(Long societyId) {
		this.societyId = societyId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPhotoUrl() {
		return photoUrl;
	}

	public void setPhotoUrl(String photoUrl) {
		this.photoUrl = photoUrl;
	}

	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}

	public String getProvince() {
		return province;
	}

	public void setProvince(String province) {
		this.province = province;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public Integer getCompereNum() {
		return compereNum;
	}

	public void setCompereNum(Integer compereNum) {
		this.compereNum = compereNum;
	}

	public int getPlayerNum() {
		return playerNum;
	}

	public void setPlayerNum(int playerNum) {
		this.playerNum = playerNum;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Long getBoomLine() {
		return boomLine;
	}

	public void setBoomLine(Long boomLine) {
		this.boomLine = boomLine;
	}

	public Long getCumulation() {
		return cumulation;
	}

	public void setCumulation(Long cumulation) {
		this.cumulation = cumulation;
	}

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public List<String> getAdmins() {
        return admins;
    }

    public void setAdmins(List<String> admins) {
        this.admins = admins;
    }

    public Long getCityId() {
        return cityId;
    }

    public void setCityId(Long cityId) {
        this.cityId = cityId;
    }

    public String getCompereName() {
        return compereName;
    }

    public void setCompereName(String compereName) {
        this.compereName = compereName;
    }

    public Long getActivityId() {
        return activityId;
    }

    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

//    public List<String> getPhotos() {
//        return photos;
//    }
//
//    public void setPhotos(List<String> photos) {
//        this.photos = photos;
//    }

    public Integer getDefenseNum() {
        return defenseNum;
    }

    public void setDefenseNum(Integer defenseNum) {
        this.defenseNum = defenseNum;
    }

    public Integer getMaxAttackNum() {
        return maxAttackNum;
    }

    public void setMaxAttackNum(Integer maxAttackNum) {
        this.maxAttackNum = maxAttackNum;
    }

    public String getChatroomId() {
        return chatroomId;
    }

    public void setChatroomId(String chatroomId) {
        this.chatroomId = chatroomId;
    }

    public Integer getAttackerNum() {
        return attackerNum;
    }

    public void setAttackerNum(Integer attackerNum) {
        this.attackerNum = attackerNum;
    }

    public String getMineEndTime() {
        return mineEndTime;
    }

    public void setMineEndTime(String mineEndTime) {
        this.mineEndTime = mineEndTime;
    }

    public String getActivityContent() {
        return activityContent;
    }

    public void setActivityContent(String activityContent) {
        this.activityContent = activityContent;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public String getMasterId() {
        return masterId;
    }

    public void setMasterId(String masterId) {
        this.masterId = masterId;
    }

    public String getMasterName() {
        return masterName;
    }

    public void setMasterName(String masterName) {
        this.masterName = masterName;
    }

    public String getMasterPhone() {
        return masterPhone;
    }

    public void setMasterPhone(String masterPhone) {
        this.masterPhone = masterPhone;
    }

    public boolean isHasCompere() {
        return hasCompere;
    }

    public void setHasCompere(boolean hasCompere) {
        this.hasCompere = hasCompere;
    }

    public boolean isHasPlayer() {
        return hasPlayer;
    }

    public void setHasPlayer(boolean hasPlayer) {
        this.hasPlayer = hasPlayer;
    }

    public String getSocietyPhotos() {
        return societyPhotos;
    }

    public void setSocietyPhotos(String societyPhotos) {
        this.societyPhotos = societyPhotos;
    }

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}
}
