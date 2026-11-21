//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_merchant_goods_photo")
//public class TMerchantGoodsPhoto {
//    @Id
//    @Column(name = "photo_id")
//    private Long photoId;
//
//    @Column(name = "merchant_goods_id")
//    private Long merchantGoodsId;
//
//    private String url;
//
//    /**
//     * @return photo_id
//     */
//    public Long getPhotoId() {
//        return photoId;
//    }
//
//    /**
//     * @param photoId
//     */
//    public void setPhotoId(Long photoId) {
//        this.photoId = photoId;
//    }
//
//    public Long getMerchantGoodsId() {
//		return merchantGoodsId;
//	}
//
//	public void setMerchantGoodsId(Long merchantGoodsId) {
//		this.merchantGoodsId = merchantGoodsId;
//	}
//
//	/**
//     * @return url
//     */
//    public String getUrl() {
//        return url;
//    }
//
//    /**
//     * @param url
//     */
//    public void setUrl(String url) {
//        this.url = url;
//    }
//}