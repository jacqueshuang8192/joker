package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Created by muzi on 23/11/2017.
 */
@Table(name="t_player_task")
public class TPlayerTask {

    @Id
    @Column(name = "id")
    private Integer id;

    @Column(name = "player_id")
    private Integer playerId;

    @Column(name = "task_id")
    private Integer taskid;

    @Column(name = "squence")
    private Integer squence;

    @Column(name = "term_now")
    private Integer termNow;

    @Column(name = "status")
    private Integer status;


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

    public Integer getTaskid() {
        return taskid;
    }

    public void setTaskid(Integer taskid) {
        this.taskid = taskid;
    }

    public Integer getSquence() {
        return squence;
    }

    public void setSquence(Integer squence) {
        this.squence = squence;
    }

    public Integer getTermNow() {
        return termNow;
    }

    public void setTermNow(Integer termNow) {
        this.termNow = termNow;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }
}
