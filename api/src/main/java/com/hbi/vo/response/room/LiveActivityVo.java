package com.hbi.vo.response.room;

import java.io.Serializable;

public class LiveActivityVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private String type;
	
	private String liveActivityId;
	
	private String liveActivityName;
	
	private String photo;
	
	private String description;

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getLiveActivityId() {
		return liveActivityId;
	}

	public void setLiveActivityId(String liveActivityId) {
		this.liveActivityId = liveActivityId;
	}

	public String getLiveActivityName() {
		return liveActivityName;
	}

	public void setLiveActivityName(String liveActivityName) {
		this.liveActivityName = liveActivityName;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	
}
