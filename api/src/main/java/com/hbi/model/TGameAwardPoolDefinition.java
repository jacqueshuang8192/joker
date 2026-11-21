//package com.hbi.model;
//
//import java.util.List;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//
//@Table(name = "t_game_award_pool_definition")
//public class TGameAwardPoolDefinition {
//
//    @Id
//    @Column(name = "id")
//    private Long id;
//    @Column(name = "game_id")
//    private Long gameId;
//    @Column(name = "full_amount")
//    private Integer fullAmount;
//    @Column(name = "remind_amount")
//    private Integer remindAmount;
//    @Column(name = "upper_limit")
//    private Integer upperLimit;
//    @Column(name = "lower_limit")
//    private Integer lowerLimit;
//    @Column(name = "status")
//    private String status;
//
//    @Transient
//    private List<TGameAwardPoolDeductPond> gameAwardPoolDeductPonds;
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
//    public Integer getFullAmount() {
//        return fullAmount;
//    }
//
//    public void setFullAmount(Integer fullAmount) {
//        this.fullAmount = fullAmount;
//    }
//
//    public Integer getRemindAmount() {
//        return remindAmount;
//    }
//
//    public void setRemindAmount(Integer remindAmount) {
//        this.remindAmount = remindAmount;
//    }
//
//    public Integer getUpperLimit() {
//        return upperLimit;
//    }
//
//    public void setUpperLimit(Integer upperLimit) {
//        this.upperLimit = upperLimit;
//    }
//
//    public Integer getLowerLimit() {
//        return lowerLimit;
//    }
//
//    public void setLowerLimit(Integer lowerLimit) {
//        this.lowerLimit = lowerLimit;
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
//    public List<TGameAwardPoolDeductPond> getGameAwardPoolDeductPonds() {
//        return gameAwardPoolDeductPonds;
//    }
//
//    public void setGameAwardPoolDeductPonds(List<TGameAwardPoolDeductPond> gameAwardPoolDeductPonds) {
//        this.gameAwardPoolDeductPonds = gameAwardPoolDeductPonds;
//    }
//
//}