//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_user_goods_use_record")
//public class TUserGoodsUseRecord {
//
//	@Id
//	@Column(name = "id")
//	private Long id;
//
//	@Column(name = "user_id")
//	private Long userId;
//
//	@Column(name = "activity_id")
//	private Long activityId;
//
//	@Column(name = "category_type")
//	private String categoryType;
//
//	@Column(name = "category_id")
//	private Long categoryId;
//
//	@Column(name = "category_photo")
//	private String categoryPhoto;
//
//	@Column(name = "category_name")
//	private String categoryName;
//
//	@Column(name = "amount")
//	private Integer amount;
//
//	@Column(name = "price")
//	private Integer price;
//
//	@Column(name = "room_id")
//	private Long roomId;
//
//	@Column(name = "use_date")
//	private Date useDate;
//
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	public Long getUserId() {
//		return userId;
//	}
//
//	public void setUserId(Long userId) {
//		this.userId = userId;
//	}
//
//	public Long getActivityId() {
//		return activityId;
//	}
//
//	public void setActivityId(Long activityId) {
//		this.activityId = activityId;
//	}
//
//	public String getCategoryType() {
//		return categoryType;
//	}
//
//	public void setCategoryType(String categoryType) {
//		this.categoryType = categoryType;
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
//	public String getCategoryPhoto() {
//		return categoryPhoto;
//	}
//
//	public void setCategoryPhoto(String categoryPhoto) {
//		this.categoryPhoto = categoryPhoto;
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
//	public Integer getAmount() {
//		return amount;
//	}
//
//	public void setAmount(Integer amount) {
//		this.amount = amount;
//	}
//
//	public Integer getPrice() {
//		return price;
//	}
//
//	public void setPrice(Integer price) {
//		this.price = price;
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
//	public Date getUseDate() {
//		return useDate;
//	}
//
//	public void setUseDate(Date useDate) {
//		this.useDate = useDate;
//	}
//
//}