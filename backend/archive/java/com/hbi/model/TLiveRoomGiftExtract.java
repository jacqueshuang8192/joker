//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_live_room_gift_extract")
//public class TLiveRoomGiftExtract {
//	@Id
//	@Column(name = "id")
//	private Long id;
//	@Column(name = "strategy_id")
//	private Long strategyId;
//	@Column(name = "giver_id")
//	private Long giverId;
//	@Column(name = "room_id")
//	private Long roomId;
//	@Column(name = "activity_total_income")
//	private Integer activityTotalIncome;
//	@Column(name = "percentage")
//	private Float percentage;
//	@Column(name = "extract_income")
//	private Integer extractIncome;
//	@Column(name = "activity_date")
//	private Date activityDate;
//
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	public Long getStrategyId() {
//		return strategyId;
//	}
//
//	public void setStrategyId(Long strategyId) {
//		this.strategyId = strategyId;
//	}
//
//	public Long getGiverId() {
//		return giverId;
//	}
//
//	public void setGiverId(Long giverId) {
//		this.giverId = giverId;
//	}
//
//	public Long getRoomId() {
//		return roomId;
//	}
//
//	public void setRoomId(Long roomId) {
//		this.roomId = roomId;
//	}
//
//	public Integer getActivityTotalIncome() {
//		return activityTotalIncome;
//	}
//
//	public void setActivityTotalIncome(Integer activityTotalIncome) {
//		this.activityTotalIncome = activityTotalIncome;
//	}
//
//	public Float getPercentage() {
//		return percentage;
//	}
//
//	public void setPercentage(Float percentage) {
//		this.percentage = percentage;
//	}
//
//	public Integer getExtractIncome() {
//		return extractIncome;
//	}
//
//	public void setExtractIncome(Integer extractIncome) {
//		this.extractIncome = extractIncome;
//	}
//
//	public Date getActivityDate() {
//		return activityDate;
//	}
//
//	public void setActivityDate(Date activityDate) {
//		this.activityDate = activityDate;
//	}
//
//}