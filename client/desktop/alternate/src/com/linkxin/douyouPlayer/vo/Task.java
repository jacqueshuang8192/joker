package com.linkxin.douyouPlayer.vo;

import android.text.TextUtils;

/**
 * Created by lxy on 2016/5/15.
 */
public class Task {

    /**
     * actualAmount : 0
     * bounceCoin : 0
     * bounceExperience : 200
     * name : 分享主播
     * planAmount : 10
     * remark : 把你认为漂亮的主播分享给你的朋友吧，看看他们喜不喜欢？
     * sort : 1
     * status : 0
     * taskId : 3
     * taskType : 1 0表示今日
     * userId : 272
     */

    private int actualAmount;
    private int bounceCoin;
    private int bounceExperience;
    private String name;
    private int planAmount;
    private String remark;
    private int sort;
    private String status;
    private String taskId;
    private String taskType;
    private String userId;

    public boolean isTodayTask(){
        return TextUtils.equals("0",taskType);
    }
    public int getActualAmount() {
        return actualAmount;
    }

    public void setActualAmount(int actualAmount) {
        this.actualAmount = actualAmount;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
