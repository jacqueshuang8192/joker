package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;
import java.util.Date;

/**
 * Created by muzi on 2017/12/9.
 */
@Table(name = "t_msg_playergroup")
public class TMsgPlayerGroup {



    @Id
    @Column(name = "id")
    private Integer id;

    @Column(name = "player_id")
    private Integer playerId;

    @Column(name = "ower_id")
    private Integer owerId;

    @Column(name = "group_id")
    private Integer groupId;

    @Column(name = "status")
    private Integer status;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "inviter_uid")
    private Integer inviterUid;

    @Transient
    private String nickName;

    @Transient
    private String photoUrl;

    @Transient
    private String inviterNickName;

    @Transient
    private String inviterPhotoUrl;

    @Transient
    private String groupName;

    public String getInviterNickName() {
        return inviterNickName;
    }

    public void setInviterNickName(String inviterNickName) {
        this.inviterNickName = inviterNickName;
    }

    public String getInviterPhotoUrl() {
        return inviterPhotoUrl;
    }

    public void setInviterPhotoUrl(String inviterPhotoUrl) {
        this.inviterPhotoUrl = inviterPhotoUrl;
    }

    public Integer getInviterUid() {
        return inviterUid;
    }

    public void setInviterUid(Integer inviterUid) {
        this.inviterUid = inviterUid;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getPlayerId() {
        return playerId;
    }

    public void setPlayerId(Integer playerId) {
        this.playerId = playerId;
    }

    public Integer getOwerId() {
        return owerId;
    }

    public void setOwerId(Integer owerId) {
        this.owerId = owerId;
    }

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }
}
