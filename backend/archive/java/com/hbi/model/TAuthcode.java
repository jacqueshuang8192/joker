//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_authcode")
//public class TAuthcode {
//    @Id
//    @Column(name = "auth_id")
//    private Long authId;
//
//    private String phone;
//
//    private String authcode;
//
//    private String type;
//
//    @Column(name = "valid_time")
//    private Integer validTime;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    /**
//     * @return auth_id
//     */
//    public Long getAuthId() {
//        return authId;
//    }
//
//    /**
//     * @param authId
//     */
//    public void setAuthId(Long authId) {
//        this.authId = authId;
//    }
//
//    /**
//     * @return phone
//     */
//    public String getPhone() {
//        return phone;
//    }
//
//    /**
//     * @param phone
//     */
//    public void setPhone(String phone) {
//        this.phone = phone;
//    }
//
//    /**
//     * @return authcode
//     */
//    public String getAuthcode() {
//        return authcode;
//    }
//
//    /**
//     * @param authcode
//     */
//    public void setAuthcode(String authcode) {
//        this.authcode = authcode;
//    }
//
//    /**
//     * @return type
//     */
//    public String getType() {
//        return type;
//    }
//
//    /**
//     * @param type
//     */
//    public void setType(String type) {
//        this.type = type;
//    }
//
//    /**
//     * @return valid_time
//     */
//    public Integer getValidTime() {
//        return validTime;
//    }
//
//    /**
//     * @param validTime
//     */
//    public void setValidTime(Integer validTime) {
//        this.validTime = validTime;
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
//}