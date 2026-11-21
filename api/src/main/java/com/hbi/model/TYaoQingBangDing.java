package com.hbi.model;

import java.util.Date;
import javax.persistence.*;

@Table(name = "t_yaoqing_bangding")
public class TYaoQingBangDing {
    @Id
    private Long id;

    @Column(name = "user_id")
    private Long userId;
    @Column(name = "promoter_id")
    private Long promoterId;
    @Column(name = "promoter_name")
    private String promoterName;
    @Column(name = "user_name")
    private String userName;
    @Column(name = "date")
    private Date date;
    @Column(name = "is_getRoomcard")
    private Integer isGetRoomcards;
    @Column(name = "yaoqing_roomcards")
    private Integer yaoqingRoomcards;
    
	
	public Integer getYaoqingRoomcards() {
		return yaoqingRoomcards;
	}
	public void setYaoqingRoomcards(Integer yaoqingRoomcards) {
		this.yaoqingRoomcards = yaoqingRoomcards;
	}
	public Integer getIsGetRoomcards() {
		return isGetRoomcards;
	}
	public void setIsGetRoomcards(Integer isGetRoomcards) {
		this.isGetRoomcards = isGetRoomcards;
	}
	public String getPromoterName() {
		return promoterName;
	}
	public void setPromoterName(String promoterName) {
		this.promoterName = promoterName;
	}
	public Date getDate() {
		return date;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getUserId() {
		return userId;
	}
	public void setUserId(Long userId) {
		this.userId = userId;
	}
	
	public Long getPromoterId() {
		return promoterId;
	}
	public void setPromoterId(Long promoterId) {
		this.promoterId = promoterId;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	
	


    

}