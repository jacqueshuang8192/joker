package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.Date;


@Table(name = "t_group_game")
public class TGroupGame {
    @Id
    @Column(name="id")
    private Long id;

    @Column(name="name")
    private String name;

    private Integer level;

    @Column(name="game_id")
    private Long gameId;

    private String remark;

    private Integer coins;

    @Column(name = "ori_coins")
    private Integer oriCoins;

    private Float extract;

    @Column(name="creator_id")
    private Long creatorId;

    @Column(name="create_date")
    private Date createDate;

    private String status;

    @Column(name="last_modifier_id")
    private Long lastModifierId;

    @Column(name="last_modify_date")
    private Date lastModifierDate;

    private String ip;

    private Integer port;

    @Column(name="player_count")
    private Integer playerCount;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getGameId() {
        return gameId;
    }

    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    public Integer getCoins() {
        return coins;
    }

    public void setCoins(Integer coins) {
        this.coins = coins;
    }

    public Float getExtract() {
        return extract;
    }

    public void setExtract(Float extract) {
        this.extract = extract;
    }

    public Long getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(Long creatorId) {
        this.creatorId = creatorId;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getLastModifierId() {
        return lastModifierId;
    }

    public void setLastModifierId(Long lastModifierId) {
        this.lastModifierId = lastModifierId;
    }

    public Date getLastModifierDate() {
        return lastModifierDate;
    }

    public void setLastModifierDate(Date lastModifierDate) {
        this.lastModifierDate = lastModifierDate;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
    }

    public Integer getOriCoins() {
        return oriCoins;
    }

    public void setOriCoins(Integer oriCoins) {
        this.oriCoins = oriCoins;
    }

    public Integer getPlayerCount() {
        return playerCount;
    }

    public void setPlayerCount(Integer playerCount) {
        this.playerCount = playerCount;
    }
}