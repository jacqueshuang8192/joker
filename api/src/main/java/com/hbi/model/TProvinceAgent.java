package com.hbi.model;

import java.util.List;

import jakarta.persistence.*;

@Table(name = "t_province_agent")
public class TProvinceAgent {
    @Id
    @Column(name = "province_id")
    private Long provinceId;

    @Column(name = "agent_id")
    private Long agentId;

	public Long getProvinceId() {
		return provinceId;
	}

	public void setProvinceId(Long provinceId) {
		this.provinceId = provinceId;
	}

	public Long getAgentId() {
		return agentId;
	}

	public void setAgentId(Long agentId) {
		this.agentId = agentId;
	}

    
    
}