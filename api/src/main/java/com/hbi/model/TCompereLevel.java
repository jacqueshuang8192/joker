//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_compere_level")
//public class TCompereLevel {
//
//	@Id
//	private Integer id;
//
//	@Column(name = "level")
//    private Integer level;
//
//    private String name;
//
//    @Column(name = "coin_amount")
//    private Long coinAmount;
//
//    private String badge;
//
//    @Column(name = "max_photos")
//    private Long maxPhotos;
//
//    @Column(name = "need_ransom_card_count")
//    private Integer needRansomCardCount;
//
//    public Integer getId() {
//		return id;
//	}
//
//	public void setId(Integer id) {
//		this.id = id;
//	}
//
//	/**
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
//     * @return coin_amount
//     */
//    public Long getCoinAmount() {
//        return coinAmount;
//    }
//
//    /**
//     * @param coinAmount
//     */
//    public void setCoinAmount(Long coinAmount) {
//        this.coinAmount = coinAmount;
//    }
//
//    /**
//     * @return badge
//     */
//    public String getBadge() {
//        return badge;
//    }
//
//    /**
//     * @param badge
//     */
//    public void setBadge(String badge) {
//        this.badge = badge;
//    }
//
//    /**
//     * @return max_photos
//     */
//    public Long getMaxPhotos() {
//        return maxPhotos;
//    }
//
//    /**
//     * @param maxPhotos
//     */
//    public void setMaxPhotos(Long maxPhotos) {
//        this.maxPhotos = maxPhotos;
//    }
//
//    public Integer getNeedRansomCardCount() {
//        return needRansomCardCount;
//    }
//
//    public void setNeedRansomCardCount(Integer needRansomCardCount) {
//        this.needRansomCardCount = needRansomCardCount;
//    }
//}