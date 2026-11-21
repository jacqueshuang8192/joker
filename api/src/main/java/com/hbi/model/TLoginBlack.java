//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_login_black")
//public class TLoginBlack {
//    @Id
//    @Column(name = "black_id")
//    private Long blackId;
//
//    private String photo;
//
//    private String imei;
//
//    private String imsi;
//
//    @Column(name = "effective_start")
//    private Date effectiveStart;
//
//    @Column(name = "effective_end")
//    private Date effectiveEnd;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    /**
//     * @return black_id
//     */
//    public Long getBlackId() {
//        return blackId;
//    }
//
//    /**
//     * @param blackId
//     */
//    public void setBlackId(Long blackId) {
//        this.blackId = blackId;
//    }
//
//    /**
//     * @return photo
//     */
//    public String getPhoto() {
//        return photo;
//    }
//
//    /**
//     * @param photo
//     */
//    public void setPhoto(String photo) {
//        this.photo = photo;
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
//     * @return effective_start
//     */
//    public Date getEffectiveStart() {
//        return effectiveStart;
//    }
//
//    /**
//     * @param effectiveStart
//     */
//    public void setEffectiveStart(Date effectiveStart) {
//        this.effectiveStart = effectiveStart;
//    }
//
//    /**
//     * @return effective_end
//     */
//    public Date getEffectiveEnd() {
//        return effectiveEnd;
//    }
//
//    /**
//     * @param effectiveEnd
//     */
//    public void setEffectiveEnd(Date effectiveEnd) {
//        this.effectiveEnd = effectiveEnd;
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