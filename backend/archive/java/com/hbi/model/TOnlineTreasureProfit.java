//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Table;
//import java.math.BigDecimal;
//
//@Table(name = "t_online_treasure_profit")
//public class TOnlineTreasureProfit {
//
//	@Column(name = "id")
//	private Long id;
//
//	@Column(name = "extract_id")
//	private Long extractId;
//
//	@Column(name = "activity_id")
//	private Long activityId;
//
//	@Column(name = "receiver_id")
//	private Long receiverId;
//
//	@Column(name = "receiver_type")
//	private String receiverType;
//
//	@Column(name = "income")
//	private BigDecimal income;
//
//	@Column(name = "contributory_id")
//	private Long contributoryId;
//
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	public Long getExtractId() {
//		return extractId;
//	}
//
//	public void setExtractId(Long extractId) {
//		this.extractId = extractId;
//	}
//
//	public Long getReceiverId() {
//		return receiverId;
//	}
//
//	public void setReceiverId(Long receiverId) {
//		this.receiverId = receiverId;
//	}
//
//	public String getReceiverType() {
//		return receiverType;
//	}
//
//	public void setReceiverType(String receiverType) {
//		this.receiverType = receiverType;
//	}
//
//	public BigDecimal getIncome() {
//		return income;
//	}
//
//	public void setIncome(BigDecimal income) {
//		this.income = income;
//	}
//
//	public Long getContributoryId() {
//		return contributoryId;
//	}
//
//	public void setContributoryId(Long contributoryId) {
//		this.contributoryId = contributoryId;
//	}
//
//	public Long getActivityId() {
//		return activityId;
//	}
//
//	public void setActivityId(Long activityId) {
//		this.activityId = activityId;
//	}
//}