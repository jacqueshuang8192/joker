package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_game_province")
public class TGameProvince {
    @Id
    @Column("id")
    private Long id;
    @Column("province_id")
    private Long provinceId;
    @Column("province_name")
    private String provinceName;
    @Column("agent_number")
    private Long agentNumber;
    @Column("is_show")
    private Long isShow;
    @Column("is_hot")
    private Long isHot;
    @Column("is_new")
    private Long isNew;
    @Column("default_agent")
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