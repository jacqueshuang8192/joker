//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_user_task")
//public class TUserTask {
//    @Id
//    private Long id;
//
//    @Column(name="user_id")
//    private Long userId;
//
//    @Column(name = "task_id")
//    private Long taskId;
//
//    @Column(name = "task_type")
//    private String taskType;
//
//    @Column(name = "start_date")
//    private Date startDate;
//
//    @Column(name = "end_date")
//    private Date endDate;
//
//    @Column(name = "actual_amount")
//    private Integer actualAmount;
//
//    @Column(name = "update_date")
//    private Date updateDate;
//
//    @Column(name="award_status")
//    private Integer awardStatus;
//
//    @Column(name = "priority")
//    private Integer priority;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    /**
//     * @return userid
//     */
//    public Long getUserId() {
//        return userId;
//    }
//
//    /**
//     * @param userid
//     */
//    public void setUserId(Long userId) {
//        this.userId = userId;
//    }
//
//    /**
//     * @return task_id
//     */
//    public Long getTaskId() {
//        return taskId;
//    }
//
//    /**
//     * @param taskId
//     */
//    public void setTaskId(Long taskId) {
//        this.taskId = taskId;
//    }
//
//    public String getTaskType() {
//		return taskType;
//	}
//
//	public void setTaskType(String taskType) {
//		this.taskType = taskType;
//	}
//
//	/**
//     * @return start_date
//     */
//    public Date getStartDate() {
//        return startDate;
//    }
//
//    /**
//     * @param startDate
//     */
//    public void setStartDate(Date startDate) {
//        this.startDate = startDate;
//    }
//
//    /**
//     * @return end_date
//     */
//    public Date getEndDate() {
//        return endDate;
//    }
//
//    /**
//     * @param endDate
//     */
//    public void setEndDate(Date endDate) {
//        this.endDate = endDate;
//    }
//
//    /**
//     * @return actual_amount
//     */
//    public Integer getActualAmount() {
//        return actualAmount;
//    }
//
//    /**
//     * @param actualAmount
//     */
//    public void setActualAmount(Integer actualAmount) {
//        this.actualAmount = actualAmount;
//    }
//
//    /**
//     * @return update_date
//     */
//    public Date getUpdateDate() {
//        return updateDate;
//    }
//
//    /**
//     * @param updateDate
//     */
//    public void setUpdateDate(Date updateDate) {
//        this.updateDate = updateDate;
//    }
//
//    public Integer getAwardStatus() {
//        return awardStatus;
//    }
//
//    public void setAwardStatus(Integer awardStatus) {
//        this.awardStatus = awardStatus;
//    }
//
//	public Integer getPriority() {
//		return priority;
//	}
//
//	public void setPriority(Integer priority) {
//		this.priority = priority;
//	}
//
//
//}