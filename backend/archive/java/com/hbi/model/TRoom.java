//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_room")
//public class TRoom {
//
//	public static final String MICPHONE_FREE = "0";
//
//	public static final String MICPHONE_COMPERE = "1";
//
//	public static final String MICPHONE_QUEUE = "2";
//
//	public static final String MICPHONE_PLAYER = "3";
//
//    @Id
//    @Column(name = "room_id")
//    private Long roomId;
//
//    @Column(name = "compere_id")
//    private Long compereId;
//
//    @Column(name = "room_password")
//    private String roomPassword;
//
//    @Column(name = "room_photo")
//    private String roomPhoto;
//
//    @Column(name = "room_list_photo")
//    private String roomListPhoto;
//
//    private String name;
//
//    @Column(name = "chatroom_id")
//    private String chatroomId;
//
//    private Integer status;
//
//    private String microphone;
//
//    @Column(name = "start_date")
//    private Date startDate;
//
//    @Column(name = "end_date")
//    private Date endDate;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    @Column(name = "live_id")
//    private Long liveId;
//
//    @Column(name = "live_type")
//    private String liveType;
//
//    private String resolution;
//
//    /**
//     * @return room_id
//     */
//    public Long getRoomId() {
//        return roomId;
//    }
//
//    /**
//     * @param roomId
//     */
//    public void setRoomId(Long roomId) {
//        this.roomId = roomId;
//    }
//
//    /**
//     * @return compere_id
//     */
//    public Long getCompereId() {
//        return compereId;
//    }
//
//    /**
//     * @param compereId
//     */
//    public void setCompereId(Long compereId) {
//        this.compereId = compereId;
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
//     * @return microphone
//     */
//    public String getMicrophone() {
//        return microphone;
//    }
//
//    /**
//     * @param microphone
//     */
//    public void setMicrophone(String microphone) {
//        this.microphone = microphone;
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
//     * @return end_date
//     */
//    public Date getEndDate() {
//        return endDate;
//    }
//
//    /**
//     * @param endDate
//     */
//    public void setEndDate(Date endDate) {
//        this.endDate = endDate;
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
//    public Long getLiveId() {
//        return liveId;
//    }
//
//    public void setLiveId(Long liveId) {
//        this.liveId = liveId;
//    }
//
//    public String getRoomPassword() {
//        return roomPassword;
//    }
//
//    public void setRoomPassword(String roomPassword) {
//        this.roomPassword = roomPassword;
//    }
//
//    public String getChatroomId() {
//        return chatroomId;
//    }
//
//    public void setChatroomId(String chatroomId) {
//        this.chatroomId = chatroomId;
//    }
//
//    public Integer getStatus() {
//        return status;
//    }
//
//    public void setStatus(Integer status) {
//        this.status = status;
//    }
//
//    public String getRoomPhoto() {
//        return roomPhoto;
//    }
//
//    public void setRoomPhoto(String roomPhoto) {
//        this.roomPhoto = roomPhoto;
//    }
//
//    public String getRoomListPhoto() {
//        return roomListPhoto;
//    }
//
//    public void setRoomListPhoto(String roomListPhoto) {
//        this.roomListPhoto = roomListPhoto;
//    }
//
//    public String getLiveType() {
//        return liveType;
//    }
//
//    public void setLiveType(String liveType) {
//        this.liveType = liveType;
//    }
//
//    public String getResolution() {
//        return resolution;
//    }
//
//    public void setResolution(String resolution) {
//        this.resolution = resolution;
//    }
//}