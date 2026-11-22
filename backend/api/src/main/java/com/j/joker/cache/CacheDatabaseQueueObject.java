package com.j.joker.cache;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

public class CacheDatabaseQueueObject implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String playerId;
	
	private Date date;
	
	private List<CacheDatabaseObject> insertList;
	
	private List<CacheDatabaseObject> updateList;

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public List<CacheDatabaseObject> getInsertList() {
		return insertList;
	}

	public void setInsertList(List<CacheDatabaseObject> insertList) {
		this.insertList = insertList;
	}

	public List<CacheDatabaseObject> getUpdateList() {
		return updateList;
	}

	public void setUpdateList(List<CacheDatabaseObject> updateList) {
		this.updateList = updateList;
	}
	
}
