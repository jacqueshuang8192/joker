package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Date;

@Table(name = "t_rongcloud_server")
public class TRongcloudServer {
    @Id
    @Column(name = "rongcloud_id")
    private Long rongcloudId;

    @Column(name = "province")
    private String provinceId;

    @Column(name = "room_id")
    private String roomId;

    @Column(name = "room_name")
    private String roomName;

    @Column(name = "createTime")
    private Date createtime;
    @Column(name = "token")
    private String token;

    public Long getRongcloudId() {
        return rongcloudId;
    }

    public void setRongcloudId(Long rongcloudId) {
        this.rongcloudId = rongcloudId;
    }

    public String getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(String provinceId) {
        this.provinceId = provinceId;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public Date getCreatetime() {
        return createtime;
    }

    public void setCreatetime(Date createtime) {
        this.createtime = createtime;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}