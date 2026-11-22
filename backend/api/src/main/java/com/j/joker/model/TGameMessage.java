package com.j.joker.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import java.util.Date;

/**
 * Created by muzi on 21/11/2017.
 */
@Table("t_game_message")
public class TGameMessage {
    @Id
    private Long id;

    private Integer uid;

    private Integer level;

    private Date date;

    private String msg;

    private Integer type;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }



    public Integer getUid() {
        return uid;
    }

    public void setUid(Integer uid) {
        this.uid = uid;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }



    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

}
