//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_emotion_group")
//public class TEmotionGroup {
//    @Id
//    @Column(name = "emotion_group_id")
//    private Long emotionGroupId;
//
//    private String name;
//
//    private String remark;
//
//    @Column(name = "min_vip_level")
//    private Integer minVipLevel;
//
//    /**
//     * @return emotion_group_id
//     */
//    public Long getEmotionGroupId() {
//        return emotionGroupId;
//    }
//
//    /**
//     * @param emotionGroupId
//     */
//    public void setEmotionGroupId(Long emotionGroupId) {
//        this.emotionGroupId = emotionGroupId;
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
//     * @return remark
//     */
//    public String getRemark() {
//        return remark;
//    }
//
//    /**
//     * @param remark
//     */
//    public void setRemark(String remark) {
//        this.remark = remark;
//    }
//
//    /**
//     * @return min_vip_level
//     */
//    public Integer getMinVipLevel() {
//        return minVipLevel;
//    }
//
//    /**
//     * @param minVipLevel
//     */
//    public void setMinVipLevel(Integer minVipLevel) {
//        this.minVipLevel = minVipLevel;
//    }
//}