//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_album")
//public class TAlbum {
//    @Id
//    @Column(name = "photo_id")
//    private Long photoId;
//
//    @Column(name = "moment_id")
//    private Long momentId;
//
//    private Long userid;
//
//    private String filename;
//
//    private String remark;
//
////    private Long size;
////
////    private String ext;
//
//    private String type;
//
////    @Column(name = "mime_type")
////    private String mimeType;
////
////    private String category;
////
////    private String access;
//
//    private String path;
//
//    @Column(name = "upload_date")
//    private Date uploadDate;
//
////    @Column(name = "small_icon")
////    private String smallIcon;
////
////    @Column(name = "video_time")
////    private Integer videoTime;
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
//    /**
//     * @return userid
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
//     * @return filename
//     */
//    public String getFilename() {
//        return filename;
//    }
//
//    /**
//     * @param filename
//     */
//    public void setFilename(String filename) {
//        this.filename = filename;
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
//     * @return type
//     */
//    public String getType() {
//        return type;
//    }
//
//    /**
//     * @param type
//     */
//    public void setType(String type) {
//        this.type = type;
//    }
//
//    /**
//     * @return path
//     */
//    public String getPath() {
//        return path;
//    }
//
//    /**
//     * @param path
//     */
//    public void setPath(String path) {
//        this.path = path;
//    }
//
//    /**
//     * @return upload_date
//     */
//    public Date getUploadDate() {
//        return uploadDate;
//    }
//
//    /**
//     * @param uploadDate
//     */
//    public void setUploadDate(Date uploadDate) {
//        this.uploadDate = uploadDate;
//    }
//
//    public Long getMomentId() {
//        return momentId;
//    }
//
//    public void setMomentId(Long momentId) {
//        this.momentId = momentId;
//    }
//
//}