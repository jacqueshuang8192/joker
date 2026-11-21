package com.hbi.model;

import java.util.Date;
import jakarta.persistence.*;

@Table(name = "t_clu_repository_handle_history")
public class TCluRepositoryHandleHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "player_id")
    private Integer playerId;

    @Column(name = "group_id")
    private Integer groupId;

    private Integer type;

    private Integer point;

    @Column(name = "create_time")
    private Date createTime;

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
     * @return player_id
     */
    public Integer getPlayerId() {
        return playerId;
    }

    /**
     * @param playerId
     */
    public void setPlayerId(Integer playerId) {
        this.playerId = playerId;
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
     * @return type
     */
    public Integer getType() {
        return type;
    }

    /**
     * @param type
     */
    public void setType(Integer type) {
        this.type = type;
    }

    /**
     * @return point
     */
    public Integer getPoint() {
        return point;
    }

    /**
     * @param point
     */
    public void setPoint(Integer point) {
        this.point = point;
    }

    /**
     * @return create_time
     */
    public Date getCreateTime() {
        return createTime;
    }

    /**
     * @param createTime
     */
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}