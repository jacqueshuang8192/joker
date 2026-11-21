package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;

@Table(name = "t_memdata_server")
public class TMemdataServer {
    @Id
    @Column(name = "id")
    private Long id;

    @Column(name = "memdata_server_ip")
    private String memdataServerIp;

    private Integer port;

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
    }

    public String getMemdataServerIp() {
        return memdataServerIp;
    }

    public void setMemdataServerIp(String memdataServerIp) {
        this.memdataServerIp = memdataServerIp;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
}