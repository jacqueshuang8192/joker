package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;

@Table(name = "t_game_province")
public class TGameProvince {
    @Id
    @Column(name = "id")
    private Long id;
    @Column(name = "province_id")
    private Long provinceId;
    @Column(name = "province_name")
    private String provinceName;
    @Column(name = "agent_number")
    private Long agentNumber;
    @Column(name = "is_show")
    private Long isShow;
    @Column(name = "is_hot")
    private Long isHot;
    @Column(name = "is_new")
    private Long isNew;
    @Column(name = "default_agent")
    private Long defaultAgent;
    
    
    
	public Long getIsHot() {
		return isHot;
	}
	public void setIsHot(Long isHot) {
		this.isHot = isHot;
	}
	public Long getIsNew() {
		return isNew;
	}
	public void setIsNew(Long isNew) {
		this.isNew = isNew;
	}
	public Long getDefaultAgent() {
		return defaultAgent;
	}
	public void setDefaultAgent(Long defaultAgent) {
		this.defaultAgent = defaultAgent;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getProvinceId() {
		return provinceId;
	}
	public void setProvinceId(Long provinceId) {
		this.provinceId = provinceId;
	}
	public String getProvinceName() {
		return provinceName;
	}
	public void setProvinceName(String provinceName) {
		this.provinceName = provinceName;
	}
	public Long getAgentNumber() {
		return agentNumber;
	}
	public void setAgentNumber(Long agentNumber) {
		this.agentNumber = agentNumber;
	}
	public Long getIsShow() {
		return isShow;
	}
	public void setIsShow(Long isShow) {
		this.isShow = isShow;
	}

    
}