package com.j.joker.vo.response.game;

import java.util.List;

import com.j.joker.model.TFreeGameSingleresult;

public class GameSingleRankVo {
	private List<TFreeGameSingleresult> rankList;
	private TFreeGameSingleresult self;

	public List<TFreeGameSingleresult> getRankList() {
		return rankList;
	}
	public void setRankList(List<TFreeGameSingleresult> rankList) {
		this.rankList = rankList;
	}
	public TFreeGameSingleresult getSelf() {
		return self;
	}
	public void setSelf(TFreeGameSingleresult self) {
		this.self = self;
	}
	
}
