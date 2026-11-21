package com.hbi.model;

import javax.persistence.Table;

@Table(name = "t_task")
public class TTask {
    private Integer taskId;
    private String taskName;
    private Integer squence;
    private Integer status;
    private Integer parentId;
    private Integer taskTerm;
    private String taskDescribe;
    private String gift;


    public String getGift() {
        return gift;
    }

    public void setGift(String gift) {
        this.gift = gift;
    }

    public Integer getTaskId() {
        return taskId;
    }

    public void setTaskId(Integer taskId) {
        this.taskId = taskId;
    }

    public String getTaskName() {
        return taskName;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public Integer getSquence() {
        return squence;
    }

    public void setSquence(Integer squence) {
        this.squence = squence;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public Integer getTaskTerm() {
        return taskTerm;
    }

    public void setTaskTerm(Integer taskTerm) {
        this.taskTerm = taskTerm;
    }

    public String getTaskDescribe() {
        return taskDescribe;
    }

    public void setTaskDescribe(String taskDescribe) {
        this.taskDescribe = taskDescribe;
    }

}