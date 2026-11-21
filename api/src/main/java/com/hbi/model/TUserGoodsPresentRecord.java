//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_user_goods_present_record")
//public class TUserGoodsPresentRecord {
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
//	private String type;
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
//	@Column(name = "goods_id")
//	private Long goodsId;
//
//	@Column(name = "goods_photo")
//	private String goodsPhoto;
//
//	@Column(name = "goods_name")
//	private String goodsName;
//
//	@Column(name = "total_price")
//	private Integer totalPrice;
//
//	private Integer amount;
//
//	@Column(name = "room_id")
//	private Long roomId;
//
//	@Column(name = "giver_id")
//	private Long giverId;
//
//	@Column(name = "give_date")
//	private Date giveDate;
//
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	/**
//	 * @return userId
//	 */
//	public Long getUserId() {
//		return userId;
//	}
//
//	/**
//	 * @param userId
//	 */
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
//	/**
//	 * @return type
//	 */
//	public String getType() {
//		return type;
//	}
//
//	/**
//	 * @param type
//	 */
//	public void setType(String type) {
//		this.type = type;
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
//	/**
//	 * @return goods_id
//	 */
//	public Long getGoodsId() {
//		return goodsId;
//	}
//
//	/**
//	 * @param goodsId
//	 */
//	public void setGoodsId(Long goodsId) {
//		this.goodsId = goodsId;
//	}
//
//	/**
//	 * @return goodsPhoto
//	 */
//	public String getGoodsPhoto() {
//		return goodsPhoto;
//	}
//
//	/**
//	 * @param goodsPhoto
//	 */
//	public void setGoodsPhoto(String goodsPhoto) {
//		this.goodsPhoto = goodsPhoto;
//	}
//
//	/**
//	 * @return goods_name
//	 */
//	public String getGoodsName() {
//		return goodsName;
//	}
//
//	/**
//	 * @param goodsName
//	 */
//	public void setGoodsName(String goodsName) {
//		this.goodsName = goodsName;
//	}
//
//	/**
//	 * @return total_price
//	 */
//	public Integer getTotalPrice() {
//		return totalPrice;
//	}
//
//	/**
//	 * @param totalPrice
//	 */
//	public void setTotalPrice(Integer totalPrice) {
//		this.totalPrice = totalPrice;
//	}
//
//	/**
//	 * @return amount
//	 */
//	public Integer getAmount() {
//		return amount;
//	}
//
//	/**
//	 * @param amount
//	 */
//	public void setAmount(Integer amount) {
//		this.amount = amount;
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
//	public Long getGiverId() {
//		return giverId;
//	}
//
//	public void setGiverId(Long giverId) {
//		this.giverId = giverId;
//	}
//
//	public Date getGiveDate() {
//		return giveDate;
//	}
//
//	public void setGiveDate(Date giveDate) {
//		this.giveDate = giveDate;
//	}
//
//}