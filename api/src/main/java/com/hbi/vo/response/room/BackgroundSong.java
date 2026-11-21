package com.hbi.vo.response.room;

import java.io.Serializable;

public class BackgroundSong implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private String seconds;
	
	private String photo;
	
	private String fileName;

	public String getSeconds() {
		return seconds;
	}

	public void setSeconds(String seconds) {
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
