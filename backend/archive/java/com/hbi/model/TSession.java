//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_session")
//public class TSession {
//    @Id
//    @Column(name = "session_id")
//    private Long sessionId;
//
//    private String state;
//
//    @Column(name = "las_sms")
//    private Date lasSms;
//
//    @Column(name = "last_active")
//    private Date lastActive;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    @Column(name = "mobile_type")
//    private String mobileType;
//
//    private String os;
//
//    @Column(name = "os_version")
//    private String osVersion;
//
//    private String imsi;
//
//    private String imei;
//
//    @Column(name = "client_version")
//    private String clientVersion;
//
//    @Column(name = "LastLogonIP")
//    private String lastlogonip;
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
//     * @return state
//     */
//    public String getState() {
//        return state;
//    }
//
//    /**
//     * @param state
//     */
//    public void setState(String state) {
//        this.state = state;
//    }
//
//    /**
//     * @return las_sms
//     */
//    public Date getLasSms() {
//        return lasSms;
//    }
//
//    /**
//     * @param lasSms
//     */
//    public void setLasSms(Date lasSms) {
//        this.lasSms = lasSms;
//    }
//
//    /**
//     * @return last_active
//     */
//    public Date getLastActive() {
//        return lastActive;
//    }
//
//    /**
//     * @param lastActive
//     */
//    public void setLastActive(Date lastActive) {
//        this.lastActive = lastActive;
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
//     * @return mobile_type
//     */
//    public String getMobileType() {
//        return mobileType;
//    }
//
//    /**
//     * @param mobileType
//     */
//    public void setMobileType(String mobileType) {
//        this.mobileType = mobileType;
//    }
//
//    /**
//     * @return os
//     */
//    public String getOs() {
//        return os;
//    }
//
//    /**
//     * @param os
//     */
//    public void setOs(String os) {
//        this.os = os;
//    }
//
//    /**
//     * @return os_version
//     */
//    public String getOsVersion() {
//        return osVersion;
//    }
//
//    /**
//     * @param osVersion
//     */
//    public void setOsVersion(String osVersion) {
//        this.osVersion = osVersion;
//    }
//
//    /**
//     * @return imsi
//     */
//    public String getImsi() {
//        return imsi;
//    }
//
//    /**
//     * @param imsi
//     */
//    public void setImsi(String imsi) {
//        this.imsi = imsi;
//    }
//
//    /**
//     * @return imei
//     */
//    public String getImei() {
//        return imei;
//    }
//
//    /**
//     * @param imei
//     */
//    public void setImei(String imei) {
//        this.imei = imei;
//    }
//
//    /**
//     * @return client_version
//     */
//    public String getClientVersion() {
//        return clientVersion;
//    }
//
//    /**
//     * @param clientVersion
//     */
//    public void setClientVersion(String clientVersion) {
//        this.clientVersion = clientVersion;
//    }
//
//    /**
//     * @return LastLogonIP
//     */
//    public String getLastlogonip() {
//        return lastlogonip;
//    }
//
//    /**
//     * @param lastlogonip
//     */
//    public void setLastlogonip(String lastlogonip) {
//        this.lastlogonip = lastlogonip;
//    }
//}