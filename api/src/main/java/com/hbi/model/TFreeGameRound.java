package com.hbi.model;

import jakarta.persistence.*;
import java.util.Date;

@Table(name = "t_free_game_round")
public class TFreeGameRound {
    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "activity_id")
    private Long activityId;

    private String content;

    private Integer level;

    @Column(name = "round_index")
    private Integer roundIndex;

    @Column(name = "start_time")
    private Date startTime;

    @Column(name = "end_time")
    private Date endTime;
    
    @Column(name = "replay_url")
    private String replayUrl;

    @Column(name =  "group_id")
    private Integer groupId;

    @Transient
    private String gameName;

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public String getReplayUrl() {
		return replayUrl;
	}

	public void setReplayUrl(String replayUrl) {
		this.replayUrl = replayUrl;
	}

	public Long getActivityId() {
        return activityId;
    }

    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Date getEndTime() {
        return endTime;
    }

    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Date getStartTime() {
        return startTime;
    }

    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }

    public Integer getRoundIndex() {
        return roundIndex;
    }

    public void setRoundIndex(Integer roundIndex) {
        this.roundIndex = roundIndex;
    }

    public String getGameName() {
        return gameName;
    }

    public void setGameName(String gameName) {
        this.gameName = gameName;
    }
}