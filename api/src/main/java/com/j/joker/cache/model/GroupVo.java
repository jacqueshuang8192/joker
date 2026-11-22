package com.j.joker.cache.model;

import java.io.Serializable;
import java.util.List;

public class GroupVo implements Serializable {

	private Long groupId;
	
	private String groupName;
	
	private String groupPhoto;
	
	private String remark;
	
	private String masterName;
	
	private String creatorName;
	
	private String easeGroupId;
	
	private List<GroupMemberVo> members;

	public Long getGroupId() {
		return groupId;
	}

	public void setGroupId(Long groupId) {
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

	public String getMasterName() {
		return masterName;
	}

	public void setMasterName(String masterName) {
		this.masterName = masterName;
	}

	public String getCreatorName() {
		return creatorName;
	}

	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}

	public String getEaseGroupId() {
		return easeGroupId;
	}

	public void setEaseGroupId(String easeGroupId) {
		this.easeGroupId = easeGroupId;
	}

	public List<GroupMemberVo> getMembers() {
		return members;
	}

	public void setMembers(List<GroupMemberVo> members) {
		this.members = members;
	}
	
}
