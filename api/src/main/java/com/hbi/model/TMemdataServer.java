package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_memdata_server")
public class TMemdataServer {
    @Id
    @Column("id")
    private Long id;

    @Column("memdata_server_ip")
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