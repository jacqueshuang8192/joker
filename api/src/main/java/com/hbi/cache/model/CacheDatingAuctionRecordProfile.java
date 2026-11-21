package com.hbi.cache.model;

import java.util.Date;

import com.hbi.cache.CacheModel;

public class CacheDatingAuctionRecordProfile extends CacheModel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private Long recordId;
	// private Long compereId;
	private Long auctionUserId;
	private Long datingActivityId;
	private CacheDatingActivityProfile datingActivity;
//	private Long categoryId;
//	private String categoryName;
	private Integer auctionCount;
	private String status;
	private Date lastAuctionDate;

	public Long getRecordId() {
		return recordId;
	}

	public void setRecordId(Long recordId) {
		this.recordId = recordId;
	}

	public Long getAuctionUserId() {
		return auctionUserId;
	}

	public void setAuctionUserId(Long auctionUserId) {
		this.auctionUserId = auctionUserId;
	}

	public Long getDatingActivityId() {
		return datingActivityId;
	}

	public void setDatingActivityId(Long datingActivityId) {
		this.datingActivityId = datingActivityId;
	}

	public CacheDatingActivityProfile getDatingActivity() {
		return datingActivity;
	}

	public void setDatingActivity(CacheDatingActivityProfile datingActivity) {
		this.datingActivity = datingActivity;
	}

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

	public Integer getAuctionCount() {
		return auctionCount;
	}

	public void setAuctionCount(Integer auctionCount) {
		this.auctionCount = auctionCount;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Date getLastAuctionDate() {
		return lastAuctionDate;
	}

	public void setLastAuctionDate(Date lastAuctionDate) {
		this.lastAuctionDate = lastAuctionDate;
	}

}
