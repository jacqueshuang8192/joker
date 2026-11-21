package com.hbi.vo.response.room;

import java.util.List;

import com.hbi.vo.response.base.BaseResultVo;

public class ViewLiveGamesVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private int count;
	
	private List<Object> games;

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<Object> getGames() {
		return games;
	}

	public void setGames(List<Object> games) {
		this.games = games;
	}
	
}
