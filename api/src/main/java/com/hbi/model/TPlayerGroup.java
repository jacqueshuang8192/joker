package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.util.Date;

/**
 * Created by muzi on 2017/12/7.
 */
@Table(name = "t_player_group")
public class TPlayerGroup {

    @Id
    @Column(name = "id")
    private Integer id;

    @Column(name = "player_id")
    private Integer playerId;

    @Column(name = "group_id")
    private Integer groupId;

    @Column(name = "changci_count")
    private Integer changciCount;

    @Column(name = "point_count")
    private Double pointCount;

    @Column(name = "dayingjia_count")
    private Integer dayingjiaCount;

    @Column(name = "dayingjia_point_count")
    private Integer dayingjiaPointCount;

    // 上级合伙人ID
    @Column(name = "up_player_id")
    private Integer upPlayerId;

    // 用户类型
    @Column(name = "player_type")
    private Integer playerType;

    // 分红比例
    @Column(name = "bonus")
    private Double bonus;

    // 加入时间
    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "xiaohao_count")
    private Integer xiaohaoCount;

    @Column(name =  "tixian_count")
    private Integer tixianCount;

    @Column(name = "invite_code")
    private String inviteCode;

    @Column(name = "repository_point")
    private Integer repositoryPoint;

    @Column(name = "xiaohao_today")
    private Integer xiaohaoToday;

    @Column(name = "xiaohao_yesterday")
    private Integer xiaohaoYesterday;

    @Column(name = "team_play_count_yesterday")
    private Integer teamPlayCountYesterday;

    @Column(name = "wxchat")
    private String wxchat;

    @Column(name = "qq")
    private String qq;

    @Column(name =  "xianliao")
    private String xianliao;

    @Column(name = "invite_icon")
    private String inviteIcon;

    @Column(name =  "is_robot")
    private Integer isRobot;

    @Transient
    private Long sonPool;

    @Transient
    private Integer gongxianYesterday;

    @Transient
    private Integer gongxianToday;

    @Transient
    private Integer thresholdValue;

    @Transient
    private Integer teamPlayCountToday;

    public Long getSonPool() {
        return sonPool;
    }

    public void setSonPool(Long sonPool) {
        this.sonPool = sonPool;
    }

    public Integer getIsRobot() {
        return isRobot;
    }

    public void setIsRobot(Integer isRobot) {
        this.isRobot = isRobot;
    }

    public String getWxchat() {
        return wxchat;
    }

    public void setWxchat(String wxchat) {
        this.wxchat = wxchat;
    }

    public String getQq() {
        return qq;
    }

    public void setQq(String qq) {
        this.qq = qq;
    }

    public String getXianliao() {
        return xianliao;
    }

    public void setXianliao(String xianliao) {
        this.xianliao = xianliao;
    }

    public String getInviteIcon() {
        return inviteIcon;
    }

    public void setInviteIcon(String inviteIcon) {
        this.inviteIcon = inviteIcon;
    }

    public Integer getTeamPlayCountYesterday() {
        return teamPlayCountYesterday;
    }

    public void setTeamPlayCountYesterday(Integer teamPlayCountYesterday) {
        this.teamPlayCountYesterday = teamPlayCountYesterday;
    }

    @Transient
    private String nickName;

    @Transient
    private String photo;

    @Column(name = "dayingjia_count_today")
    private Integer dayingjiaCountToday;

    @Column(name = "dayingjia_count_yesterday")
    private Integer dayingjiaCountYesterday;

    @Column(name = "play_count_today")
    private Integer playCountToday;

    @Column(name = "play_count_yesterday")
    private Integer playCountYesterday;

    public Integer getDayingjiaCountToday() {
        return dayingjiaCountToday;
    }

    public void setDayingjiaCountToday(Integer dayingjiaCountToday) {
        this.dayingjiaCountToday = dayingjiaCountToday;
    }

    public Integer getDayingjiaCountYesterday() {
        return dayingjiaCountYesterday;
    }

    public void setDayingjiaCountYesterday(Integer dayingjiaCountYesterday) {
        this.dayingjiaCountYesterday = dayingjiaCountYesterday;
    }

    public Integer getPlayCountToday() {
        return playCountToday;
    }

    public void setPlayCountToday(Integer playCountToday) {
        this.playCountToday = playCountToday;
    }

    public Integer getPlayCountYesterday() {
        return playCountYesterday;
    }

    public void setPlayCountYesterday(Integer playCountYesterday) {
        this.playCountYesterday = playCountYesterday;
    }

    public Integer getXiaohaoToday() {
        return xiaohaoToday;
    }

    public void setXiaohaoToday(Integer xiaohaoToday) {
        this.xiaohaoToday = xiaohaoToday;
    }

    public Integer getXiaohaoYesterday() {
        return xiaohaoYesterday;
    }

    public void setXiaohaoYesterday(Integer xiaohaoYesterday) {
        this.xiaohaoYesterday = xiaohaoYesterday;
    }

    public Integer getRepositoryPoint() {
        return repositoryPoint;
    }

    public void setRepositoryPoint(Integer repositoryPoint) {
        this.repositoryPoint = repositoryPoint;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public Integer getTixianCount() {
        return tixianCount;
    }

    public void setTixianCount(Integer tixianCount) {
        this.tixianCount = tixianCount;
    }

    public Integer getXiaohaoCount() {
        return xiaohaoCount;
    }

    public void setXiaohaoCount(Integer xiaohaoCount) {
        this.xiaohaoCount = xiaohaoCount;
    }

    public Integer getChangciCount() {
        return changciCount;
    }

    public void setChangciCount(Integer changciCount) {
        this.changciCount = changciCount;
    }

    public Double getPointCount() {
        return pointCount;
    }

    public void setPointCount(Double pointCount) {
        this.pointCount = pointCount;
    }

    public Integer getDayingjiaCount() {
        return dayingjiaCount;
    }

    public void setDayingjiaCount(Integer dayingjiaCount) {
        this.dayingjiaCount = dayingjiaCount;
    }

    public Integer getDayingjiaPointCount() {
        return dayingjiaPointCount;
    }

    public void setDayingjiaPointCount(Integer dayingjiaPointCount) {
        this.dayingjiaPointCount = dayingjiaPointCount;
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

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public Integer getUpPlayerId() {
        return upPlayerId;
    }

    public void setUpPlayerId(Integer upPlayerId) {
        this.upPlayerId = upPlayerId;
    }

    public Integer getPlayerType() {
        return playerType;
    }

    public void setPlayerType(Integer playerType) {
        this.playerType = playerType;
    }

    public Double getBonus() {
        return bonus;
    }

    public void setBonus(Double bonus) {
        this.bonus = bonus;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Integer getGongxianYesterday() {
        return gongxianYesterday;
    }

    public void setGongxianYesterday(Integer gongxianYesterday) {
        this.gongxianYesterday = gongxianYesterday;
    }

    public Integer getGongxianToday() {
        return gongxianToday;
    }

    public void setGongxianToday(Integer gongxianToday) {
        this.gongxianToday = gongxianToday;
    }

    public Integer getThresholdValue() {
        return thresholdValue;
    }

    public void setThresholdValue(Integer thresholdValue) {
        this.thresholdValue = thresholdValue;
    }

    public Integer getTeamPlayCountToday() {
        return teamPlayCountToday;
    }

    public void setTeamPlayCountToday(Integer teamPlayCountToday) {
        this.teamPlayCountToday = teamPlayCountToday;
    }
}
