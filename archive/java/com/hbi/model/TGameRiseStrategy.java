//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_game_rise_strategy")
//public class TGameRiseStrategy {
//    @Id
//    @Column(name = "game_id")
//    private Long gameId;
//
//    @Id
//    private Integer level;
//
//    private String name;
//
//    @Column(name = "min_grounds")
//    private Integer minGrounds;
//
//    @Column(name = "win_rate")
//    private Float winRate;
//
//    @Column(name = "min_experience")
//    private Integer minExperience;
//
//    @Column(name = "allow_low")
//    private String allowLow;
//
//    /**
//     * @return level
//     */
//    public Integer getLevel() {
//        return level;
//    }
//
//    /**
//     * @param level
//     */
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    /**
//     * @return name
//     */
//    public String getName() {
//        return name;
//    }
//
//    /**
//     * @param name
//     */
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    /**
//     * @return min_grounds
//     */
//    public Integer getMinGrounds() {
//        return minGrounds;
//    }
//
//    /**
//     * @param minGrounds
//     */
//    public void setMinGrounds(Integer minGrounds) {
//        this.minGrounds = minGrounds;
//    }
//
//    /**
//     * @return win_rate
//     */
//    public Float getWinRate() {
//        return winRate;
//    }
//
//    /**
//     * @param winRate
//     */
//    public void setWinRate(Float winRate) {
//        this.winRate = winRate;
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
//    public Integer getMinExperience() {
//        return minExperience;
//    }
//
//    public void setMinExperience(Integer minExperience) {
//        this.minExperience = minExperience;
//    }
//
//    public String getAllowLow() {
//        return allowLow;
//    }
//
//    public void setAllowLow(String allowLow) {
//        this.allowLow = allowLow;
//    }
//}