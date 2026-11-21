package com.hbi.model;

import javax.persistence.*;

@Table(name = "t_free_game_activity")
public class TFreeGameActivity {
    @Id
    @Column(name = "activity_id")
    private Long activityId;

    @Column(name = "game_id")
    private Long gameId;

    private Integer coins;

    private Integer minutes;

    @Column(name = "chatroom_id")
    private String chatroomId;

    @Column(name = "table_id")
    private Integer tableId;
    
    /**
     * 局数
     */
    private Integer count;
    
    @Column(name = "invite_code")
    private String inviteCode;
    
    @Column(name = "level")
    private Integer level;
    
    @Transient
    private TActivity activity;

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
     * @return game_id
     */
    public Long getGameId() {
        return gameId;
    }

    /**
     * @param gameId
     */
    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    /**
     * @return coins
     */
    public Integer getCoins() {
        return coins;
    }

    /**
     * @param coins
     */
    public void setCoins(Integer coins) {
        this.coins = coins;
    }

    /**
     * @return minutes
     */
    public Integer getMinutes() {
        return minutes;
    }

    /**
     * @param minutes
     */
    public void setMinutes(Integer minutes) {
        this.minutes = minutes;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public TActivity getActivity() {
        return activity;
    }

    public Integer getLevel() {
		return level;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}

	public void setActivity(TActivity activity) {
        this.activity = activity;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public String getChatroomId() {
        return chatroomId;
    }

    public void setChatroomId(String chatroomId) {
        this.chatroomId = chatroomId;
    }

    public Integer getTableId() {
        return tableId;
    }

    public void setTableId(Integer tableId) {
        this.tableId = tableId;
    }
}