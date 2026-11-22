package com.j.joker.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.j.joker.cache.model.CacheCompereListProfile;
import com.j.joker.model.TFreeGameResult;
import com.j.joker.model.TFreeGameTotal;
import com.j.joker.model.TFreeGameTotalranking;

import com.j.joker.core.mapper.EntityMapper;

public interface TFreeGameTotalMapper extends EntityMapper<TFreeGameTotal>{
	TFreeGameTotal queryTotalGroupGeRenRank(@Param(value = "userId") Long userId);
	TFreeGameTotal queryTotalGroupGeRenRank2(@Param(value = "userId") Long userId);
	Long queryTotalByUserId(@Param(value = "userId") Long userId);
	List<TFreeGameTotal> queryTotalGroupRank(@Param(value = "rankcount") Long rankcount);
	Integer updateTotal(@Param("win") Integer win, @Param("draw") Integer draw, @Param("lose") Integer lose,
			@Param("total") Integer total, @Param("user_id") Long userId);
	
	
	
	TFreeGameTotal querytotal(@Param(value = "userId") Long userId);
	
}
