//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.Column;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//
//@Table(name = "t_capture_defender")
//public class TCaptureDefender {
//    private Long id;
//
//    @Column(name="player_id")
//    private Long playerId;
//
//    @Column(name="compere_id")
//    private Long compereId;
//
//    @Column(name="start_date")
//    private Date startDate;
//
//    @Column(name="end_date")
//    private Date endDate;
//
//    private Integer type;
//
//    @Transient
//    private String compereNickname;
//
//    @Transient
//    private String playerNickname;
//
//    @Transient
//    private String comperePhoto;
//
//    @Transient
//    private String playerPhoto;
//
//    @Transient
//    private String compereGender;
//
//    @Transient
//    private String playerGender;
//
//    @Transient
//    private Date compereBirthday;
//
//    @Transient
//    private Date playerBirthday;
//
//    @Transient
//    private Float compereLongitude;
//
//    @Transient
//    private Float compereLatitude;
//
//    @Transient
//    private Float playerLongitude;
//
//    @Transient
//    private Float playerLatitude;
//
//    @Transient
//    private Integer playerVipLevel;
//
//    @Transient
//    private Integer compereLevel;
//
//    @Transient
//    private String compereLevelBadge;
//
//    @Transient
//    private Integer captureStatus;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getPlayerId() {
//        return playerId;
//    }
//
//    public void setPlayerId(Long playerId) {
//        this.playerId = playerId;
//    }
//
//    public Long getCompereId() {
//        return compereId;
//    }
//
//    public void setCompereId(Long compereId) {
//        this.compereId = compereId;
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
//    public Integer getType() {
//        return type;
//    }
//
//    public void setType(Integer type) {
//        this.type = type;
//    }
//
//    public Date getCompereBirthday() {
//        return compereBirthday;
//    }
//
//    public void setCompereBirthday(Date compereBirthday) {
//        this.compereBirthday = compereBirthday;
//    }
//
//    public String getCompereGender() {
//        return compereGender;
//    }
//
//    public void setCompereGender(String compereGender) {
//        this.compereGender = compereGender;
//    }
//
//    public String getCompereNickname() {
//        return compereNickname;
//    }
//
//    public void setCompereNickname(String compereNickname) {
//        this.compereNickname = compereNickname;
//    }
//
//    public String getComperePhoto() {
//        return comperePhoto;
//    }
//
//    public void setComperePhoto(String comperePhoto) {
//        this.comperePhoto = comperePhoto;
//    }
//
//    public Date getPlayerBirthday() {
//        return playerBirthday;
//    }
//
//    public void setPlayerBirthday(Date playerBirthday) {
//        this.playerBirthday = playerBirthday;
//    }
//
//    public String getPlayerGender() {
//        return playerGender;
//    }
//
//    public void setPlayerGender(String playerGender) {
//        this.playerGender = playerGender;
//    }
//
//    public String getPlayerNickname() {
//        return playerNickname;
//    }
//
//    public void setPlayerNickname(String playerNickname) {
//        this.playerNickname = playerNickname;
//    }
//
//    public String getPlayerPhoto() {
//        return playerPhoto;
//    }
//
//    public void setPlayerPhoto(String playerPhoto) {
//        this.playerPhoto = playerPhoto;
//    }
//
//    public Float getCompereLatitude() {
//        return compereLatitude;
//    }
//
//    public void setCompereLatitude(Float compereLatitude) {
//        this.compereLatitude = compereLatitude;
//    }
//
//    public Float getPlayerLatitude() {
//        return playerLatitude;
//    }
//
//    public void setPlayerLatitude(Float playerLatitude) {
//        this.playerLatitude = playerLatitude;
//    }
//
//    public Float getCompereLongitude() {
//        return compereLongitude;
//    }
//
//    public void setCompereLongitude(Float compereLongitude) {
//        this.compereLongitude = compereLongitude;
//    }
//
//    public Float getPlayerLongitude() {
//        return playerLongitude;
//    }
//
//    public void setPlayerLongitude(Float playerLongitude) {
//        this.playerLongitude = playerLongitude;
//    }
//
//    public Integer getCaptureStatus() {
//        return captureStatus;
//    }
//
//    public void setCaptureStatus(Integer captureStatus) {
//        this.captureStatus = captureStatus;
//    }
//
//    public Integer getPlayerVipLevel() {
//        return playerVipLevel;
//    }
//
//    public void setPlayerVipLevel(Integer playerVipLevel) {
//        this.playerVipLevel = playerVipLevel;
//    }
//
//    public Integer getCompereLevel() {
//        return compereLevel;
//    }
//
//    public void setCompereLevel(Integer compereLevel) {
//        this.compereLevel = compereLevel;
//    }
//
//    public String getCompereLevelBadge() {
//        return compereLevelBadge;
//    }
//
//    public void setCompereLevelBadge(String compereLevelBadge) {
//        this.compereLevelBadge = compereLevelBadge;
//    }
//}
