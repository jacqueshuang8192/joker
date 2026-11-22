package com.j.joker.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;


@Table("t_game_server")
public class TGameServer {
    @Id
    private Long id;

    private String name;

    private String ip;

    private String port;

    private Integer status;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPort() {
        return port;
    }

    public void setPort(String port) {
        this.port = port;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }
}