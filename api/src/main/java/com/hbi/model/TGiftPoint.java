package com.hbi.model;

import java.util.Date;

/**
 * Created by Administrator on 2017/7/12.
 */
public class TGiftPoint {
    private Long id;
    private Long userId;
    private Long toUserId;
    private Integer point;
    private Integer userPoint;
    private Integer toUserPoint;
    private Date createTime;

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

    public Integer getPoint() {
        return point;
    }

    public void setPoint(Integer point) {
        this.point = point;
    }

    public Integer getUserPoint() {
        return userPoint;
    }

    public void setUserPoint(Integer userPoint) {
        this.userPoint = userPoint;
    }

    public Integer getToUserPoint() {
        return toUserPoint;
    }

    public void setToUserPoint(Integer toUserPoint) {
        this.toUserPoint = toUserPoint;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}
