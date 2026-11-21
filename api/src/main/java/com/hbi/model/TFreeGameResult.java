package com.hbi.model;

import jakarta.persistence.*;
import java.util.Date;

@Table(name = "t_free_game_result")
public class TFreeGameResult {
    @Column(name = "id")
    private Long id;

    @Column(name = "activity_id")
    private Long activityId;

    private String content;
    private String name;

    private Integer level;
    
    @Column(name = "ori_coins")
    private Integer oriCoins;

    @Column(name = "end_date")
    private Date endDate;

    @Column(name = "group_id")
    private Integer groupId;

    @Transient
    private String json;

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public String getJson() {
        return json;
    }

    public void setJson(String json) {
        this.json = json;
    }

    public Integer getOriCoins() {
		return oriCoins;
	}

	public void setOriCoins(Integer oriCoins) {
		this.oriCoins = oriCoins;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
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

    public Long getActivityId() {
        return activityId;
    }

    public void setActivityId(Long activityId) {
        this.activityId = activityId;
    }
}