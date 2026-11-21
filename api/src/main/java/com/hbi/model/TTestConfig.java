package com.hbi.model;

/**
 * Created by Administrator on 2017/7/21.
 */
public class TTestConfig {
    private Long userid;
    private Integer level;
    private Integer is_test;
    private Integer is_control;
    private Integer win_percent;
    private String verify;
    private Long agentId;

    public Long getAgentId() {
        return agentId;
    }

    public void setAgentId(Long agentId) {
        this.agentId = agentId;
    }

    public String getVerify() {
        return verify;
    }

    public void setVerify(String verify) {
        this.verify = verify;
    }

    public Long getUserid() {
        return userid;
    }

    public void setUserid(Long userid) {
        this.userid = userid;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getIs_test() {
        return is_test;
    }

    public void setIs_test(Integer is_test) {
        this.is_test = is_test;
    }

    public Integer getIs_control() {
        return is_control;
    }

    public void setIs_control(Integer is_control) {
        this.is_control = is_control;
    }

    public Integer getWin_percent() {
        return win_percent;
    }

    public void setWin_percent(Integer win_percent) {
        this.win_percent = win_percent;
    }
}
