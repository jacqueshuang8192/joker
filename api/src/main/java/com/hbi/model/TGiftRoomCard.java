package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Date;

/**
 * Created by Administrator on 2017/7/12.
 */
@Table(name = "t_gift_room_card")
public class TGiftRoomCard {

    @Id
    @Column(name = "id")
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "to_user_id")
    private Long toUserId;

    @Column(name = "roomcard_num")
    private Integer roomcardNum;

    @Column(name = "user_roomcard_num")
    private Integer userRoomcardNum;

    @Column(name = "to_user_roomcard_num")
    private Integer toUserRoomcardNum;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "type")
    private Integer type;

    @Column(name = "remark")
    private String remark;

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }


    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getToUserId() {
        return toUserId;
    }

    public void setToUserId(Long toUserId) {
        this.toUserId = toUserId;
    }

    public Integer getRoomcardNum() {
        return roomcardNum;
    }

    public void setRoomcardNum(Integer roomcardNum) {
        this.roomcardNum = roomcardNum;
    }

    public Integer getUserRoomcardNum() {
        return userRoomcardNum;
    }

    public void setUserRoomcardNum(Integer userRoomcardNum) {
        this.userRoomcardNum = userRoomcardNum;
    }

    public Integer getToUserRoomcardNum() {
        return toUserRoomcardNum;
    }

    public void setToUserRoomcardNum(Integer toUserRoomcardNum) {
        this.toUserRoomcardNum = toUserRoomcardNum;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}
