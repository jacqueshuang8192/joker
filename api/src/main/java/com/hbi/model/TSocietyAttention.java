//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_society_attention")
//public class TSocietyAttention {
//    @Id
//    @Column(name = "USERID")
//    private Long userid;
//
//    @Id
//    @Column(name = "SOCIETY_ID")
//    private Long societyId;
//
//    @Column(name = "ATTENTION_DATE")
//    private Date attentionDate;
//
//    @Column(name = "CREATE_DATE")
//    private Date createDate;
//
//    /**
//     * @return USERID
//     */
//    public Long getUserid() {
//        return userid;
//    }
//
//    /**
//     * @param userid
//     */
//    public void setUserid(Long userid) {
//        this.userid = userid;
//    }
//
//    /**
//     * @return SOCIETY_ID
//     */
//    public Long getSocietyId() {
//        return societyId;
//    }
//
//    /**
//     * @param societyId
//     */
//    public void setSocietyId(Long societyId) {
//        this.societyId = societyId;
//    }
//
//    /**
//     * @return ATTENTION_DATE
//     */
//    public Date getAttentionDate() {
//        return attentionDate;
//    }
//
//    /**
//     * @param attentionDate
//     */
//    public void setAttentionDate(Date attentionDate) {
//        this.attentionDate = attentionDate;
//    }
//
//    /**
//     * @return CREATE_DATE
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//}