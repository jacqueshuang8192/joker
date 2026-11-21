//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_group")
//public class TGroup {
//    @Id
//    @Column(name = "GROUP_ID")
//    private Long groupId;
//
//    @Column(name = "ease_group_id")
//    private String easeGroupId;
//
//    @Column(name = "NAME")
//    private String name;
//
//    @Column(name = "photo_url")
//    private String photoUrl;
//
//    private String remakr;
//
//    @Column(name = "MASTER")
//    private Long master;
//
//    @Column(name = "CREATOR")
//    private Long creator;
//
//    @Column(name = "CREATE_DATE")
//    private Date createDate;
//
//    /**
//     * @return GROUP_ID
//     */
//    public Long getGroupId() {
//        return groupId;
//    }
//
//    /**
//     * @param groupId
//     */
//    public void setGroupId(Long groupId) {
//        this.groupId = groupId;
//    }
//
//    public String getPhotoUrl() {
//		return photoUrl;
//	}
//
//	public void setPhotoUrl(String photoUrl) {
//		this.photoUrl = photoUrl;
//	}
//
//	/**
//     * @return NAME
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
//     * @return remakr
//     */
//    public String getRemakr() {
//        return remakr;
//    }
//
//    /**
//     * @param remakr
//     */
//    public void setRemakr(String remakr) {
//        this.remakr = remakr;
//    }
//
//    /**
//     * @return MASTER
//     */
//    public Long getMaster() {
//        return master;
//    }
//
//    /**
//     * @param master
//     */
//    public void setMaster(Long master) {
//        this.master = master;
//    }
//
//    /**
//     * @return CREATOR
//     */
//    public Long getCreator() {
//        return creator;
//    }
//
//    /**
//     * @param creator
//     */
//    public void setCreator(Long creator) {
//        this.creator = creator;
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
//
//    public String getEaseGroupId() {
//        return easeGroupId;
//    }
//
//    public void setEaseGroupId(String easeGroupId) {
//        this.easeGroupId = easeGroupId;
//    }
//}