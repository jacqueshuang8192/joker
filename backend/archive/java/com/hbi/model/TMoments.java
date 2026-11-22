//package com.hbi.model;
//
//import java.util.Date;
//import java.util.List;
//
//import javax.persistence.Column;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import javax.persistence.Transient;
//
///**
// * 朋友圈
// * @author ceeuoo
// *
// */
//@Table(name="t_moments")
//public class TMoments {
//    @Id
//    private Long id;
//
//    @Column(name="user_id")
//    private Long userId;
//
//    private String text;
//
//    private String status;
//
//    @Column(name="create_date")
//    private Date createDate;
//
//    @Transient
//    private List<TAlbum> list;
//
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getUserId() {
//        return userId;
//    }
//
//    public void setUserId(Long userId) {
//        this.userId = userId;
//    }
//
//    public String getText() {
//        return text;
//    }
//
//    public void setText(String text) {
//        this.text = text;
//    }
//
//    public List<TAlbum> getList() {
//        return list;
//    }
//
//    public void setList(List<TAlbum> list) {
//        this.list = list;
//    }
//
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//
//    public String getStatus() {
//        return status;
//    }
//
//    public void setStatus(String status) {
//        this.status = status;
//    }
//}
