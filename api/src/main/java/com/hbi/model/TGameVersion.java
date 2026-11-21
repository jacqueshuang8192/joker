//package com.hbi.model;
//
//import java.util.Date;
//
//import javax.persistence.*;
//
//@Table(name = "t_game_version")
//public class TGameVersion {
//    @Id
//    @Column(name = "game_id")
//    private Long gameId;
//
//    @Id
//    private Long version;
//
//    private String filename;
//
//    private String md5;
//
//    private Long size;
//
//    private String url;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    /**
//     * 是否强制更新：0非强制；1强制
//     */
//    @Column(name = "isManual")
//    private Integer ismanual;
//
//    /**
//     * @return game_id
//     */
//    public Long getGameId() {
//        return gameId;
//    }
//
//    /**
//     * @param gameId
//     */
//    public void setGameId(Long gameId) {
//        this.gameId = gameId;
//    }
//
//    /**
//     * @return version
//     */
//    public Long getVersion() {
//        return version;
//    }
//
//    /**
//     * @param version
//     */
//    public void setVersion(Long version) {
//        this.version = version;
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
//     * @return md5
//     */
//    public String getMd5() {
//        return md5;
//    }
//
//    /**
//     * @param md5
//     */
//    public void setMd5(String md5) {
//        this.md5 = md5;
//    }
//
//    /**
//     * @return size
//     */
//    public Long getSize() {
//        return size;
//    }
//
//    /**
//     * @param size
//     */
//    public void setSize(Long size) {
//        this.size = size;
//    }
//
//    /**
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
//
//    /**
//     * @return create_date
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
//    public Integer getIsmanual() {
//        return ismanual;
//    }
//
//    public void setIsmanual(Integer ismanual) {
//        this.ismanual = ismanual;
//    }
//}