package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_free_game_activity")
public class TFreeGameActivity {
    @Id
    @Column("activity_id")
    private Long activityId;

    @Column("game_id")
    private Long gameId;

    private Integer coins;

    private Integer minutes;

    @Column("chatroom_id")
    private String chatroomId;

    @Column("table_id")
    private Integer tableId;
    
    /**
     * 局数
     */
    private Integer count;
    
    @Column("invite_code")
    private String inviteCode;
    
    @Column("level")
    private Integer level;
    
    @Column(ignore = true)
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