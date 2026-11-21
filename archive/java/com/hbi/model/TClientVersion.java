//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_client_version")
//public class TClientVersion {
//    @Id
//    @Column(name = "version_id")
//    private Long versionId;
//
//    private Long name;
//
//    private Integer version;
//
//    @Column(name = "upgrade_from_min")
//    private Integer upgradeFromMin;
//
//    @Column(name = "download_url")
//    private String downloadUrl;
//
//    @Column(name = "effective_date")
//    private Date effectiveDate;
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
//    private String remark;
//
//    /**
//     * @return version_id
//     */
//    public Long getVersionId() {
//        return versionId;
//    }
//
//    /**
//     * @param versionId
//     */
//    public void setVersionId(Long versionId) {
//        this.versionId = versionId;
//    }
//
//    /**
//     * @return name
//     */
//    public Long getName() {
//        return name;
//    }
//
//    /**
//     * @param name
//     */
//    public void setName(Long name) {
//        this.name = name;
//    }
//
//    /**
//     * @return version
//     */
//    public Integer getVersion() {
//        return version;
//    }
//
//    /**
//     * @param version
//     */
//    public void setVersion(Integer version) {
//        this.version = version;
//    }
//
//    /**
//     * @return upgrade_from_min
//     */
//    public Integer getUpgradeFromMin() {
//        return upgradeFromMin;
//    }
//
//    /**
//     * @param upgradeFromMin
//     */
//    public void setUpgradeFromMin(Integer upgradeFromMin) {
//        this.upgradeFromMin = upgradeFromMin;
//    }
//
//    /**
//     * @return download_url
//     */
//    public String getDownloadUrl() {
//        return downloadUrl;
//    }
//
//    /**
//     * @param downloadUrl
//     */
//    public void setDownloadUrl(String downloadUrl) {
//        this.downloadUrl = downloadUrl;
//    }
//
//    /**
//     * @return effective_date
//     */
//    public Date getEffectiveDate() {
//        return effectiveDate;
//    }
//
//    /**
//     * @param effectiveDate
//     */
//    public void setEffectiveDate(Date effectiveDate) {
//        this.effectiveDate = effectiveDate;
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
//    /**
//     * 获取是否强制更新：0非强制；1强制
//     *
//     * @return isManual - 是否强制更新：0非强制；1强制
//     */
//    public Integer getIsmanual() {
//        return ismanual;
//    }
//
//    /**
//     * 设置是否强制更新：0非强制；1强制
//     *
//     * @param ismanual 是否强制更新：0非强制；1强制
//     */
//    public void setIsmanual(Integer ismanual) {
//        this.ismanual = ismanual;
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
//}