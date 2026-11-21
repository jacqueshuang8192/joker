//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_operation_log")
//public class TOperationLog {
//    @Id
//    @Column(name = "log_id")
//    private Long logId;
//
//    private Long userid;
//
//    private String username;
//
//    @Column(name = "operation_time")
//    private Date operationTime;
//
//    private String ip;
//
//    private String module;
//
//    private String business;
//
//    private String operation;
//
//    private Short result;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    private String input;
//
//    private String output;
//
//    @Column(name = "error_info")
//    private String errorInfo;
//
//    /**
//     * @return log_id
//     */
//    public Long getLogId() {
//        return logId;
//    }
//
//    /**
//     * @param logId
//     */
//    public void setLogId(Long logId) {
//        this.logId = logId;
//    }
//
//    /**
//     * @return userid
//     */
//    public Long getUserid() {
//        return userid;
//    }
//
//    /**
//     * @param userid
//     */
//    public void setUserid(Long userid) {
//        this.userid = userid;
//    }
//
//    /**
//     * @return username
//     */
//    public String getUsername() {
//        return username;
//    }
//
//    /**
//     * @param username
//     */
//    public void setUsername(String username) {
//        this.username = username;
//    }
//
//    /**
//     * @return operation_time
//     */
//    public Date getOperationTime() {
//        return operationTime;
//    }
//
//    /**
//     * @param operationTime
//     */
//    public void setOperationTime(Date operationTime) {
//        this.operationTime = operationTime;
//    }
//
//    /**
//     * @return ip
//     */
//    public String getIp() {
//        return ip;
//    }
//
//    /**
//     * @param ip
//     */
//    public void setIp(String ip) {
//        this.ip = ip;
//    }
//
//    /**
//     * @return module
//     */
//    public String getModule() {
//        return module;
//    }
//
//    /**
//     * @param module
//     */
//    public void setModule(String module) {
//        this.module = module;
//    }
//
//    /**
//     * @return business
//     */
//    public String getBusiness() {
//        return business;
//    }
//
//    /**
//     * @param business
//     */
//    public void setBusiness(String business) {
//        this.business = business;
//    }
//
//    /**
//     * @return operation
//     */
//    public String getOperation() {
//        return operation;
//    }
//
//    /**
//     * @param operation
//     */
//    public void setOperation(String operation) {
//        this.operation = operation;
//    }
//
//    /**
//     * @return result
//     */
//    public Short getResult() {
//        return result;
//    }
//
//    /**
//     * @param result
//     */
//    public void setResult(Short result) {
//        this.result = result;
//    }
//
//    /**
//     * @return create_date
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//
//    /**
//     * @return input
//     */
//    public String getInput() {
//        return input;
//    }
//
//    /**
//     * @param input
//     */
//    public void setInput(String input) {
//        this.input = input;
//    }
//
//    /**
//     * @return output
//     */
//    public String getOutput() {
//        return output;
//    }
//
//    /**
//     * @param output
//     */
//    public void setOutput(String output) {
//        this.output = output;
//    }
//
//    /**
//     * @return error_info
//     */
//    public String getErrorInfo() {
//        return errorInfo;
//    }
//
//    /**
//     * @param errorInfo
//     */
//    public void setErrorInfo(String errorInfo) {
//        this.errorInfo = errorInfo;
//    }
//}