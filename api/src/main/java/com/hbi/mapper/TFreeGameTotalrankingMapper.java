package com.hbi.mapper;

import java.math.BigDecimal;

import org.apache.ibatis.annotations.Param;

import com.hbi.model.TFreeGameSingleresult;
import com.hbi.model.TFreeGameTotalranking;

import com.core.mapper.EntityMapper;

public interface TFreeGameTotalrankingMapper extends EntityMapper<TFreeGameTotalranking> {
	void updateTotalranking(@Param("win") Integer win,@Param("score") Integer  score, @Param("draw") Integer draw, @Param("lose") Integer lose,
			@Param("total") Integer total, @Param("user_id") Long userId, @Param("game_id") Long gameId);

	TFreeGameTotalranking querytotalranking(@Param(value = "gameId") Long gameId, @Param(value = "userId") Long userId);
}
