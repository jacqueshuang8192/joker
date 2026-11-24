package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

@Table("t_sec_user")
public class TSecUser {
    @Id
    @Column("userId")
    private Long userid;

    private String username;

    @Column("userType")
    private String usertype;

    private String password;

    private String fullname;
    
    @Column("sell_count")
    private Long sellCount;

    @Column("secondLayerSellCount")
    private Long secondLayerSellCount;

    @Column("invitation_code")
    private String invitationCode;
    
    /**
     * 分成收入
     */
    @Column("extract_income")
    private Double extractIncome;

    /**
     * 状态
     */
    private Short status;

    @Column("grandfatherId")
    private Long grandfatherId;

    @Column("parent_id")
    private Long parentId;
    
    @Column("province_id")
    private Long provinceId;

    @Column("room_card_num")
    private Integer roomCardNum;

    @Column("createDate")
    private Date createDate;

    public Long getSellCount() {
		return sellCount;
	}

	public void setSellCount(Long sellCount) {
		this.sellCount = sellCount;
	}

	/**
     * @return userId
     */
    public Long getUserid() {
        return userid;
    }

    public Long getProvinceId() {
		return provinceId;
	}

	public void setProvinceId(Long provinceId) {
		this.provinceId = provinceId;
	}

	/**
     * @param userid
     */
    public void setUserid(Long userid) {
        this.userid = userid;
    }

    /**
     * @return username
     */
    public String getUsername() {
        return username;
    }

    /**
     * @param username
     */
    public void setUsername(String username) {
        this.username = username;
    }

    /**
     * @return userType
     */
    public String getUsertype() {
        return usertype;
    }

    /**
     * @param usertype
     */
    public void setUsertype(String usertype) {
        this.usertype = usertype;
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
     * @return fullname
     */
    public String getFullname() {
        return fullname;
    }

    /**
     * @param fullname
     */
    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    /**
     * 获取状态
     *
     * @return status - 状态
     */
    public Short getStatus() {
        return status;
    }

    /**
     * 设置状态
     *
     * @param status 状态
     */
    public void setStatus(Short status) {
        this.status = status;
    }

    public String getInvitationCode() {
        return invitationCode;
    }

    public void setInvitationCode(String invitationCode) {
        this.invitationCode = invitationCode;
    }

    public Double getExtractIncome() {
        return extractIncome;
    }

    public void setExtractIncome(Double extractIncome) {
        this.extractIncome = extractIncome;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Integer getRoomCardNum() {
        return roomCardNum;
    }

    public void setRoomCardNum(Integer roomCardNum) {
        this.roomCardNum = roomCardNum;
    }

    public Long getSecondLayerSellCount() {
        return secondLayerSellCount;
    }

    public void setSecondLayerSellCount(Long secondLayerSellCount) {
        this.secondLayerSellCount = secondLayerSellCount;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public Long getGrandfatherId() {
        return grandfatherId;
    }

    public void setGrandfatherId(Long grandfatherId) {
        this.grandfatherId = grandfatherId;
    }
}