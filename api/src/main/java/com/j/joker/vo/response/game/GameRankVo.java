package com.j.joker.vo.response.game;

import java.util.List;

import com.j.joker.model.TFreeGameTotal;

public class GameRankVo {
	private List<TFreeGameTotal> rankList;
	private TFreeGameTotal self;

	public List<TFreeGameTotal> getRankList() {
		return rankList;
	}
	public void setRankList(List<TFreeGameTotal> rankList) {
		this.rankList = rankList;
	}
	public TFreeGameTotal getSelf() {
		return self;
	}
	public void setSelf(TFreeGameTotal self) {
		this.self = self;
	}
	
}
