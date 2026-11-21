package com.hbi.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_activity_user")
public class TActivityUser {
    @Id
    private Long userid;
    @Column(ignore = true)
    private String nickname;
    @Column(ignore = true)
    private String photo;

    @Id
    @Column("activity_id")
    private Long activityId;

    private Short status;

    @Column("is_doll")
    private Short isDoll;

    @Column("is_winner")
    private Short isWinner;

    @Column("is_player")
    private Short isPlayer;

    @Column("invite_date")
    private Date inviteDate;

    @Column("start_date")
    private Date startDate;

    @Column("end_date")
    private Date endDate;
    
    /**
     * 带入筹码
     */
    @Column("bring_chip")
    private Integer bringChip;
    
    /**
     * 系统筹码
     */
    @Column("present_chip")
    private Integer presentChip;

    /**
     * @return userid
     */
    public Long getUserid() {
        return userid;
    }

    /**
     * @param userid
     */
    public void setUserid(Long userid) {
        this.userid = userid;
    }

    public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	/**
     * @return activity_id
     */
    public Long getActivityId() {
        return activityId;
    }

    /**
     * @param activityId
     */
    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

    /**
     * @return status
     */
    public Short getStatus() {
        return status;
    }

    /**
     * @param status
     */
    public void setStatus(Short status) {
        this.status = status;
    }

    /**
     * @return is_doll
     */
    public Short getIsDoll() {
        return isDoll;
    }

    /**
     * @param isDoll
     */
    public void setIsDoll(Short isDoll) {
        this.isDoll = isDoll;
    }

    /**
     * @return is_winner
     */
    public Short getIsWinner() {
        return isWinner;
    }

    /**
     * @param isWinner
     */
    public void setIsWinner(Short isWinner) {
        this.isWinner = isWinner;
    }

    /**
     * @return is_player
     */
    public Short getIsPlayer() {
        return isPlayer;
    }

    /**
     * @param isPlayer
     */
    public void setIsPlayer(Short isPlayer) {
        this.isPlayer = isPlayer;
    }

    /**
     * @return invite_date
     */
    public Date getInviteDate() {
        return inviteDate;
    }

    /**
     * @param inviteDate
     */
    public void setInviteDate(Date inviteDate) {
        this.inviteDate = inviteDate;
    }

    /**
     * @return start_date
     */
    public Date getStartDate() {
        return startDate;
    }

    /**
     * @param startDate
     */
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    /**
     * @return end_date
     */
    public Date getEndDate() {
        return endDate;
    }

    /**
     * @param endDate
     */
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Integer getBringChip() {
        return bringChip;
    }

    public void setBringChip(Integer bringChip) {
        this.bringChip = bringChip;
    }

    public Integer getPresentChip() {
        return presentChip;
    }

    public void setPresentChip(Integer presentChip) {
        this.presentChip = presentChip;
    }
}