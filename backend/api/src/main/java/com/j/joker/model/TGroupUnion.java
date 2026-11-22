package com.j.joker.model;

import java.util.Date;

/**
 * 联盟联盟
 * Create by Mars on 2019/5/27 15:12
 */
public class TGroupUnion {

    private Integer id;

    // 联盟名称
    private String unionName;

    // 游戏配置
    private String config;

    // 1=>固定抽水  2 => 比例抽水
    private Integer costPattern;

    // 抽水限制，赢多少才抽水
    private Double costLimit;

    // 1 => 固定抽成的量 2 => 最多保留两位小数 比例抽水  这个的时候比传需要设定 0-100
    private Double commission;

    // 0=>抽大赢家  1 => 抽赢家
    private Integer costUserType;

    private Date createTime;

    public TGroupUnion(){}

    public TGroupUnion(String unionName){
        this.unionName = unionName;
        createTime = new Date();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUnionName() {
        return unionName;
    }

    public void setUnionName(String unionName) {
        this.unionName = unionName;
    }

    public String getConfig() {
        return config;
    }

    public void setConfig(String config) {
        this.config = config;
    }

    public Integer getCostPattern() {
        return costPattern;
    }

    public void setCostPattern(Integer costPattern) {
        this.costPattern = costPattern;
    }

    public Double getCostLimit() {
        return costLimit;
    }

    public void setCostLimit(Double costLimit) {
        this.costLimit = costLimit;
    }

    public Double getCommission() {
        return commission;
    }

    public void setCommission(Double commission) {
        this.commission = commission;
    }

    public Integer getCostUserType() {
        return costUserType;
    }

    public void setCostUserType(Integer costUserType) {
        this.costUserType = costUserType;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}
