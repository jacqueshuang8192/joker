//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Table;
//import java.util.Date;
//
///**
// * Created by ceeuoo on 3/28/2016.
// */
//@Table(name = "t_schedule")
//public class TSchedule {
//    private Long id;
//
//    @Column(name = "jobId")
//    private String jobId;
//
//    @Column(name = "jobGroup")
//    private String jobGroup;
//
//    @Column(name = "beanName")
//    private String beanName;
//
//    @Column(name = "cronExpression")
//    private String cronExpression;
//
//    private Object data;
//
//    @Column(name = "endDate")
//    private Date endDate;
//
//    public String getBeanName() {
//        return beanName;
//    }
//
//    public void setBeanName(String beanName) {
//        this.beanName = beanName;
//    }
//
//    public String getCronExpression() {
//        return cronExpression;
//    }
//
//    public void setCronExpression(String cronExpression) {
//        this.cronExpression = cronExpression;
//    }
//
//    public Object getData() {
//        return data;
//    }
//
//    public void setData(Object data) {
//        this.data = data;
//    }
//
//    public Date getEndDate() {
//        return endDate;
//    }
//
//    public void setEndDate(Date endDate) {
//        this.endDate = endDate;
//    }
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getJobGroup() {
//        return jobGroup;
//    }
//
//    public void setJobGroup(String jobGroup) {
//        this.jobGroup = jobGroup;
//    }
//
//    public String getJobId() {
//        return jobId;
//    }
//
//    public void setJobId(String jobId) {
//        this.jobId = jobId;
//    }
//}
