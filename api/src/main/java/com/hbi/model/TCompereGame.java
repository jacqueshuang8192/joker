//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_compere_game")
//public class TCompereGame {
//
//	@Id
//	@Column(name = "id")
//	private Long id;
//	@Column(name = "game_id")
//	private Long gameId;
//	@Column(name = "banker_coins")
//	private Integer bankerCoins;
//	@Column(name = "seat_coins")
//	private Integer seatCoins;
//	@Column(name = "bet_coins")
//	private Integer betCoins;
//	@Column(name = "extract")
//	private Float extract;
//	@Column(name = "level")
//	private Integer level;
//
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	public Long getGameId() {
//		return gameId;
//	}
//
//	public void setGameId(Long gameId) {
//		this.gameId = gameId;
//	}
//
//	public Integer getBankerCoins() {
//		return bankerCoins;
//	}
//
//	public void setBankerCoins(Integer bankerCoins) {
//		this.bankerCoins = bankerCoins;
//	}
//
//	public Integer getSeatCoins() {
//		return seatCoins;
//	}
//
//	public void setSeatCoins(Integer seatCoins) {
//		this.seatCoins = seatCoins;
//	}
//
//	public Integer getBetCoins() {
//		return betCoins;
//	}
//
//	public void setBetCoins(Integer betCoins) {
//		this.betCoins = betCoins;
//	}
//
//	public Float getExtract() {
//		return extract;
//	}
//
//	public void setExtract(Float extract) {
//		this.extract = extract;
//	}
//
//    public Integer getLevel() {
//        return level;
//    }
//
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//}