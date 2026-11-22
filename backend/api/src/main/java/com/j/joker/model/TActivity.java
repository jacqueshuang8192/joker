package com.j.joker.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_activity")
public class TActivity {
    @Id
    @Column("activity_id")
    private Long activityId;
    
    @Column("activity_name")
    private String activityName;

    @Column("parent_id")
    private Long parentId;
    @Column("cards")
    private Integer cards;
    @Column("is_deduct")
    private Integer isDeduct;

    private String type;
    @Column("discription")
    private String discription;

    @Column("owner_id")
    private Long ownerId;

    @Column("game_id")
    private Long gameId;

    private Integer level;

    private Short status;

    @Column("start_date")
    private Date startDate;

    @Column("end_date")
    private Date endDate;

    @Column("create_date")
    private Date createDate;

    @Column("room_type")
    private Integer roomType;

    @Column("group_id")
    private Integer groupId;

    @Column("game_json")
    private String  gameJson;

    @Column("extend_activity_id")
    private Long extendActivityId;

    @Column("invite_code")
    private String inviteCode;

    @Column(ignore = true)
    private Integer round;
    @Column(ignore = true)
    private Integer score;
    @Column(ignore = true)
    private Integer playerId;

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public Long getExtendActivityId() {
        return extendActivityId;
    }

    public void setExtendActivityId(Long extendActivityId) {
        this.extendActivityId = extendActivityId;
    }

    public String getGameJson() {
        return gameJson;
    }

    public void setGameJson(String gameJson) {
        this.gameJson = gameJson;
    }

    public Integer getRound(){
        return round;
    }

    public void setRound(Integer round){
        this.round = round;
    }

    public Integer getScore(){
        return score;
    }

    public void setScore(Integer score){
        this.score = score;
    }

    public Integer getPlayerId(){
        return playerId;
    }

    public void setPlayerId(Integer playerId){
        this.playerId = playerId;
    }

    public Integer getRoomType() {
        return roomType;
    }

    public void setRoomType(Integer roomType) {
        this.roomType = roomType;
    }

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public String getDiscription() {
		return discription;
	}

	public void setDiscription(String discription) {
		this.discription = discription;
	}

	/**
     * @return activity_id
     */
    public Long getActivityId() {
        return activityId;
    }

    public Integer getCards() {
		return cards;
	}

	public void setCards(Integer cards) {
		this.cards = cards;
	}

	public Integer getIsDeduct() {
		return isDeduct;
	}

	public void setIsDeduct(Integer isDeduct) {
		this.isDeduct = isDeduct;
	}

	/**
     * @param activityId
     */
    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

    /**
     * @return parent_id
     */
    public Long getParentId() {
        return parentId;
    }

    /**
     * @param parentId
     */
    public void setParentId(Long parentId) {
        this.parentId = parentId;
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

    /**
     * @return owner_id
     */
    public Long getOwnerId() {
        return ownerId;
    }

    /**
     * @param ownerId
     */
    public void setOwnerId(Long ownerId) {
        this.ownerId = ownerId;
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

    /**
     * @return create_date
     */
    public Date getCreateDate() {
        return createDate;
    }

    /**
     * @param createDate
     */
    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public String getActivityName() {
        return activityName;
    }

    public void setActivityName(String activityName) {
        this.activityName = activityName;
    }

    public Long getGameId() {
        return gameId;
    }

    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }
}