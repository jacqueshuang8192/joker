package com.hbi.cache.model;

import com.hbi.cache.CacheModel;

public class CacheLiveVoice extends CacheModel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 音效名称
	 */
	private String name;
	
	/**
	 * 时长
	 */
	private int seconds;
	
	/**
	 * 图标
	 */
	private String photo;
	
	/**
	 * 文件名
	 */
	private String fileName;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getSeconds() {
		return seconds;
	}

	public void setSeconds(int seconds) {
		this.seconds = seconds;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	
	
	
}
