//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_message")
//public class TMessage {
//    @Id
//    @Column(name = "MSG_ID")
//    private Long msgId;
//
//    private Long sender;
//
//    private Long receiver;
//
//    @Column(name = "group_id")
//    private Long groupId;
//
//    private String category;
//
//    private String type;
//
//    @Column(name = "send_date")
//    private Date sendDate;
//
//    @Column(name = "receive_date")
//    private Date receiveDate;
//
//    private String status;
//
//    private String msg;
//
//    /**
//     * @return MSG_ID
//     */
//    public Long getMsgId() {
//        return msgId;
//    }
//
//    /**
//     * @param msgId
//     */
//    public void setMsgId(Long msgId) {
//        this.msgId = msgId;
//    }
//
//    /**
//     * @return sender
//     */
//    public Long getSender() {
//        return sender;
//    }
//
//    /**
//     * @param sender
//     */
//    public void setSender(Long sender) {
//        this.sender = sender;
//    }
//
//    /**
//     * @return receiver
//     */
//    public Long getReceiver() {
//        return receiver;
//    }
//
//    /**
//     * @param receiver
//     */
//    public void setReceiver(Long receiver) {
//        this.receiver = receiver;
//    }
//
//    /**
//     * @return group_id
//     */
//    public Long getGroupId() {
//        return groupId;
//    }
//
//    /**
//     * @param groupId
//     */
//    public void setGroupId(Long groupId) {
//        this.groupId = groupId;
//    }
//
//    /**
//     * @return category
//     */
//    public String getCategory() {
//        return category;
//    }
//
//    /**
//     * @param category
//     */
//    public void setCategory(String category) {
//        this.category = category;
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
//     * @return send_date
//     */
//    public Date getSendDate() {
//        return sendDate;
//    }
//
//    /**
//     * @param sendDate
//     */
//    public void setSendDate(Date sendDate) {
//        this.sendDate = sendDate;
//    }
//
//    /**
//     * @return receive_date
//     */
//    public Date getReceiveDate() {
//        return receiveDate;
//    }
//
//    /**
//     * @param receiveDate
//     */
//    public void setReceiveDate(Date receiveDate) {
//        this.receiveDate = receiveDate;
//    }
//
//    /**
//     * @return status
//     */
//    public String getStatus() {
//        return status;
//    }
//
//    /**
//     * @param status
//     */
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//    /**
//     * @return msg
//     */
//    public String getMsg() {
//        return msg;
//    }
//
//    /**
//     * @param msg
//     */
//    public void setMsg(String msg) {
//        this.msg = msg;
//    }
//}