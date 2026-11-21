package com.hbi.model;

import java.util.Date;

import jakarta.persistence.*;

@Table(name = "t_rechargeticheng_flow")
public class TRechargeTiChengFlow {
    @Id
    private Integer id;
    @Column(name = "player_id")
    private Long playerId;
    @Column(name = "agent_id")
    private Long agentId;
    @Column(name = "ticheng")
    private Double ticheng;
    @Column(name = "nick_name")
    private String nickName;
    @Column(name = "date")
    private Date date;
	@Column(name = "isbinding")
	private Integer isBinding;
	@Column(name = "rechargenumber")
	private Integer rechargeNumber;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Long getPlayerId() {
		return playerId;
	}

	public void setPlayerId(Long playerId) {
		this.playerId = playerId;
	}

	public Long getAgentId() {
		return agentId;
	}

	public void setAgentId(Long agentId) {
		this.agentId = agentId;
	}

	public Double getTicheng() {
		return ticheng;
	}

	public void setTicheng(Double ticheng) {
		this.ticheng = ticheng;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public Integer getIsBinding() {
		return isBinding;
	}

	public void setIsBinding(Integer isBinding) {
		this.isBinding = isBinding;
	}

	public Integer getRechargeNumber() {
		return rechargeNumber;
	}

	public void setRechargeNumber(Integer rechargeNumber) {
		this.rechargeNumber = rechargeNumber;
	}
}