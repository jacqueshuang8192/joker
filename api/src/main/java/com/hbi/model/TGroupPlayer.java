package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.Date;

/**
 * Created by muzi on 2017/12/7.
 */
@Table(name = "t_group_player")
public class TGroupPlayer {
    @Id
    @Column(name = "group_id")
    private Integer groupId;

    @Column(name = "group_name")
    private String groupName;

    @Column(name = "ower_id")
    private Integer owerId;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "config")
    private String config;

    @Column(name = "cost_pattern")
    private Integer costPattern;

    @Column(name = "play_coins")
    private Integer playCoins;

    @Column(name = "commission")
    private Double commission;

    @Column(name = "cost_user_type")
    private Integer costUserType;

    @Column(name = "cost_limit")
    private Double costLimit;

    @Column(name = "strength_limit")
    private Integer strengthLimit;

    @Column(name = "update_cost_count")
    private Integer updateCostCount;

    @Column(name = "choushui_count")
    private Integer choushuiCount;

    @Column(name = "max_point")
    private Integer maxPoint;

    @Column(name = "point_pool")
    private Integer pointPool;

    @Column(name = "profit_count")
    private Integer profitCount;

    @Column(name = "profit_club_count")
    private Integer profitClubCount;

    @Column(name = "profit_yesterday")
    private Integer profitYesterday;

    @Column(name = "profit_today")
    private Integer profitToday;

    public Integer getMaxPoint() {
        return maxPoint;
    }

    public void setMaxPoint(Integer maxPoint) {
        this.maxPoint = maxPoint;
    }

    public Integer getPointPool() {
        return pointPool;
    }

    public void setPointPool(Integer pointPool) {
        this.pointPool = pointPool;
    }

    public Integer getProfitCount() {
        return profitCount;
    }

    public void setProfitCount(Integer profitCount) {
        this.profitCount = profitCount;
    }

    public Integer getProfitClubCount() {
        return profitClubCount;
    }

    public void setProfitClubCount(Integer profitClubCount) {
        this.profitClubCount = profitClubCount;
    }

    public Integer getProfitYesterday() {
        return profitYesterday;
    }

    public void setProfitYesterday(Integer profitYesterday) {
        this.profitYesterday = profitYesterday;
    }

    public Integer getProfitToday() {
        return profitToday;
    }

    public void setProfitToday(Integer profitToday) {
        this.profitToday = profitToday;
    }

    public Integer getChoushuiCount() {
        return choushuiCount;
    }

    public void setChoushuiCount(Integer choushuiCount) {
        this.choushuiCount = choushuiCount;
    }

    public Integer getUpdateCostCount(){
        return updateCostCount;
    }

    public void setUpdateCostCount(Integer updateCostCount){
        this.updateCostCount = updateCostCount;
    }

    public Double getCostLimit(){
        return costLimit;
    }

    public void setCostLimit(Double costLimit){
        this.costLimit = costLimit;
    }

    public Integer getStrengthLimit(){
        return strengthLimit;
    }

    public void setStrengthLimit(Integer strengthLimit){
        this.strengthLimit = strengthLimit;
    }

    public Integer getCostPattern() {
        return costPattern;
    }

    public void setCostPattern(Integer costPattern) {
        this.costPattern = costPattern;
    }

    public Integer getPlayCoins() {
        return playCoins;
    }

    public void setPlayCoins(Integer playCoins) {
        this.playCoins = playCoins;
    }

    public Integer getCostUserType() {
        return costUserType;
    }

    public void setCostUserType(Integer costUserType) {
        this.costUserType = costUserType;
    }

    public Double getCommission() {
        return commission;
    }

    public void setCommission(Double commission) {
        this.commission = commission;
    }

    public String getConfig() {
        return config;
    }

    public void setConfig(String config) {
        this.config = config;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public Integer getOwerId() {
        return owerId;
    }

    public void setOwerId(Integer owerId) {
        this.owerId = owerId;
    }

    @Override
    public String toString() {
        return "TGroupPlayer{" +
                "groupId=" + groupId +
                ", groupName='" + groupName + '\'' +
                ", owerId=" + owerId +
                ", createTime=" + createTime +
                ", config='" + config + '\'' +
                ", costPattern=" + costPattern +
                ", playCoins=" + playCoins +
                ", commission=" + commission +
                ", costUserType=" + costUserType +
                '}';
    }
}
