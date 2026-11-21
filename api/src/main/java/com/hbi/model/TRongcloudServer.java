package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

@Table("t_rongcloud_server")
public class TRongcloudServer {
    @Id
    @Column("rongcloud_id")
    private Long rongcloudId;

    @Column("province")
    private String provinceId;

    @Column("room_id")
    private String roomId;

    @Column("room_name")
    private String roomName;

    @Column("createTime")
    private Date createtime;
    @Column("token")
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