package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_role_res")
public class TRoleRes {
    @Id
    @Column("roleId")
    private Long roleid;

    @Id
    @Column("resourceId")
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