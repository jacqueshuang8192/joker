//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_game_award_pool")
//public class TGameAwardPool {
//
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "game_id")
//    private Long gameId;
//    @Column(name = "coin_amount")
//    private Integer coinAmount;
//    @Column(name = "last_update_date")
//    private Date lastUpdateDate;
//    @Column(name = "status")
//    private String status;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getGameId() {
//        return gameId;
//    }
//
//    public void setGameId(Long gameId) {
//        this.gameId = gameId;
//    }
//
//    public Integer getCoinAmount() {
//        return coinAmount;
//    }
//
//    public void setCoinAmount(Integer coinAmount) {
//        this.coinAmount = coinAmount;
//    }
//
//    public Date getLastUpdateDate() {
//        return lastUpdateDate;
//    }
//
//    public void setLastUpdateDate(Date lastUpdateDate) {
//        this.lastUpdateDate = lastUpdateDate;
//    }
//
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//
//}