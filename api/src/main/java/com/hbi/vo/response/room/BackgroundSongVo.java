package com.hbi.vo.response.room;

import java.util.List;

import com.hbi.vo.response.base.BaseResultVo;

/**
 * @author zh
 *
 */
public class BackgroundSongVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private int count;
	
	private List<BackgroundSong> songs;

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<BackgroundSong> getSongs() {
		return songs;
	}

	public void setSongs(List<BackgroundSong> songs) {
		this.songs = songs;
	}
	
	
}
