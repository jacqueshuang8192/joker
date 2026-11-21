package com.hbi.schedule.model;

import java.util.Date;

public class ScheduleJob {
    /** 任务名称 */
    private String jobId;
    /** 任务分组 */
    private String jobGroup;
    /** 任务运行时间表达式 */
    private String cronExpression;
    /** 实例名称 */
    private String beanName;
    /** 传输对象 */
    private Object data;
    /** 用于判断方法 */
    private int methodType;

    private Date endDate;

    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public String getJobGroup() {
        return jobGroup;
    }

    public void setJobGroup(String jobGroup) {
        this.jobGroup = jobGroup;
    }

    public String getCronExpression() {
        return cronExpression;
    }

    public void setCronExpression(String cronExpression) {
        this.cronExpression = cronExpression;
    }

    public String getBeanName() {
        return beanName;
    }

    public void setBeanName(String beanName) {
        this.beanName = beanName;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public int getMethodType() {
        return methodType;
    }

    public void setMethodType(int methodType) {
        this.methodType = methodType;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
}
