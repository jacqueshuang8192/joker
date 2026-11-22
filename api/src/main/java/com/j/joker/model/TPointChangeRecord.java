package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

/**
 * Created by muzi on 23/11/2017.
 */
@Table("t_point_change_record")
public class TPointChangeRecord {

    @Id
    @Column("id")
    private Integer id;

    @Column("club_id")
    private Integer clubId;

    @Column("uid")
    private Integer uid;

    @Column("type")
    private Integer type;

    @Column("before_point")
    private Integer beforePoint;

    @Column("now_point")
    private Integer nowPoint;

    @Column("change_point")
    private Integer changePoint;

    @Column("operator")
    private Integer operator;

    @Column("activity_id")
    private Integer activityId;

    @Column("index")
    private Integer index;

    @Column("remark_info")
    private String remarkInfo;

    @Column("change_time")
    private Date changeTime;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getClubId() {
        return clubId;
    }

    public void setClubId(Integer clubId) {
        this.clubId = clubId;
    }

    public Integer getUid() {
        return uid;
    }

    public void setUid(Integer uid) {
        this.uid = uid;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Integer getBeforePoint() {
        return beforePoint;
    }

    public void setBeforePoint(Integer beforePoint) {
        this.beforePoint = beforePoint;
    }

    public Integer getNowPoint() {
        return nowPoint;
    }

    public void setNowPoint(Integer nowPoint) {
        this.nowPoint = nowPoint;
    }

    public Integer getChangePoint() {
        return changePoint;
    }

    public void setChangePoint(Integer changePoint) {
        this.changePoint = changePoint;
    }

    public Integer getOperator() {
        return operator;
    }

    public void setOperator(Integer operator) {
        this.operator = operator;
    }

    public Integer getActivityId() {
        return activityId;
    }

    public void setActivityId(Integer activityId) {
        this.activityId = activityId;
    }

    public Integer getIndex() {
        return index;
    }

    public void setIndex(Integer index) {
        this.index = index;
    }

    public String getRemarkInfo() {
        return remarkInfo;
    }

    public void setRemarkInfo(String remarkInfo) {
        this.remarkInfo = remarkInfo;
    }

    public Date getChangeTime() {
        return changeTime;
    }

    public void setChangeTime(Date changeTime) {
        this.changeTime = changeTime;
    }
}
