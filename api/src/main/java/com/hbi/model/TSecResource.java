package com.hbi.model;

import jakarta.persistence.*;

@Table(name = "t_sec_resource")
public class TSecResource {
    @Id
    @Column(name = "resourceId")
    private Long resourceid;

    /**
     * 资源名
     */
    @Column(name = "resourceName")
    private String resourcename;

    /**
     * 资源标题
     */
    @Column(name = "resourceTitle")
    private String resourcetitle;

    /**
     * 资源URL
     */
    @Column(name = "resourceUrl")
    private String resourceurl;

    /**
     * 资源描述
     */
    @Column(name = "resourceDesc")
    private String resourcedesc;

    @Column(name = "parentId")
    private Long parentid;

    private String path;

    /**
     * @return resourceId
     */
    public Long getResourceid() {
        return resourceid;
    }

    /**
     * @param resourceid
     */
    public void setResourceid(Long resourceid) {
        this.resourceid = resourceid;
    }

    /**
     * 获取资源名
     *
     * @return resourceName - 资源名
     */
    public String getResourcename() {
        return resourcename;
    }

    /**
     * 设置资源名
     *
     * @param resourcename 资源名
     */
    public void setResourcename(String resourcename) {
        this.resourcename = resourcename;
    }

    /**
     * 获取资源标题
     *
     * @return resourceTitle - 资源标题
     */
    public String getResourcetitle() {
        return resourcetitle;
    }

    /**
     * 设置资源标题
     *
     * @param resourcetitle 资源标题
     */
    public void setResourcetitle(String resourcetitle) {
        this.resourcetitle = resourcetitle;
    }

    /**
     * 获取资源URL
     *
     * @return resourceUrl - 资源URL
     */
    public String getResourceurl() {
        return resourceurl;
    }

    /**
     * 设置资源URL
     *
     * @param resourceurl 资源URL
     */
    public void setResourceurl(String resourceurl) {
        this.resourceurl = resourceurl;
    }

    /**
     * 获取资源描述
     *
     * @return resourceDesc - 资源描述
     */
    public String getResourcedesc() {
        return resourcedesc;
    }

    /**
     * 设置资源描述
     *
     * @param resourcedesc 资源描述
     */
    public void setResourcedesc(String resourcedesc) {
        this.resourcedesc = resourcedesc;
    }

    /**
     * @return parentId
     */
    public Long getParentid() {
        return parentid;
    }

    /**
     * @param parentid
     */
    public void setParentid(Long parentid) {
        this.parentid = parentid;
    }

    /**
     * @return path
     */
    public String getPath() {
        return path;
    }

    /**
     * @param path
     */
    public void setPath(String path) {
        this.path = path;
    }
}