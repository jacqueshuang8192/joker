package com.j.joker.cache.model;

import java.util.Date;

import com.j.joker.cache.CacheModel;

public class CacheTask extends CacheModel {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    /**
     * 用户ID
     */
    private String userId;

    /**
     * 任务ID
     */
    private String taskId;

    private String taskType;
    /**
     * 任务名称
     */
    private String name;

    /**
     * 计划完成度
     */
    private int planAmount;

    /**
     * 当前完成度
     */
    private int actualAmount;

    /**
     * 奖励领取状态 0 未领取， 1 已领取
     */
    private String status;

    /**
     * 奖励币
     */
    private int bounceCoin;

    /**
     * 奖励经验值
     */
    private int bounceExperience;

    private Date endDate;

    private String remark;
    
    private int sort;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getTaskId() {
        return taskId;
    }

    public void setTaskId(String taskId) {
        this.taskId = taskId;
    }

    public String getTaskType() {
        return taskType;
    }

    public void setTaskType(String taskType) {
        this.taskType = taskType;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPlanAmount() {
        return planAmount;
    }

    public void setPlanAmount(int planAmount) {
        this.planAmount = planAmount;
    }

    public int getActualAmount() {
        return actualAmount;
    }

    public void setActualAmount(int actualAmount) {
        this.actualAmount = actualAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getBounceCoin() {
        return bounceCoin;
    }

    public void setBounceCoin(int bounceCoin) {
        this.bounceCoin = bounceCoin;
    }

    public int getBounceExperience() {
        return bounceExperience;
    }

    public void setBounceExperience(int bounceExperience) {
        this.bounceExperience = bounceExperience;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public int getSort() {
        return sort;
    }

    public void setSort(int sort) {
        this.sort = sort;
    }

}
