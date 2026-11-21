//package com.hbi.model;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//
//@Table(name = "t_game_match_award")
//public class TGameMatchAward {
//    @Id
//    private Long id;
//
//    @Column(name = "game_id")
//    private Long gameId;
//
//    private Integer level;
//
//    private String rank;
//
//    private Integer coin;
//
//    private Integer exp;
//
//    /**
//     * 说明
//     */
//    private String detail;
//
//    public Integer getCoin() {
//        return coin;
//    }
//
//    public void setCoin(Integer coin) {
//        this.coin = coin;
//    }
//
//    public String getDetail() {
//        return detail;
//    }
//
//    public void setDetail(String detail) {
//        this.detail = detail;
//    }
//
//    public Integer getExp() {
//        return exp;
//    }
//
//    public void setExp(Integer exp) {
//        this.exp = exp;
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
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Integer getLevel() {
//        return level;
//    }
//
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    public String getRank() {
//        return rank;
//    }
//
//    public void setRank(String rank) {
//        this.rank = rank;
//    }
//}