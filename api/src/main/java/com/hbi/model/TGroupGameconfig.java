package com.hbi.model;

import java.util.Date;
import jakarta.persistence.*;

@Table(name = "t_group_gameconfig")
public class TGroupGameconfig {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "group_id")
    private Integer groupId;

    private Integer level;

    private String name;

    private String config;

    @Column(name = "game_type")
    private Integer gameType;

    private Integer status;

    @Column(name = "crate_time")
    private Date crateTime;

    /**
     * @return id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param id
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * @return group_id
     */
    public Integer getGroupId() {
        return groupId;
    }

    /**
     * @param groupId
     */
    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    /**
     * @return level
     */
    public Integer getLevel() {
        return level;
    }

    /**
     * @param level
     */
    public void setLevel(Integer level) {
        this.level = level;
    }

    /**
     * @return name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return config
     */
    public String getConfig() {
        return config;
    }

    /**
     * @param config
     */
    public void setConfig(String config) {
        this.config = config;
    }

    /**
     * @return game_type
     */
    public Integer getGameType() {
        return gameType;
    }

    /**
     * @param gameType
     */
    public void setGameType(Integer gameType) {
        this.gameType = gameType;
    }

    /**
     * @return status
     */
    public Integer getStatus() {
        return status;
    }

    /**
     * @param status
     */
    public void setStatus(Integer status) {
        this.status = status;
    }

    /**
     * @return crate_time
     */
    public Date getCrateTime() {
        return crateTime;
    }

    /**
     * @param crateTime
     */
    public void setCrateTime(Date crateTime) {
        this.crateTime = crateTime;
    }
}