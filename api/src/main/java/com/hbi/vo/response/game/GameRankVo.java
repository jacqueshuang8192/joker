package com.hbi.vo.response.game;

import java.util.List;

import com.hbi.model.TFreeGameTotal;

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
