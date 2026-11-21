//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_dating_auction_record")
//public class TDatingAuctionRecord {
//	@Id
//	@Column(name = "id")
//	private Long id;
//	@Column(name = "auction_user_id")
//	private Long auctionUserId;
//	@Column(name = "dating_activity_id")
//	private Long datingActivityId;
//	@Column(name = "category_id")
//	private Long categoryId;
//	@Column(name = "category_name")
//	private String categoryName;
//	@Column(name = "auction_count")
//	private Integer auctionCount;
//	@Column(name = "status")
//	private String status;
//	@Column(name = "last_auction_date")
//	private Date lastAuctionDate;
//
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	public Long getAuctionUserId() {
//		return auctionUserId;
//	}
//
//	public void setAuctionUserId(Long auctionUserId) {
//		this.auctionUserId = auctionUserId;
//	}
//
//	public Long getDatingActivityId() {
//		return datingActivityId;
//	}
//
//	public void setDatingActivityId(Long datingActivityId) {
//		this.datingActivityId = datingActivityId;
//	}
//
//	public Long getCategoryId() {
//		return categoryId;
//	}
//
//	public void setCategoryId(Long categoryId) {
//		this.categoryId = categoryId;
//	}
//
//	public String getCategoryName() {
//		return categoryName;
//	}
//
//	public void setCategoryName(String categoryName) {
//		this.categoryName = categoryName;
//	}
//
//	public Integer getAuctionCount() {
//		return auctionCount;
//	}
//
//	public void setAuctionCount(Integer auctionCount) {
//		this.auctionCount = auctionCount;
//	}
//
//	public String getStatus() {
//		return status;
//	}
//
//	public void setStatus(String status) {
//		this.status = status;
//	}
//
//	public Date getLastAuctionDate() {
//		return lastAuctionDate;
//	}
//
//	public void setLastAuctionDate(Date lastAuctionDate) {
//		this.lastAuctionDate = lastAuctionDate;
//	}
//
//}