package com.j.joker.mapper;

import java.math.BigDecimal;

import org.apache.ibatis.annotations.Param;

import com.j.joker.model.TFreeGameSingleresult;
import com.j.joker.model.TFreeGameTotalranking;

import com.j.joker.core.mapper.EntityMapper;

public interface TFreeGameTotalrankingMapper extends EntityMapper<TFreeGameTotalranking> {
	void updateTotalranking(@Param("win") Integer win,@Param("score") Integer  score, @Param("draw") Integer draw, @Param("lose") Integer lose,
			@Param("total") Integer total, @Param("user_id") Long userId, @Param("game_id") Long gameId);

	TFreeGameTotalranking querytotalranking(@Param(value = "gameId") Long gameId, @Param(value = "userId") Long userId);
}
