//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_individuation_extract_strategy")
//public class TIndividuationExtractStrategy {
//
//    @Id
//    private Long id;
//    @Column(name = "source")
//    private String source;
//    @Column(name = "primary_agent_id")
//    private Long primaryAgentId;
//    @Column(name = "primary_agent_percentage")
//    private Double primaryAgentPercentage;
//    @Column(name = "secondary_agent_id")
//    private Long secondaryAgentId;
//    @Column(name = "secondary_agent_percentage")
//    private Double secondaryAgentPercentage;
//    @Column(name = "thirdly_agent_id")
//    private Long thirdlyAgentId;
//    @Column(name = "thirdly_agent_percentage")
//    private Double thirdlyAgentPercentage;
//    @Column(name = "manager_id")
//    private Long managerId;
//    @Column(name = "manager_percentage")
//    private Double managerPercentage;
//    @Column(name = "start_date")
//    private Date startDate;
//    @Column(name = "end_date")
//    private Date endDate;
//    @Column(name = "status")
//    private String status;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getSource() {
//        return source;
//    }
//
//    public void setSource(String source) {
//        this.source = source;
//    }
//
//    public Long getPrimaryAgentId() {
//        return primaryAgentId;
//    }
//
//    public void setPrimaryAgentId(Long primaryAgentId) {
//        this.primaryAgentId = primaryAgentId;
//    }
//
//    public Double getPrimaryAgentPercentage() {
//        return primaryAgentPercentage;
//    }
//
//    public void setPrimaryAgentPercentage(Double primaryAgentPercentage) {
//        this.primaryAgentPercentage = primaryAgentPercentage;
//    }
//
//    public Long getSecondaryAgentId() {
//        return secondaryAgentId;
//    }
//
//    public void setSecondaryAgentId(Long secondaryAgentId) {
//        this.secondaryAgentId = secondaryAgentId;
//    }
//
//    public Double getSecondaryAgentPercentage() {
//        return secondaryAgentPercentage;
//    }
//
//    public void setSecondaryAgentPercentage(Double secondaryAgentPercentage) {
//        this.secondaryAgentPercentage = secondaryAgentPercentage;
//    }
//
//    public Long getThirdlyAgentId() {
//        return thirdlyAgentId;
//    }
//
//    public void setThirdlyAgentId(Long thirdlyAgentId) {
//        this.thirdlyAgentId = thirdlyAgentId;
//    }
//
//    public Double getThirdlyAgentPercentage() {
//        return thirdlyAgentPercentage;
//    }
//
//    public void setThirdlyAgentPercentage(Double thirdlyAgentPercentage) {
//        this.thirdlyAgentPercentage = thirdlyAgentPercentage;
//    }
//
//    public Long getManagerId() {
//        return managerId;
//    }
//
//    public void setManagerId(Long managerId) {
//        this.managerId = managerId;
//    }
//
//    public Double getManagerPercentage() {
//        return managerPercentage;
//    }
//
//    public void setManagerPercentage(Double managerPercentage) {
//        this.managerPercentage = managerPercentage;
//    }
//
//    public Date getStartDate() {
//        return startDate;
//    }
//
//    public void setStartDate(Date startDate) {
//        this.startDate = startDate;
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
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//}