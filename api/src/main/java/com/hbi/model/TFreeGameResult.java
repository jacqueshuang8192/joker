package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Table;
import java.util.Date;

@Table("t_free_game_result")
public class TFreeGameResult {
    @Column("id")
    private Long id;

    @Column("activity_id")
    private Long activityId;

    private String content;
    private String name;

    private Integer level;
    
    @Column("ori_coins")
    private Integer oriCoins;

    @Column("end_date")
    private Date endDate;

    @Column("group_id")
    private Integer groupId;

    @Column(ignore = true)
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