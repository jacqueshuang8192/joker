//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Entity
//@Table(name = "t_game_award_pool_deduct_pond")
//public class TGameAwardPoolDeductPond {
//
//    @Id
//    private Long id;
//    @Column(name = "game_award_pool_definition_id")
//    private Long gameAwardPoolDefinitionId;
//    @Column(name = "ranking")
//    private Integer ranking;
//    @Column(name = "percentage")
//    private Integer percentage;
//    @Column(name = "org_include")
//    private Short orgInclude;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getGameAwardPoolDefinitionId() {
//        return gameAwardPoolDefinitionId;
//    }
//
//    public void setGameAwardPoolDefinitionId(Long gameAwardPoolDefinitionId) {
//        this.gameAwardPoolDefinitionId = gameAwardPoolDefinitionId;
//    }
//
//    /**
//     * @return ranking
//     */
//
//    public Integer getRanking() {
//        return ranking;
//    }
//
//    /**
//     * @param ranking
//     */
//    public void setRanking(Integer ranking) {
//        this.ranking = ranking;
//    }
//
//    /**
//     * @return percentage
//     */
//    public Integer getPercentage() {
//        return percentage;
//    }
//
//    /**
//     * @param percentage
//     */
//    public void setPercentage(Integer percentage) {
//        this.percentage = percentage;
//    }
//
//    /**
//     * @return org_include
//     */
//    public Short getOrgInclude() {
//        return orgInclude;
//    }
//
//    /**
//     * @param orgInclude
//     */
//    public void setOrgInclude(Short orgInclude) {
//        this.orgInclude = orgInclude;
//    }
//}