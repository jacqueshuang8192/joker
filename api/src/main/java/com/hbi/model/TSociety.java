//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_society")
//public class TSociety {
//    @Id
//    @Column(name = "society_id")
//    private Long societyId;
//
//    @Column(name = "society_code")
//    private String societyCode;
//
//    @Column(name = "master_id")
//    private Long masterId;
//
//    @Column(name = "master_phone")
//    private String masterPhone;
//
//    private String photo;
//
//    private String name;
//
//    private String remark;
//
//    @Column(name = "compere_num")
//    private Integer compereNum;
//
//    @Column(name = "player_num")
//    private Integer playerNum;
//
//    private Integer experence;
//
//    @Column(name = "province_id")
//    private Long provinceId;
//
//    @Column(name = "city_id")
//    private Long cityId;
//
//    @Column(name = "current_mine")
//    private Long currentMine;
//
//    private Integer level;
//
//    private Float longitude;
//
//    private String status;
//
//    private Float latitude;
//
//    @Column(name = "start_date")
//    private Date startDate;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    @Column(name = "chatroom_id")
//    private Long chatroomId;
//
//    @Column(name = "society_photos")
//    private String societyPhotos;
//
//    /**
//     * @return society_id
//     */
//    public Long getSocietyId() {
//        return societyId;
//    }
//
//    /**
//     * @param societyId
//     */
//    public void setSocietyId(Long societyId) {
//        this.societyId = societyId;
//    }
//
//    /**
//     * @return society_code
//     */
//    public String getSocietyCode() {
//        return societyCode;
//    }
//
//    /**
//     * @param societyCode
//     */
//    public void setSocietyCode(String societyCode) {
//        this.societyCode = societyCode;
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
//     * @return name
//     */
//    public String getName() {
//        return name;
//    }
//
//    /**
//     * @param name
//     */
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    /**
//     * @return remark
//     */
//    public String getRemark() {
//        return remark;
//    }
//
//    /**
//     * @param remark
//     */
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//
//    /**
//     * @return compere_num
//     */
//    public Integer getCompereNum() {
//        return compereNum;
//    }
//
//    /**
//     * @param compereNum
//     */
//    public void setCompereNum(Integer compereNum) {
//        this.compereNum = compereNum;
//    }
//
//    /**
//     * @return player_num
//     */
//    public Integer getPlayerNum() {
//        return playerNum;
//    }
//
//    /**
//     * @param playerNum
//     */
//    public void setPlayerNum(Integer playerNum) {
//        this.playerNum = playerNum;
//    }
//
//    /**
//     * @return experence
//     */
//    public Integer getExperence() {
//        return experence;
//    }
//
//    /**
//     * @param experence
//     */
//    public void setExperence(Integer experence) {
//        this.experence = experence;
//    }
//
//    /**
//     * @return province_id
//     */
//    public Long getProvinceId() {
//        return provinceId;
//    }
//
//    /**
//     * @param provinceId
//     */
//    public void setProvinceId(Long provinceId) {
//        this.provinceId = provinceId;
//    }
//
//    /**
//     * @return city_id
//     */
//    public Long getCityId() {
//        return cityId;
//    }
//
//    /**
//     * @param cityId
//     */
//    public void setCityId(Long cityId) {
//        this.cityId = cityId;
//    }
//
//    /**
//     * @return current_mine
//     */
//    public Long getCurrentMine() {
//        return currentMine;
//    }
//
//    /**
//     * @param currentMine
//     */
//    public void setCurrentMine(Long currentMine) {
//        this.currentMine = currentMine;
//    }
//
//    /**
//     * @return level
//     */
//    public Integer getLevel() {
//        return level;
//    }
//
//    /**
//     * @param level
//     */
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    /**
//     * @return longitude
//     */
//    public Float getLongitude() {
//        return longitude;
//    }
//
//    /**
//     * @param longitude
//     */
//    public void setLongitude(Float longitude) {
//        this.longitude = longitude;
//    }
//
//    /**
//     * @return latitude
//     */
//    public Float getLatitude() {
//        return latitude;
//    }
//
//    /**
//     * @param latitude
//     */
//    public void setLatitude(Float latitude) {
//        this.latitude = latitude;
//    }
//
//    /**
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
//    public Long getChatroomId() {
//        return chatroomId;
//    }
//
//    public void setChatroomId(Long chatroomId) {
//        this.chatroomId = chatroomId;
//    }
//
//    public Long getMasterId() {
//        return masterId;
//    }
//
//    public void setMasterId(Long masterId) {
//        this.masterId = masterId;
//    }
//
//    public String getMasterPhone() {
//        return masterPhone;
//    }
//
//    public void setMasterPhone(String masterPhone) {
//        this.masterPhone = masterPhone;
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
//    public String getSocietyPhotos() {
//        return societyPhotos;
//    }
//
//    public void setSocietyPhotos(String societyPhotos) {
//        this.societyPhotos = societyPhotos;
//    }
//}