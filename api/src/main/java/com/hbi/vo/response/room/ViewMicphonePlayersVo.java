package com.hbi.vo.response.room;

import java.util.List;

import com.hbi.vo.response.base.BaseResultVo;

public class ViewMicphonePlayersVo extends BaseResultVo {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private int count;
	
	private List<Object> players;

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<Object> getPlayers() {
		return players;
	}

	public void setPlayers(List<Object> players) {
		this.players = players;
	}
}
