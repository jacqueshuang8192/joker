package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

/**
 * Created by muzi on 2017/12/7.
 */
@Table("t_player_group")
public class TPlayerGroup {

    @Id
    @Column("id")
    private Integer id;

    @Column("player_id")
    private Integer playerId;

    @Column("group_id")
    private Integer groupId;

    @Column("changci_count")
    private Integer changciCount;

    @Column("point_count")
    private Double pointCount;

    @Column("dayingjia_count")
    private Integer dayingjiaCount;

    @Column("dayingjia_point_count")
    private Integer dayingjiaPointCount;

    // 上级合伙人ID
    @Column("up_player_id")
    private Integer upPlayerId;

    // 用户类型
    @Column("player_type")
    private Integer playerType;

    // 分红比例
    @Column("bonus")
    private Double bonus;

    // 加入时间
    @Column("create_time")
    private Date createTime;

    @Column("xiaohao_count")
    private Integer xiaohaoCount;

    @Column("tixian_count")
    private Integer tixianCount;

    @Column("invite_code")
    private String inviteCode;

    @Column("repository_point")
    private Integer repositoryPoint;

    @Column("xiaohao_today")
    private Integer xiaohaoToday;

    @Column("xiaohao_yesterday")
    private Integer xiaohaoYesterday;

    @Column("team_play_count_yesterday")
    private Integer teamPlayCountYesterday;

    @Column("wxchat")
    private String wxchat;

    @Column("qq")
    private String qq;

    @Column("xianliao")
    private String xianliao;

    @Column("invite_icon")
    private String inviteIcon;

    @Column("is_robot")
    private Integer isRobot;

    @Column(ignore = true)
    private Long sonPool;

    @Column(ignore = true)
    private Integer gongxianYesterday;

    @Column(ignore = true)
    private Integer gongxianToday;

    @Column(ignore = true)
    private Integer thresholdValue;

    @Column(ignore = true)
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

    @Column(ignore = true)
    private String nickName;

    @Column(ignore = true)
    private String photo;

    @Column("dayingjia_count_today")
    private Integer dayingjiaCountToday;

    @Column("dayingjia_count_yesterday")
    private Integer dayingjiaCountYesterday;

    @Column("play_count_today")
    private Integer playCountToday;

    @Column("play_count_yesterday")
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
