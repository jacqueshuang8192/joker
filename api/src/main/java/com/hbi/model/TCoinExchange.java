//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_coin_exchange")
//public class TCoinExchange {
//	@Id
//	private Long tid;
//
//	@Column(name = "user_id")
//	private Long userId;
//
//	@Column(name = "user_type")
//	private String userType;
//
//	@Column(name = "coin_amount")
//	private Long coinAmount;
//
//	@Column(name = "jewel_amount")
//	private Long jewelAmount;
//
//	@Column(name = "exchange_date")
//	private Date exchangeDate;
//
//	public Long getTid() {
//		return tid;
//	}
//
//	public void setTid(Long tid) {
//		this.tid = tid;
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
//	public Long getCoinAmount() {
//		return coinAmount;
//	}
//
//	public void setCoinAmount(Long coinAmount) {
//		this.coinAmount = coinAmount;
//	}
//
//	public Long getJewelAmount() {
//		return jewelAmount;
//	}
//
//	public void setJewelAmount(Long jewelAmount) {
//		this.jewelAmount = jewelAmount;
//	}
//
//	public Date getExchangeDate() {
//		return exchangeDate;
//	}
//
//	public void setExchangeDate(Date exchangeDate) {
//		this.exchangeDate = exchangeDate;
//	}
//
//    public String getUserType() {
//        return userType;
//    }
//
//    public void setUserType(String userType) {
//        this.userType = userType;
//    }
//
//}