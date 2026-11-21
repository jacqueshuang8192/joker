package com.hbi.vo.response.room;

import java.util.List;

import com.hbi.cache.model.CacheUserListProfile;

public class ViewRoomPlayersVo {

	private List<CacheUserListProfile> players;
	
	private List<CacheUserListProfile> micPlayers;
	
	private List<CacheUserListProfile> fmPlayers;
	
	private List<CacheUserListProfile> defendPlayers;

	public List<CacheUserListProfile> getPlayers() {
		return players;
	}

	public void setPlayers(List<CacheUserListProfile> players) {
		this.players = players;
	}

	public List<CacheUserListProfile> getMicPlayers() {
		return micPlayers;
	}

	public void setMicPlayers(List<CacheUserListProfile> micPlayers) {
		this.micPlayers = micPlayers;
	}

	public List<CacheUserListProfile> getFmPlayers() {
		return fmPlayers;
	}

	public void setFmPlayers(List<CacheUserListProfile> fmPlayers) {
		this.fmPlayers = fmPlayers;
	}

	public List<CacheUserListProfile> getDefendPlayers() {
		return defendPlayers;
	}

	public void setDefendPlayers(List<CacheUserListProfile> defendPlayers) {
		this.defendPlayers = defendPlayers;
	}

}
