package com.hbi.model;

import javax.persistence.*;

@Table(name = "t_role_res")
public class TRoleRes {
    @Id
    @Column(name = "roleId")
    private Long roleid;

    @Id
    @Column(name = "resourceId")
    private Long resourceid;

    /**
     * @return roleId
     */
    public Long getRoleid() {
        return roleid;
    }

    /**
     * @param roleid
     */
    public void setRoleid(Long roleid) {
        this.roleid = roleid;
    }

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
}