package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

/**
 * Created by muzi on 2017/12/9.
 */
@Table("t_msg_playergroup")
public class TMsgPlayerGroup {



    @Id
    @Column("id")
    private Integer id;

    @Column("player_id")
    private Integer playerId;

    @Column("ower_id")
    private Integer owerId;

    @Column("group_id")
    private Integer groupId;

    @Column("status")
    private Integer status;

    @Column("create_time")
    private Date createTime;

    @Column("inviter_uid")
    private Integer inviterUid;

    @Column(ignore = true)
    private String nickName;

    @Column(ignore = true)
    private String photoUrl;

    @Column(ignore = true)
    private String inviterNickName;

    @Column(ignore = true)
    private String inviterPhotoUrl;

    @Column(ignore = true)
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
