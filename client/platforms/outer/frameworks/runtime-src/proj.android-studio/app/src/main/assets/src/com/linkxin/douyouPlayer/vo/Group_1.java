package com.linkxin.douyouPlayer.vo;

import net.tsz.afinal.annotation.sqlite.Id;
import net.tsz.afinal.annotation.sqlite.Table;

/**
 * Created by lxy on 2016/4/22.
 */
@Table(name = "DouyouGroup")
public class Group {

    /**
     * easeGroupId : 1461317736695
     * groupId : 73
     * groupName : 路人甲,风一样吹,广州
     * groupPhoto : http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/336Group20160422173536.jpg
     * remark :
     */

    @Id(column="id")
    private int id;
    private String easeGroupId;
    private String groupId;
    private String groupName;
    private String groupPhoto;
    private String remark;

    //本地维护的userId
    private String belongTo;

    public String getEaseGroupId() {
        return easeGroupId;
    }

    public void setEaseGroupId(String easeGroupId) {
        this.easeGroupId = easeGroupId;
    }

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getGroupPhoto() {
        return groupPhoto;
    }

    public void setGroupPhoto(String groupPhoto) {
        this.groupPhoto = groupPhoto;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBelongTo() {
        return belongTo;
    }

    public void setBelongTo(String belongTo) {
        this.belongTo = belongTo;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Group)) return false;

        Group group = (Group) o;

        if (!getEaseGroupId().equals(group.getEaseGroupId())) return false;
        return getGroupId().equals(group.getGroupId());

    }

    @Override
    public int hashCode() {
        int result = getEaseGroupId().hashCode();
        result = 31 * result + getGroupId().hashCode();
        return result;
    }
}
