//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_token")
//public class TToken {
//    @Id
//    private Long token;
//
//    @Column(name = "session_id")
//    private Long sessionId;
//
//    private String stratege;
//
//    private Integer amount;
//
//    private Long userid;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    @Column(name = "valid_date")
//    private Date validDate;
//
//    /**
//     * @return token
//     */
//    public Long getToken() {
//        return token;
//    }
//
//    /**
//     * @param token
//     */
//    public void setToken(Long token) {
//        this.token = token;
//    }
//
//    /**
//     * @return session_id
//     */
//    public Long getSessionId() {
//        return sessionId;
//    }
//
//    /**
//     * @param sessionId
//     */
//    public void setSessionId(Long sessionId) {
//        this.sessionId = sessionId;
//    }
//
//    /**
//     * @return stratege
//     */
//    public String getStratege() {
//        return stratege;
//    }
//
//    /**
//     * @param stratege
//     */
//    public void setStratege(String stratege) {
//        this.stratege = stratege;
//    }
//
//    /**
//     * @return amount
//     */
//    public Integer getAmount() {
//        return amount;
//    }
//
//    /**
//     * @param amount
//     */
//    public void setAmount(Integer amount) {
//        this.amount = amount;
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
//     * @return valid_date
//     */
//    public Date getValidDate() {
//        return validDate;
//    }
//
//    /**
//     * @param validDate
//     */
//    public void setValidDate(Date validDate) {
//        this.validDate = validDate;
//    }
//}