package com.hbi.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.Date;

@Table(name = "t_advert")
public class TAdvert {
    @Id
    @Column(name = "id")
    private Long id;

    @Column(name = "phone_url")
    private String phoneUrl;

    @Column(name = "describe")
    private String describe;

    @Column(name = "is_show")
    private Integer isShow;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "phone_name")
    private String phoneName;

    @Column(name = "visit_url")
    private String visitUrl;

    public String getVisitUrl() {
        return visitUrl;
    }

    public void setVisitUrl(String visitUrl) {
        this.visitUrl = visitUrl;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPhoneUrl() {
        return phoneUrl;
    }

    public void setPhoneUrl(String phoneUrl) {
        this.phoneUrl = phoneUrl == null ? null : phoneUrl.trim();
    }

    public String getDescribe() {
        return describe;
    }

    public void setDescribe(String describe) {
        this.describe = describe == null ? null : describe.trim();
    }

    public Integer getIsShow() {
        return isShow;
    }

    public void setIsShow(Integer isShow) {
        this.isShow = isShow;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public String getPhoneName() {
        return phoneName;
    }

    public void setPhoneName(String phoneName) {
        this.phoneName = phoneName == null ? null : phoneName.trim();
    }
}