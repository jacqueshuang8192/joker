package com.linkxin.douyouPlayer.vo;

/**
 * Created by lxy on 2016/4/13.
 */
public class Photo {


    /**
     * filename :
     * momentId : 19
     * path : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/207anchorPhoto201603141926340.jpg
     * photoId : 34
     * remark :
     * type : 0 表示图片，1表示视频
     * uploadDate : 2016-03-14 19:26:35
     * userid : 207
     */

    private String filename;
    private long momentId;
    private String path;
    private long photoId;
    private String remark;
    private String type;
    private String uploadDate;
    private long userid;

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public long getMomentId() {
        return momentId;
    }

    public void setMomentId(long momentId) {
        this.momentId = momentId;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public long getPhotoId() {
        return photoId;
    }

    public void setPhotoId(long photoId) {
        this.photoId = photoId;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getUploadDate() {
        return uploadDate;
    }

    public void setUploadDate(String uploadDate) {
        this.uploadDate = uploadDate;
    }

    public long getUserid() {
        return userid;
    }

    public void setUserid(long userid) {
        this.userid = userid;
    }
}
