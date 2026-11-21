package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_sec_role")
public class TSecRole {
    @Id
    @Column("roleId")
    private Long roleid;

    /**
     * 角色名称
     */
    @Column("roleName")
    private String rolename;

    /**
     * 角色描述
     */
    @Column("roleDesc")
    private String roledesc;

    /**
     * 状态
     */
    private Short status;

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
     * 获取角色名称
     *
     * @return roleName - 角色名称
     */
    public String getRolename() {
        return rolename;
    }

    /**
     * 设置角色名称
     *
     * @param rolename 角色名称
     */
    public void setRolename(String rolename) {
        this.rolename = rolename;
    }

    /**
     * 获取角色描述
     *
     * @return roleDesc - 角色描述
     */
    public String getRoledesc() {
        return roledesc;
    }

    /**
     * 设置角色描述
     *
     * @param roledesc 角色描述
     */
    public void setRoledesc(String roledesc) {
        this.roledesc = roledesc;
    }

    /**
     * 获取状态
     *
     * @return status - 状态
     */
    public Short getStatus() {
        return status;
    }

    /**
     * 设置状态
     *
     * @param status 状态
     */
    public void setStatus(Short status) {
        this.status = status;
    }
}