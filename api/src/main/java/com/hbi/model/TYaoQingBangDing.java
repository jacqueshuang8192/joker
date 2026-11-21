package com.hbi.model;

import java.util.Date;
import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_yaoqing_bangding")
public class TYaoQingBangDing {
    @Id
    private Long id;

    @Column("user_id")
    private Long userId;
    @Column("promoter_id")
    private Long promoterId;
    @Column("promoter_name")
    private String promoterName;
    @Column("user_name")
    private String userName;
    @Column("date")
    private Date date;
    @Column("is_getRoomcard")
    private Integer isGetRoomcards;
    @Column("yaoqing_roomcards")
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